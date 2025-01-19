import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/utils/logger.dart';
import '../../view_model/map/map_controller.dart';

// TODO : 마커 2개 이은 선을 그릴 수 있는 기능 추가해야함(view model?)
class SkyMapView extends GetView<MapController> {
  const SkyMapView({super.key});

  @override
  Widget build(BuildContext context) {
    MapController controller = Get.put(MapController());
    Log.info(
        "1.sw : ${1.sw}, 1.sh : ${1.sh}, 1.w : ${1.w}, 1.h : ${1.h}, 1.sp : ${1.sp}");

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          Expanded(
            child: NaverMap(
              // 지도를 처음 그릴 때 적용할 옵션
              options: NaverMapViewOptions(
                // TODO : 화면 크기에 맞게 조정되도록 기능 추가
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
                  northEast: NLatLng(36.3763, 127.3705),
                  southWest: NLatLng(36.363, 127.355),
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
                // 제스처 설정 : 스톱 제스처만 비활성화
                rotationGesturesEnable: true,
                scrollGesturesEnable: true,
                tiltGesturesEnable: true,
                zoomGesturesEnable: true,
                stopGesturesEnable: false,
                // 네이버 로고 위치
                logoAlign: NLogoAlign.leftTop,
              ),
              // 컨트롤러에게 지도 준비 완료를 알림
              onMapReady: controller.onMapReady,
              // 맵 터치 시 로그 출력 + 원하는 좌표에 마커 추가
              onMapTapped: (point, latLng) {
                Log.info(
                    "맵 터치 - 위도: ${latLng.latitude}, 경도: ${latLng.longitude}");

                // // 터치한 위치에 새 마커 추가 (유니크한 ID를 주기 위해 timestamp 사용) -> 주석처리
                // controller.addMarker(NLatLng(latLng.latitude, latLng.longitude),
                //     'marker_${DateTime.now().millisecondsSinceEpoch}');
              },
            ),
          ),
        ],
      ),
    );
  }
}
