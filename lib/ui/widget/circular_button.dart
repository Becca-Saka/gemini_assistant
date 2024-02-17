import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final void Function()? onPressed;
  final Color? backgroundColor;
  final Widget? child;
  final double? size;
  const CircularButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.child,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: size,
      // width: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            fixedSize: size == null ? null : Size(size!, size!)),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
