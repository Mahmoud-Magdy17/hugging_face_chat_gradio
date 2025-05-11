import 'dart:convert';
import 'hf_chat_gradio_utils.dart';

class HuggingFaceChatGradioParser {
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
}
