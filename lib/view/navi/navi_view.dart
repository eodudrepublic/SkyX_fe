import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/utils/logger.dart';
import '../../view_model/navi/navi_controller.dart';

class NaviView extends GetView<NaviController> {
  const NaviView({super.key});

  @override
  Widget build(BuildContext context) {
    /// NaviController 주입
    final NaviController naviController = Get.put(NaviController());

    /// 출발지, 도착지 좌표를 이용해 지도 제한 영역 설정
    final lat1 = naviController.startStation.lat;
    final lng1 = naviController.startStation.lng;
    final lat2 = naviController.endStation.lat;
    final lng2 = naviController.endStation.lng;

    // 지도 중점 (출발지와 도착지의 중간점)
    final centerLat = (lat1 + lat2) / 2;
    final centerLng = (lng1 + lng2) / 2;
    final center = NLatLng(centerLat, centerLng);

    // 지도 제한 영역 (southWest, northEast)
    // ※ 만약 시작점이 더 북쪽(위도↑)에 있을 수도 있으므로 min/max 처리
    final southWest = NLatLng(
      lat1 < lat2 ? lat1 : lat2,
      lng1 < lng2 ? lng1 : lng2,
    );
    final northEast = NLatLng(
      lat1 > lat2 ? lat1 : lat2,
      lng1 > lng2 ? lng1 : lng2,
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// 네이버 지도
            Positioned.fill(
              child: NaverMap(
                // 지도 옵션 (SkyMapView의 옵션 대부분 유지)
                options: NaverMapViewOptions(
                  initialCameraPosition: NCameraPosition(
                    target: center,
                    zoom: 16,
                    bearing: 0,
                    tilt: 0,
                  ),
                  extent: NLatLngBounds(
                    northEast: northEast,
                    southWest: southWest,
                  ),
                  mapType: NMapType.basic,
                  activeLayerGroups: [
                    NLayerGroup.building,
                    NLayerGroup.transit,
                    NLayerGroup.traffic,
                  ],
                  minZoom: 14.0,
                  rotationGesturesEnable: true,
                  scrollGesturesEnable: true,
                  tiltGesturesEnable: true,
                  zoomGesturesEnable: true,
                  stopGesturesEnable: false,
                  logoAlign: NLogoAlign.leftBottom,
                  logoMargin: EdgeInsets.only(bottom: 10.sp, left: 10.sp),
                ),
                onMapReady: naviController.onMapReady,
              ),
            ),

            /// 뒤로 가기 버튼
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: Icon(Icons.arrow_back, size: 30.sp),
                onPressed: () {
                  Log.info('NaviView -> 뒤로가기 (검색 화면으로)');
                  Get.back(); // /search로 복귀
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
