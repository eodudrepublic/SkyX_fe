class AppSizes {
  // Singleton 인스턴스
  AppSizes._privateConstructor();

  static final AppSizes instance = AppSizes._privateConstructor();

  // 상태 표시줄 높이
  late final double statusBarHeight;
  void setStatusBarHeight(double height) {
    statusBarHeight = height;
  }
}
