import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import '../../common/app_colors.dart';
import '../../common/utils/logger.dart';
import '../../model/station_info.dart';
import '../../service/websocket_service.dart';
import '../../view/map/widget/custom_marker.dart';

/// /navi 페이지 전용 컨트roller
class NaviController extends GetxController {
  /// 외부(서버)에서 받아온 경로 좌표 리스트
  late final List<NLatLng> routePoints;

  /// 출발지, 도착지 정보
  late final StationInfo startStation;
  late final StationInfo endStation;

  /// 네이버맵 컨트롤러 (onMapReady에서 주입)
  final Rxn<NaverMapController> _naverMapController = Rxn<NaverMapController>();
  NaverMapController? get naverMapController => _naverMapController.value;

  /// 경로 전체 길이
  int get totalRouteSize => routePoints.length;

  /// 현재 몇 번째 좌표까지 이동했는지 인덱스를 관리
  int _currentIndex = 0;

  /// 사용자 마커 (현재 위치 표시)
  UserMarker? _userMarker;

  /// 이미 지난 경로는 kaistDarkGray, 남은 경로는 kaistBlue로 표현하기 위해
  /// 2개의 pathOverlay (다중 경로용) 사용
  NMultipartPathOverlay? _partialPathOverlay;

  /// WebSocket 통신 객체
  final WebSocketService _wsService = Get.find<WebSocketService>();

  /// Timer - 1초마다 routePoints를 따라 이동시키기 위함
  Timer? _moveTimer;

  @override
  void onInit() {
    super.onInit();

    /// /route → /navi 로 넘어올 때, Get.arguments로부터 routePoints, startStation, endStation을 받는다.
    final args = Get.arguments;
    if (args == null) {
      Log.error("[NaviController] arguments is null. Check route push.");
      return;
    }

    routePoints = args['routePoints'] as List<NLatLng>;
    startStation = args['startStation'] as StationInfo;
    endStation = args['endStation'] as StationInfo;

    Log.info(
        "[NaviController onInit] routePoints.length=${routePoints.length}, "
        "start=${startStation.name}, end=${endStation.name}");
  }

  /// 지도가 준비되면 호출
  Future<void> onMapReady(NaverMapController controller) async {
    Log.info("[NaviController onMapReady]");
    _naverMapController.value = controller;

    // 1) 출발지 마커
    Log.info("Add startMarker @(${startStation.lat}, ${startStation.lng})");
    final startMarker = PlaceMarker(
      lat: startStation.lat,
      lng: startStation.lng,
      placeId: 'start_marker',
      captionText: '출발',
    );
    await controller.addOverlay(startMarker);

    // 2) 도착지 마커
    Log.info("Add endMarker @(${endStation.lat}, ${endStation.lng})");
    final endMarker = PlaceMarker(
      lat: endStation.lat,
      lng: endStation.lng,
      placeId: 'end_marker',
      captionText: '도착',
    );
    await controller.addOverlay(endMarker);

    // 3) 유저 마커 (초기 위치 = routePoints[0], 즉 출발점)
    if (routePoints.isNotEmpty) {
      final firstPos = routePoints[0];
      _userMarker = UserMarker(
        lat: firstPos.latitude,
        lng: firstPos.longitude,
      );
      Log.info("Add userMarker @(${firstPos.latitude}, ${firstPos.longitude})");
      await controller.addOverlay(_userMarker!);
    } else {
      Log.warning(
          "[NaviController] routePoints is empty. No userMarker created.");
    }

    // 4) 처음 경로 표시 (처음엔 지나온 경로가 없으므로 남은 경로만 파란색)
    _partialPathOverlay = await _drawMultiPartPaths(controller, 0);

    // 5) 카메라 이동
    if (routePoints.length > 1) {
      final double initBearing =
          _calculateBearing(routePoints[0], routePoints[1]);
      await _moveCameraTo(
        target: routePoints[0],
        zoom: 16,
        bearing: initBearing,
        tilt: 50,
      );
    } else if (routePoints.isNotEmpty) {
      // 점이 1개만 있는 경우
      await _moveCameraTo(
        target: routePoints[0],
        zoom: 16,
        bearing: 0,
        tilt: 50,
      );
    }

    // 6) 1초 간격 타이머 시작
    _moveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _moveNextStep();
    });
  }

  /// 한 단계(1초) 이동
  Future<void> _moveNextStep() async {
    Log.info(
        "[_moveNextStep] currentIndex=$_currentIndex / total=$totalRouteSize");
    if (_currentIndex >= totalRouteSize - 1) {
      _arriveAtDestination();
      return;
    }

    // 다음 위치로 이동
    _currentIndex++;

    final nextPos = routePoints[_currentIndex];
    Log.info("[_moveNextStep] Move userMarker to index=$_currentIndex => "
        "(${nextPos.latitude}, ${nextPos.longitude})");

    if (naverMapController == null || _userMarker == null) {
      Log.error("[_moveNextStep] naverMapController or _userMarker is null");
      return;
    }

    // 1) 유저 마커 position 업데이트 : 오버레이 수정 시 remove→재추가
    await naverMapController!.deleteOverlay(_userMarker!.info);
    _userMarker = UserMarker(lat: nextPos.latitude, lng: nextPos.longitude);
    await naverMapController!.addOverlay(_userMarker!);

    // 2) 웹소켓 서버로 위치 전송 (type: "updateLocation")
    _sendLocationViaWebSocket(nextPos.latitude, nextPos.longitude);

    // 3) 이미 지난 경로(0 ~ _currentIndex) = 회색, 남은 경로(_currentIndex ~ 끝) = 파란색
    _partialPathOverlay =
        await _drawMultiPartPaths(naverMapController!, _currentIndex);

    // 4) 카메라 bearing 변경 (이동 방향)
    if (_currentIndex < totalRouteSize - 1) {
      final nextNextPos = routePoints[_currentIndex + 1];
      final bearing = _calculateBearing(nextPos, nextNextPos);

      // 카메라 이동 (bearing만 변경)
      await _moveCameraTo(
        target: nextPos,
        zoom: 16,
        bearing: bearing,
        tilt: 50,
      );
    } else {
      // 더 이상 다음 지점이 없으면 도착 처리
      _arriveAtDestination();
    }
  }

  /// 도착 처리 (도착 시점에 알림 / Snackbar / Dialog 등)
  void _arriveAtDestination() {
    _moveTimer?.cancel();
    _moveTimer = null;

    Get.snackbar('안내', '목적지에 도착했습니다!');
    Log.info("NaviController: Arrived at destination.");
  }

  /// 멀티파트 경로 그리기
  /// - visitedIndex까지의 경로는 회색
  /// - visitedIndex~끝까지는 파란색
  Future<NMultipartPathOverlay> _drawMultiPartPaths(
    NaverMapController controller,
    int visitedIndex,
  ) async {
    Log.info(
        "[_drawMultiPartPaths] visitedIndex=$visitedIndex, total=$totalRouteSize");
    // 이전 pathOverlay 삭제
    if (_partialPathOverlay != null) {
      await controller.deleteOverlay(_partialPathOverlay!.info);
    }

    final visitedPath = routePoints.sublist(0, visitedIndex + 1);
    final remainingPath = routePoints.sublist(visitedIndex, totalRouteSize);

    Log.info(
        "  -> visitedPath.length=${visitedPath.length}, remainingPath.length=${remainingPath.length}");

    // 최소 2점 이상인 경우에만 path 리스트에 추가
    final List<NMultipartPath> pathList = [];

    if (visitedPath.length >= 2) {
      pathList.add(
        NMultipartPath(
          coords: visitedPath,
          color: AppColors.instance.kaistDarkGray,
          outlineColor: AppColors.instance.kaistDarkGray,
        ),
      );
    }

    // remainingPath가 점이 2개 이상일 때만 그리기
    if (remainingPath.length >= 2) {
      pathList.add(
        NMultipartPath(
          coords: remainingPath,
          color: AppColors.instance.kaistBlue,
          outlineColor: AppColors.instance.kaistMediumBlue,
        ),
      );
    }

    // 만약 두 경로가 모두 없다면, 그냥 return 처리할 수도 있음
    if (pathList.isEmpty) {
      Log.warning("[_drawMultiPartPaths] pathList is empty. No line to draw.");
      // 여기서 바로 return 해버리거나, 임시 overlay 반환
      return _partialPathOverlay ??
          NMultipartPathOverlay(id: "empty", paths: []);
    }

    final multiPathOverlay = NMultipartPathOverlay(
      id: 'navi_path_${DateTime.now().millisecondsSinceEpoch}',
      paths: pathList,
      width: 4.0,
      outlineWidth: 2.0,
    );

    await controller.addOverlay(multiPathOverlay);
    Log.info(
        "[_drawMultiPartPaths] => created overlay: ${multiPathOverlay.info.id}");
    return multiPathOverlay;
  }

  /// 카메라를 특정 좌표로 이동시키되, bearing/tilt도 함께 조정
  Future<void> _moveCameraTo({
    required NLatLng target,
    required double zoom,
    double bearing = 0,
    double tilt = 0,
  }) async {
    Log.info(
        "[_moveCameraTo] target=($target), zoom=$zoom, bearing=$bearing, tilt=$tilt");
    if (naverMapController == null) return;

    final cameraUpdate = NCameraUpdate.withParams(
      target: target,
      zoom: zoom,
      bearing: bearing,
      tilt: tilt,
    );

    // 애니메이션 효과: 반드시 named parameter로
    cameraUpdate.setAnimation(
      animation: NCameraAnimation.easing,
      duration: const Duration(milliseconds: 800),
    );

    await naverMapController!.updateCamera(cameraUpdate);
  }

  /// 두 좌표 (A → B) 사이의 bearing(0도=북쪽)을 계산
  double _calculateBearing(NLatLng from, NLatLng to) {
    final lat1 = _deg2rad(from.latitude);
    final lon1 = _deg2rad(from.longitude);
    final lat2 = _deg2rad(to.latitude);
    final lon2 = _deg2rad(to.longitude);
    final dLon = lon2 - lon1;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x);
    double bearingDeg = _rad2deg(bearing);
    bearingDeg = (bearingDeg + 360) % 360;
    return bearingDeg;
  }

  double _deg2rad(double deg) => deg * math.pi / 180.0;
  double _rad2deg(double rad) => rad * 180.0 / math.pi;

  /// 서버로 위치 전송
  void _sendLocationViaWebSocket(double lat, double lng) {
    Log.info("[_sendLocationViaWebSocket] lat=$lat, lng=$lng");
    final body = {
      "type": "updateLocation",
      "payload": {
        "latitude": lat,
        "longitude": lng,
        // TODO : 이거 0이여도 되냐??
        "altitude": 0,
      }
    };

    _wsService.sendJsonMessage(body);
  }

  @override
  void onClose() {
    _moveTimer?.cancel();
    _moveTimer = null;
    super.onClose();
  }
}
