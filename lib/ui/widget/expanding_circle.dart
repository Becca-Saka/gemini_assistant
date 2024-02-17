import 'dart:math';

import 'package:flutter/material.dart';

class ExpandingCircle extends StatefulWidget {
  final double size;
  final List<Color> colors;
  const ExpandingCircle({
    super.key,
    required this.size,
    required this.colors,
  });

  @override
  State<ExpandingCircle> createState() => _ExpandingCircleState();
}

class _ExpandingCircleState extends State<ExpandingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleTween;
  late Animation<double> opacityTween;
  late Animation<double> secondOpacityTween;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    scaleTween = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0,
          0.5,
          curve: Curves.ease,
        ),
      ),
    );

    opacityTween = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0,
          0.25,
          curve: Curves.ease,
        ),
      ),
    );

    secondOpacityTween = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0.25,
          0.5,
          curve: Curves.ease,
        ),
      ),
    );

    controller.repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Opacity(
        opacity: min(opacityTween.value, secondOpacityTween.value),
        child: Transform.scale(
          scale: scaleTween.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
                // color: widget.color,
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: widget.colors,
                )),
          ),
        ),
      ),
    );
  }
}
