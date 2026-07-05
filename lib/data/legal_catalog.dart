import '../models/movie.dart';
import '../config/app_config.dart';

const legalCatalog = [
  Movie(
    id: '11111111-1111-4111-8111-111111111111',
    title: 'Night of the Living Dead',
    description:
        'George A. Romero\'s landmark independent horror film, available from Internet Archive with a public-domain mark.',
    posterUrl:
        '${AppConfig.mediaBaseUrl}/services/img/NightOfTheLivingDead_201508',
    backdropUrl:
        '${AppConfig.mediaBaseUrl}/services/img/NightOfTheLivingDead_201508',
    videoUrl:
        '${AppConfig.mediaBaseUrl}/download/NightOfTheLivingDead_201508/Night%20of%20the%20Living%20Dead.mp4',
    videoType: 'mp4',
    genres: ['Horror', 'Classic', 'Public Domain'],
    releaseYear: 1968,
    rating: 'NR',
    durationMinutes: 95,
    isFeatured: false,
    sourceName: 'Internet Archive',
    licenseNote: 'Public Domain Mark 1.0 on the Internet Archive item.',
  ),
  Movie(
    id: '22222222-2222-4222-8222-222222222222',
    title: 'His Girl Friday',
    description:
        'A fast-talking screwball comedy starring Cary Grant and Rosalind Russell, sourced from a public-domain-marked Internet Archive item.',
    posterUrl:
        '${AppConfig.mediaBaseUrl}/services/img/his-girl-friday-1940_202310',
    backdropUrl:
        '${AppConfig.mediaBaseUrl}/services/img/his-girl-friday-1940_202310',
    videoUrl:
        '${AppConfig.mediaBaseUrl}/download/his-girl-friday-1940_202310/His%20Girl%20Friday%20%281940%29.mp4',
    videoType: 'mp4',
    genres: ['Comedy', 'Romance', 'Public Domain'],
    releaseYear: 1940,
    rating: 'NR',
    durationMinutes: 92,
    isFeatured: false,
    sourceName: 'Internet Archive',
    licenseNote: 'Public Domain Mark 1.0 on the Internet Archive item.',
  ),
  Movie(
    id: '33333333-3333-4333-8333-333333333333',
    title: 'The General',
    description:
        'Buster Keaton\'s silent action-comedy classic, presented here from a public-domain-marked Internet Archive source.',
    posterUrl: '${AppConfig.mediaBaseUrl}/services/img/TheGeneral1926',
    backdropUrl: '${AppConfig.mediaBaseUrl}/services/img/TheGeneral1926',
    videoUrl:
        '${AppConfig.mediaBaseUrl}/download/TheGeneral1926/The_General_1926_720p_512kb.mp4',
    videoType: 'mp4',
    genres: ['Silent Film', 'Comedy', 'Public Domain'],
    releaseYear: 1926,
    rating: 'NR',
    durationMinutes: 75,
    sourceName: 'Internet Archive',
    licenseNote: 'Public Domain Mark 1.0 on the Internet Archive item.',
  ),
  Movie(
    id: '44444444-4444-4444-8444-444444444444',
    title: 'The Stranger',
    description:
        'Orson Welles directs and stars in this tense post-war thriller, available from Internet Archive under a public-domain license note.',
    posterUrl: '${AppConfig.mediaBaseUrl}/services/img/TheStranger_0',
    backdropUrl: '${AppConfig.mediaBaseUrl}/services/img/TheStranger_0',
    videoUrl:
        '${AppConfig.mediaBaseUrl}/download/TheStranger_0/The_Stranger_512kb.mp4',
    videoType: 'mp4',
    genres: ['Thriller', 'Noir', 'Public Domain'],
    releaseYear: 1946,
    rating: 'NR',
    durationMinutes: 95,
    sourceName: 'Internet Archive',
    licenseNote: 'Public domain license note on the Internet Archive item.',
  ),
  Movie(
    id: '55555555-5555-4555-8555-555555555555',
    title: 'Nosferatu',
    description:
        'A restored shareable version of the silent vampire classic, sourced from a Creative Commons Internet Archive item.',
    posterUrl:
        '${AppConfig.mediaBaseUrl}/services/img/ToddKelsoAKAnihilator77_3',
    backdropUrl:
        '${AppConfig.mediaBaseUrl}/services/img/ToddKelsoAKAnihilator77_3',
    videoUrl:
        '${AppConfig.mediaBaseUrl}/download/ToddKelsoAKAnihilator77_3/Nosferatu1.0_512kb.mp4',
    videoType: 'mp4',
    genres: ['Horror', 'Silent Film', 'Creative Commons'],
    releaseYear: 1922,
    rating: 'NR',
    durationMinutes: 94,
    sourceName: 'Internet Archive',
    licenseNote:
        'Creative Commons Attribution-NonCommercial-ShareAlike 2.5 on the Internet Archive item.',
  ),
  Movie(
    id: '66666666-6666-4666-8666-666666666666',
    title: 'Big Buck Bunny',
    description:
        'The Blender Foundation open movie short, included as a lightweight legal playback test with a Creative Commons license.',
    posterUrl: '${AppConfig.mediaBaseUrl}/services/img/BigBuckBunny_328',
    backdropUrl: '${AppConfig.mediaBaseUrl}/services/img/BigBuckBunny_328',
    videoUrl:
        '${AppConfig.mediaBaseUrl}/download/BigBuckBunny_328/BigBuckBunny_512kb.mp4',
    videoType: 'mp4',
    genres: ['Animation', 'Family', 'Creative Commons'],
    releaseYear: 2008,
    rating: 'All',
    durationMinutes: 10,
    isFeatured: true,
    sourceName: 'Internet Archive',
    licenseNote:
        'Creative Commons Attribution 3.0 United States on the Internet Archive item.',
  ),
];
