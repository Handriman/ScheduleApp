import 'file_work.dart';
import 'package:http/http.dart' as http;

class Schedule{

  Map<String, List<Map<String, String>>> mainSchedule = <String, List<Map<String, String>>>{};
  FileManager fileManager = FileManager();
  String group;

  Schedule(
      this.group
      );

  void loadSchedule() async {
    mainSchedule =  await fileManager.parseJson(group);
  }

  Future<bool> updateSchedule() async {
    final response = await http.get(Uri.parse("https://handri.pythonanywhere.com/get_data/$group"));
    fileManager.writeToFile(group, response.body);
    return true;
  }


}