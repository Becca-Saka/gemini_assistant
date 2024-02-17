import 'package:flutter/material.dart';
import 'package:gemini_assistant/shared/app_colors.dart';

import 'circular_button.dart';
import 'expanding_circle.dart';

class PushToTalk extends StatelessWidget {
  final bool loading;
  final bool isNotListening;
  final void Function()? onPressed;
  const PushToTalk({
    super.key,
    required this.loading,
    required this.onPressed,
    required this.isNotListening,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (!isNotListening)
          ExpandingCircle(
            colors: [
              Colors.white,
              AppColors.secondaryColor.withOpacity(0.2),
              AppColors.tertiaryColor.withOpacity(0.5),
            ],
            size: 250,
          ),
        CircularButton(
          size: 150,
          backgroundColor: AppColors.secondaryColor,
          onPressed: onPressed,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: loading
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  )
                : Icon(
                    isNotListening ? Icons.mic_off : Icons.mic,
                    size: 50,
                    color: Colors.white,
                  ),
          ),
        ),
      ],
    );
  }
}
