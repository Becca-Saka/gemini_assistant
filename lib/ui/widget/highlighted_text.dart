import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final int start;
  final int end;
  const HighlightedText(
      {super.key, required this.text, required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 200,
      child: SingleChildScrollView(
        child: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: start != 0 ? text.substring(0, start) : "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  )),
              TextSpan(
                  text: text.substring(start, end),
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              TextSpan(
                text: text.substring(end),
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
