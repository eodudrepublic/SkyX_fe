import 'package:get/get.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../common/utils/logger.dart';

class MapController extends GetxController {
  // NaverMapController를 담아둘 Rxn 멤버
  final Rxn<NaverMapController> _naverMapController = Rxn<NaverMapController>();
  NaverMapController? get naverMapController => _naverMapController.value;

  /// onMapReady 콜백
  /// NaverMap이 준비되면 자동으로 호출되는 함수
  void onMapReady(NaverMapController controller) {
    Log.info("네이버 맵 로딩 완료: 컨트롤러 바인딩");
    _naverMapController.value = controller;

    // 네이버 맵 초기화 작업
    /// 지도 중점 좌표(36.37075, 127.3615) 위치에 마커 추가
    addMarker(36.37075, 127.3615, 'center_marker');

    /// 지도 동북쪽 경계와 남서쪽 경계에 마커 추가
    addMarker(36.3763, 127.3705, 'northEast_bound');
    addMarker(36.363, 127.355, 'southWest_bound');
  }

  /// 특정 위도/경도에 마커를 추가하는 메서드
  Future<void> addMarker(double lat, double lng, String markerId) async {
    if (naverMapController == null) return;

    final marker = NMarker(
      id: markerId, // 마커 식별자
      position: NLatLng(lat, lng),
    );

    // addOverlay로 지도 위에 표시
    await naverMapController!.addOverlay(marker);
    Log.info("마커 추가 완료: $lat, $lng / ID: $markerId");
  }
}
