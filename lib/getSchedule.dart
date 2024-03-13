import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'main.dart';


Future<http.Response> fetchSchedule() {
  return http.get(Uri.parse("https://handri.pythonanywhere.com/get_data"));
}

Future<bool> doesFileExist(String filePath) async {
  return File(filePath).exists();
}

Future<bool> upt1() async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/121111.json';
  final isExist = await doesFileExist(filePath);
  final response =  await fetchSchedule();

  if (isExist) {
    final file = File(filePath);
    // Map<String, dynamic> jsonData = jsonDecode(response.body);
    file.writeAsString(response.body);

    return true;
  } else {
    return false;
  }
}