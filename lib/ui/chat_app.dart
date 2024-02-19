import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gemini_assistant/services/file_picker_service.dart';
import 'package:gemini_assistant/services/gemini_service.dart';
import 'package:gemini_assistant/services/speech_to_text_service.dart';
import 'package:gemini_assistant/services/text_to_speech_service.dart';
import 'package:gemini_assistant/shared/app_colors.dart';

import 'widget/circular_button.dart';
import 'widget/gradient_text.dart';
import 'widget/image_in_process.dart';
import 'widget/push_to_talk.dart';
import 'widget/wave_animation.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextToSpeechService _textToSpeechService = TextToSpeechService();
  final SpeechToTextService _speechToTextService = SpeechToTextService();
  final GerminiService _germiniServices = GerminiService();
  final FilePickerService _filePickerService = FilePickerService();
  ScrollController controller = ScrollController();
  bool get _loading => _germiniServices.loading.value;
  bool imageLoading = false;
  TtsState ttsState = TtsState.stopped;
  String spokenText = '';
  String resultText = '';
  int start = 0;
  int end = 0;
  List<FileData>? filesInProcess;

  @override
  void initState() {
    super.initState();
    _initGemini();
    _initSpeechServices();
  }

  void _initGemini() => _germiniServices.init();

  void _initSpeechServices() async {
    await _speechToTextService.initSpeech(
      onError: (e) {
        spokenText = '';
        setState(() {});
        debugPrint('error: $e');
      },
    );

    setState(() {});
    _textToSpeechService.initTTS(
        onListener: (ttsState) {
          this.ttsState = ttsState;

          debugPrint("ttsState: ${ttsState.name}");
          if (ttsState == TtsState.stopped) {
            spokenText = '';
            resultText = '';
            start = 0;
            end = 0;
            filesInProcess = null;
          }
          setState(() {});
        },
        onProgress: _onTextSpeechProgress);
  }

  void _onTextSpeechProgress(
    String text,
    int start,
    int end,
    String word,
  ) {
    resultText = word;
    // resultText = text;
    this.start = start;
    this.end = end;

    setState(() {});
  }

  void _startListening() async {
    await _textToSpeechService.stop();
    await _speechToTextService.startListening(
      onSpeech: (lastWords, isFinal) {
        spokenText = lastWords;
        setState(() {});
        if (isFinal) {
          _sendMessage(message: lastWords);
        }
      },
    );
  }

  Future<void> _stopListening() async {
    await _speechToTextService.stopListening(
      onSpeechStopped: (lastWords) {
        spokenText = lastWords;
        setState(() {});

        _sendMessage(message: lastWords);
      },
    );
  }

  void _stopSession() {
    if (!_speechToTextService.isNotListening) {
      _speechToTextService.cancel();
    } else if (ttsState == TtsState.playing) {
      _textToSpeechService.stop();
    }

    spokenText = '';
    filesInProcess = null;

    setState(() {});
  }

  Future<void> _pickImage() async {
    final files = await _filePickerService.pickFile(
        allowMultiple: true,
        type: FileType.image,
        onFileLoading: (status) {
          if (status == FilePickerStatus.picking) {
            imageLoading = true;
          } else if (status == FilePickerStatus.done) {
            imageLoading = false;
          }

          debugPrint('loading: ${status.name}');
          setState(() {});
        });

    if (files != null && files.isNotEmpty) {
      filesInProcess = files;
      debugPrint('returning: ${files.length} files');
      setState(() {});
      _sendMessage(imageBytes: files);
    }
  }

  Future<void> _sendMessage({
    String? message,
    List<FileData>? imageBytes,
  }) async {
    bool hasValidMessage = message != null && message.isNotEmpty ||
        imageBytes != null && imageBytes.isNotEmpty;
    bool canSendMessage = hasValidMessage &&
        _speechToTextService.isNotListening &&
        ttsState == TtsState.stopped &&
        !_loading;
    if (canSendMessage) {
      debugPrint("Sending message: $message ${imageBytes?.length}");
      await _germiniServices.sendMessage(
        message: message,
        imageBytes: imageBytes,
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
    filesInProcess = null;
    imageLoading = false;
    spokenText = '';
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
                          const SizedBox(height: 30),
                          ImageInProcessWidget(
                            filesInProcess: filesInProcess,
                            imageLoading: imageLoading,
                          ),

                          // HighlightedText(
                          //   text: resultText,
                          //   start: start,
                          //   end: end,
                          // ),
                          const Spacer(),
                          if (resultText.isNotEmpty)
                            Text(
                              resultText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          const SizedBox(
                            height: 80,
                          ),
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
                                      ValueListenableBuilder(
                                          valueListenable:
                                              _germiniServices.loading,
                                          builder: (context, value, child) {
                                            return PushToTalk(
                                              loading: value,
                                              isNotListening:
                                                  _speechToTextService
                                                      .isNotListening,
                                              onPressed: _speechToTextService
                                                      .isNotListening
                                                  ? _startListening
                                                  : _stopListening,
                                            );
                                          }),
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
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CircularButton(
                                  size: 50,
                                  backgroundColor: Colors.red,
                                  onPressed: _pickImage,
                                  child: const Icon(
                                    Icons.image,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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
