import 'dart:async';
import 'package:dio/dio.dart';

import 'hf_chat_gradio_parsers.dart';
import 'hf_chat_gradio_utils.dart';

class HuggingFaceChatGradioApis {
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
      // GradioUtils.logMessage('Event ID: $eventId');
      return eventId;
    } catch (e) {
      HuggingFaceChatGradioUtils.handleException(e);
      return null;
    }
  }

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
        // GradioUtils.logMessage('Stream Chunk: $dataChunk');

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

          if (eventType == null || eventData == null) continue;

          // GradioUtils.logMessage('Event: $eventType, Data: $eventData');

          switch (eventType) {
            case 'data':
            case 'complete':
              final parsed = HuggingFaceChatGradioParser.parseSseMessage(
                eventData,
              );
              if (parsed != null) {
                completer.complete(parsed);

                HuggingFaceChatGradioUtils.logMessage(
                  'Model Answer Received Successfully',
                );
                return completer.future;
              }
              break;
            case 'error':
              HuggingFaceChatGradioUtils.logMessage(
                'Error event received: $eventData',
              );
              break;
            case 'heartbeat':
              HuggingFaceChatGradioUtils.logMessage(
                'Received heartbeat, continuing to wait for response',
              );
              break;
          }
        }
      }

      throw Exception('No valid response received');
    } catch (e) {
      HuggingFaceChatGradioUtils.handleException(e);
      rethrow;
    }
  }
}
