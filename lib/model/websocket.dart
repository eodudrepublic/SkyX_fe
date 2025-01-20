import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../common/server_url.dart';
import 'user_model.dart';
import '../common/utils/logger.dart';

/// 웹소켓 서버와의 연결, 연결 해제를 담당하는 Model 클래스.
class WebSocketModel {
  /// ------------------------- Members ------------------------- ///
  final AppUser _appUser = AppUser();

  /// 실제 WebSocket 통신을 담당하는 WebSocketChannel
  WebSocketChannel? _channel;

  /// 연결 상태 변화를 감지하기 위한 StreamController
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  /// ---------------------- Constructor ---------------------- ///
  WebSocketModel();

  /// [stream] - 웹소켓에서 전달되는 데이터를 들을 수 있는 Stream
  /// 연결이 안 되어있으면 빈 스트림 반환
  Stream<dynamic> get stream {
    if (_channel != null) {
      return _channel!.stream;
    } else {
      Log.error('WebSocketModel: Stream not connected');
      return const Stream.empty();
    }
  }

  /// 연결 상태 여부를 외부에서 구독할 수 있는 Stream
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// ---------------------- Functions ----------------------- ///

  /// [connect]
  /// - Kakao 로그인으로 획득한 user_id를 쿼리로 붙여 웹소켓 연결 시도
  void connect() {
    String? userId = _appUser.id;
    if (userId == null || userId.isEmpty) {
      Log.error('WebSocketModel: userId is null or empty, cannot connect.');
      _connectionStatusController.add(false);
      return;
    }

    try {
      final fullUrl = '$wsServerUrl:3001/ws?user_id=$userId';

      _channel = WebSocketChannel.connect(Uri.parse(fullUrl));
      Log.info('WebSocketModel: Connected to $fullUrl');

      // 연결 성공 시 true 전달
      _connectionStatusController.add(true);
    } catch (e) {
      Log.error('WebSocketModel: Connection failed: $e');
      _connectionStatusController.add(false);
      rethrow;
    }
  }

  /// [disconnect]
  /// - 웹소캣 연결 해제
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.normalClosure);
      _connectionStatusController.add(false);
      _channel = null;
      Log.info('WebSocketModel: Disconnected from $wsServerUrl');
    }
  }

  /// [dispose]
  /// - Model 객체 사용 종료 시, StreamController 닫기
  void dispose() {
    disconnect(); // 혹은 여기서만 close()를 호출해도 됨
    _connectionStatusController.close();
  }
}
