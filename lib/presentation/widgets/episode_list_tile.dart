import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/episode.dart';

class EpisodeListTile extends StatelessWidget {
  final Episode episode;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;
  final VoidCallback? onDownloadTap;
  final bool isPlaying;
  final double? downloadProgress;

  const EpisodeListTile({
    super.key,
    required this.episode,
    this.onTap,
    this.onPlayTap,
    this.onDownloadTap,
    this.isPlaying = false,
    this.downloadProgress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: episode.imageUrl.isNotEmpty
                    ? episode.imageUrl
                    : 'https://via.placeholder.com/60',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[800],
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(Icons.podcasts, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    episode.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isPlaying
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          DateFormat('MMM d, yyyy').format(episode.publishedAt),
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          episode.formattedDuration,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onDownloadTap != null)
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: downloadProgress != null
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: downloadProgress,
                                strokeWidth: 2,
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: onDownloadTap,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          )
                        : IconButton(
                            icon: Icon(
                              episode.isDownloaded
                                  ? Icons.download_done
                                  : Icons.download_outlined,
                              color: episode.isDownloaded
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            onPressed: onDownloadTap,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                  ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: Theme.of(context).colorScheme.primary,
                    size: 40,
                  ),
                  onPressed: onPlayTap,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}