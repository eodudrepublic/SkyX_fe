import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import '../../common/utils/logger.dart';

class MapController extends GetxController {
  // NaverMapController를 담아둘 Rxn 멤버
  final Rxn<NaverMapController> _naverMapController = Rxn<NaverMapController>();
  NaverMapController? get naverMapController => _naverMapController.value;

  // 좌표 상수
  static const NLatLng center = NLatLng(36.37075, 127.3615);
  static const NLatLng northEastBound = NLatLng(36.3763, 127.3705);
  static const NLatLng southWestBound = NLatLng(36.363, 127.355);

  // 등록된 마커를 저장해둘 Map
  // - 마커 아이디를 키(key)로 하고, 마커 객체를 값(value)으로 저장
  final Map<String, NMarker> _markers = {};

  /// onMapReady 콜백 : NaverMap이 준비되면 자동으로 호출되는 함수
  void onMapReady(NaverMapController controller) {
    Log.info("네이버 맵 로딩 완료: 컨트롤러 바인딩");
    _naverMapController.value = controller;

    // 네이버 맵 초기화 작업
    /// 지도 중점 좌표 위치에 마커 추가
    addMarker(center, 'center_marker');

    /// 지도 동북쪽 경계와 남서쪽 경계에 마커 추가
    addMarker(northEastBound, 'northEast_bound');
    addMarker(southWestBound, 'southWest_bound');

    // TEST 1) 북동쪽 좌표 -> 중앙 좌표 -> 남서쪽 좌표를 잇는 멀티 경로
    drawMultipartPaths(
      coordinatesList: [
        [northEastBound, center, southWestBound],
      ],
      pathId: 'multi_center_path',
      width: 5.0,
      outlineWidth: 2.0,
      defaultColor: Colors.green,
      defaultOutlineColor: Colors.black,
    );

    // // TEST 2) 북동쪽 좌표 <-> 남서쪽 좌표 두 점을 직선으로 연결
    // drawLineBetween(
    //   startLat: northEastBound.latitude,
    //   startLng: northEastBound.longitude,
    //   endLat: southWestBound.latitude,
    //   endLng: southWestBound.longitude,
    //   lineId: 'line_NE_SW',
    //   color: Colors.red,
    //   width: 4.0,
    // );
  }

  /// 특정 위도/경도에 마커를 추가하는 기본 메서드
  /// - (커스텀 아이콘이 아닌) 기본 마커 아이콘으로 표시
  Future<void> addMarker(NLatLng position, String markerId) async {
    if (naverMapController == null) return;

    final marker = NMarker(
      id: markerId, // 마커 식별자
      position: position,
    );

    // addOverlay로 지도 위에 표시
    await naverMapController!.addOverlay(marker);

    // 마커 목록에 저장 (추후 infoWindow 사용 등 마커 접근을 위해)
    _markers[markerId] = marker;

    Log.info(
        "마커 추가 완료: ${position.latitude}, ${position.longitude} / ID: $markerId");
  }

  //--------------------------------------------------------------------------
  // (1) 마커 디자인을 설정하는 메서드
  //     - Widget을 이용해 마커 이미지를 생성 (NOverlayImage.fromWidget)
  //     - 직접 만든 widget 아이콘을 마커에 적용해준다.
  //--------------------------------------------------------------------------
  Future<void> addCustomMarker({
    required double lat,
    required double lng,
    required String markerId,
    required Widget markerWidget,
    required BuildContext context, // fromWidget 호출 시 필요
    Size size = const Size(48, 48),
  }) async {
    if (naverMapController == null) return;

    // 1) widget -> NOverlayImage 변환
    final overlayImage = await NOverlayImage.fromWidget(
      widget: markerWidget,
      size: size,
      context: context,
    );

    // 2) 커스텀 아이콘 마커 생성
    final marker = NMarker(
      id: markerId,
      position: NLatLng(lat, lng),
      icon: overlayImage,
    );

    // 3) 지도에 표시
    await naverMapController!.addOverlay(marker);

    // 4) 마커 목록에 저장
    _markers[markerId] = marker;

    Log.info("커스텀 마커 추가 완료: $lat, $lng / ID: $markerId");
  }

  //--------------------------------------------------------------------------
  // (2) 마커에 정보창(NInfoWindow)을 띄우는 메서드
  //--------------------------------------------------------------------------
  Future<void> showMarkerInfoWindow(String markerId, String infoText) async {
    if (naverMapController == null) return;

    // 현재 등록된 마커 목록에서 아이디로 마커를 찾아온다.
    final marker = _markers[markerId];
    if (marker == null) {
      Log.warning("마커($markerId)가 존재하지 않습니다. 먼저 마커를 추가해주세요.");
      return;
    }

    // 1) 마커에 표시할 정보창 생성
    //    - onMarker 생성자를 사용해야 마커 위에 정상적으로 붙는다.
    final infoWindow = NInfoWindow.onMarker(
      id: 'info_$markerId', // 정보창 id. markerId와 구분되게 해도 좋다.
      text: infoText,
    );

    // 2) 마커에 정보창 표시
    await marker.openInfoWindow(infoWindow);

    Log.info("마커($markerId)에 정보창 표시 완료: $infoText");
  }

  //--------------------------------------------------------------------------
  // (3) 2개의 좌표 사이에 직선을 그리는 메서드 (NPolylineOverlay)
  //--------------------------------------------------------------------------
  Future<void> drawLineBetween({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String lineId = '',
    Color color = Colors.red,
    double width = 4.0,
  }) async {
    if (naverMapController == null) return;

    // NPolylineOverlay 생성
    final polyline = NPolylineOverlay(
      // id가 없다면 임의로 만들어줌
      id: lineId.isNotEmpty
          ? lineId
          : 'line_${DateTime.now().millisecondsSinceEpoch}',
      coords: [
        NLatLng(startLat, startLng),
        NLatLng(endLat, endLng),
      ],
      color: color,
      width: width,
    );

    // 지도에 추가
    await naverMapController!.addOverlay(polyline);

    Log.info(
      "직선 추가 완료: start($startLat, $startLng) ~ end($endLat, $endLng), id=${polyline.info.id}",
    );
  }

  //--------------------------------------------------------------------------
  // (4) 여러 좌표 경로를 잇는 멀티 경로(다중 경로)를 그리는 메서드
  //     - NMultipartPathOverlay 사용
  //--------------------------------------------------------------------------
  Future<void> drawMultipartPaths({
    required List<List<NLatLng>> coordinatesList,
    String pathId = '',
    double width = 4.0,
    double outlineWidth = 1.0,
    Color defaultColor = Colors.blue,
    Color defaultOutlineColor = Colors.black,
  }) async {
    if (naverMapController == null) return;

    // 경로 세트(List<NLatLng>)를 NMultipartPath 형태로 변환
    final paths = coordinatesList
        .map(
          (coords) => NMultipartPath(
            coords: coords,
            color: defaultColor,
            outlineColor: defaultOutlineColor,
          ),
        )
        .toList();

    // 멀티파트 경로 오버레이 생성
    final multipartOverlay = NMultipartPathOverlay(
      id: pathId.isNotEmpty
          ? pathId
          : 'multipart_${DateTime.now().millisecondsSinceEpoch}',
      paths: paths,
      width: width,
      outlineWidth: outlineWidth,
    );

    // 지도에 추가
    await naverMapController!.addOverlay(multipartOverlay);

    Log.info(
      "멀티 경로 추가 완료: pathId=${multipartOverlay.info.id}, 총 경로 수=${paths.length}",
    );
  }
}
