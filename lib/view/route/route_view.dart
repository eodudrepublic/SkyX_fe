import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import '../../common/app_colors.dart';
import '../../common/utils/logger.dart';
import '../../view_model/route/route_controller.dart';

class RouteView extends GetView<RouteController> {
  const RouteView({super.key});

  @override
  Widget build(BuildContext context) {
    /// NaviController 주입
    final RouteController routeController = Get.put(RouteController());

    /// RouteController의 데이터 가져오기
    final routePoints = routeController.routePoints;
    final startStation = routeController.startStation;
    final endStation = routeController.endStation;

    /// 출발지, 도착지 좌표를 이용해 지도 제한 영역 설정
    final lat1 = routeController.startStation.lat;
    final lng1 = routeController.startStation.lng;
    final lat2 = routeController.endStation.lat;
    final lng2 = routeController.endStation.lng;

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(children: [
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 상단 영역 : 뒤로가기 버튼 + 출발지/도착지 표시
                Container(
                    color: Colors.white,
                    height: 0.07.sh,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.sp),

                          /// 뒤로가기 아이콘
                          child: GestureDetector(
                            onTap: () {
                              Log.info('RouteView -> 뒤로가기 (검색 화면으로)');
                              Get.back();
                            },
                            child: Icon(
                              Icons.arrow_back,
                              size: 30.sp,
                            ),
                          ),
                        ),

                        /// 출발지 → 도착지 텍스트
                        Expanded(
                          child: _buildRouteText(
                            startName: routeController.startStation.name,
                            endName: routeController.endStation.name,
                          ),
                        ),
                        SizedBox(width: 10.sp),
                      ],
                    )),

                /// 지도 영역
                Expanded(
                  child: NaverMap(
                    // 지도 옵션
                    options: NaverMapViewOptions(
                      initialCameraPosition: NCameraPosition(
                        target: center,
                        zoom: 15,
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
                    onMapReady: routeController.onMapReady,
                  ),
                )
              ],
            ),
          ),
          Positioned(
              bottom: 10,
              right: 0,
              left: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Log.info('경로 안내 버튼 클릭 : route -> navi');
                    controller.sendStartNavigation();
                    Get.toNamed('/navi', arguments: {
                      'routePoints': routePoints,
                      'startStation': startStation,
                      'endStation': endStation,
                    });
                  },
                  // TODO : 버튼 스타일 수정 필요 -> kaist 파란색들 조합해서 / 배경은 투명하게 + 터치하면 배경 진해지도록
                  child: Container(
                    width: 70.sp,
                    height: 70.sp,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      // TODO : 배경 색상 수정 필요
                      color: AppColors.instance.buttonBackgroundColor,
                      borderRadius: BorderRadius.circular(10.sp),
                    ),
                    child: Icon(
                      CupertinoIcons.location_fill,
                      color: Colors.black,
                      size: 30.sp,
                    ),
                  ),
                ),
              ))
        ]),
      ),
    );
  }

  /// 출발지 → 도착지 표시 위젯
  Widget _buildRouteText({
    required String startName,
    required String endName,
  }) {
    final String text = '$startName → $endName';

    // LayoutBuilder를 통해 실제로 Row에서 배정된 maxWidth를 확인한 뒤,
    // 글자 폭이 더 크면 Marquee(흘러가는 텍스트)로, 작으면 단일 줄 표기 + ellipsis로 처리
    return LayoutBuilder(
      builder: (context, constraints) {
        // 글자 폭 측정
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'SCDream',
            ),
          ),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();

        // 실제 텍스트 길이가 주어진 maxWidth보다 작거나 같으면, 그대로 표시
        if (textPainter.width <= constraints.maxWidth) {
          return Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: 'SCDream',
            ),
          );
        } else {
          // 글자 폭이 영역보다 크면, marquee 효과 (스크롤)로 보여주기
          return SizedBox(
            height: 22.sp, // 세로 높이는 적당히 지정
            width: constraints.maxWidth,
            child: Marquee(
              text: text,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'SCDream',
              ),
              scrollAxis: Axis.horizontal,
              velocity: 30.0, // 텍스트 이동 속도
              blankSpace: 20.0, // 맨 끝까지 이동 후, 다음 라운드까지의 간격
              pauseAfterRound: const Duration(seconds: 1), // 한 바퀴 후 쉬는 시간
              accelerationDuration: const Duration(seconds: 1),
              decelerationDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      },
    );
  }
}
