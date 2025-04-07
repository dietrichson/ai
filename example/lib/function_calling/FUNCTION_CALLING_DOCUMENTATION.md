# Function Calling in Flutter AI Toolkit

This document provides an overview of the function calling examples in the Flutter AI Toolkit, including the implementation approaches, features, and usage examples.

## Overview

Function calling allows an LLM to call predefined functions based on user input. This enables the model to perform actions beyond just generating text, such as calculations, retrieving data, or controlling application features.

This repository includes two different approaches to function calling:

1. **Standard Function Calling** (`function_calling.dart`): Uses the Gemini API's built-in function calling capabilities with tools and function declarations.

2. **Simplified Function Calling** (`simple_function_calling_fixed.dart`): Uses a custom implementation that doesn't rely on the Gemini API's function calling feature, making it more reliable and easier to understand.

## Features

### 1. Theme Support

Both examples now support light and dark themes that automatically switch when the app theme changes:

- **Dark Theme**: A sleek dark interface with appropriate contrast for low-light environments
- **Light Theme**: A clean light interface for better readability in bright environments

The chat UI components (messages, input field, buttons) all adapt to the current theme.

### 2. Function Implementation

Both examples implement two functions:

- **Add Numbers**: Takes two integer parameters and returns their sum
- **Random Number**: Generates a random number between 1 and 100

### 3. Error Handling

Improved error handling with:

- Custom error handlers that show errors in snackbars instead of dialogs
- Graceful handling of empty responses from the model
- Robust parameter parsing with fallbacks

### 4. Function Call Display

A dedicated panel shows all function calls made during the session, including:

- Function name
- Parameters passed to the function
- Timestamp of the call (in the simplified example)

## Implementation Approaches

### Standard Function Calling

Uses the Gemini API's built-in function calling capabilities:

```dart
// Define function declarations
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

// Configure the model with tools
GenerativeModel(
  model: 'gemini-1.5-pro',
  apiKey: geminiApiKey,
  tools: [
    Tool(
      functionDeclarations: [addNumbersFunction, randomNumberFunction],
    )
  ],
  toolConfig: ToolConfig(
    functionCallingConfig: FunctionCallingConfig(
      mode: FunctionCallingMode.auto,
    ),
  ),
)
```

### Simplified Function Calling

Uses pattern matching to detect function call requests:

```dart
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
}
```

## Usage Examples

### Adding Numbers

User input: "What is 123 plus 456?"

The system will:
1. Detect that this is an addition request
2. Extract the numbers 123 and 456
3. Call the `add_numbers` function with these parameters
4. Return: "The sum of 123 and 456 is 579"

### Generating a Random Number

User input: "Can you give me a random number?"

The system will:
1. Detect that this is a random number request
2. Call the `get_random_number` function
3. Return: "Your random number is: 42" (or any random number between 1 and 100)

## Theming

The examples now include both light and dark themes:

```dart
// In the build method
LlmChatView(
  provider: _provider,
  style: App.themeMode.value == ThemeMode.dark
      ? darkChatViewStyle()
      : lightChatViewStyle(),
  // ...
)
```

The theme automatically switches when the app theme changes, providing a consistent user experience.

## Conclusion

These examples demonstrate two different approaches to implementing function calling in a Flutter application. The standard approach uses the Gemini API's built-in capabilities, while the simplified approach uses pattern matching for more reliability and control.

Both examples include theme support, robust error handling, and a clean user interface, making them ready for use in production applications.
