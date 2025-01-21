import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/utils/logger.dart';
import '../../model/station_info.dart';

/// 출발지/도착지 검색 및 선택 로직을 담당하는 컨트롤러
class RouteSearchController extends GetxController {
  /// TextEditingController & FocusNode
  final TextEditingController startTextController = TextEditingController();
  final TextEditingController endTextController = TextEditingController();
  final FocusNode startFocusNode = FocusNode();
  final FocusNode endFocusNode = FocusNode();

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
    // 만약 '출발지' 입력창에 포커스가 가 있다면 → 그 입력값으로 필터링
    // 아니라면(다른 곳에 포커스가 있다면) 검색 목록은 다른 로직에 의해 업데이트
    if (startFocusNode.hasFocus) {
      _filterStations(startTextController.text);
    }
    _logIfBothFieldsFilled();
  }

  /// 도착지 TextField 입력값 변경 시 호출
  void _onEndTextChanged() {
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

  /// 주어진 query(입력값)이 station.id에 포함되는지 필터링
  void _filterStations(String query) {
    if (query.isEmpty) {
      // 입력이 비어있으면 전체 역 목록
      searchList.assignAll(allStations);
    } else {
      // 입력이 포함된 역들만 검색
      final filtered = allStations.where((station) {
        return station.id.toLowerCase().contains(query.toLowerCase());
      }).toList();

      searchList.assignAll(filtered);
    }
  }

  /// 사용자가 검색 결과 리스트에서 특정 역을 탭했을 때 처리
  /// 현재 포커스가 출발지면 출발지 TextField에 채우고, 도착지면 도착지 TextField에 채움
  void selectStation(StationInfo station) {
    if (startFocusNode.hasFocus) {
      startTextController.text = station.id;
      // 선택 후, 포커스 해제(원하는 경우)
      startFocusNode.unfocus();
    } else if (endFocusNode.hasFocus) {
      endTextController.text = station.id;
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
    final start = startTextController.text;
    final end = endTextController.text;

    if (start.isNotEmpty && end.isNotEmpty) {
      Log.info("출발지 : $start, 도착지 : $end");
      // TODO : 여기서 서버에 startId, endId를 전송하고, 경로를 받아오는 로직 추가
      // TODO : 경로를 받은 뒤, MapController의 drawMultipartPaths() 등을 호출
    }
  }

  /// swap 버튼 클릭 시 호출 → 출발지/도착지 텍스트를 서로 교환
  void swapStartEnd() {
    final temp = startTextController.text;
    startTextController.text = endTextController.text;
    endTextController.text = temp;

    Log.info(
        "swap 버튼 클릭 - 출발지 : ${startTextController.text}, 도착지 : ${endTextController.text}");

    // TODO : swap 후, 지도 마커/경로도 다시 그리려면 이곳에서 MapController 호출 등 추가
    // 예) MapController의 removeOverlay -> 다시 addMarker -> drawMultipartPaths...
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
