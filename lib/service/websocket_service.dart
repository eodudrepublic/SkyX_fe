import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../common/utils/logger.dart';
import '../model/websocket.dart';

/// - 웹소캣 서버와 연결된 채널을 통해 실제 데이터 송수신 로직을 담당.
/// - Model(WebSocketModel)로부터 WebSocketChannel을 주입받아 사용.
/// - TODO: 서버와의 프로토콜(메시지 구조 등)이 확정되면 아래 메서드들을 구현.
class WebSocketService {
  /// ------------------------- Members ------------------------- ///
  /// WebSocketModel을 통해 얻은 WebSocketChannel.
  /// (외부에서 WebSocketModel을 주입받거나 내부에서 생성해서 사용할 수 있음)
  final WebSocketModel _webSocketModel;

  /// 읽기 전용 Getter
  WebSocketChannel? get _channel {
    // 현재 _webSocketModel.stream 이 WebSocketChannel로 캐스팅이 안 되면 null
    if (_webSocketModel.stream is WebSocketChannel) {
      return _webSocketModel.stream as WebSocketChannel;
    }
    return null;
  }

  /// ---------------------- Constructor ---------------------- ///
  /// WebSocketModel을 주입받아 WebSocketService 생성
  WebSocketService(this._webSocketModel);

  /// ---------------------- Functions ----------------------- ///

  /// [connect]
  /// - 외부에서 WebSocketModel.connect()를 호출
  void connect() {
    _webSocketModel.connect();
  }

  /// [initConnection]
  /// - 필요 시 인증이나 초기 구독 요청 등을 추가할 수 있음
  void initConnection() {
    // 예: 서버가 별도의 핸드셰이크 메세지를 요구하지 않는다면 비워둬도 됩니다.
    // 예: sendMessage('Hello, I just connected with userId');
    // TODO : 근데 핸드쉐이크해야 이후 데이터 송수신에 문제가 없을것 같음
  }

  /// [listenToMessages]
  /// - Model의 `stream`을 구독(subscribe)하여 서버가 보내는 메세지를 처리.
  void listenToMessages() {
    try {
      _webSocketModel.stream.listen((data) {
        // 서버로부터 전달된 데이터 처리
        Log.info('Received from server: $data');

        // TODO: data가 JSON 형식이라면 decode 후 로직 수행
        // final decodedData = jsonDecode(data);
        // handleIncomingData(decodedData);
      });
    } catch (e) {
      // 에러 처리 로직
      Log.error('Error listening to messages: $e');
    }
  }

  /// [sendMessage]
  /// - 서버로 메시지를 보내는 기본 메서드.
  /// - 문자열(String) 형태로 메시지를 전송.
  void sendMessage(String message) {
    try {
      if (_channel != null) {
        _channel!.sink.add(message);
        Log.info('Sent to server: $message');
      } else {
        Log.warning('Channel is not available.');
      }
    } catch (e) {
      Log.error('Error sending message: $e');
    }
  }

  /// [sendJsonMessage]
  /// - 서버로 JSON 형태의 메시지를 전송.
  /// - JSON 인코딩을 거쳐 서버에 전달.
  void sendJsonMessage(Map<String, dynamic> jsonBody) {
    try {
      if (_channel != null) {
        final encoded = jsonEncode(jsonBody);
        _channel!.sink.add(encoded);
        Log.info('Sent JSON to server: $encoded');
      } else {
        Log.warning('Channel is not available.');
      }
    } catch (e) {
      Log.error('Error sending JSON message: $e');
    }
  }

  /// [closeConnection]
  /// - 웹소캣 연결을 종료할 때 사용하는 메서드.
  /// - 실제 종료 로직은 Model에 위임.
  void closeConnection() {
    _webSocketModel.disconnect();
  }

  /// ---------------------- Private Helper Methods ---------------------- ///
  // TODO: handleIncomingData(Map<String, dynamic> data) {
  //   // 서버에서 오는 데이터 구조에 따라 적절히 구현
  // }

  // TODO: sendAuthToken(String token) {
  //   // 인증 토큰 전송 로직 구현
  // }
}
