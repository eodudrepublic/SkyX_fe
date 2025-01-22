import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../common/utils/logger.dart';
import '../../common/server_url.dart';
import '../../model/station_info.dart';
import '../../model/user_model.dart';

/// 출발지/도착지 검색 및 선택 로직을 담당하는 컨트롤러
class RouteSearchController extends GetxController {
  /// TextEditingController & FocusNode
  final TextEditingController startTextController = TextEditingController();
  final TextEditingController endTextController = TextEditingController();
  final FocusNode startFocusNode = FocusNode();
  final FocusNode endFocusNode = FocusNode();

  /// RxString : Obx가 관찰할 수 있는 출발지/도착지 입력값
  final RxString startInput = ''.obs;
  final RxString endInput = ''.obs;

  /// 검색 결과 (StationInfo) 목록 (SingleChildScrollView에 표시할 목록)
  RxList<StationInfo> searchList = <StationInfo>[].obs;

  /// 전체 StationInfo 목록 (station_info.dart에서 가져옴)
  final List<StationInfo> allStations = StationRepository.stationList;

  @override
  void onInit() {
    super.onInit();

    /// 처음에는 출발지/도착지 TextField가 모두 비어있고 포커스도 없으므로
    /// 전체 목록을 보여주기 위해 searchList에 allStations를 그대로 넣음
    searchList.assignAll(allStations);

    /// TextField 입력값이 바뀔 때마다 검색 수행
    startTextController.addListener(_onStartTextChanged);
    endTextController.addListener(_onEndTextChanged);

    /// FocusNode 변경 감지 → 어느 필드가 선택되었는지에 따라 검색목록 필터링
    startFocusNode.addListener(_onFocusChange);
    endFocusNode.addListener(_onFocusChange);
  }

  /// 출발지 TextField 입력값 변경 시 호출
  void _onStartTextChanged() {
    // RxString에 반영
    startInput.value = startTextController.text;
    // 만약 '출발지' 입력창에 포커스가 있다면 → 그 입력값으로 필터링
    if (startFocusNode.hasFocus) {
      _filterStations(startTextController.text);
    }
    _logIfBothFieldsFilled();
  }

  /// 도착지 TextField 입력값 변경 시 호출
  void _onEndTextChanged() {
    // RxString에 반영
    endInput.value = endTextController.text;
    // 만약 '도착지' 입력창에 포커스가 있다면 → 그 입력값으로 필터링
    if (endFocusNode.hasFocus) {
      _filterStations(endTextController.text);
    }
    _logIfBothFieldsFilled();
  }

  /// FocusNode가 바뀔 때마다 호출되어, 현재 어느 TextField가 선택되었는지 판단 후 필터링
  void _onFocusChange() {
    // 출발지 창 포커스가 생기면 -> 출발지 입력값으로 필터링
    if (startFocusNode.hasFocus) {
      _filterStations(startTextController.text);
    }
    // 도착지 창 포커스가 생기면 -> 도착지 입력값으로 필터링
    else if (endFocusNode.hasFocus) {
      _filterStations(endTextController.text);
    }
    // 둘 다 포커스가 아니면(둘 다 unfocus상태) -> 전체 역 목록 표시
    else if (!startFocusNode.hasFocus && !endFocusNode.hasFocus) {
      searchList.assignAll(allStations);
    }
  }

  /// 주어진 query(입력값)이 station.name에 포함되는지 필터링
  void _filterStations(String query) {
    if (query.isEmpty) {
      // 입력이 비어있으면 전체 역 목록
      searchList.assignAll(allStations);
    } else {
      // 입력이 포함된 역들만 검색
      final filtered = allStations.where((station) {
        return station.name.toLowerCase().contains(query.toLowerCase());
      }).toList();

      searchList.assignAll(filtered);
    }
  }

  /// 사용자가 검색 결과 리스트에서 특정 역을 탭했을 때 처리
  /// 현재 포커스가 출발지면 출발지 TextField에 채우고, 도착지면 도착지 TextField에 채움
  void selectStation(StationInfo station) {
    if (startFocusNode.hasFocus) {
      startTextController.text = station.name;
      startInput.value = station.name; // RxString에도 반영
      // 선택 후, 포커스 해제(원하는 경우)
      startFocusNode.unfocus();
    } else if (endFocusNode.hasFocus) {
      endTextController.text = station.name;
      endInput.value = station.name; // RxString에도 반영
      endFocusNode.unfocus();
    }
    // 둘 다 아닌 경우(예: 실수로 리스트를 눌렀을 때) 처리
    else {
      // 아무 작업 안 함 or 로그
      Log.info("Neither start nor end focused, ignoring selection");
    }

    // 출발지/도착지 둘 다 채워졌으면 로그 출력
    _logIfBothFieldsFilled();
  }

  /// 출발지, 도착지 둘 다 채워져 있으면 로그 출력
  void _logIfBothFieldsFilled() {
    final start = startInput.value.trim();
    final end = endInput.value.trim();

    if (start.isNotEmpty && end.isNotEmpty) {
      Log.info("출발지 : $start, 도착지 : $end");
      // TODO : 여기서 서버에 startId, endId를 전송하고, 경로를 받아오는 로직 추가
      // TODO : 경로를 받은 뒤, MapController의 drawMultipartPaths() 등을 호출
    }
  }

  /// swap 버튼 클릭 시 호출 → 출발지/도착지 텍스트를 서로 교환
  void swapStartEnd() {
    final tempText = startTextController.text;
    startTextController.text = endTextController.text;
    endTextController.text = tempText;

    // RxString 스왑
    final tempRx = startInput.value;
    startInput.value = endInput.value;
    endInput.value = tempRx;

    Log.info(
        "swap 버튼 클릭 - 출발지 : ${startTextController.text}, 도착지 : ${endTextController.text}");

    // TODO : swap 후, 지도 마커/경로도 다시 그리려면 이곳에서 MapController 호출 등 추가
    // 예) MapController의 removeOverlay -> 다시 addMarker -> drawMultipartPaths...
  }

  /// "안내 시작" 버튼 클릭 시 호출
  Future<void> startNavigation() async {
    final startName = startTextController.text.trim();
    final endName = endTextController.text.trim();

    if (startName.isEmpty || endName.isEmpty) {
      Log.warning("출발지 혹은 도착지가 비어있어 안내를 시작할 수 없습니다.");
      return;
    }

    // 입력된 출발지/도착지 ID에 해당하는 StationInfo 찾기
    final StationInfo? startStation =
        allStations.firstWhereOrNull((s) => s.name == startName);
    final StationInfo? endStation =
        allStations.firstWhereOrNull((s) => s.name == endName);

    if (startStation == null || endStation == null) {
      Log.error("유효하지 않은 출발지/도착지 StationInfo입니다.");
      return;
    }

    // 서버 요청 준비
    // TODO : userId는 현재 임시로 "asdf"로 설정되어 있음. -> 나중에는 그냥 AppUser().id로 변경
    final userId = AppUser().id ?? "asdf"; // 사용자 ID
    final url = '$serverUrl:3001/api/path/single';
    final body = {
      "user_id": userId,
      "originID": startStation.id,
      "destinationID": endStation.id,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['ok'] == true && data['path'] != null) {
          final pathData = data['path'] as List<dynamic>;
          // lat, lon, alt가 있는데 alt는 무시하고 lat/lon만 사용
          final routePoints = pathData.map((p) {
            final lat = p['lat'] as double;
            final lon = p['lon'] as double;
            return NLatLng(lat, lon);
          }).toList();

          Log.info("경로 요청 성공 -> /navi 페이지로 이동합니다.");

          // /navi로 이동, 출발/도착 StationInfo + 경로 점들을 함께 전달
          Get.toNamed('/navi', arguments: {
            'startStation': startStation,
            'endStation': endStation,
            'routePoints': routePoints,
          });
        } else {
          Log.error("경로 요청 실패: 응답 ok=false 또는 path=null");
        }
      } else {
        Log.error(
            "경로 요청 실패: status=${response.statusCode}, body=${response.body}");
      }
    } catch (e) {
      Log.error("경로 요청 에러: $e");
    }
  }

  @override
  void onClose() {
    startTextController.dispose();
    endTextController.dispose();
    startFocusNode.dispose();
    endFocusNode.dispose();
    super.onClose();
  }
}
