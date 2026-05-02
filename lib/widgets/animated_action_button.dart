import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String tooltip;
  final bool animate;
  final bool animateIconSwap;
  final double size;

  const AnimatedActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.onLongPress,
    required this.tooltip,
    this.animate = false,
    this.animateIconSwap = false,
    this.size = 28,
    super.key,
  });

  @override
  State<AnimatedActionButton> createState() => AnimatedActionButtonState();
}

class AnimatedActionButtonState extends State<AnimatedActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.controlPress,
      lowerBound: 0.0,
      upperBound: 0.12,
    );
    _scaleAnim = Tween<double>(begin: 1, end: 1.18).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.playful),
    );
    if (widget.animate) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkResponse(
                containedInkWell: true,
                highlightShape: BoxShape.circle,
                splashColor: widget.color.withValues(alpha: 0.18),
                highlightColor: widget.color.withValues(alpha: 0.08),
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                child: SizedBox.expand(
                  child: Center(
                    child: widget.animateIconSwap
                        ? AnimatedSwitcher(
                            duration: AppMotion.standard,
                            switchInCurve: AppMotion.emphasized,
                            switchOutCurve: AppMotion.emphasizedIn,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Icon(
                              widget.icon,
                              key: ValueKey<IconData>(widget.icon),
                              color: widget.color,
                              size: widget.size,
                            ),
                          )
                        : Icon(
                            widget.icon,
                            color: widget.color,
                            size: widget.size,
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
