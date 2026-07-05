class WatchProgress {
  const WatchProgress({
    required this.movieId,
    required this.positionSeconds,
    required this.completed,
  });

  final String movieId;
  final int positionSeconds;
  final bool completed;

  factory WatchProgress.fromJson(Map<String, dynamic> json) {
    return WatchProgress(
      movieId: json['movie_id'] as String,
      positionSeconds: json['position_seconds'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'movie_id': movieId,
    'position_seconds': positionSeconds,
    'completed': completed,
  };
}
