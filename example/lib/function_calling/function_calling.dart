// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../dark_style.dart';
import '../gemini_api_key.dart';
import 'function_call_provider.dart' as fc;

void main() => runApp(const App());

class App extends StatelessWidget {
  static const title = 'Example: Function Calling';
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
  late final fc.FunctionCallProvider _provider;
  final List<fc.FunctionCall> _functionCalls = [];

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  void _initProvider() {
    // Define the function declarations for our two functions
    final addNumbersFunction = FunctionDeclaration(
      'add_numbers',
      'Adds two numbers together and returns the result.',
      Schema.object(
        properties: {
          'a': Schema.integer(description: 'The first number to add.'),
          'b': Schema.integer(description: 'The second number to add.'),
        },
        requiredProperties: ['a', 'b'],
      ),
    );

    final randomNumberFunction = FunctionDeclaration(
      'get_random_number',
      'Generates a random number between 1 and 100.',
      Schema.object(
        properties: {},
      ),
    );

    // System instructions to call the functions when asked
    final systemInstructions = Content.system('''
        You are a helpful assistant that can call functions.
        ALWAYS use the add_numbers function when the user asks about adding, summing, or calculating the total of two numbers.
        ALWAYS use the get_random_number function when the user asks for a random number.
        DO NOT try to calculate the answers yourself - you MUST use the functions.
        For example, if the user asks "What is 5 plus 7?", you MUST call the add_numbers function with a=5 and b=7.
        ''');

    // Create the provider with the tools and system instructions
    _provider = fc.FunctionCallProvider(
      model: GenerativeModel(
        model:
            'gemini-1.5-pro', // Use gemini-1.5-pro which has better function calling support
        apiKey: geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0,
        ),
        systemInstruction: systemInstructions,
        tools: [
          Tool(
            functionDeclarations: [addNumbersFunction, randomNumberFunction],
          )
        ],
        // Set the function calling mode to AUTO to let the model decide when to call functions
        toolConfig: ToolConfig(
          functionCallingConfig: FunctionCallingConfig(
            mode: FunctionCallingMode.auto,
          ),
        ),
      ),
      onFunctionCall: _handleFunctionCall,
    );
  }

  // Handle function calls from the LLM
  String _handleFunctionCall(fc.FunctionCall call) {
    debugPrint('DEBUG HANDLER: Received function call: $call');
    debugPrint('DEBUG HANDLER: Function name: ${call.name}');
    debugPrint('DEBUG HANDLER: Parameters: ${call.parameters}');

    setState(() {
      _functionCalls.add(call);
    });

    // Call the appropriate function based on the name
    switch (call.name) {
      case 'add_numbers':
        debugPrint('DEBUG HANDLER: Handling add_numbers function');
        try {
          // Try to safely convert parameters to integers
          final a = int.tryParse(call.parameters['a'].toString()) ?? 0;
          final b = int.tryParse(call.parameters['b'].toString()) ?? 0;
          debugPrint('DEBUG HANDLER: Parameters parsed - a: $a, b: $b');
          final result = fc.addNumbers(a, b);
          debugPrint('DEBUG HANDLER: Result: $result');
          return result;
        } catch (e) {
          debugPrint('DEBUG HANDLER ERROR: Error in add_numbers: $e');
          return "Error adding numbers: $e";
        }
      case 'get_random_number':
        debugPrint('DEBUG HANDLER: Handling get_random_number function');
        final result = fc.getRandomNumber();
        debugPrint('DEBUG HANDLER: Result: $result');
        return result;
      default:
        debugPrint('DEBUG HANDLER: Unknown function: ${call.name}');
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
              child: LlmChatView(
                provider: _provider,
                style: App.themeMode.value == ThemeMode.dark
                    ? darkChatViewStyle()
                    : LlmChatViewStyle.defaultStyle(),
                welcomeMessage:
                    'Welcome to the Function Calling example! Try asking me to add two numbers or generate a random number.',
                suggestions: [
                  'Add 42 and 17',
                  'Can you give me a random number?',
                  'What is 123 plus 456?',
                ],
                // Custom error handler to log errors instead of showing a dialog
                onErrorCallback: (context, error) {
                  debugPrint('CUSTOM ERROR HANDLER: ${error.toString()}');
                  // You can add a more user-friendly error message here if needed
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

// Using FunctionCall from function_call_provider.dart
