import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:get/get.dart';
import 'package:sky_x_fe/view/map/widget/custom_marker.dart';
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
    // /// 지도 중점 좌표 위치에 마커 추가
    // addMarker(center, 'center_marker');
    //
    // /// 지도 동북쪽 경계와 남서쪽 경계에 마커 추가
    // addMarker(northEastBound, 'northEast_bound');
    // addMarker(southWestBound, 'southWest_bound');
    //
    // // TEST 1) 북동쪽 좌표 -> 중앙 좌표 -> 남서쪽 좌표를 잇는 멀티 경로
    // drawMultipartPaths(
    //   coordinatesList: [
    //     [northEastBound, center, southWestBound],
    //   ],
    //   pathId: 'multi_center_path',
    //   width: 5.0,
    //   outlineWidth: 2.0,
    //   defaultColor: Colors.green,
    //   defaultOutlineColor: Colors.black,
    // );

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

    // TEST 3) N1 역 마커 추가
    addStationMarker(
      lat: 36.37422319491133,
      lng: 127.3657201432359,
      stationId: "N1",
      // infoText: "N1 station",
    );
  }

  /// 특정 위도/경도에 기본 마커를 추가하는 메서드
  Future<void> addMarker(NLatLng position, String markerId) async {
    if (naverMapController == null) return;

    final marker = NMarker(
      id: markerId, // 마커 식별자
      position: position,
      // caption: NOverlayCaption(text: markerId),
    );

    // addOverlay로 지도 위에 표시
    await naverMapController!.addOverlay(marker);

    // 마커 목록에 저장 (추후 infoWindow 사용 등 마커 접근을 위해)
    _markers[markerId] = marker;

    Log.info(
        "마커 추가 완료: ${position.latitude}, ${position.longitude} / ID: $markerId");
  }

  /// station 마커를 추가하는 메서드
  Future<void> addStationMarker({
    required double lat,
    required double lng,
    required String stationId,
    String captionText = '',
    String infoText = '',
  }) async {
    if (naverMapController == null) return;

    // 1) station 마커 생성
    final marker = StationMarker(
      lat: lat,
      lng: lng,
      stationId: stationId,
      captionText: captionText,
      infoText: infoText,
    );

    // 2) 터치 리스너 등록 (토글 기능)
    if (infoText.isNotEmpty) {
      marker.setOnTapListener((NMarker tappedMarker) async {
        // 현재 InfoWindow가 열려있는지 확인
        final bool isOpen = await tappedMarker.hasOpenInfoWindow();
        if (isOpen) {
          // 이미 열려 있으면 => 닫기
          final infoWindowId = 'info_${tappedMarker.info.id}';
          final infoWindowOverlay = NOverlayInfo(
            type: NOverlayType.infoWindow,
            id: infoWindowId,
          );
          // 지도에서 해당 InfoWindow를 제거하면 닫히는 효과가 난다.
          await naverMapController!.deleteOverlay(infoWindowOverlay);
        } else {
          // 닫혀 있으면 => 열기
          final infoWindow = NInfoWindow.onMarker(
            id: 'info_${tappedMarker.info.id}',
            text: infoText,
          );
          await tappedMarker.openInfoWindow(infoWindow);
        }
      });
    }

    // 3) 지도에 표시
    await naverMapController!.addOverlay(marker);

    // 4) 내부 Map에 저장
    _markers[stationId] = marker;

    Log.info("커스텀 마커 추가 완료: $lat, $lng / ID: $stationId");
  }

  //--------------------------------------------------------------------------
  // 2개의 좌표 사이에 직선을 그리는 메서드 (NPolylineOverlay)
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
  // 여러 좌표 경로를 잇는 멀티 경로(다중 경로)를 그리는 메서드 : NMultipartPathOverlay 사용
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
