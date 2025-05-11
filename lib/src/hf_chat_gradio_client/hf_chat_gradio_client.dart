import 'package:dio/dio.dart';
import 'hf_chat_gradio_api.dart';
import 'hf_chat_gradio_utils.dart';

class HuggingFaceChatGradioClient {
  final Dio _dio;
  final String baseUrl;
  final String predictEndpoint;

  HuggingFaceChatGradioClient({
    required this.baseUrl,
    required this.predictEndpoint,
    Duration timeout = const Duration(seconds: 60),
  }) : _dio = Dio(
         BaseOptions(
           connectTimeout: timeout,
           receiveTimeout: timeout,
           headers: {'Content-Type': 'application/json'},
         ),
       );

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
}
