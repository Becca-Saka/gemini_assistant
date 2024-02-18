import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'file_picker_service.dart';

// enum QueryType { text, image }

class GerminiService {
  late GenerativeModel model;
  late GenerativeModel imageModel;
  late ChatSession chat;
  // final String prompt =
  //     "You are my personal assistant. Give the answer you find the questions below. However, if the question is beyond your capabilities, tell me 'I don't have an answer' or something more creative. \n\n  ";
  final String prompt =
      "Assume the role of a helpful AI assistant: I'm seeking your assistance with these inquiries. Respond as if you were a voice-activated device, providing clear and concise answers. If and only if a question is beyond your capabilities, acknowledge it politely.";
  // final String prompt =
  //     "You are an AI assistant, I want you to answer as an ai assistant like Siri or Alexa would answer the questions below. When you dont have an answer dont tell me you are an AI assistant. give me a mock response instead. \n\n  ";
  final String imagePrompt =
      "What do you see? For every entity in the image, tell the name and simple details about it";
  // final String imagePrompt =
  //     "Assume the role of a helpful AI assistant: I'm seeking your assistance with getting information about these images. Respond as if you were a voice-activated device, providing clear and concise answers. NOTE: do not include any call to action.";

  // final imagePrompt =
  //     'What do you see? Tell me everything you see in the image and what you know about the contents in indepth details.';
  // final imagePrompt =
  //     'What do you see? Use lists. Start with a headline for each image.';

  final ValueNotifier<bool> loading = ValueNotifier(false);
  List<Content> get chats => chat.history.toList();

  int maxMessageSize = 1005299;
  void init() {
    const apiKey = String.fromEnvironment('API_KEY');

    model = GenerativeModel(
      model: 'gemini-1.0-pro',
      apiKey: apiKey,
    );
    imageModel = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: apiKey,
    );
    chat = model.startChat();
  }

  Future<void> sendMessage({
    String? message,
    List<FileData>? imageBytes,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    if (message != null) {
      _sendTextMessage(message, onSuccess: onSuccess, onError: onError);
    } else if (imageBytes != null) {
      _sendImageMessage(imageBytes, onSuccess: onSuccess, onError: onError);
    } else {
      onError('No message or image provided');
    }
  }

  Future<void> _sendTextMessage(
    String message, {
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    try {
      var response = await chat.sendMessage(Content.text('$prompt$message'));
      _onResponse(response, onSuccess: onSuccess, onError: onError);
    } catch (e) {
      onError(e.toString());
      _setLoading(false);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _sendImageMessage(
    List<FileData> message, {
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    try {
      final contentParts = [
        TextPart(imagePrompt),
        ...message.map((file) => DataPart(file.fileType, file.bytes)),
      ];
      final messageSize = _calculateMessageSize(contentParts);
      debugPrint(
          'Message size: $messageSize bytes maxMessageSize: $maxMessageSize is ${messageSize > maxMessageSize}');
      if (messageSize > maxMessageSize) {
        onError('Message size is too large.');
        return;
      }
      final content = [Content.multi(contentParts)];

      final response = await imageModel.generateContent(content);
      _onResponse(response, onSuccess: onSuccess, onError: onError);
    } catch (e) {
      debugPrint(e.toString());
      onError(e.toString());
      _setLoading(false);
    } finally {
      _setLoading(false);
    }
  }

  void _onResponse(
    GenerateContentResponse response, {
    required Function(String) onSuccess,
    required Function(String) onError,
  }) {
    var text = response.text;
    debugPrint('text: $text');
    _setLoading(false);
    if (text == null) {
      onError('No response from API.');
      return;
    } else {
      onSuccess(text);
    }
  }

  int _calculateMessageSize(List<Part> message) {
    var size = 0;
    for (var part in message) {
      if (part is TextPart) {
        size += part.text.length;
      } else if (part is DataPart) {
        final json = part.toJson();
        final jsonString = jsonEncode(json);
        final jsonSizeInBytes = utf8.encode(jsonString).length;
        size += jsonSizeInBytes;
      }
    }
    return size;
  }

  void _setLoading(bool value) => loading.value = value;
}
