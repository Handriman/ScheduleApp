import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class FileManager {

  void writeToFile(String group, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$group.json');
    file.writeAsString(content);
  }

  Future<Map<String, List<Map<String, String>>>> parseJson(String group) async {
    String rawData = '';
    rawData = await readFile(group);
    Map<String, dynamic> jsonData = jsonDecode(rawData);
    return jsonData.map((key, value) {
      if (value is List) {
        List<Map<String, String>> dataList = (value).map((item) {
          return Map<String, String>.from(item as Map<String, dynamic>);
        }).toList();
        return MapEntry(key, dataList);
      } else {
        return MapEntry(key, []);
      }
    });
  }

  Future<bool> isFileExist(String directory, String fileName) async {
    return File('$directory/$fileName.json').exists();
  }

  static void createFile(String directory, String fileName) {
    final file = File('$directory/$fileName.json');
    file.writeAsString("");
  }

  Future<String> readFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    if (isFileExist(directory.path, fileName) == false) {
      createFile(directory.path, fileName);
    }
    final file = File('${directory.path}/$fileName.json');
    return file.readAsStringSync();
  }
}
