import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, player, child) {
        final track = player.currentTrack;

        if (track == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlayerScreen()),
            );
          },
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: player.progress,
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                ),
                // Player controls
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Track info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                track.artistName,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Controls
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous),
                              onPressed: player.skipToPrevious,
                            ),
                            IconButton(
                              icon: Icon(
                                player.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                              ),
                              iconSize: 40,
                              onPressed: player.togglePlayPause,
                            ),
                            IconButton(
                              icon: const Icon(Icons.skip_next),
                              onPressed: player.skipToNext,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
