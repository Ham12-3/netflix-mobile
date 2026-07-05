class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.backdropUrl,
    required this.videoUrl,
    required this.videoType,
    required this.genres,
    required this.releaseYear,
    required this.sourceName,
    required this.licenseNote,
    this.rating,
    this.durationMinutes,
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String backdropUrl;
  final String videoUrl;
  final String videoType;
  final List<String> genres;
  final int releaseYear;
  final String? rating;
  final int? durationMinutes;
  final bool isFeatured;
  final String sourceName;
  final String licenseNote;

  String get metaLine {
    final parts = [
      releaseYear.toString(),
      if (rating != null && rating!.isNotEmpty) rating!,
      if (durationMinutes != null) '${durationMinutes}m',
      videoType.toUpperCase(),
    ];
    return parts.join('  |  ');
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      posterUrl: json['poster_url'] as String,
      backdropUrl: json['backdrop_url'] as String,
      videoUrl: json['video_url'] as String,
      videoType: json['video_type'] as String,
      genres: (json['genres'] as List<dynamic>).cast<String>(),
      releaseYear: json['release_year'] as int,
      rating: json['rating'] as String?,
      durationMinutes: json['duration_minutes'] as int?,
      isFeatured: json['is_featured'] as bool? ?? false,
      sourceName: json['source_name'] as String,
      licenseNote: json['license_note'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'poster_url': posterUrl,
    'backdrop_url': backdropUrl,
    'video_url': videoUrl,
    'video_type': videoType,
    'genres': genres,
    'release_year': releaseYear,
    'rating': rating,
    'duration_minutes': durationMinutes,
    'is_featured': isFeatured,
    'source_name': sourceName,
    'license_note': licenseNote,
  };
}
