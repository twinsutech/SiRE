import 'package:shared_preferences/shared_preferences.dart';

class ProStorage {
  static const _key = 'is_pro';

  Future<bool> getIsPro() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_key) ?? false;
  }

  Future<void> setIsPro(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_key, value);
  }
}
