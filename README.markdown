# hugging_face_chat_gradio

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
  hugging_face_chat_gradio: ^0.1.0
```

Run the following command to install the package:

```bash
flutter pub get
```

Ensure you have the `dio` package as a dependency, as it is used for HTTP requests:

```yaml
dependencies:
  dio: ^5.4.0
```

## Usage

### 1. Initialize the Client

Create an instance of `HuggingFaceChatGradioClient` with the base URL of your Hugging Face Space and the predict endpoint (`/gradio_api/call/predict`):

```dart
import 'package:hugging_face_chat_gradio/hf_chat_gradio_client.dart';

final client = HuggingFaceChatGradioClient(
  baseUrl: 'https://baher-hamada-final-project.hf.space',
  predictEndpoint: '/gradio_api/call/predict',
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
    baseUrl: 'https://baher-hamada-final-project.hf.space',
    predictEndpoint: '/gradio_api/call/predict',
  );

  try {
    final response = await client.sendMessage('كيف احمي اسناني!!');
    developer.log('Response: $response', name: 'GradioClient');
  } catch (e) {
    developer.log('Error: $e', name: 'GradioClient');
  }
}
```

### 3. Core Implementation Details

The package is structured into modular components:

- **HuggingFaceChatGradioClient**: The main client class that orchestrates sending messages and receiving responses.
- **HuggingFaceChatGradioApis**: Handles API calls for fetching the `event_id` and waiting for SSE responses.
- **HuggingFaceChatGradioParser**: Parses SSE messages to extract response data.
- **HuggingFaceChatGradioUtils**: Provides logging and error handling utilities.

Below is a key snippet from `HuggingFaceChatGradioClient` showing how it sends a message:

```dart
Future<String> sendMessage(String message) async {
  try {
    final eventId = await HuggingFaceChatGradioApis.fetchEventId(
      _dio,
      baseUrl,
      predictEndpoint,
      message,
    );
    if (eventId == null) throw Exception('Failed to get event ID');

    return await HuggingFaceChatGradioApis.waitForResponse(
      _dio,
      baseUrl,
      predictEndpoint,
      eventId,
    );
  } catch (e) {
    HuggingFaceChatGradioUtils.handleException(e);
    rethrow;
  }
}
```

The `fetchEventId` method sends a POST request to get the `event_id`:

```dart
static Future<String?> fetchEventId(
  Dio dio,
  String baseUrl,
  String endpoint,
  String message,
) async {
  try {
    final response = await dio.post(
      '$baseUrl$endpoint',
      data: {
        "data": [message],
      },
    );
    final eventId = response.data["event_id"] as String?;
    return eventId;
  } catch (e) {
    HuggingFaceChatGradioUtils.handleException(e);
    return null;
  }
}
```

The `waitForResponse` method processes the SSE stream and extracts the response:

```dart
static Future<String> waitForResponse(
  Dio dio,
  String baseUrl,
  String endpoint,
  String eventId,
) async {
  final completer = Completer<String>();
  try {
    final response = await dio.get(
      '$baseUrl$endpoint/$eventId',
      options: Options(responseType: ResponseType.stream),
    );
    String buffer = '';
    await for (var chunk in response.data.stream) {
      final dataChunk = String.fromCharCodes(chunk);
      buffer += dataChunk;
      final messages = buffer.split('\n\n');
      buffer = messages.last;
      for (var message in messages.sublist(0, messages.length - 1)) {
        final lines = message.split('\n');
        String? eventType;
        String? eventData;
        for (var line in lines) {
          if (line.startsWith('event: ')) {
            eventType = line.substring(7).trim();
          } else if (line.startsWith('data: ')) {
            eventData = line.substring(6).trim();
          }
        }
        if (eventType == 'complete' && eventData != null) {
          final parsed = HuggingFaceChatGradioParser.parseSseMessage(eventData);
          if (parsed != null) {
            completer.complete(parsed);
            return completer.future;
          }
        }
      }
    }
    throw Exception('No valid response received');
  } catch (e) {
    HuggingFaceChatGradioUtils.handleException(e);
    rethrow;
  }
}
```

The `HuggingFaceChatGradioParser` handles JSON parsing for SSE messages:

```dart
static String? parseSseMessage(String eventData) {
  try {
    final decoded = jsonDecode(eventData);
    if (decoded is List && decoded.isNotEmpty) {
      return decoded[0];
    } else if (decoded is Map<String, dynamic>) {
      return decoded['data']?[0];
    }
  } catch (e) {
    HuggingFaceChatGradioUtils.logMessage('Error decoding data: $e');
  }
  return null;
}
```

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
    baseUrl: 'https://baher-hamada-final-project.hf.space',
    predictEndpoint: '/gradio_api/call/predict',
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
      appBar: AppBar(title: Text('Hugging Face Chat')),
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

## Requirements

- **Flutter SDK**: >=3.0.0
- **Dart SDK**: >=2.17.0
- **Dependencies**: `dio` (^5.4.0)

## Limitations

- **Dependency on Hugging Face Space**: The package is designed for Gradio-based APIs hosted on Hugging Face Spaces. Ensure the target Space is active and uses the `/gradio_api/call/predict` endpoint.
- **SSE Response Format**: The package assumes responses follow the expected SSE format (e.g., `event: complete` with a JSON array or object). If the format changes, you may need to update the parser.
- **Network Dependency**: Requires a stable internet connection for API communication.

## Contributing

Contributions are welcome! Please submit issues or pull requests to the [GitHub repository](https://github.com/your-repo/hugging_face_chat_gradio).
