import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sky_x_fe/common/app_colors.dart';
import '../../common/utils/logger.dart';
import '../../view_model/map/map_controller.dart';

class SkyMapView extends GetView<MapController> {
  const SkyMapView({super.key});

  @override
  Widget build(BuildContext context) {
    MapController controller = Get.put(MapController());

    return Scaffold(
      // TODO : SafeArea로 해놓긴 했는데 키보드 올라왔을때 입력창 부분 어떻게 되는지 확인해봐야함
      body: SafeArea(
        child: Stack(
          children: [
            /// 네이버 지도
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
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
                  logoAlign: NLogoAlign.leftBottom,
                  logoMargin: EdgeInsets.only(bottom: 10.sp, left: 10.sp),
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

            Positioned(
                top: 0,
                right: 0,
                // TODO : 경로 탐색 버튼 스타일 수정 필요
                child: Container(
                  padding: EdgeInsets.only(top: 10.sp, right: 10.sp),
                  child: GestureDetector(
                    onTap: () {
                      Log.info('경로 탐색 버튼 클릭 : map -> search');
                      Get.toNamed('/search');
                    },
                    child: Icon(
                      Icons.search,
                      size: 50.sp,
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
