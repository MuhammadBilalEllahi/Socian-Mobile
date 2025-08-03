import 'package:universal_io/io.dart';

class IoChecker {
  static bool isFile(dynamic value) => value is File;
  static bool isListOfFiles(dynamic value) =>
      value is List && value.isNotEmpty && value.first is File;
}
