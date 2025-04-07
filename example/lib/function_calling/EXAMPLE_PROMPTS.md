# Example Prompts for Function Calling

This file contains example prompts you can use to test the function calling examples.

## Addition Function

The `add_numbers` function takes two integer parameters and returns their sum.

### Example Prompts:

- "Add 42 and 17"
- "What is 123 plus 456?"
- "Calculate 789 + 321"
- "Sum of 55 and 45"
- "What's 1000 plus 2000?"
- "Can you add 7 and 8 for me?"
- "What is the total of 123 and 456?"

## Random Number Function

The `get_random_number` function generates a random number between 1 and 100.

### Example Prompts:

- "Give me a random number"
- "Generate a random number"
- "I need a random number"
- "Can you provide a random number?"
- "Random number please"
- "I'm feeling lucky, give me a random number"

## Regular Conversation

For regular conversation that doesn't trigger function calls:

- "Hello, how are you?"
- "Tell me about Flutter"
- "What is function calling?"
- "Explain the concept of AI"
- "What's the weather like today?" (Note: This won't actually check the weather, as we haven't implemented a weather function)

## Testing Error Handling

To test error handling:

- "Add text and numbers" (This should fail gracefully as "text" is not a valid number)
- "Add" (This doesn't provide enough parameters)
- "Random" (This might not be detected as a random number request)

## Tips for Testing

1. Try variations of the prompts to see how robust the function detection is
2. Test with different number formats (e.g., "1,000" vs "1000")
3. Try mixing function calls with regular conversation
4. Test the theme switching by clicking the brightness icon in the app bar
