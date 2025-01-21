import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../common/server_url.dart';
import '../../common/utils/logger.dart';
import '../../model/station_info.dart';
import '../../model/user_model.dart';
import '../../service/kakao_login_api.dart';
import '../../service/websocket_service.dart';
import '../../model/websocket.dart';

class UserController extends GetxController {
  // Rx<AppUser?>은 반응형으로 사용자 정보를 저장합니다.
  var user = Rxn<AppUser>();
  final KakaoLoginApi kakaoLoginApi;

  // WebSocketService
  late final WebSocketService _wsService;

  UserController({required this.kakaoLoginApi});

  @override
  void onInit() {
    super.onInit();
    // 싱글톤 인스턴스로 초기화
    user.value = AppUser();

    // WebSocketModel, WebSocketService 초기화
    WebSocketModel wsModel = WebSocketModel();
    _wsService = WebSocketService(wsModel);
  }

  // 카카오 로그인
  Future<void> kakaoLogin() async {
    try {
      var kakaoUser = await kakaoLoginApi.signWithKakao();
      if (kakaoUser != null) {
        // 카카오 로그인 성공 후, AppUser 생성
        AppUser appUser = AppUser.fromKakaoUser(kakaoUser);
        user.value = appUser;

        // 1) 서버에 사용자 정보 등록 (POST)
        final bool isRegistered = await _registerUser(appUser);

        // 2) 즐겨찾기 목록 불러오기
        await StationRepository.fetchFavoriteList(appUser.id!);

        // 3) 등록 성공 시, WebSocket 연결
        if (isRegistered) {
          // 웹소켓 연결 시도
          _wsService.connect();
          // 필요 시 바로 메시지 구독도 실행
          _wsService.listenToMessages();

          // 4) 모든 과정 성공 시, '로그인 성공' 출력 및 화면 전환
          Log.info('로그인 성공');
          Get.offNamed('/map');
        } else {
          // 서버 등록 실패
          Get.snackbar('서버 오류', '사용자 정보 등록에 실패했습니다.');
        }
      } else {
        Get.snackbar('실패', '카카오 로그인이 취소되었거나 실패했습니다.');
      }
    } catch (error) {
      Log.error('로그인 중 오류가 발생했습니다: $error');
      Get.snackbar('오류', '로그인 중 오류가 발생했습니다: $error');
    }
  }

  // 로그아웃 (선택)
  Future<void> kakaoLogout() async {
    try {
      await kakaoLoginApi.logout();
      AppUser().clearUser();
      user.value = AppUser();

      // 웹소켓 연결 해제
      _wsService.closeConnection();

      Get.snackbar('성공', '로그아웃에 성공했습니다.');
    } catch (error) {
      Get.snackbar('실패', '로그아웃에 실패했습니다.');
    }
  }

  /// 사용자 정보 등록 (POST)
  Future<bool> _registerUser(AppUser appUser) async {
    // JSON Payload
    Map<String, dynamic> payload = {
      "id": appUser.id,
      "nickname": appUser.nickname ?? "",
      "profileURL": appUser.profileImageUrl ?? "",
    };

    try {
      var response = await http.post(
        Uri.parse("$serverUrl:3001/api/auth/signIn"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      Log.info("Status Code: ${response.statusCode}");
      Log.info("Response Body: ${response.body}");
      Log.info("Payload being sent: ${jsonEncode(payload)}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        String updatedAt = responseData["updatedAt"];
        Log.info("서버 전송 성공! Server updated at: $updatedAt");
        return true;
      } else {
        Log.error('서버와의 통신 중 문제가 발생했습니다. 상태 코드: ${response.statusCode}');
        Get.snackbar(
            '서버 오류', '서버와의 통신 중 문제가 발생했습니다. 상태 코드: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      Log.error('서버 전송 중 오류가 발생했습니다: $e');
      return false;
    }
  }
}
