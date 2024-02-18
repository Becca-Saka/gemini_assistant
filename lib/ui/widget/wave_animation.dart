import 'dart:math' as math;

import 'package:flutter/material.dart';

class SpeakingWave extends StatelessWidget {
  const SpeakingWave({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpeakingWaveBlock(delay: 0.25),
        SizedBox(width: 5),
        SpeakingWaveBlock(delay: 0.5),
        SizedBox(width: 5),
        SpeakingWaveBlock(delay: 0.75),
        SizedBox(width: 5),
        SpeakingWaveBlock(delay: 1),
      ],
    );
  }
}

class SpeakingWaveBlock extends StatefulWidget {
  final double delay;
  const SpeakingWaveBlock({super.key, required this.delay});

  @override
  State<SpeakingWaveBlock> createState() => _SpeakingWaveBlockState();
}

class _SpeakingWaveBlockState extends State<SpeakingWaveBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late CurvedAnimation animation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    controller.forward(from: widget.delay);
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    super.dispose();
  }

  double _waveHeight() {
    // double maxify = 25;
    // final maxify = math.Random().nextInt(25);

    return math.sin((animation.value * math.pi) - 0.5) * 0.5 + 0.5;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Tween<double>(begin: 0.2, end: 1).animate(animation),
      builder: (context, child) {
        return CustomPaint(
          painter: SpeakingWavePainter(_waveHeight()),
          size: const Size(75, 100),
        );
      },
    );
  }
}

class SpeakingWavePainter extends CustomPainter {
  final double waveHeight;
  const SpeakingWavePainter(this.waveHeight) : super();

  @override
  Future<void> paint(Canvas canvas, Size size) async {
    final paint = Paint();
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 5;
    final rectagleHeight = size.height;
    final rectagleWidth = size.width;
    // final heightMagnifier = 30 * animationValue;

    // for (int i = 0; i < 4; i++) {
    double maxify = 25;
    // final maxify = math.Random().nextInt(25);
    double heightMagnifier = 5 + maxify * waveHeight;

    canvas.drawRRect(
      RRect.fromLTRBR(
        0,
        -heightMagnifier,
        rectagleWidth,
        rectagleHeight + heightMagnifier,
        const Radius.circular(30),
      ),
      paint,
    );

    // }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
