import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/app_colors.dart';
import '../../common/utils/logger.dart';
import '../../view_model/search/search_controller.dart';

class SearchView extends GetView<RouteSearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final RouteSearchController controller = Get.put(RouteSearchController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            /// 메인 영역 (출발지/도착지 입력 + 검색 결과 리스트)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  /// 상단: 출발지, 도착지 입력 영역
                  Container(
                    color: Colors.white,
                    child: Row(
                      children: [
                        /// 왼쪽 X 버튼
                        Container(
                          padding: EdgeInsets.all(5.sp),
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              Log.info('검색 화면 닫기');
                              Get.back();
                            },
                            child: Icon(CupertinoIcons.xmark, size: 30.sp),
                          ),
                        ),

                        /// TextFields (출발지 / 도착지)
                        // TODO 1 : 출발지, 도착지가 모두 채워지면 서버로 출발지, 도착지 id 전송 -> 서버에서 경로 받아오기
                        // -> 일단 현재는 서버가 완성되지 않아서, Log.info("출발지 : $startId, 도착지 : $endId"); 로 출력
                        // TODO 2 : 출발지, 도착지에 각각 출발/도착 마커를 찍고, 경로를 그리면 됨. swap 버튼을 누르면 출발지와 도착지가 바꾸어 지도에 다시 그려짐
                        // TODO 3 : 서버에서 받아온 경로를 그리기 -> MapController의 drawMultipartPaths 함수 사용
                        // 이를 위해 경로와 현재 위치를 표시할 /navi 페이지를 만들어야 함
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.sp),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 10.sp),

                                /// 출발지 입력 필드
                                Container(
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 5.sp,
                                    horizontal: 10.r,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors
                                        .instance.searchBackgroundColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: TextField(
                                    controller: controller.startTextController,
                                    focusNode: controller.startFocusNode,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '출발지 입력',
                                    ),
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                                SizedBox(height: 5.sp),

                                /// 도착지 입력 필드
                                Container(
                                  width: double.infinity,
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 5.sp,
                                    horizontal: 10.r,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors
                                        .instance.searchBackgroundColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: TextField(
                                    controller: controller.endTextController,
                                    focusNode: controller.endFocusNode,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '도착지 입력',
                                    ),
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                                SizedBox(height: 5.sp),
                              ],
                            ),
                          ),
                        ),

                        /// 출발지 <-> 도착지 swap 버튼
                        Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.all(5.sp),
                          child: GestureDetector(
                            onTap: () => controller.swapStartEnd(),
                            child: Icon(
                              CupertinoIcons.arrow_up_arrow_down,
                              size: 30.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// 검색 결과 리스트
                  Expanded(
                    child: Obx(
                      () => SingleChildScrollView(
                        child: Column(
                          children: controller.searchList.map((station) {
                            // TODO 1 : 리스트 타일 디자인 수정
                            // TODO 2 : 즐겨찾기(별/하트 모양) 버튼 추가 -> 즐겨찾기한 역은 별/하트 모양이 채워져 있도록
                            return ListTile(
                              title: Text(station.name),
                              onTap: () {
                                // 리스트에서 해당 역을 선택하면, 출발/도착 중 포커스된 곳에 값 대입
                                controller.selectStation(station);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 안내 시작 버튼 (Obx에서 RxString을 참조)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Obx(() {
                // 여기서는 RxString을 참조해야 함
                final startText = controller.startInput.value.trim();
                final endText = controller.endInput.value.trim();

                if (startText.isNotEmpty && endText.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: EdgeInsets.all(10.sp),
                    child: ElevatedButton(
                      onPressed: controller.startNavigation,
                      child: Text('안내 시작', style: TextStyle(fontSize: 16.sp)),
                    ),
                  );
                } else {
                  return const SizedBox.shrink(); // 미표시
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
