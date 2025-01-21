import 'package:flutter/material.dart';

class AppColors {
  // Singleton 인스턴스
  AppColors._privateConstructor();

  static final AppColors instance = AppColors._privateConstructor();

  // 카카오톡 버튼에 사용해야 하는 색상
  final Color kakaotalkYellow = const Color(0xFFFEE500);
  final Color kakaotalkLabel = const Color(0xD8000000);

  // KAIST 색상 팔레트
  final Color kaistDarkBlue = const Color(0xFF003C91);
  final Color kaistBlue = const Color(0xFF1487C8);
  final Color kaistMediumBlue = const Color(0xFF004187);
  final Color kaistLightBlue = const Color(0xFF5FBEEB);
  final Color kaistDarkGray = const Color(0xFF7C7C7C);

  // 검색 배경 회색
  final Color searchBackgroundColor = Color(0xFFDADADA);
}
