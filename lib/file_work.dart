import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';

import 'package:flutter/foundation.dart' show kIsWeb;


import 'package:path_provider/path_provider.dart';




class CounterStorage{


  Future<String> get _localPath async {
    if(kIsWeb){
      const path = 'C:/Users/denis/AndroidStudioProjects/new_learn/web_doc';

      return path;
    }
    else {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/user_settings.txt');
  }

  Future<File> writeCounter(String str) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(str);
  }


  Future<String> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return contents.toString();
    } catch (e) {
      // If encountering an error, return 0
      return "${e.toString()}";
    }
  }

}