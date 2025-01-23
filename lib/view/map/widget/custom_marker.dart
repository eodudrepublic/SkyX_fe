import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter/material.dart';

import '../../../model/user_model.dart';

class StationMarker extends NMarker {
  final double lat;
  final double lng;
  final String stationId;
  final String captionText;
  final String infoText;

  StationMarker({
    required this.lat,
    required this.lng,
    required this.stationId,
    required this.infoText,
    this.captionText = '',
  }) : super(
          id: stationId,
          position: NLatLng(lat, lng),
          icon: NOverlayImage.fromAssetImage('assets/icons/station_icon.png'),
          size: Size(25, 25),
          caption: NOverlayCaption(
            text: captionText,
            // TODO : 캡션 디자인 수정
          ),
          // TODO : 마커, 캡션 보여지는 줌 레벨 범위 지정
        );
}

class PlaceMarker extends NMarker {
  final double lat;
  final double lng;
  final String placeId;
  final String captionText;

  PlaceMarker({
    required this.lat,
    required this.lng,
    required this.placeId,
    required this.captionText,
  }) : super(
          id: placeId,
          position: NLatLng(lat, lng),
          icon: NOverlayImage.fromAssetImage('assets/icons/place_icon.png'),
          size: Size(35, 35),
          anchor: NPoint(0.5, 0.75),
          caption: NOverlayCaption(
            text: captionText,
          ),
        );
}

class UserMarker extends NMarker {
  final double lat;
  final double lng;

  UserMarker({
    required this.lat,
    required this.lng,
  }) : super(
          id: AppUser().id ?? 'user_marker',
          position: NLatLng(lat, lng),
          icon: NOverlayImage.fromAssetImage('assets/icons/user_icon.png'),
          size: Size(35, 35),
          // anchor: NPoint(0.5, 0.75),
        );
}
