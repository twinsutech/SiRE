// import 'dart:io';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:device_info_plus/device_info_plus.dart';
//
// class SupportService {
//   // 📍 실제 관리자 이메일 주소를 입력하세요.
//   static const String adminEmail = 'yskim10007@gmail.com';
//
//   /// 이메일 문의하기 실행
//   static Future<void> sendSupportEmail() async {
//     final PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     final String version = packageInfo.version;
//     final String buildNumber = packageInfo.buildNumber;
//
//     // 기기 정보 가져오기
//     String deviceInfo = await _getDeviceInfo();
//
//     // 📍 제목 구성
//     final String subject = _encodeQuery('[SiRE Support] Inquiry / Refund Request');
//
//     // 📍 본문 구성: 환불 안내 문구(영/한 병기) 및 기기 정보 포함
//     final String body = _encodeQuery(
//         '--- Please write your inquiry below ---\n\n\n\n'
//             '--------------------------------------\n'
//             '* Important for Refund:\n'
//             'Please attach a screenshot of your Google Play receipt or copy the Order ID (GPA.XXXX-XXXX-XXXX-XXXXX).\n'
//             '--------------------------------------\n'
//             'App Version: $version ($buildNumber)\n'
//             'Device Info: $deviceInfo\n'
//             '--------------------------------------'
//     );
//
//     // 📍 queryParameters 대신 query 속성에 직접 인코딩된 문자열을 넣어 + 기호 발생을 방지합니다.
//     final Uri emailUri = Uri(
//       scheme: 'mailto',
//       path: adminEmail,
//       query: 'subject=$subject&body=$body',
//     );
//
//     try {
//       // 📍 외부 애플리케이션 모드로 실행하여 이메일 앱 선택창이 잘 뜨도록 유도합니다.
//       if (await canLaunchUrl(emailUri)) {
//         await launchUrl(
//           emailUri,
//           mode: LaunchMode.externalApplication,
//         );
//       } else {
//         // 📍 canLaunchUrl이 실패하더라도 강제 실행 시도 (많은 안드로이드 기기 대응)
//         await launchUrl(emailUri);
//       }
//     } catch (e) {
//       // 📍 이메일 앱이 없거나 실행 불가능한 경우 상위 위젯으로 에러를 던집니다.
//       throw 'Could not launch email client';
//     }
//   }
//
//   /// 공백을 + 대신 %20으로 인코딩하는 헬퍼 함수
//   static String _encodeQuery(String text) {
//     return Uri.encodeComponent(text).replaceAll('+', '%20');
//   }
//
//   /// 기기 정보를 문자열로 요약
//   static Future<String> _getDeviceInfo() async {
//     final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//     try {
//       if (Platform.isAndroid) {
//         final androidInfo = await deviceInfoPlugin.androidInfo;
//         return 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt}), ${androidInfo.model}';
//       } else if (Platform.isIOS) {
//         final iosInfo = await deviceInfoPlugin.iosInfo;
//         return 'iOS ${iosInfo.systemVersion}, ${iosInfo.utsname.machine}';
//       }
//     } catch (e) {
//       return 'Unknown Device (Error: $e)';
//     }
//     return 'Unknown Device';
//   }
// }

//
// import 'dart:io';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // 📍 [추가] Riverpod 사용
// import '../../core/localization/localization_provider.dart'; // 📍 [추가] 다국어 provider 연결
//
// class SupportService {
//   // 📍 실제 관리자 이메일 주소를 입력하세요.
//   static const String adminEmail = 'yskim10007@gmail.com';
//
//   /// 이메일 문의하기 실행
//   /// 📍 WidgetRef를 매개변수로 받아 현재 설정된 언어에 맞는 텍스트를 가져옵니다.
//   static Future<void> sendSupportEmail(WidgetRef ref) async {
//     final PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     final String version = packageInfo.version;
//     final String buildNumber = packageInfo.buildNumber;
//
//     // 기기 정보 가져오기
//     String deviceInfo = await _getDeviceInfo();
//
//     // 📍 제목 구성 (다국어 키: SUPPORT_EMAIL_SUBJECT)
//     final String subject = _encodeQuery("SUPPORT_EMAIL_SUBJECT".tr(ref));
//
//     // 📍 본문 구성: 환불 안내 문구 및 기기 정보 포함 (다국어 적용)
//     final String body = _encodeQuery(
//         '${"SUPPORT_EMAIL_BODY_TOP".tr(ref)}\n\n\n\n'
//             '--------------------------------------\n'
//             '* ${"SUPPORT_EMAIL_REFUND_INFO".tr(ref)}\n'
//             '--------------------------------------\n'
//             '${"SUPPORT_EMAIL_APP_INFO".tr(ref)}: $version ($buildNumber)\n'
//             'Device Info: $deviceInfo\n'
//             '--------------------------------------'
//     );
//
//     // 📍 queryParameters 대신 query 속성에 직접 인코딩된 문자열을 넣어 + 기호 발생을 방지합니다.
//     final Uri emailUri = Uri(
//       scheme: 'mailto',
//       path: adminEmail,
//       query: 'subject=$subject&body=$body',
//     );
//
//     try {
//       // 📍 외부 애플리케이션 모드로 실행하여 이메일 앱 선택창이 잘 뜨도록 유도합니다.
//       if (await canLaunchUrl(emailUri)) {
//         await launchUrl(
//           emailUri,
//           mode: LaunchMode.externalApplication,
//         );
//       } else {
//         // 📍 canLaunchUrl이 실패하더라도 강제 실행 시도 (많은 안드로이드 기기 대응)
//         await launchUrl(emailUri);
//       }
//     } catch (e) {
//       // 📍 이메일 앱이 없거나 실행 불가능한 경우 상위 위젯으로 에러를 던집니다.
//       throw 'Could not launch email client';
//     }
//   }
//
//   /// 공백을 + 대신 %20으로 인코딩하는 헬퍼 함수
//   static String _encodeQuery(String text) {
//     return Uri.encodeComponent(text).replaceAll('+', '%20');
//   }
//
//   /// 기기 정보를 문자열로 요약
//   static Future<String> _getDeviceInfo() async {
//     final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//     try {
//       if (Platform.isAndroid) {
//         final androidInfo = await deviceInfoPlugin.androidInfo;
//         return 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt}), ${androidInfo.model}';
//       } else if (Platform.isIOS) {
//         final iosInfo = await deviceInfoPlugin.iosInfo;
//         return 'iOS ${iosInfo.systemVersion}, ${iosInfo.utsname.machine}';
//       }
//     } catch (e) {
//       return 'Unknown Device (Error: $e)';
//     }
//     return 'Unknown Device';
//   }
// }

//
// import 'dart:io';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // 📍 [추가] Riverpod 사용
// import '../../core/localization/localization_provider.dart'; // 📍 [추가] 다국어 provider 연결
//
// class SupportService {
//   // 📍 실제 관리자 이메일 주소를 입력하세요.
//   static const String adminEmail = 'yskim10007@gmail.com';
//
//   /// 이메일 문의하기 실행
//   /// 📍 WidgetRef를 매개변수로 받아 현재 설정된 언어에 맞는 텍스트를 가져옵니다.
//   static Future<void> sendSupportEmail(WidgetRef ref) async {
//     final PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     final String version = packageInfo.version;
//     final String buildNumber = packageInfo.buildNumber;
//
//     // 기기 정보 가져오기
//     String deviceInfo = await _getDeviceInfo();
//
//     // 📍 제목 구성 (다국어 키: SUPPORT_EMAIL_SUBJECT)
//     final String subject = _encodeQuery("${"SUPPORT_EMAIL_SUBJECT".tr(ref)} / Inquiry & Refund Request");
//
//     // 📍 본문 구성: 환불 안내 문구 및 기기 정보 포함 (현지어 + 영어 병기 스타일)
//     final String body = _encodeQuery(
//         '${"SUPPORT_EMAIL_BODY_TOP".tr(ref)}\n'
//             '(Please write your inquiry below)\n\n\n\n'
//             '--------------------------------------\n'
//             '* ${"SUPPORT_EMAIL_REFUND_INFO".tr(ref)}\n'
//             '(Please attach Google Play receipt screenshot or copy Order ID (GPA.---))\n'
//             '--------------------------------------\n'
//             '${"SUPPORT_EMAIL_APP_INFO".tr(ref)} (App Version): $version ($buildNumber)\n'
//             'Device Info: $deviceInfo\n'
//             '--------------------------------------'
//     );
//
//     // 📍 queryParameters 대신 query 속성에 직접 인코딩된 문자열을 넣어 + 기호 발생을 방지합니다.
//     final Uri emailUri = Uri(
//       scheme: 'mailto',
//       path: adminEmail,
//       query: 'subject=$subject&body=$body',
//     );
//
//     try {
//       // 📍 외부 애플리케이션 모드로 실행하여 이메일 앱 선택창이 잘 뜨도록 유도합니다.
//       if (await canLaunchUrl(emailUri)) {
//         await launchUrl(
//           emailUri,
//           mode: LaunchMode.externalApplication,
//         );
//       } else {
//         // 📍 canLaunchUrl이 실패하더라도 강제 실행 시도 (많은 안드로이드 기기 대응)
//         await launchUrl(emailUri);
//       }
//     } catch (e) {
//       // 📍 이메일 앱이 없거나 실행 불가능한 경우 상위 위젯으로 에러를 던집니다.
//       throw 'Could not launch email client';
//     }
//   }
//
//   /// 공백을 + 대신 %20으로 인코딩하는 헬퍼 함수
//   static String _encodeQuery(String text) {
//     return Uri.encodeComponent(text).replaceAll('+', '%20');
//   }
//
//   /// 기기 정보를 문자열로 요약
//   static Future<String> _getDeviceInfo() async {
//     final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
//     try {
//       if (Platform.isAndroid) {
//         final androidInfo = await deviceInfoPlugin.androidInfo;
//         return 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt}), ${androidInfo.model}';
//       } else if (Platform.isIOS) {
//         final iosInfo = await deviceInfoPlugin.iosInfo;
//         return 'iOS ${iosInfo.systemVersion}, ${iosInfo.utsname.machine}';
//       }
//     } catch (e) {
//       return 'Unknown Device (Error: $e)';
//     }
//     return 'Unknown Device';
//   }
// }
//


import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 📍 [추가] Riverpod 사용
import '../../core/localization/localization_provider.dart'; // 📍 [추가] 다국어 provider 연결

class SupportService {
  // 📍 실제 관리자 이메일 주소를 입력하세요.
  static const String adminEmail = 'yskim10007@gmail.com';

  /// 이메일 문의하기 실행
  /// 📍 WidgetRef를 매개변수로 받아 현재 설정된 언어에 맞는 텍스트를 가져옵니다.
  static Future<void> sendSupportEmail(WidgetRef ref) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String version = packageInfo.version;
    final String buildNumber = packageInfo.buildNumber;

    // 기기 정보 가져오기
    String deviceInfo = await _getDeviceInfo();

    // 📍 현재 언어 설정 확인 (영어 중복 방지용)
    final currentLang = ref.read(localizationProvider.notifier).currentLang;
    final isEn = currentLang == 'en';

    // 📍 제목 구성: 영어인 경우 다국어 키만 사용, 영어가 아닌 경우에만 영어 병기
    final String subjectText = isEn
        ? "SUPPORT_EMAIL_SUBJECT".tr(ref)
        : "${"SUPPORT_EMAIL_SUBJECT".tr(ref)} / Inquiry & Refund Request";
    final String subject = _encodeQuery(subjectText);

    // 📍 본문 구성: 현지어와 영어 병기 (영어 설정 시 중복 노출 방지)
    final String bodyTop = isEn
        ? "SUPPORT_EMAIL_BODY_TOP".tr(ref)
        : "${"SUPPORT_EMAIL_BODY_TOP".tr(ref)}\n(Please write your inquiry below)";

    final String refundInfo = isEn
        ? "SUPPORT_EMAIL_REFUND_INFO".tr(ref)
        : "${"SUPPORT_EMAIL_REFUND_INFO".tr(ref)}\n(Please attach Google Play receipt screenshot or copy Order ID (GPA.---))";

    final String appInfoLabel = isEn
        ? "SUPPORT_EMAIL_APP_INFO".tr(ref)
        : "${"SUPPORT_EMAIL_APP_INFO".tr(ref)} (App Version)";

    final String body = _encodeQuery(
        '$bodyTop\n\n\n\n'
            '--------------------------------------\n'
            '* $refundInfo\n'
            '--------------------------------------\n'
            '$appInfoLabel: $version ($buildNumber)\n'
            'Device Info: $deviceInfo\n'
            '--------------------------------------'
    );

    // 📍 queryParameters 대신 query 속성에 직접 인코딩된 문자열을 넣어 + 기호 발생을 방지합니다.
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: adminEmail,
      query: 'subject=$subject&body=$body',
    );

    try {
      // 📍 외부 애플리케이션 모드로 실행하여 이메일 앱 선택창이 잘 뜨도록 유도합니다.
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // 📍 canLaunchUrl이 실패하더라도 강제 실행 시도 (많은 안드로이드 기기 대응)
        await launchUrl(emailUri);
      }
    } catch (e) {
      // 📍 이메일 앱이 없거나 실행 불가능한 경우 상위 위젯으로 에러를 던집니다.
      throw 'Could not launch email client';
    }
  }

  /// 공백을 + 대신 %20으로 인코딩하는 헬퍼 함수
  static String _encodeQuery(String text) {
    return Uri.encodeComponent(text).replaceAll('+', '%20');
  }

  /// 기기 정보를 문자열로 요약
  static Future<String> _getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt}), ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return 'iOS ${iosInfo.systemVersion}, ${iosInfo.utsname.machine}';
      }
    } catch (e) {
      return 'Unknown Device (Error: $e)';
    }
    return 'Unknown Device';
  }
}