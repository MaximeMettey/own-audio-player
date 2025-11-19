import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music),
            onPressed: () {
              // TODO: Show queue
            },
          ),
        ],
      ),
      body: Consumer<PlayerProvider>(
        builder: (context, player, child) {
          final track = player.currentTrack;

          if (track == null) {
            return const Center(child: Text('No track playing'));
          }

          return Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Album art placeholder
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.album,
                        size: 120,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Track info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            track.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            track.artistName,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.albumName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Controls
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Progress bar
                    Column(
                      children: [
                        Slider(
                          value: player.position.inSeconds.toDouble(),
                          max: player.duration.inSeconds.toDouble() > 0
                              ? player.duration.inSeconds.toDouble()
                              : 1,
                          onChanged: (value) {
                            player.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(player.position)),
                              Text(_formatDuration(player.duration)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Main controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            player.shuffleMode
                                ? Icons.shuffle_on_outlined
                                : Icons.shuffle,
                          ),
                          color: player.shuffleMode
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          onPressed: player.toggleShuffle,
                          iconSize: 28,
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          onPressed: player.skipToPrevious,
                          iconSize: 40,
                        ),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              player.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: player.togglePlayPause,
                            iconSize: 40,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: player.skipToNext,
                          iconSize: 40,
                        ),
                        IconButton(
                          icon: Icon(_getLoopIcon(player.loopMode)),
                          color: player.loopMode != LoopMode.off
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          onPressed: player.toggleLoopMode,
                          iconSize: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  IconData _getLoopIcon(LoopMode mode) {
    switch (mode) {
      case LoopMode.off:
        return Icons.repeat;
      case LoopMode.all:
        return Icons.repeat_on_outlined;
      case LoopMode.one:
        return Icons.repeat_one_on_outlined;
    }
  }
}
