import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/utils/logger.dart';
import '../../view_model/map/map_controller.dart';

class SkyMapView extends GetView<MapController> {
  const SkyMapView({super.key});

  @override
  Widget build(BuildContext context) {
    MapController controller = Get.put(MapController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.05.sw),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 0.1.sh),
            SizedBox(
              height: 0.9.sw,
              width: 0.9.sw,
              child: NaverMap(
                // 지도를 처음 그릴 때 적용할 옵션
                options: NaverMapViewOptions(
                  initialCameraPosition: NCameraPosition(
                    // 중점 좌표 : 수정해야할까?
                    target: NLatLng(36.37075, 127.3615),
                    // 지도 확대 수준 : 평면에선 14.4가 적당한듯
                    zoom: 14.4,
                    // 카메라 방향 (0 : 북쪽)
                    bearing: 0,
                    // 두 손가락을 위로 밀면 지도가 기울어짐!
                    tilt: 0,
                  ),
                  // 지도의 제한 영역
                  extent: NLatLngBounds(
                    northEast: NLatLng(36.372, 127.365),
                    southWest: NLatLng(36.367, 127.359),
                    // 실제 영역 경계
                    // TODO : 다른 폰으로 테스트해보면서 지도 어떻게 보이는지 확인
                    // northEast: NLatLng(36.3763, 127.3705),
                    // southWest: NLatLng(36.363, 127.355),
                  ),
                  // 지도 유형
                  mapType: NMapType.basic,
                  // 표시할 레이어
                  activeLayerGroups: [
                    NLayerGroup.building,
                    NLayerGroup.transit,
                    NLayerGroup.traffic,
                  ],
                  // 최소 줌 레벨 : 14
                  minZoom: 14.0,
                ),
                // 컨트롤러에게 지도 준비 완료를 알림
                onMapReady: controller.onMapReady,
                // 맵 터치 시 로그 출력 + 원하는 좌표에 마커 추가
                onMapTapped: (point, latLng) {
                  Log.info(
                      "맵 터치 - 위도: ${latLng.latitude}, 경도: ${latLng.longitude}");

                  // 터치한 위치에 새 마커 추가 (유니크한 ID를 주기 위해 timestamp 사용)
                  controller.addMarker(latLng.latitude, latLng.longitude,
                      'marker_${DateTime.now().millisecondsSinceEpoch}');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
