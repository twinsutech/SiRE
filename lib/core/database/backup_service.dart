import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;

class BackupService {
  // 1. 백업하기 (DB 파일을 외부로 공유)
  Future<void> backupDatabase() async {
    final dbFolder = await getApplicationDocumentsMethod(); // 앱 내부 DB 폴더
    final dbFile = File(p.join(dbFolder.path, 'db.sqlite'));

    if (await dbFile.exists()) {
      // 파일을 이메일, 카톡 등으로 전송할 수 있게 공유창을 띄움
      await Share.shareXFiles([XFile(dbFile.path)], text: 'SiRE App Data Backup');
    }
  }

  // 2. 복구하기 (외부 파일을 선택해서 앱 내부로 덮어쓰기)
  Future<bool> restoreDatabase() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final dbFolder = await getApplicationDocumentsMethod();
      final newDbFile = File(result.files.single.path!);

      // 기존 파일을 백업 파일로 교체
      await newDbFile.copy(p.join(dbFolder.path, 'db.sqlite'));
      return true;
    }
    return false;
  }

  Future<Directory> getApplicationDocumentsMethod() async {
    return await getApplicationDocumentsDirectory();
  }
}