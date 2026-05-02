import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/settings_provider.dart';
import '../theme/app_theme.dart';

class AnimatedGradientBackground extends ConsumerStatefulWidget {
  const AnimatedGradientBackground({super.key});

  @override
  ConsumerState<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends ConsumerState<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    final pace = ref.read(activePaceProvider);
    _controller = AnimationController(
      vsync: this,
      duration: _durationForPace(pace),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.standardCurve,
    );
    ref.listenManual<SlideshowPace>(activePaceProvider, (prev, next) {
      if (prev == next) return;
      final current = _controller.value;
      _controller.stop();
      _controller.duration = _durationForPace(next);
      _controller.value = current;
      _controller.repeat(reverse: true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimationState();
  }

  Duration _durationForPace(SlideshowPace pace) {
    switch (pace) {
      case SlideshowPace.fast:
        return const Duration(seconds: 5);
      case SlideshowPace.normal:
        return AppMotion.ambientCycle;
      case SlideshowPace.slow:
        return const Duration(seconds: 13);
    }
  }

  void _syncAnimationState() {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final shouldAnimate = TickerMode.of(context) && !disableAnimations;

    if (shouldAnimate) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
      return;
    }

    if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = ref.watch(settingsProvider).colorTheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value;
        final wave = math.sin(t * math.pi * 2);
        final drift = math.cos(t * math.pi * 2);

        final baseA = Color.lerp(colorTheme.gradientStart, colorTheme.gradientMid, t)!;
        final baseB = Color.lerp(
          colorTheme.gradientMid,
          colorTheme.gradientEnd,
          (t * 0.8).clamp(0.0, 1.0),
        )!;
        final baseC = Color.lerp(
          colorTheme.gradientEnd,
          colorTheme.accent,
          (0.4 + (t * 0.6)).clamp(0.0, 1.0),
        )!;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [baseA, baseB, baseC],
              begin: Alignment(-1.0 + (t * 0.8), -1.0),
              end: Alignment(1.0, 1.0 - (t * 0.7)),
              stops: const [0.05, 0.55, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: -40 + (drift * 24),
                top: 70 + (wave * 20),
                child: _Orb(
                  size: 180,
                  color: colorTheme.accent.withValues(alpha: 0.18),
                ),
              ),
              Positioned(
                right: -56 + (wave * 26),
                bottom: 100 + (drift * 22),
                child: _Orb(
                  size: 230,
                  color: colorTheme.primary.withValues(alpha: 0.14),
                ),
              ),
              Positioned(
                right: 80 + (drift * 18),
                top: -42 + (wave * 18),
                child: _Orb(
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;

  const _Orb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.45,
            spreadRadius: size * 0.05,
          ),
        ],
      ),
    );
  }
}
