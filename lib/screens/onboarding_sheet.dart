import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class OnboardingSheet extends StatelessWidget {
  const OnboardingSheet({
    super.key,
    required this.onStart,
  });

  final VoidCallback onStart;

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onStart,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OnboardingSheet(onStart: onStart),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Faith Inspire',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'A calm daily ritual for reflection, read-aloud focus, and quick encouragement.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: AppTheme.textSecondary.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 20),
                const _OnboardingFeature(
                  icon: Icons.record_voice_over_rounded,
                  title: 'Read and listen',
                  description:
                      'Turn on Read Aloud to keep spoken playback moving with each card.',
                ),
                const SizedBox(height: 12),
                const _OnboardingFeature(
                  icon: Icons.speed_rounded,
                  title: 'Control the pace',
                  description:
                      'Tap the pace chip to switch between fast, normal, and slow slideshow timing.',
                ),
                const SizedBox(height: 12),
                const _OnboardingFeature(
                  icon: Icons.notifications_active_outlined,
                  title: 'Make it a habit',
                  description:
                      'Use Settings to choose a daily reminder time and theme that feels right.',
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Start Exploring'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingFeature extends StatelessWidget {
  const _OnboardingFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary.withValues(alpha: 0.88),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
