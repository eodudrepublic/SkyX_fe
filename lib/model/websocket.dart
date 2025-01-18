import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'user_model.dart';
import '../common/utils/logger.dart';

/// 웹소켓 서버와의 연결, 연결 해제를 담당하는 Model 클래스.
/// - 서버와의 연결 시도
/// - 연결 해제(닫기)
/// - 메세지 스트림 제공
class WebSocketModel {
  /// ------------------------- Members ------------------------- ///
  /// 웹소캣 서버의 기본 URL
  late String _baseUrl;

  final AppUser _appUser = AppUser();

  /// 실제 WebSocket 통신을 담당하는 WebSocketChannel
  WebSocketChannel? _channel;

  /// 연결 상태 변화를 감지하기 위한 StreamController
  /// (연결 성공/실패 여부 등을 UI 쪽에서 Listen할 수 있게 해줌)
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  /// ---------------------- Constructor ---------------------- ///
  /// 생성 시점에 WS의 기본 URL을 설정
  WebSocketModel(String baseUrl) {
    _baseUrl = baseUrl;
  }

  /// ---------------------- Getter / Setter ---------------------- ///
  /// 웹소캣 서버의 기본 URL Getter
  String get baseUrl => _baseUrl;

  /// 웹소캣 서버의 기본 URL Setter
  set baseUrl(String url) {
    Log.trace('WebSocketModel: URL changed $_baseUrl -> $url');
    _baseUrl = url;
  }

  /// 웹소켓에서 전달되는 데이터를 들을 수 있는 Stream.
  /// (연결이 안 되어있으면 예외 처리)
  Stream<dynamic> get stream {
    if (_channel != null) {
      Log.info('WebSocketModel: Stream connected');
      return _channel!.stream;
    } else {
      Log.error('WebSocketModel: Stream not connected');
      throw WebSocketChannelException(
          'WebSocketChannel is not initialized or connection failed.');
    }
  }

  /// 연결 상태 여부를 외부에서 구독할 수 있는 Stream
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// ---------------------- Functions ----------------------- ///

  /// [connectWithUserId]
  /// - 카카오 로그인 후 획득한 kakao_id(= user_id)를 파라미터로 받아,
  ///   ws://...:port/...?user_id={kakaoId} 형태의 URL로 웹소켓 연결 시도
  /// - 연결 성공 시, 내부 스트림에 연결 성공(true) 값을 전달
  void connect() {
    String? userId = _appUser.id;
    try {
      // userId 파라미터를 쿼리로 붙여서 최종 URL 완성
      final fullUrl = '$_baseUrl?user_id=$userId';

      _channel = WebSocketChannel.connect(Uri.parse(fullUrl));
      Log.info('WebSocketModel: Connected to $fullUrl');

      // 연결 성공 시 true 전달
      _connectionStatusController.add(true);
    } catch (e) {
      Log.error('WebSocketModel: Connection failed: $e');
      // 연결 실패 시 false 전달
      _connectionStatusController.add(false);
      rethrow;
    }
  }

  /// [disconnect]
  /// - 웹소캣 연결 해제
  /// - 연결이 정상적으로 닫히면, 내부 스트림에 연결 해제(false) 값을 전달
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.normalClosure);
      _connectionStatusController.add(false);
      _channel = null; // 채널도 null 처리
      Log.info('WebSocketModel: Disconnected from $_baseUrl');
    }
  }

  /// [dispose]
  /// - 객체(모델) 사용 종료 시, StreamController를 닫아줌
  /// - 예: GetX Controller 또는 Provider에서 onClose() 시점 등
  void dispose() {
    _connectionStatusController.close();
  }
}
