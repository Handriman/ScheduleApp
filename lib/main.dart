import 'dart:convert';
import 'dart:io';
import 'package:week_of_year/week_of_year.dart';
import 'dayLesson.dart';
import 'dayTile.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 17),
          bodyLarge: TextStyle(fontSize: 22),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.primaries[2]),
        useMaterial3: true,
      ),
      home: ScheduleListView(),
    );
  }
}

String normalizeDate(String badString) {
  List<String> tempString = badString.split('-');

  var normalString =
      '${tempString[2].characters.take(2).string}.${tempString[1]}';

  return normalString;
}

DateTime stringDateToTypeDate(String stringDate) {
  var temp = stringDate.split('.');
  var tempYear = DateTime.now().year;
  final data =
      DateTime.utc(tempYear, int.parse(temp[1]), int.parse(temp[0]), 23, 59);
  return data;
}

bool dataCompare(DateTime currentDate, DateTime comparedDate) {
  if (comparedDate.isBefore(currentDate)) {
    return false;
  } else {
    return true;
  }
}

final wek = {
  '1': 'Понедельник',
  '2': 'Вторник',
  '3': 'Среда',
  '4': 'Четверг',
  '5': 'Пятница',
  '6': 'Суббота',
  '7': 'Воскресенье',
};

class AllSubject extends StatelessWidget {
  final String name;
  final currentDate = DateTime.now();
  Map<String, List<Map<String, String>>> scheduleData;

  AllSubject({
    super.key,
    required this.name,
    required this.scheduleData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.topLeft,
        child: ListView.builder(
          itemCount: scheduleData.length,
          itemBuilder: (context, index) {
            String date = scheduleData.keys.elementAt(index);
            var rightDate = stringDateToTypeDate(date);
            List<Map<String, String>> items = scheduleData[date] ?? [];
            final fItems = [
              for (var lesson in items) ...[
                if (lesson['subject'] == name) lesson
              ]
            ];
            if ((fItems.isNotEmpty ) && (dataCompare(currentDate, stringDateToTypeDate(date)))) {
              return Column(
                children: [
                  dayTitle(date),
                  for (var lesson in fItems) ...[
                    dayLesson(lesson, scheduleData, context)
                  ]
                ],
              );
            } else {
              return const Column();
            }
          },
        ),
      ),
    );
  }
}

class ScheduleListView extends StatefulWidget {
  const ScheduleListView({super.key});

  @override
  _ScheduleListViewState createState() => _ScheduleListViewState();
}

class _ScheduleListViewState extends State<ScheduleListView> {
  Map<String, List<Map<String, String>>> scheduleData = {};
  var rightIndex = 0;
  final currentDate = DateTime.now();
  var firestoreFlag = false;


  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      String content = await rootBundle.loadString('assets/schedule.json');
      Map<String, dynamic> jsonData = jsonDecode(content);
      setState(() {
        scheduleData = jsonData.map((key, value) {
          if (value is List) {
            List<Map<String, String>> dataList = (value as List).map((item) {
              return Map<String, String>.from(item as Map<String, dynamic>);
            }).toList();
            return MapEntry(key, dataList);
          } else {
            return MapEntry(key, []);
          }
        });
      });
    } catch (e) {
      print('Ошибка чтения файла JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if(scheduleData.isNotEmpty){
      Iterable<String> k = scheduleData.keys;
      print(k.toString());
      for(var i = 0; i<scheduleData.length;i++){
        String stDate = k.elementAt(i);
        if(dataCompare( currentDate, stringDateToTypeDate(stDate)) == true) {
          rightIndex = i;
        }
      }
    }
    final medText = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:  const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Расписание'),
          ],
        ),
      ),
      body: Center(
        child: scheduleData.isEmpty
            ? const CircularProgressIndicator()
            : Align(
                alignment: Alignment.topLeft,
                child: ListView(
                  children: [
                    for (var el in scheduleData.keys) ...[
                        if (dataCompare(currentDate, stringDateToTypeDate(el)) == true)
                    Column(children: [dayTitle(el), for(var lesson in scheduleData[el]!)...[dayLesson(lesson, scheduleData, context)]],)
                  ]],
                )),
      ),
    );
  }
}

// ListView.builder(
// itemCount: scheduleData.length,
// itemBuilder: (context, index) {
// String date = scheduleData.keys.elementAt(index);
// var rightDate = stringDateToTypeDate(date);
// if (dataCompare(currentDate, stringDateToTypeDate(date)) ==
// true) {
// List<Map<String, String>> items =
// scheduleData[date] ?? [];
// return Column(
// children: [
// dayTitle(date),
// for (var lesson in items) ...[
// dayLesson(lesson, scheduleData, context),
// ],
// ],
// );
// } else {
// return const Column();
// }
// },
// ),
