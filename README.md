# hugging_face_chat_gradio
## 📢 Publisher: Mahmoud Magdy (Verified soon)
##### This package was built and published by Mahmoud Magdy, a Flutter developer passionate about integrating AI into mobile apps.

A Flutter package for interacting with Hugging Face Chat Space APIs using Server-Sent Events (SSE). This package provides a clean and robust way to send messages to a Hugging Face Gradio API and process real-time responses, making it ideal for integrating AI-powered chat functionalities into Flutter applications.

## Why Use This Package?

The `hugging_face_chat_gradio` package is designed for developers who need to:

- **Integrate AI Chat Models**: Connect to Hugging Face Spaces hosting Gradio-based chat APIs, enabling AI-driven conversations in Flutter apps.
- **Handle Real-Time Responses**: Process Server-Sent Events (SSE) for streaming responses, ensuring smooth and responsive user experiences.
- **Simplify API Interactions**: Abstract complex HTTP requests and SSE parsing into a simple client interface, reducing development time.
- **Support Multilingual Applications**: Send and receive messages in various languages (e.g., Arabic, as shown in the example), leveraging Hugging Face's powerful language models.
- **Ensure Robust Error Handling**: Gracefully handle network issues, server errors, and malformed responses with built-in utilities.

Use this package if you're building a Flutter app that requires conversational AI, such as chatbots, virtual assistants, or interactive Q&A features, powered by Hugging Face's Gradio-based APIs.

## Features

- Send messages to Hugging Face Gradio APIs with a single method call.
- Stream real-time responses using Server-Sent Events (SSE).
- Modular design with separate classes for API calls, parsing, and utilities.
- Robust error handling for network issues, server errors, and JSON parsing.
- Configurable timeouts for reliable API communication.
- Lightweight, using `dio` for HTTP requests and `dart:developer` for logging.

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  hugging_face_chat_gradio: ^0.0.5
```

Run the following command to install the package:

```bash
flutter pub get
```

The package already includes `dio` as a dependency for HTTP requests, so you don't need to add it separately.

## Usage

### 1. Initialize the Client

Create an instance of `HuggingFaceChatGradioClient` with the base URL of your Hugging Face Space and the predict endpoint:

```dart
import 'package:hugging_face_chat_gradio/hf_chat_gradio_client.dart';

final client = HuggingFaceChatGradioClient(
  baseUrl: '<your-hugging-face-space-url>',
  predictEndpoint: '<predict-endpoint>',
);
```

### 2. Send a Message and Receive a Response

Use the `sendMessage` method to send a message and receive the response. The method handles the POST request to initiate the chat, retrieves the `event_id`, and processes the SSE stream for the response.

Here’s an example of sending a message and handling the response:

```dart
import 'package:hugging_face_chat_gradio/hf_chat_gradio_client.dart';
import 'dart:developer' as developer;

void main() async {
  final client = HuggingFaceChatGradioClient(
    baseUrl: '<your-hugging-face-space-url>',
    predictEndpoint: '<predict-endpoint>',
  );

  try {
    final response = await client.sendMessage('كيف احمي اسناني!!');
    developer.log('Response: $response', name: 'GradioClient');
  } catch (e) {
    developer.log('Error: $e', name: 'GradioClient');
  }
}
```

### 3. Core Implementation Overview

The package is designed with a modular architecture, separating concerns for API interactions, response parsing, and error handling. The main client class orchestrates message sending and response retrieval, while dedicated utilities manage HTTP requests (via `dio`), parse SSE responses, and log errors. This structure ensures clean, maintainable code and simplifies integration with Hugging Face Gradio APIs.

### 4. Error Handling

The package uses `HuggingFaceChatGradioUtils` for consistent logging and error handling:

```dart
static void handleException(dynamic e) {
  final message =
      (e is DioException)
          ? 'Dio error: ${e.message}'
          : 'Unexpected error: $e';
  logMessage(message);
}
```

This ensures errors (e.g., network issues, server errors) are logged clearly, making debugging easier.

### 5. Example Application

Create a simple Flutter app to test the package:

```dart
import 'package:flutter/material.dart';
import 'package:hugging_face_chat_gradio/hf_chat_gradio_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final client = HuggingFaceChatGradioClient(
    baseUrl: '<your-hugging-face-space-url>', /// https://chatBot.hf.space
    predictEndpoint: '<predict-endpoint>', /// /gradio_api/call/predict
  );
  final TextEditingController _controller = TextEditingController();
  String _response = '';

  void _sendMessage() async {
    final message = _controller.text;
    if (message.isEmpty) return;

    try {
      final response = await client.sendMessage(message);
      setState(() {
        _response = response;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appAppBar: AppBar(title: Text('Hugging Face Chat')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter your message'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Send'),
            ),
            SizedBox(height: 16.0),
            Text('Response: $_response'),
          ],
        ),
      ),
    );
  }
}
```

This app allows users to input a message, send it to the Hugging Face API, and display the response.

## Limitations

- **Dependency on Hugging Face Space**: The package is designed for Gradio-based APIs hosted on Hugging Face Spaces. Ensure the target Space is active and uses the specified predict endpoint.
- **SSE Response Format**: The package assumes responses follow the expected SSE format (e.g., `event: complete` with a JSON array or object). If the format changes, you may need to update the parser.
- **Network Dependency**: Requires a stable internet connection for API communication.

## Contributing

Contributions are welcome! Please submit issues or pull requests to the [GitHub repository](https://github.com/your-repo/hugging_face_chat_gradio).