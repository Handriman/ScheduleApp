import 'package:http/http.dart' as http;



class Internet {

  Future<http.Response> fetchSchedule(String group) {
    return http.get(Uri.parse("https://handri.pythonanywhere.com/get_data/$group"));
  }



}