import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_database.dart';

part 'database_provider.g.dart';

// 앱 전체에서 공유하는 DB 인스턴스입니다.
// keepAlive: true -> 앱이 켜져있는 동안 DB 연결을 끊지 않고 유지합니다.
@Riverpod(keepAlive: true)
AppDatabase database(DatabaseRef ref) {
  return AppDatabase();
}