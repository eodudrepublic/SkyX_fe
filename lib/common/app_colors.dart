import 'package:flutter/material.dart';

class AppColors {
  // Singleton 인스턴스
  AppColors._privateConstructor();

  static final AppColors instance = AppColors._privateConstructor();

  // 카카오톡 버튼에 사용해야 하는 색상
  final Color kakaotalkYellow = const Color(0xFFFEE500);
  final Color kakaotalkLabel = const Color(0xD8000000);
}
