import 'dart:convert';
import 'package:http/http.dart' as http;
import '../common/server_url.dart';
import '../common/utils/logger.dart';

/// 서버에서 불러온 건물 정보를 보관할 모델
class StationInfo {
  final String id; // 서버 buildingID
  final double lat; // 서버 latitude
  final double lng; // 서버 longitude
  final String name; // 서버 buildingName
  final String infoText; // 지도 InfoWindow 등에 표시할 문구

  StationInfo({
    required this.id,
    required this.lat,
    required this.lng,
    required this.name,
    this.infoText = '',
  });

  /// StationInfo 객체를 문자열로 표현하기 위한 메서드
  @override
  String toString() {
    return 'StationInfo(id: $id, name: $name, lat: $lat, lng: $lng, infoText: $infoText)';
  }
}

/// StationInfo와 즐겨찾기 목록을 관리하는 역할
class StationRepository {
  /// 서버에서 불러온 전체 건물(정류장) 목록
  static List<StationInfo> stationList = [];

  /// 사용자 즐겨찾기 목록
  static List<StationInfo> favoriteList = [];

  /// 모든 건물(정류장) 목록 불러오기
  static Future<void> fetchStationListFromServer() async {
    final url = '$serverUrl:3001/api/building/buildingList';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // 서버 응답을 StationInfo 리스트로 변환
        stationList = data.map((json) {
          return StationInfo(
            id: json['buildingID'],
            lat: double.parse(json['latitude']),
            lng: double.parse(json['longitude']),
            name: json['buildingName'],
            infoText: "정류장 이름: ${json['buildingName']}",
          );
        }).toList();

        Log.info("StationRepository : 건물 목록 불러오기 성공: 총 ${stationList.length}개");

        // // 전체 건물 목록 출력 (디버깅용)
        // Log.info("전체 건물 목록:");
        // for (var station in stationList) {
        //   Log.info(station.toString());
        // }
      } else {
        Log.error("건물 목록 불러오기 실패: 상태코드=${response.statusCode}");
      }
    } catch (e) {
      Log.error("건물 목록 불러오기 에러: $e");
    }
  }

  /// 사용자 즐겨찾기 목록 불러오기
  static Future<void> fetchFavoriteList(String userId) async {
    final url = '$serverUrl:3001/api/search/favorite?user_id=$userId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // 서버 응답을 StationInfo 리스트로 변환
        favoriteList = data.map((json) {
          return StationInfo(
            id: json['buildingID'],
            lat: double.parse(json['latitude']),
            lng: double.parse(json['longitude']),
            name: json['buildingName'],
            infoText: "정류장 이름: ${json['buildingName']}",
          );
        }).toList();

        Log.info("즐겨찾기 불러오기 성공: 총 ${favoriteList.length}개");

        // // 전체 즐겨찾기 목록 출력 (디버깅용)
        // Log.info("전체 즐겨찾기 목록:");
        // for (var favorite in favoriteList) {
        //   Log.info(favorite.toString());
        // }
      } else {
        Log.error("즐겨찾기 불러오기 실패: 상태코드=${response.statusCode}");
      }
    } catch (e) {
      Log.error("즐겨찾기 불러오기 에러: $e");
    }
  }

  /// 즐겨찾기 추가: 추가 후, 서버 즐겨찾기 목록을 다시 불러와 갱신
  static Future<void> addFavorite(String userId, StationInfo station) async {
    final url = '$serverUrl:3001/api/search/postFavorite';
    final body = {
      "user_id": userId, // 사용자 ID
      "building_id": station.id, // buildingID
      "favorite_name": station.name
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // 즐겨찾기 추가 성공 → 최신 즐겨찾기 목록 다시 불러오기
        Log.info("즐겨찾기 등록 성공: ${station.name}");
        await fetchFavoriteList(userId);
      } else {
        Log.error(
            "즐겨찾기 등록 실패: 상태코드=${response.statusCode}, 응답=${response.body}");
      }
    } catch (e) {
      Log.error("즐겨찾기 등록 에러: $e");
    }
  }
}
