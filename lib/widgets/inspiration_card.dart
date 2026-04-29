import 'package:flutter/material.dart';
import '../core/models/inspiration_item.dart';

class InspirationCard extends StatelessWidget {
  final InspirationItem item;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onPauseAudio;
  final VoidCallback? onReplayAudio;
  final GlobalKey? repaintKey;

  const InspirationCard({
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
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: bgColor,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.type == InspirationType.quote)
                const Icon(Icons.format_quote, size: 40, color: Colors.deepPurple),
              if (item.type == InspirationType.affirmation)
                const Icon(Icons.favorite, size: 40, color: Colors.deepPurple),
              if (item.type == InspirationType.scripture)
                const Icon(Icons.menu_book, size: 40, color: Colors.deepPurple),
              const SizedBox(height: 20),
              Text(
                item.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              if (item.author != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    item.author!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
              if (item.reference != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    item.reference!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
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
