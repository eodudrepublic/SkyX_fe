import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../common/utils/logger.dart';
import '../model/websocket.dart';

/// WebSocketModel을 주입받아 실제 데이터 송수신 로직 담당
class WebSocketService {
  final WebSocketModel _webSocketModel;

  WebSocketService(this._webSocketModel);

  /// [connect] - 내부적으로 WebSocketModel.connect() 호출
  void connect() {
    _webSocketModel.connect();
  }

  /// [initConnection] - 필요시 인증/초기화 메시지 전송
  void initConnection() {
    // TODO: 서버가 별도 핸드셰이크 요구 시 구현
    // 예) sendMessage('Hello, I just connected with userId');
  }

  /// [sendMessage] - 채팅 용도
  /// 서버에서 data.type === "chat" 으로 구분하도록 가정
  void sendMessage(String chatMessage) {
    final chatData = {
      "type": "chat",
      "payload": chatMessage,
    };
    sendJsonMessage(chatData);
  }

  /// [sendJsonMessage] - 서버가 요구하는 JSON 구조 (type, payload)
  void sendJsonMessage(Map<String, dynamic> jsonBody) {
    try {
      final channel = _getChannel();
      if (channel != null) {
        final encoded = jsonEncode(jsonBody);
        channel.sink.add(encoded);
        Log.info('Sent JSON to server: $encoded');
      }
    } catch (e) {
      Log.error('Error sending JSON message: $e');
    }
  }

  /// [listenToMessages] - 서버가 보내는 메시지를 구독(listen)
  void listenToMessages() {
    try {
      _webSocketModel.stream.listen((data) {
        Log.info('Received from server: $data');

        // TODO: 서버에서 오는 데이터 구조에 맞춰 처리
        // final decodedData = jsonDecode(data);
        // _handleIncomingData(decodedData);
      });
    } catch (e) {
      Log.error('Error listening to messages: $e');
    }
  }

  /// [closeConnection]
  void closeConnection() {
    _webSocketModel.disconnect();
  }

  WebSocketChannel? _getChannel() {
    // _webSocketModel.stream 자체는 Stream<dynamic>이므로
    // WebSocketChannel을 직접 받을 수 있는 인터페이스는 따로 없음.
    // 단, 실사용시엔 Model 내부에서 channel을 바로 사용하는 편이 나을 수 있음.
    // 여기서는 예시상 편의 메서드만 남겨둠.
    return null;
  }
}
