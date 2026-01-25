// lib/src/features/settings/user_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/localization_provider.dart'; // 📍 다국어 임포트

part 'user_provider.g.dart';

// 📍 닉네임과 이미지 경로를 함께 담을 데이터 클래스
class UserProfileData {
  final String nickname;
  final String? imagePath;

  UserProfileData({required this.nickname, this.imagePath});
}

@riverpod
class UserNickname extends _$UserNickname {
  @override
  UserProfileData build() {
    _loadProfile();
    // 📍 초기 기본값: 다국어 지원을 위해 임시 값을 넣고 _loadProfile에서 실제 번역본을 적용합니다.
    return UserProfileData(nickname: "Landlord");
  }

  // 📍 로컬에서 닉네임과 이미지 경로를 함께 불러오기
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final l10n = ref.read(localizationProvider.notifier);

    // 📍 다국어 적용: 저장된 이름이 없으면 각 언어별 "건물주" 기본칭호 사용
    final defaultNickname = l10n.translate("SETTINGS_DEFAULT_NICKNAME");
    final name = prefs.getString('user_nickname') ?? defaultNickname;
    final path = prefs.getString('user_image_path');

    state = UserProfileData(nickname: name, imagePath: path);
  }

  // 📍 닉네임 업데이트 함수
  Future<void> updateNickname(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_nickname', newName);
    state = UserProfileData(nickname: newName, imagePath: state.imagePath);
  }

  // 📍 프로필 이미지 업데이트 함수 (새로 추가)
  Future<void> updateImagePath(String? newPath) async {
    final prefs = await SharedPreferences.getInstance();
    if (newPath == null) {
      await prefs.remove('user_image_path');
    } else {
      await prefs.setString('user_image_path', newPath);
    }
    state = UserProfileData(nickname: state.nickname, imagePath: newPath);
  }
}