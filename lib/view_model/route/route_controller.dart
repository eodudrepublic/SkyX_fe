import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import '../../common/app_colors.dart';
import '../../common/utils/logger.dart';
import '../../model/station_info.dart';
import '../../model/websocket.dart';
import '../../service/websocket_service.dart';
import '../../view/map/widget/custom_marker.dart';

class RouteController extends GetxController {
  /// 출발지, 도착지, 그리고 서버에서 받아온 경로 포인트
  late StationInfo startStation;
  late StationInfo endStation;
  late List<NLatLng> routePoints;

  /// NaverMapController
  final Rxn<NaverMapController> _naverMapController = Rxn<NaverMapController>();
  NaverMapController? get naverMapController => _naverMapController.value;

  /// 마커 목록
  final Map<String, NMarker> _markers = {};

  /// WebSocket 통신 객체
  final WebSocketService _wsService = Get.find<WebSocketService>();

  @override
  void onInit() {
    super.onInit();

    /// Get.arguments로부터 필요한 값들을 가져옴
    // /search에서 Get.toNamed('/route', arguments: {...}) 형태로 넘겨줄 예정
    final args = Get.arguments;
    if (args == null ||
        args['startStation'] == null ||
        args['endStation'] == null ||
        args['routePoints'] == null) {
      Log.error("NaviController -> Missing arguments. Check your route setup.");
      return;
    }

    startStation = args['startStation'] as StationInfo;
    endStation = args['endStation'] as StationInfo;
    routePoints = args['routePoints'] as List<NLatLng>;
  }

  /// 지도 준비 완료 콜백
  Future<void> onMapReady(NaverMapController controller) async {
    _naverMapController.value = controller;

    // 출발지/도착지 마커 표시
    await addStationMarker(
      lat: startStation.lat,
      lng: startStation.lng,
      stationId: 'start_marker',
      captionText: '출발',
    );
    await addStationMarker(
      lat: endStation.lat,
      lng: endStation.lng,
      stationId: 'end_marker',
      captionText: '도착',
    );

    // 경로 표시 (단일 경로라면 coordinatesList에 routePoints 하나만 넣으면 됨)
    await drawMultipartPaths(
      coordinatesList: [routePoints],
    );
  }

  /// 출발지/도착지 마커를 추가하는 메서드
  Future<void> addStationMarker({
    required double lat,
    required double lng,
    required String stationId,
    required String captionText,
  }) async {
    if (naverMapController == null) return;

    final marker = PlaceMarker(
      lat: lat,
      lng: lng,
      placeId: stationId,
      captionText: captionText,
    );

    await naverMapController!.addOverlay(marker);
    _markers[stationId] = marker;

    Log.info("Navi Marker 추가 완료: $stationId -> ($lat, $lng)");
  }

  /// 다중 경로를 그리는 메서드
  // TODO : 디자인 수정
  Future<void> drawMultipartPaths({
    required List<List<NLatLng>> coordinatesList,
    double width = 4.0,
    double outlineWidth = 1.0,
  }) async {
    if (naverMapController == null) return;

    // 각 경로 세트를 NMultipartPath로 생성
    final paths = coordinatesList
        .map(
          (coords) => NMultipartPath(
            coords: coords,
            color: AppColors.instance.kaistBlue,
            outlineColor: AppColors.instance.kaistMediumBlue,
          ),
        )
        .toList();

    final multipartOverlay = NMultipartPathOverlay(
      id: 'navi_path_${DateTime.now().millisecondsSinceEpoch}',
      paths: paths,
      width: width,
      outlineWidth: outlineWidth,
    );

    await naverMapController!.addOverlay(multipartOverlay);

    Log.info(
      "NaviController : 경로 표시 완료 (pathId=${multipartOverlay.info.id})",
    );
  }

  /// 웹소캣 서버로 "startAnimation" 전송
  void sendStartNavigation() {
    Log.info("WebSocket : sendStartNavigation");
    final body = {
      "type": "startNavigation",
      "payload": {
        "latitude": 0,
        "longitude": 0,
        "altitude": 0,
      }
    };
    _wsService.sendJsonMessage(body);
  }
}
