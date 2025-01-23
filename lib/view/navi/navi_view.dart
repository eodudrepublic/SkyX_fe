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
    // NaviController 주입
    final NaviController naviController = Get.put(NaviController());

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// NaverMap
            Positioned.fill(
              child: NaverMap(
                options: NaverMapViewOptions(
                  // initialCameraPosition은 onMapReady 이후에 따로 update할 수도 있지만
                  // 여기선 초기값(출발지 좌표, tilt=50, bearing=경로방향)을 지정해두어도 OK
                  // 일단 아래는 dummy로만 두고, 실제는 onMapReady에서 _moveCameraTo 호출
                  initialCameraPosition: NCameraPosition(
                    target: const NLatLng(36.3742231949, 127.3657201432),
                    zoom: 16,
                    bearing: 0,
                    tilt: 0,
                  ),
                  activeLayerGroups: [
                    NLayerGroup.building,
                    NLayerGroup.traffic,
                  ],
                  minZoom: 10,
                  maxZoom: 19,
                  // 지도 로고 위치
                  logoAlign: NLogoAlign.leftBottom,
                  logoMargin: EdgeInsets.only(left: 10.sp, bottom: 10.sp),
                ),
                onMapReady: (controller) =>
                    naviController.onMapReady(controller),
              ),
            ),

            /// 상단 AppBar 영역
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                  color: Colors.white,
                  height: 0.07.sh,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.sp),

                        /// 뒤로가기 아이콘
                        child: GestureDetector(
                          onTap: () {
                            Log.info('NaviView -> 뒤로가기 (경로 화면으로)');
                            Get.back();
                          },
                          child: Icon(
                            Icons.arrow_back,
                            size: 30.sp,
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
