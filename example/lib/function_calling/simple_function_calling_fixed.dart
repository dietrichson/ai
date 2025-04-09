// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../dark_style.dart';
import '../light_style.dart';
import '../gemini_api_key.dart';
import 'permission_aware_chat_view.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  static const title = 'Simple Function Calling Example';
  static final themeMode = ValueNotifier(ThemeMode.dark);

  const App({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
        valueListenable: themeMode,
        builder: (context, mode, child) => MaterialApp(
          title: title,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: mode,
          home: const ChatPage(),
          debugShowCheckedModeBanner: false,
        ),
      );
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final LlmProvider _provider;
  final List<FunctionCall> _functionCalls = [];

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() {
    // Create a custom provider that handles function calls
    _provider = SimpleFunctionCallProvider(
      apiKey: geminiApiKey,
      onFunctionCall: _handleFunctionCall,
    );
  }

  // Handle function calls from the LLM
  String _handleFunctionCall(FunctionCall call) {
    debugPrint('Function called: ${call.name} with params: ${call.parameters}');

    setState(() {
      _functionCalls.add(call);
    });

    // Call the appropriate function based on the name
    switch (call.name) {
      case 'add_numbers':
        try {
          // Try to safely convert parameters to integers
          final a = int.tryParse(call.parameters['a'].toString()) ?? 0;
          final b = int.tryParse(call.parameters['b'].toString()) ?? 0;
          return "The sum of $a and $b is ${a + b}";
        } catch (e) {
          debugPrint('Error in add_numbers: $e');
          return "Error adding numbers: $e";
        }
      case 'get_random_number':
        final random = Random();
        final randomNumber =
            random.nextInt(100) + 1; // Random number between 1 and 100
        return "Your random number is: $randomNumber";
      default:
        return "Unknown function: ${call.name}";
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(App.title),
          actions: [
            IconButton(
              onPressed: () => App.themeMode.value =
                  App.themeMode.value == ThemeMode.light
                      ? ThemeMode.dark
                      : ThemeMode.light,
              tooltip: App.themeMode.value == ThemeMode.light
                  ? 'Dark Mode'
                  : 'Light Mode',
              icon: const Icon(Icons.brightness_4_outlined),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: PermissionAwareChatView(
                provider: _provider,
                style: App.themeMode.value == ThemeMode.dark
                    ? darkChatViewStyle()
                    : lightChatViewStyle(),
                welcomeMessage:
                    'Welcome to the Simple Function Calling example! Try asking me to add two numbers or generate a random number.',
                suggestions: [
                  'Add 42 and 17',
                  'Can you give me a random number?',
                  'What is 123 plus 456?',
                ],
                // Custom error handler to show errors in a snackbar instead of a dialog
                onErrorCallback: (context, error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${error.toString()}'),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                },
              ),
            ),
            if (_functionCalls.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Function Calls (${_functionCalls.length}):',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _functionCalls.length,
                        itemBuilder: (context, index) {
                          final call = _functionCalls[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Function: ${call.name}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Parameters: ${call.parameters}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

// Simple class to represent a function call
class FunctionCall {
  final String name;
  final Map<String, dynamic> parameters;

  FunctionCall({required this.name, required this.parameters});

  @override
  String toString() => 'FunctionCall(name: $name, parameters: $parameters)';
}

// A simple provider that handles function calls
class SimpleFunctionCallProvider extends ChangeNotifier implements LlmProvider {
  SimpleFunctionCallProvider({
    required this.apiKey,
    required this.onFunctionCall,
  });

  final String apiKey;
  final String Function(FunctionCall) onFunctionCall;
  final List<ChatMessage> _history = [];

  @override
  List<ChatMessage> get history => _history;

  @override
  set history(Iterable<ChatMessage> value) {
    // Not implemented
  }

  // Helper method to check if a prompt is asking for addition
  bool _isAdditionRequest(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    return (lowerPrompt.contains('add') ||
            lowerPrompt.contains('plus') ||
            lowerPrompt.contains('sum') ||
            prompt.contains('+')) &&
        _extractNumbersFromPrompt(prompt).length >= 2;
  }

  // Helper method to check if a prompt is asking for a random number
  bool _isRandomNumberRequest(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    return lowerPrompt.contains('random') && lowerPrompt.contains('number');
  }

  // Helper method to extract numbers from a prompt
  List<int> _extractNumbersFromPrompt(String prompt) {
    final numbers = <int>[];
    final RegExp regExp = RegExp(r'\b(\d+)\b');
    final matches = regExp.allMatches(prompt);

    for (final match in matches) {
      if (match.group(1) != null) {
        final number = int.tryParse(match.group(1)!);
        if (number != null) {
          numbers.add(number);
        }
      }
    }

    return numbers;
  }

  @override
  Stream<String> sendMessageStream(
    String prompt, {
    Iterable<Attachment> attachments = const [],
  }) async* {
    // Add user message to history
    final userMessage = ChatMessage.user(prompt, attachments);
    final llmMessage = ChatMessage.llm();
    _history.addAll([userMessage, llmMessage]);

    // Check if this is a function call request
    if (_isAdditionRequest(prompt)) {
      // Extract numbers using regex
      final numbers = _extractNumbersFromPrompt(prompt);

      if (numbers.length >= 2) {
        final a = numbers[0];
        final b = numbers[1];

        // Create a function call
        final functionCall = FunctionCall(
          name: 'add_numbers',
          parameters: {'a': a, 'b': b},
        );

        // Get the response from the function handler
        final response = onFunctionCall(functionCall);

        // Add the response to the message
        llmMessage.append(response);
        yield response;
        return;
      }
    } else if (_isRandomNumberRequest(prompt)) {
      // Create a function call for random number
      final functionCall = FunctionCall(
        name: 'get_random_number',
        parameters: {},
      );

      // Get the response from the function handler
      final response = onFunctionCall(functionCall);

      // Add the response to the message
      llmMessage.append(response);
      yield response;
      return;
    }

    // If not a function call, use the Gemini API for a regular response
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
      );

      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      final responseText =
          response.text ?? "I'm not sure how to respond to that.";
      llmMessage.append(responseText);
      yield responseText;
    } catch (e) {
      final errorMessage = "I encountered an error: $e";
      llmMessage.append(errorMessage);
      yield errorMessage;
    }

    // Notify listeners that the history has changed
    notifyListeners();
  }

  @override
  Stream<String> generateStream(String prompt,
      {Iterable<Attachment> attachments = const []}) {
    // This is just a wrapper around sendMessageStream
    return sendMessageStream(prompt, attachments: attachments);
  }

  Future<void> cancel() async {
    // Not implemented
  }
}
