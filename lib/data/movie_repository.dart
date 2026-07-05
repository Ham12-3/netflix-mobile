import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/movie.dart';
import '../models/watch_progress.dart';
import 'legal_catalog.dart';

abstract class MovieRepository {
  Future<List<Movie>> fetchMovies();
  Future<Set<String>> fetchWatchlistIds(String userId);
  Future<void> addToWatchlist(String userId, String movieId);
  Future<void> removeFromWatchlist(String userId, String movieId);
  Future<Map<String, WatchProgress>> fetchHistory(String userId);
  Future<void> saveProgress(String userId, WatchProgress progress);
}

class DemoMovieRepository implements MovieRepository {
  String _watchlistKey(String userId) => 'demo_watchlist_$userId';
  String _historyKey(String userId) => 'demo_history_$userId';

  @override
  Future<List<Movie>> fetchMovies() async => legalCatalog;

  @override
  Future<Set<String>> fetchWatchlistIds(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_watchlistKey(userId))?.toSet() ?? {};
  }

  @override
  Future<void> addToWatchlist(String userId, String movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_watchlistKey(userId))?.toSet() ?? {};
    ids.add(movieId);
    await prefs.setStringList(_watchlistKey(userId), ids.toList());
  }

  @override
  Future<void> removeFromWatchlist(String userId, String movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_watchlistKey(userId))?.toSet() ?? {};
    ids.remove(movieId);
    await prefs.setStringList(_watchlistKey(userId), ids.toList());
  }

  @override
  Future<Map<String, WatchProgress>> fetchHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey(userId));
    if (raw == null) return {};
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return data.map(
      (key, value) =>
          MapEntry(key, WatchProgress.fromJson(value as Map<String, dynamic>)),
    );
  }

  @override
  Future<void> saveProgress(String userId, WatchProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await fetchHistory(userId);
    history[progress.movieId] = progress;
    await prefs.setString(
      _historyKey(userId),
      jsonEncode(history.map((key, value) => MapEntry(key, value.toJson()))),
    );
  }
}

class SupabaseMovieRepository implements MovieRepository {
  SupabaseMovieRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Movie>> fetchMovies() async {
    final rows = await _client
        .from('movies')
        .select()
        .order('is_featured', ascending: false)
        .order('created_at', ascending: false);
    return rows.map<Movie>((row) => Movie.fromJson(row)).toList();
  }

  @override
  Future<Set<String>> fetchWatchlistIds(String userId) async {
    final rows = await _client
        .from('watchlist')
        .select('movie_id')
        .eq('user_id', userId);
    return rows.map<String>((row) => row['movie_id'] as String).toSet();
  }

  @override
  Future<void> addToWatchlist(String userId, String movieId) async {
    await _client.from('watchlist').upsert({
      'user_id': userId,
      'movie_id': movieId,
    });
  }

  @override
  Future<void> removeFromWatchlist(String userId, String movieId) async {
    await _client
        .from('watchlist')
        .delete()
        .eq('user_id', userId)
        .eq('movie_id', movieId);
  }

  @override
  Future<Map<String, WatchProgress>> fetchHistory(String userId) async {
    final rows = await _client
        .from('watch_history')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    final entries = rows.map<MapEntry<String, WatchProgress>>((row) {
      final progress = WatchProgress.fromJson(row);
      return MapEntry(progress.movieId, progress);
    });
    return Map.fromEntries(entries);
  }

  @override
  Future<void> saveProgress(String userId, WatchProgress progress) async {
    await _client.from('watch_history').upsert({
      'user_id': userId,
      'movie_id': progress.movieId,
      'position_seconds': progress.positionSeconds,
      'completed': progress.completed,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
