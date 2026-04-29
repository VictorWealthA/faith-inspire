import 'package:flutter/material.dart';
import '../core/models/inspiration_item.dart';

class QuoteCard extends StatelessWidget {
  final InspirationItem item;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onPauseAudio;
  final VoidCallback? onReplayAudio;
  final GlobalKey? repaintKey;

  const QuoteCard({
    super.key,
    required this.item,
    this.onFavorite,
    this.onShare,
    this.onPlayAudio,
    this.onPauseAudio,
    this.onReplayAudio,
    this.repaintKey,
  });

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _parseColor(item.background);
    return RepaintBoundary(
      key: repaintKey,
      child: Card(
        elevation: 6,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: bgColor,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.format_quote,
                size: 48,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              Text(
                item.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              if (item.author != null)
                Text(
                  item.author!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.deepPurple,
                    ),
                    onPressed: onFavorite,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.deepPurple),
                    onPressed: onShare,
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.deepPurple),
                    onPressed: onPlayAudio,
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause, color: Colors.deepPurple),
                    onPressed: onPauseAudio,
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay, color: Colors.deepPurple),
                    onPressed: onReplayAudio,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
