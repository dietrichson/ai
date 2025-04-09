# Function Calling Examples

This directory contains examples of function calling implementations for the Flutter AI Toolkit.

## Files

- **function_calling.dart**: Standard implementation using Gemini API's function calling capabilities
- **simple_function_calling_fixed.dart**: Simplified implementation using pattern matching
- **function_call_provider.dart**: Provider for the standard implementation
- **FUNCTION_CALLING_DOCUMENTATION.md**: Detailed documentation of the implementations

## Running the Examples

### Standard Implementation

```bash
flutter run -d chrome example/lib/function_calling/function_calling.dart
```

### Simplified Implementation

```bash
flutter run -d chrome example/lib/function_calling/simple_function_calling_fixed.dart
```

## Features

- **Theme Support**: Both light and dark themes
- **Function Calling**: Add numbers and generate random numbers
- **Voice Notes**: Record audio messages with proper permission handling
- **Error Handling**: Custom error handlers with snackbar notifications
- **Function Call Display**: Panel showing all function calls made during the session
- **Production-Ready**: Includes all necessary setup for a production app

## Screenshots

### Dark Theme
![Dark Theme](https://via.placeholder.com/800x450.png?text=Dark+Theme+Screenshot)

### Light Theme
![Light Theme](https://via.placeholder.com/800x450.png?text=Light+Theme+Screenshot)

## Usage

1. Enter a prompt like "Add 42 and 17" or "Can you give me a random number?"
2. The system will detect the function call request and execute the appropriate function
3. The result will be displayed in the chat
4. The function call details will be shown in the panel below

## Implementation Details

See [FUNCTION_CALLING_DOCUMENTATION.md](./FUNCTION_CALLING_DOCUMENTATION.md) for detailed documentation of the implementations.
