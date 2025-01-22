import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../common/utils/logger.dart';
import '../../model/station_info.dart';

class NaviTestPage extends StatelessWidget {
  const NaviTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 테스트용으로 startStation, endStation, routePoints 하드코딩
            final startStation = StationInfo(
              id: "4de6e678-d7c0-11ef-8650-fa163e2f32e9",
              lat: 36.3727230623,
              lng: 127.3634008355,
              name: "테스트출발지",
            );
            final endStation = StationInfo(
              id: "4de6e6fa-d7c0-11ef-8650-fa163e2f32e9",
              lat: 36.3722624876,
              lng: 127.3637218543,
              name: "테스트도착지",
            );
            final routePoints = <NLatLng>[
              NLatLng(36.3727230623, 127.3634008355),
              NLatLng(36.3726717044, 127.3634521934),
              NLatLng(36.3726203465, 127.3635035513),
              NLatLng(36.3725689886, 127.3635549092),
              NLatLng(36.3725176307, 127.3636062671),
              NLatLng(36.3722624876, 127.3637218543),
            ];

            Log.info("버튼 클릭 -> /navi로 이동 (테스트 arguments)");

            // 실제 코드에서도 마찬가지로 arguments로 데이터 전달
            Get.toNamed('/navi', arguments: {
              'startStation': startStation,
              'endStation': endStation,
              'routePoints': routePoints,
            });
          },
          child: const Text('Go to Navi (테스트)'),
        ),
      ),
    );
  }
}
