import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/inspiration_item.dart';
import '../features/settings/settings_provider.dart';
import '../theme/app_theme.dart';
import 'animated_action_button.dart';

class InspirationCard extends ConsumerWidget {
  final InspirationItem item;
  final GlobalKey? repaintKey;

  const InspirationCard({
    super.key,
    required this.item,
    this.repaintKey,
  });

  IconData _typeIcon() {
    switch (item.type) {
      case InspirationType.quote:
        return Icons.format_quote;
      case InspirationType.affirmation:
        return Icons.volume_up_rounded;
      case InspirationType.scripture:
        return Icons.menu_book;
    }
  }

  Color _typeIconColor() {
    switch (item.type) {
      case InspirationType.quote:
        return AppTheme.primary.withValues(alpha: 0.85);
      case InspirationType.affirmation:
        return AppTheme.favorite.withValues(alpha: 0.85);
      case InspirationType.scripture:
        return AppTheme.accent.withValues(alpha: 0.85);
    }
  }

  double _resolveContentFontSize({
    required String text,
    required double maxWidth,
    required double textScale,
  }) {
    final length = text.runes.length;
    final widthFactor = maxWidth > 390
        ? 1.08
        : maxWidth < 290
        ? 0.86
        : 1.0;

    var size = 38.0 * widthFactor;

    if (length > 320) {
      size *= 0.54;
    } else if (length > 240) {
      size *= 0.62;
    } else if (length > 180) {
      size *= 0.72;
    } else if (length > 120) {
      size *= 0.82;
    } else if (length > 80) {
      size *= 0.9;
    }

    final normalizedForAccessibility = size / textScale;
    return normalizedForAccessibility.clamp(22.0, 42.0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorTheme = ref.watch(settingsProvider).colorTheme;

    return RepaintBoundary(
      key: repaintKey,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.95, end: 1),
        duration: AppMotion.cardEntrance,
        curve: AppMotion.entrance,
        builder: (context, scale, child) {
          return AnimatedOpacity(
            opacity: 1,
            duration: AppMotion.cardEntrance,
            child: Transform.scale(
              scale: scale,
              child: Card(
                elevation: 24,
                margin: theme.cardTheme.margin,
                shape: theme.cardTheme.shape,
                color: Colors.transparent,
                shadowColor: AppTheme.cardShadow,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorTheme.gradientStart.withValues(alpha: 0.85),
                            colorTheme.gradientMid.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cardShadow,
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: AppMotion.standard,
                            switchInCurve: AppMotion.emphasized,
                            switchOutCurve: AppMotion.emphasizedIn,
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(scale: animation, child: child);
                            },
                            child: Icon(
                              _typeIcon(),
                              key: ValueKey<InspirationType>(item.type),
                              size: 44,
                              color: _typeIconColor(),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final textScale = MediaQuery.textScalerOf(
                                  context,
                                ).scale(1).clamp(1.0, 1.35);
                                final contentFontSize = _resolveContentFontSize(
                                  text: item.text,
                                  maxWidth: constraints.maxWidth,
                                  textScale: textScale,
                                );

                                return ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(
                                    context,
                                  ).copyWith(scrollbars: false),
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: Center(
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 760,
                                          ),
                                          child: Text(
                                            item.text,
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.displayLarge
                                                ?.copyWith(
                                                  fontSize: contentFontSize,
                                                  color: AppTheme.textPrimary
                                                      .withValues(alpha: 0.97),
                                                  height: 1.2,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.08,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          if (item.author != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Text(
                                item.author!,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary.withValues(
                                    alpha: 0.85,
                                  ),
                                ),
                              ),
                            ),

                          if (item.reference != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                item.reference!,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary.withValues(
                                    alpha: 0.85,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Controls (outside the card widget for simpler composition).
class InspirationCardControls extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final bool isReadAloudEnabled;
  final bool isSlideshowPlaying;
  final String slideshowPaceLabel;
  final VoidCallback? onToggleAudio;
  final VoidCallback? onToggleSlideshow;
  final VoidCallback? onCycleSlideshowPace;

  const InspirationCardControls({
    super.key,
    required this.isFavorite,
    this.onFavorite,
    this.onShare,
    required this.isReadAloudEnabled,
    required this.isSlideshowPlaying,
    required this.slideshowPaceLabel,
    this.onToggleAudio,
    this.onToggleSlideshow,
    this.onCycleSlideshowPace,
  });

  @override
  Widget build(BuildContext context) {
    final paceColor = isSlideshowPlaying
        ? AppTheme.accent.withValues(alpha: 0.92)
        : AppTheme.textSecondary.withValues(alpha: 0.92);
    final chipScale = isSlideshowPlaying ? 1.02 : 1.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const buttonCount = 4;
          const spacing = 8.0;
          final buttonDiameter =
              ((constraints.maxWidth - (spacing * (buttonCount - 1))) /
                      buttonCount)
                  .clamp(42.0, 68.0);
          final iconSize = (buttonDiameter * 0.5).clamp(22.0, 36.0);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                label: 'Slideshow pace, current $slideshowPaceLabel',
                hint: 'Double tap to cycle pace',
                child: GestureDetector(
                  onTap: onCycleSlideshowPace,
                  child: AnimatedScale(
                    scale: chipScale,
                    duration: AppMotion.quick,
                    curve: AppMotion.emphasized,
                    child: AnimatedContainer(
                      duration: AppMotion.standard,
                      curve: AppMotion.emphasized,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: isSlideshowPlaying ? 0.88 : 0.76,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: paceColor.withValues(
                            alpha: isSlideshowPlaying ? 0.65 : 0.45,
                          ),
                          width: isSlideshowPlaying ? 1.5 : 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: AppMotion.quick,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Icon(
                              Icons.speed_rounded,
                              key: ValueKey<String>(
                                'pace-icon-$slideshowPaceLabel',
                              ),
                              size: 16,
                              color: paceColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          AnimatedSwitcher(
                            duration: AppMotion.quick,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              'Pace: $slideshowPaceLabel',
                              key: ValueKey<String>(
                                'pace-text-$slideshowPaceLabel',
                              ),
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: paceColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ControlButton(
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppTheme.favorite : AppTheme.primary,
                    onTap: onFavorite,
                    tooltip: 'Favorite',
                    animate: isFavorite,
                    diameter: buttonDiameter,
                    iconSize: iconSize,
                  ),
                  const SizedBox(width: spacing),
                  _ControlButton(
                    icon: Icons.share,
                    color: AppTheme.accent,
                    onTap: onShare,
                    tooltip: 'Share',
                    diameter: buttonDiameter,
                    iconSize: iconSize,
                  ),
                  const SizedBox(width: spacing),
                  _ControlButton(
                    icon: isReadAloudEnabled
                        ? Icons.stop_circle_outlined
                        : Icons.record_voice_over_rounded,
                    color: AppTheme.primary,
                    onTap: onToggleAudio,
                    tooltip: isReadAloudEnabled ? 'Stop Readout' : 'Read Aloud',
                    semanticLabel: isReadAloudEnabled
                        ? 'Disable Read Aloud'
                        : 'Enable Read Aloud',
                    isActive: isReadAloudEnabled,
                    isToggleControl: true,
                    animateIconSwap: true,
                    diameter: buttonDiameter,
                    iconSize: iconSize,
                  ),
                  const SizedBox(width: spacing),
                  _ControlButton(
                    icon: isSlideshowPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppTheme.accent,
                    onTap: onToggleSlideshow,
                    onLongPress: onCycleSlideshowPace,
                    tooltip: isSlideshowPlaying
                        ? 'Pause Slideshow ($slideshowPaceLabel)'
                        : 'Start Slideshow ($slideshowPaceLabel)',
                    semanticLabel: isSlideshowPlaying
                        ? 'Pause slideshow, pace $slideshowPaceLabel'
                        : 'Start slideshow, pace $slideshowPaceLabel',
                    isActive: isSlideshowPlaying,
                    isToggleControl: true,
                    animateIconSwap: true,
                    diameter: buttonDiameter,
                    iconSize: iconSize,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String semanticLabel;
  final String tooltip;
  final bool animate;
  final bool isActive;
  final bool isToggleControl;
  final bool animateIconSwap;
  final double diameter;
  final double iconSize;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.onLongPress,
    this.semanticLabel = '',
    required this.tooltip,
    this.animate = false,
    this.isActive = false,
    this.isToggleControl = false,
    this.animateIconSwap = false,
    required this.diameter,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isActive
        ? color.withValues(alpha: 0.42)
        : Colors.white.withValues(alpha: 0.0);

    return Semantics(
      button: true,
      enabled: onTap != null,
      toggled: isToggleControl ? isActive : null,
      label: semanticLabel.isEmpty ? tooltip : semanticLabel,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: isActive ? 14 : 10,
        shape: CircleBorder(
          side: BorderSide(color: borderColor, width: isActive ? 1.4 : 0),
        ),
        color: isActive ? color.withValues(alpha: 0.12) : Colors.white,
        shadowColor: color.withValues(alpha: isActive ? 0.30 : 0.20),
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: AnimatedActionButton(
            icon: icon,
            color: color,
            onTap: onTap,
            onLongPress: onLongPress,
            tooltip: tooltip,
            animate: animate,
            animateIconSwap: animateIconSwap,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
