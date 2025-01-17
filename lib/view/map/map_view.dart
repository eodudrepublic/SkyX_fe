import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/utils/logger.dart';

class SkyMapView extends StatelessWidget {
  const SkyMapView({super.key});

  @override
  Widget build(BuildContext context) {
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
                options: NaverMapViewOptions(
                  initialCameraPosition: NCameraPosition(
                    target: NLatLng(36.37075, 127.3615),
                    zoom: 14.4,
                    bearing: 0,
                    tilt: 0,
                  ),
                  mapType: NMapType.basic,
                  activeLayerGroups: [
                    NLayerGroup.building,
                    NLayerGroup.transit
                  ],
                ),
                onMapReady: (myMapController) {
                  Log.info("네이버 맵 로딩됨!");
                },
                onMapTapped: (point, latLng) {
                  Log.info("${latLng.latitude}、${latLng.longitude}");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
