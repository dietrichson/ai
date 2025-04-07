// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:math';

// No debug statements needed
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

// Class to represent a function call
class FunctionCall {
  final String name;
  final Map<String, dynamic> parameters;

  FunctionCall({required this.name, required this.parameters});

  @override
  String toString() => 'FunctionCall(name: $name, parameters: $parameters)';
}

// Type definition for function call handler
typedef FunctionCallHandler = String Function(FunctionCall call);

// Extension of GeminiProvider that supports function calling
class FunctionCallProvider extends GeminiProvider {
  FunctionCallProvider({
    required GenerativeModel model,
    required this.onFunctionCall,
    Iterable<ChatMessage>? history,
    List<SafetySetting>? chatSafetySettings,
    GenerationConfig? chatGenerationConfig,
  }) : super(
          model: model,
          history: history,
          chatSafetySettings: chatSafetySettings,
          chatGenerationConfig: chatGenerationConfig,
        );
  final FunctionCallHandler onFunctionCall;

  @override
  Stream<String> sendMessageStream(
    String prompt, {
    Iterable<Attachment> attachments = const [],
  }) async* {
    // Starting message stream
    final userMessage = ChatMessage.user(prompt, attachments);
    final llmMessage = ChatMessage.llm();
    history = [...history, userMessage, llmMessage];

    // Generate the response

    final responseStream = super.generateStream(
      prompt,
      attachments: attachments,
    );

    String fullResponse = '';

    // Collect the full response
    try {
      await for (final chunk in responseStream) {
        fullResponse += chunk;
        llmMessage.append(chunk);
        yield chunk;
      }

      // If we got an empty response, add a message to help debugging
      if (fullResponse.isEmpty) {
        llmMessage.append(
            'The model returned an empty response. Please try again with a different prompt.');
        yield 'The model returned an empty response. Please try again with a different prompt.';
      }
    } catch (e) {
      // Add error message to the chat
      llmMessage.append('Error: $e');
      yield 'Error: $e';
      // Don't rethrow - we want to handle the error gracefully
    }

    // Check if the response contains a function call
    try {
      // Parse the response to look for tool calls
      if (fullResponse.contains('"functionCall"') ||
          fullResponse.contains('"function_call"') ||
          fullResponse.contains('"tool_calls"') ||
          fullResponse.contains('"toolCalls"')) {
        // Try to extract the function call information
        Map<String, dynamic>? jsonResponse;
        try {
          jsonResponse = jsonDecode(fullResponse);
        } catch (e) {
          // If the full response isn't valid JSON, try to extract just the function call part
          final functionCallRegex =
              r'\{\s*"(function_call|functionCall|tool_calls|toolCalls)"\s*:\s*\{.*?\}\s*\}';
          final functionCallMatch =
              RegExp(functionCallRegex, dotAll: true).firstMatch(fullResponse);

          if (functionCallMatch != null) {
            final functionCallJson = functionCallMatch.group(0);
            if (functionCallJson != null) {
              try {
                jsonResponse = jsonDecode(functionCallJson);
              } catch (e) {
                // Failed to parse extracted JSON
              }
            }
          }
        }

        if (jsonResponse != null) {
          // Check for different possible formats of function calls
          final functionCallData =
              jsonResponse['function_call'] ?? jsonResponse['functionCall'];

          // Check for tool calls format
          final toolCalls =
              jsonResponse['tool_calls'] ?? jsonResponse['toolCalls'];

          if (functionCallData != null) {
            final functionCall = FunctionCall(
              name: functionCallData['name'],
              parameters: functionCallData['parameters'] ??
                  functionCallData['args'] ??
                  {},
            );

            // Call the function handler
            String functionResponse;
            try {
              functionResponse = onFunctionCall(functionCall);
            } catch (e) {
              functionResponse = "Error executing function: $e";
            }

            // Append the function response to the LLM message
            llmMessage.append('\n\n$functionResponse');
            yield '\n\n$functionResponse';
          } else if (toolCalls != null) {
            // Handle tool calls format (array or single object)
            List<dynamic> toolCallsList;

            if (toolCalls is List) {
              toolCallsList = toolCalls;
            } else {
              toolCallsList = [toolCalls];
            }

            for (final toolCall in toolCallsList) {
              final function = toolCall['function'] ?? {};
              final functionCall = FunctionCall(
                name: function['name'] ?? '',
                parameters: function['parameters'] ?? function['args'] ?? {},
              );

              // Call the function handler
              String functionResponse;
              try {
                functionResponse = onFunctionCall(functionCall);
              } catch (e) {
                functionResponse = "Error executing function: $e";
              }

              // Append the function response to the LLM message
              llmMessage.append('\n\n$functionResponse');
              yield '\n\n$functionResponse';
            }
          }
        }
      }
    } catch (e) {
      // Error handling function call parsing
    }

    // Notify listeners that the history has changed
    notifyListeners();
  }
}

// Implementation of the add numbers function
String addNumbers(int a, int b) {
  return "The sum of $a and $b is ${a + b}";
}

// Implementation of the random number function
String getRandomNumber() {
  final random = Random();
  final randomNumber =
      random.nextInt(100) + 1; // Random number between 1 and 100
  return "Your random number is: $randomNumber";
}
