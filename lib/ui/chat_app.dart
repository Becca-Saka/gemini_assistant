import 'package:flutter/material.dart';
import 'package:gemini_assistant/services/gemini_services.dart';
import 'package:gemini_assistant/services/speech_to_text_service.dart';
import 'package:gemini_assistant/services/text_to_speech_service.dart';
import 'package:gemini_assistant/shared/app_colors.dart';

import 'widget/circular_button.dart';
import 'widget/gradient_text.dart';
import 'widget/push_to_talk.dart';
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
  bool get _loading => _germiniServices.loading;
  TtsState ttsState = TtsState.stopped;
  String spokenText = '';
  @override
  void initState() {
    super.initState();
    _initGemini();
    _initSpeechServices();
  }

  void _initGemini() => _germiniServices.init();

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
      onSpeech: (lastWords, isFinal) {
        spokenText = lastWords;
        setState(() {});
        if (isFinal) {
          _sendMessage(lastWords);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speechToTextService.stopListening(
      onSpeechStopped: (lastWords) {
        spokenText = lastWords;
        setState(() {});

        _sendMessage(lastWords);
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

  Future<void> _sendMessage(String message) async {
    bool canSendMessage = message.isNotEmpty &&
        _speechToTextService.isNotListening &&
        ttsState == TtsState.stopped &&
        !_loading;
    if (canSendMessage) {
      debugPrint("Sending message: $message");
      await _germiniServices.sendMessage(
        message,
        onSuccess: (text) {
          _textToSpeechService.speak(text);
          setState(() {});
        },
        onError: (error) {
          setState(() {});
          _showError(error);
        },
      );
    }
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
                                      PushToTalk(
                                        loading: _loading,
                                        isNotListening:
                                            _speechToTextService.isNotListening,
                                        onPressed:
                                            _speechToTextService.isNotListening
                                                ? _startListening
                                                : _stopListening,
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
