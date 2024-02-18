import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService {
  final SpeechToText _speechToText = SpeechToText();
  bool speechEnabled = false;
  String _lastWords = '';
  bool isListening = false;
  bool get isNotListening => !isListening || _speechToText.isNotListening;

  Future<void> initSpeech({
    required Function(SpeechRecognitionError) onError,
  }) async =>
      speechEnabled = await _speechToText.initialize(
        debugLogging: true,
        onError: (error) {
          debugPrint('error: $error');
          _lastWords = '';
          isListening = false;
          onError(error);
        },
      );

  /// Starts a speech recognition session
  Future<void> startListening({
    required Function(String, bool) onSpeech,
  }) async {
    try {
      await _speechToText.stop();
      _lastWords = '';
      isListening = true;
      await _speechToText.listen(
        localeId: 'en-NG',
        pauseFor: const Duration(seconds: 2),
        listenOptions: SpeechListenOptions(autoPunctuation: true),
        onResult: (result) {
          debugPrint('result: ${result.recognizedWords}');

          _lastWords = result.recognizedWords;

          if (result.finalResult) {
            isListening = false;
          }
          onSpeech(_lastWords, result.finalResult);
        },
      );
      onSpeech(_lastWords, false);
    } on Exception catch (e) {
      debugPrint('error response: $e');
    }
  }

  /// Stops the active speech recognition session
  Future<void> stopListening(
      {required Function(String) onSpeechStopped}) async {
    await _speechToText.stop();

    onSpeechStopped(_lastWords);
  }

  Future<void> cancel() async => await _speechToText.cancel();
}
