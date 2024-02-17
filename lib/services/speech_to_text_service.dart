import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService {
  final SpeechToText _speechToText = SpeechToText();
  bool speechEnabled = false;

  String _lastWords = '';
  bool get isNotListening => _speechToText.isNotListening;

  Future<void> initSpeech() async =>
      speechEnabled = await _speechToText.initialize(debugLogging: true);

  /// Starts a speech recognition session
  Future<void> startListening({
    required Function(String, bool) onSpeech,
  }) async {
    await _speechToText.stop();
    _lastWords = '';
    final response = await _speechToText.listen(
      localeId: 'en-NG',
      pauseFor: const Duration(seconds: 2),
      listenOptions: SpeechListenOptions(
        autoPunctuation: true,
      ),
      onResult: (result) {
        debugPrint('result: ${result.recognizedWords}');

        _lastWords = result.recognizedWords;

        onSpeech(_lastWords, result.finalResult);
      },
    );
    log('response: $response');
    onSpeech(_lastWords, false);
  }

  /// Stops the active speech recognition session
  Future<void> stopListening(
      {required Function(String) onSpeechStopped}) async {
    await _speechToText.stop();

    onSpeechStopped(_lastWords);
  }

  Future<void> cancel() async => await _speechToText.cancel();
}
