import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';

class UserRepository {
  static const String _keyProfileImage = 'profile_image_path';
  static const String _keyUserName = 'user_name';

  Future<UserState> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final fileName = prefs.getString(_keyProfileImage);
    final name = prefs.getString(_keyUserName) ?? 'User Name';

    String? fullPath;
    if (fileName != null) {
      final validFileName = p.basename(fileName);
      final directory = await getApplicationDocumentsDirectory();
      fullPath = p.join(directory.path, validFileName);
    }

    return UserState(profileImagePath: fullPath, userName: name);
  }

  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  Future<void> saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final fileName = p.basename(path);
    await prefs.setString(_keyProfileImage, fileName);
  }
}
