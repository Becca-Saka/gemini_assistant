import 'package:flutter/material.dart';
import 'package:gemini_assistant/services/gemini_services.dart';
import 'package:gemini_assistant/services/speech_to_text_service.dart';
import 'package:gemini_assistant/services/text_to_speech_service.dart';
import 'package:gemini_assistant/shared/app_colors.dart';

import 'widget/circular_button.dart';
import 'widget/expanding_circle.dart';
import 'widget/gradient_text.dart';
import 'widget/wave_animation.dart';

class ChatApp extends StatefulWidget {
  const ChatApp({super.key});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  final TextToSpeechService _textToSpeechService = TextToSpeechService();
  final SpeechToTextService _speechToTextService = SpeechToTextService();
  final GerminiServices _germiniServices = GerminiServices();
  bool get _loading => _germiniServices.loading.value;
  TtsState ttsState = TtsState.stopped;
  String spokenText = '';
  @override
  void initState() {
    super.initState();
    _initGemini();
    _initSpeechServices();
  }

  void _initSpeechServices() async {
    await _speechToTextService.initSpeech();

    setState(() {});
    _textToSpeechService.initTTS(onListener: (ttsState) {
      this.ttsState = ttsState;

      debugPrint("ttsState: ${ttsState.name}");
      if (ttsState == TtsState.stopped) {
        spokenText = '';
      }
      setState(() {});
    });
  }

  void _startListening() async {
    await _textToSpeechService.stop();
    await _speechToTextService.startListening(
      onSpeech: (lastWords) {
        spokenText = lastWords;
        setState(() {});
      },
    );
  }

  Future<void> _stopListening() async {
    await _speechToTextService.stopListening(
      onSpeechStopped: (lastWords) {
        spokenText = lastWords;
        setState(() {});
        if (lastWords.isNotEmpty) {
          _sendMessage(lastWords);
        }
      },
    );
  }

  void _initGemini() => _germiniServices.init();

  Future<void> _sendMessage(String message) async {
    _germiniServices.sendMessage(
      message,
      onSuccess: (text) {
        _textToSpeechService.speak(text);
        setState(() {});
      },
      onError: (error) {
        _showError(error);
      },
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  void _stopSession() {
    if (!_speechToTextService.isNotListening) {
      _speechToTextService.cancel();
    } else if (ttsState == TtsState.playing) {
      _textToSpeechService.stop();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Column(
          children: [
            const GradientText(
              'Gemini Assistant',
              style: TextStyle(fontSize: 40),
              gradient: LinearGradient(colors: [
                AppColors.primaryColor,
                AppColors.secondaryColor,
                AppColors.tertiaryColor,
              ]),
            ),
            Expanded(
              child: Center(
                child: !_speechToTextService.speechEnabled
                    ? Text(
                        'Speech not enabled on your device. Check your settings ${_speechToTextService.speechEnabled} ${TtsState.playing}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: ttsState == TtsState.playing
                                ? const SpeakingWave()
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (spokenText.isNotEmpty)
                                        Text(
                                          spokenText,
                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      const SizedBox(height: 50),
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          if (!_speechToTextService
                                              .isNotListening)
                                            ExpandingCircle(
                                              color: AppColors.secondaryColor,
                                              colors: [
                                                Colors.white,
                                                AppColors.secondaryColor
                                                    .withOpacity(0.2),
                                                AppColors.tertiaryColor
                                                    .withOpacity(0.5),
                                              ],
                                              size: 250,
                                            ),
                                          CircularButton(
                                            size: 150,
                                            backgroundColor:
                                                AppColors.secondaryColor,
                                            onPressed:
                                                // If not yet listening for speech start, otherwise stop
                                                _speechToTextService
                                                        .isNotListening
                                                    ? _startListening
                                                    : _stopListening,
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              child: _loading
                                                  ? const Padding(
                                                      padding:
                                                          EdgeInsets.all(16.0),
                                                      child:
                                                          CircularProgressIndicator(),
                                                    )
                                                  : Icon(
                                                      _speechToTextService
                                                              .isNotListening
                                                          ? Icons.mic_off
                                                          : Icons.mic,
                                                      size: 50,
                                                      color: Colors.white,
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                          const Spacer(),
                          if (!_speechToTextService.isNotListening ||
                              ttsState == TtsState.playing)
                            CircularButton(
                              size: 80,
                              backgroundColor: Colors.red,
                              onPressed: _stopSession,
                              child: Icon(
                                _loading ? Icons.close_rounded : Icons.stop,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
