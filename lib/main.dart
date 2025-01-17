import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'common/key.dart';
import 'common/utils/logger.dart';
import 'package:sky_x_fe/view/login/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 세로 모드로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // KakaoSdk 초기화
  KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
  Log.wtf("KakaoSdk initialized : ${await KakaoSdk.origin} -> 이게 왜 키 해쉬예요 ㅅㅂ");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(400, 860),
      builder: (context, child) {
        return GetMaterialApp(
          title: 'SkyX',
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          getPages: [
            /// 로그인
            GetPage(name: '/login', page: () => LoginView()),
          ],
        );
      },
    );
  }
}
