import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../data/auth_repository.dart';
import '../data/movie_repository.dart';
import '../models/app_user.dart';
import '../models/movie.dart';
import '../models/watch_progress.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.hasSupabaseConfig) {
    return SupabaseAuthRepository(Supabase.instance.client);
  }
  return DemoAuthRepository();
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  if (AppConfig.hasSupabaseConfig) {
    return SupabaseMovieRepository(Supabase.instance.client);
  }
  return DemoMovieRepository();
});

final authControllerProvider = Provider<AuthController>((ref) {
  final controller = AuthController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});

class AuthController extends ChangeNotifier {
  AuthController(this._ref) {
    _load();
  }

  final Ref _ref;
  AppUser? user;
  bool isLoading = true;
  String? error;

  bool get isSignedIn => user != null;

  Future<void> _load() async {
    try {
      user = await _ref.read(authRepositoryProvider).currentUser();
    } catch (exception) {
      error = exception.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    return _runAuthAction(
      () => _ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password),
    );
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    return _runAuthAction(
      () => _ref
          .read(authRepositoryProvider)
          .signUp(email: email, password: password, displayName: displayName),
    );
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
    user = null;
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<AppUser> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      user = await action();
      return true;
    } on AuthException catch (exception) {
      error = exception.message;
      return false;
    } catch (exception) {
      error = exception.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

final moviesProvider = FutureProvider<List<Movie>>((ref) {
  return ref.watch(movieRepositoryProvider).fetchMovies();
});

final featuredMovieProvider = Provider<AsyncValue<Movie?>>((ref) {
  final movies = ref.watch(moviesProvider);
  return movies.whenData((items) {
    if (items.isEmpty) return null;
    return items.firstWhere(
      (movie) => movie.isFeatured,
      orElse: () => items.first,
    );
  });
});

final movieByIdProvider = Provider.family<AsyncValue<Movie?>, String>((
  ref,
  id,
) {
  final movies = ref.watch(moviesProvider);
  return movies.whenData(
    (items) => items.where((movie) => movie.id == id).firstOrNull,
  );
});

final genresProvider = Provider<AsyncValue<List<String>>>((ref) {
  final movies = ref.watch(moviesProvider);
  return movies.whenData((items) {
    final genres = items.expand((movie) => movie.genres).toSet().toList()
      ..sort();
    return genres;
  });
});

final watchlistIdsProvider = FutureProvider<Set<String>>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user == null) return {};
  return ref.watch(movieRepositoryProvider).fetchWatchlistIds(user.id);
});

final historyProvider = FutureProvider<Map<String, WatchProgress>>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user == null) return {};
  return ref.watch(movieRepositoryProvider).fetchHistory(user.id);
});

final libraryActionsProvider = Provider<LibraryActions>((ref) {
  return LibraryActions(ref);
});

class LibraryActions {
  const LibraryActions(this._ref);

  final Ref _ref;

  Future<void> toggleWatchlist(Movie movie) async {
    final user = _ref.read(authControllerProvider).user;
    if (user == null) return;
    final ids = await _ref.read(watchlistIdsProvider.future);
    final repo = _ref.read(movieRepositoryProvider);
    if (ids.contains(movie.id)) {
      await repo.removeFromWatchlist(user.id, movie.id);
    } else {
      await repo.addToWatchlist(user.id, movie.id);
    }
    _ref.invalidate(watchlistIdsProvider);
  }

  Future<void> saveProgress({
    required String movieId,
    required Duration position,
    required Duration duration,
  }) async {
    final user = _ref.read(authControllerProvider).user;
    if (user == null || position.inSeconds <= 0) return;
    final completed =
        duration.inSeconds > 0 && position.inSeconds >= duration.inSeconds - 20;
    await _ref
        .read(movieRepositoryProvider)
        .saveProgress(
          user.id,
          WatchProgress(
            movieId: movieId,
            positionSeconds: position.inSeconds,
            completed: completed,
          ),
        );
    _ref.invalidate(historyProvider);
  }
}
