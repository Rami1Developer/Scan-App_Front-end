import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  // Request storage permission
  final permissionStatus = await Permission.storage.request();

  // Check if the permission was granted
  if (permissionStatus.isGranted) {
    print('Storage permission granted');
    return true; // Permission granted
  } else {
    print('Storage permission denied');
    return false; // Permission denied
  }
}
