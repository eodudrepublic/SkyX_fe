import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import '../../common/utils/logger.dart';
import '../../model/station_info.dart';
import '../../view/map/widget/custom_marker.dart';

class NaviController extends GetxController {
  /// 출발지, 도착지, 그리고 서버에서 받아온 경로 포인트
  late StationInfo startStation;
  late StationInfo endStation;
  late List<NLatLng> routePoints;

  /// NaverMapController
  final Rxn<NaverMapController> _naverMapController = Rxn<NaverMapController>();
  NaverMapController? get naverMapController => _naverMapController.value;

  /// 마커 목록
  final Map<String, NMarker> _markers = {};

  @override
  void onInit() {
    super.onInit();

    /// Get.arguments로부터 필요한 값들을 가져옴
    // /search에서 Get.toNamed('/navi', arguments: {...}) 형태로 넘겨줄 예정
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
      pathId: 'navi_path',
    );
  }

  /// station 마커를 추가하는 메서드
  // TODO : 출발지/도착지 마커 따로 만들어서 사용
  Future<void> addStationMarker({
    required double lat,
    required double lng,
    required String stationId,
    String captionText = '',
  }) async {
    if (naverMapController == null) return;

    // StationMarker 재사용
    final marker = StationMarker(
      lat: lat,
      lng: lng,
      stationId: stationId,
      captionText: captionText,
      infoText: '', // 필요에 따라 정보창 텍스트 추가
    );

    await naverMapController!.addOverlay(marker);
    _markers[stationId] = marker;

    Log.info("Navi Marker 추가 완료: $stationId -> ($lat, $lng)");
  }

  /// 다중 경로를 그리는 메서드
  // TODO : 디자인 수정
  Future<void> drawMultipartPaths({
    required List<List<NLatLng>> coordinatesList,
    String pathId = '',
    double width = 4.0,
    double outlineWidth = 1.0,
    Color defaultColor = Colors.blue,
    Color defaultOutlineColor = Colors.black,
  }) async {
    if (naverMapController == null) return;

    // 각 경로 세트를 NMultipartPath로 생성
    final paths = coordinatesList
        .map(
          (coords) => NMultipartPath(
            coords: coords,
            color: defaultColor,
            outlineColor: defaultOutlineColor,
          ),
        )
        .toList();

    final multipartOverlay = NMultipartPathOverlay(
      id: pathId.isNotEmpty
          ? pathId
          : 'multipart_${DateTime.now().millisecondsSinceEpoch}',
      paths: paths,
      width: width,
      outlineWidth: outlineWidth,
    );

    await naverMapController!.addOverlay(multipartOverlay);

    Log.info(
      "NaviController : 경로 표시 완료 (pathId=${multipartOverlay.info.id})",
    );
  }
}
