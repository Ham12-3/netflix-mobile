import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/movie.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/async_state_view.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key, required this.movieId});

  final String movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movie = ref.watch(movieByIdProvider(movieId));
    return Scaffold(
      backgroundColor: Colors.black,
      body: movie.when(
        loading: () => const LoadingView(message: 'Preparing video'),
        error: (error, stack) => ErrorStateView(message: error.toString()),
        data: (item) {
          if (item == null) {
            return const ErrorStateView(message: 'Movie not found.');
          }
          return _VideoPlayerView(movie: item);
        },
      ),
    );
  }
}

class _VideoPlayerView extends ConsumerStatefulWidget {
  const _VideoPlayerView({required this.movie});

  final Movie movie;

  @override
  ConsumerState<_VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends ConsumerState<_VideoPlayerView> {
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _showControls = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.movie.videoUrl))
          ..addListener(_listen)
          ..initialize()
              .then((_) {
                if (!mounted) return;
                setState(() => _ready = true);
                _controller.play();
              })
              .catchError((Object error) {
                if (!mounted) return;
                setState(() => _error = error.toString());
              });
  }

  void _listen() {
    final error = _controller.value.errorDescription;
    if (error != null && error != _error && mounted) {
      setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    _saveProgress();
    _controller.removeListener(_listen);
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return SafeArea(
        child: ErrorStateView(
          message: 'This stream could not be loaded.\n$_error',
          onRetry: () {
            setState(() => _error = null);
            _controller.initialize();
          },
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: _ready
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(),
          ),
          if (_showControls)
            _Controls(controller: _controller, movie: widget.movie),
        ],
      ),
    );
  }

  Future<void> _saveProgress() async {
    if (!_ready) return;
    await ref
        .read(libraryActionsProvider)
        .saveProgress(
          movieId: widget.movie.id,
          position: _controller.value.position,
          duration: _controller.value.duration,
        );
  }
}

class _Controls extends StatefulWidget {
  const _Controls({required this.controller, required this.movie});

  final VideoPlayerController controller;
  final Movie movie;

  @override
  State<_Controls> createState() => _ControlsState();
}

class _ControlsState extends State<_Controls> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_tick);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_tick);
    super.dispose();
  }

  void _tick() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final position = value.position;
    final duration = value.duration;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.78),
            Colors.black.withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.82),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Back',
                ),
                Expanded(
                  child: Text(
                    widget.movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton.filled(
              onPressed: () {
                value.isPlaying
                    ? widget.controller.pause()
                    : widget.controller.play();
              },
              iconSize: 54,
              icon: Icon(
                value.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
              ),
              tooltip: value.isPlaying ? 'Pause' : 'Play',
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Column(
                children: [
                  VideoProgressIndicator(
                    widget.controller,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                      playedColor: AppTheme.flame,
                      bufferedColor: AppTheme.muted,
                      backgroundColor: AppTheme.panelSoft,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(_format(position)),
                      const Spacer(),
                      Text(_format(duration)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
