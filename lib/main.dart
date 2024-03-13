import 'dart:convert';
import 'dart:io';

import 'dart:math';

import 'package:Raspisanie/getSchedule.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:path_provider/path_provider.dart';
import 'package:week_of_year/date_week_extensions.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'darkThemeThings.dart';
import 'dayLesson.dart';
import 'dayTile.dart';
// import 'getSchedule.dart';

import 'memorialCard.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

double textScaleFactor(BuildContext context, {double maxTextScaleFactor = 2}) {
  final width = MediaQuery.of(context).size.width;
  double val = (width / 1400) * maxTextScaleFactor;
  return max(1, min(val, maxTextScaleFactor));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.deepPurple, brightness: Brightness.dark);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
                textScaler:
                    TextScaler.linear(MediaQuery.of(context).textScaleFactor)),
            child: child!,
          );
        },
        theme: ThemeData(
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 17),
            bodyLarge: TextStyle(fontSize: 22),
          ),
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.primaries[2]),
          colorScheme: lightColorScheme ??
              ColorScheme.fromSeed(
                  seedColor: Colors.primaries[2], brightness: Brightness.light),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 17),
            bodyLarge: TextStyle(fontSize: 22),
          ),
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.primaries[2]),
          colorScheme: darkColorScheme ??
              ColorScheme.fromSeed(
                  seedColor: Colors.primaries[2], brightness: Brightness.dark),
          useMaterial3: true,
        ),
        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: ScheduleListView(themeProvider),
      );
    });
  }
}

String normalizeDate(String badString) {
  List<String> tempString = badString.split('-');

  var normalString =
      '${tempString[2].characters.take(2).string}.${tempString[1]}';

  return normalString;
}

DateTime stringDateToTypeDate(String stringDate) {
  final temp = stringDate.split('.');
  int tempYaer = 0;

  tempYaer = int.parse(temp[2]);
  final data =
      DateTime.utc(tempYaer, int.parse(temp[1]), int.parse(temp[0]), 23, 59);

  return data;
}

bool dataCompare(DateTime currentDate, DateTime comparedDate) {
  // if (comparedDate.isBefore(currentDate)) {
  //   return false;
  // } else {
  //   return true;
  // }

  return comparedDate.isBefore(currentDate) ? false : true;
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

class calendarTest extends StatelessWidget {
  Map<String, Map<String, List<String>>> calendar;
  String date;

  calendarTest({super.key, required this.calendar, required this.date});

  @override
  Widget build(BuildContext context) {
    final mainClasses = [
      'block holidays',
      'block thisDay',
      'block homiesCal',
      'block knownDates',
    ];

    var currentDate = stringDateToTypeDate(date);
    String stringDate = currentDate.toString();
    String temp = stringDate;

    var list = temp.split(' ')[0].split('-');
    stringDate = '${list[2]}.${list[1]}';
    var text = '';
    List<String> textList = [];
    for (var clas in mainClasses) {
      if (calendar[stringDate]!.keys.contains(clas)) {
        for (var i = 0; i < calendar[stringDate]![clas]!.length; i++) {
          text = '$text${calendar[stringDate]![clas]![i]}\n';
          textList.add(calendar[stringDate]![clas]![i]);
        }
      }
    }
    print("text");

    return Scaffold(
      appBar: AppBar(
        title: Text(date),
      ),
      body: ListView(
        children: [
          for (var el in textList) ...[eventTile(el, context)]
        ],
      ),
    );
  }
}

class AllSubject extends StatelessWidget {
  final String name;
  final currentDate = DateTime.now();
  ThemeProvider themeProvider;
  Map<String, List<Map<String, String>>> scheduleData;

  AllSubject(
      {super.key,
      required this.name,
      required this.scheduleData,
      required this.themeProvider});

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
            if ((fItems.isNotEmpty) &&
                (dataCompare(currentDate, stringDateToTypeDate(date)))) {
              return Column(
                children: [
                  dayTitleNoCal(date, fItems, context),
                  for (var lesson in fItems) ...[
                    dayLesson(themeProvider, lesson, scheduleData, context)
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

String odd(DateTime normDate) {
  return normDate.weekOfYear % 2 == 0 ? '(чт)' : '(нч)';
}

class ScheduleListView extends StatefulWidget {
  ThemeProvider themeProvider;

  ScheduleListView(
    this.themeProvider, {
    super.key,
  });

  @override
  _ScheduleListViewState createState() => _ScheduleListViewState();
}

class _ScheduleListViewState extends State<ScheduleListView> {
  Map<String, List<Map<String, String>>> scheduleData = {};

  Map<String, Map<String, List<String>>> calendar = {};

  Map<String, dynamic> edited = {};
  var rightIndex = 0;
  String finder = '';
  Map<String, List<Map<String, String>>> finalSchedule = {};
  Map<String, List<Map<String, String>>> shortSchedule = {};
  late Future<bool> isUpdated;

  // НАДО БУДЕТ ОБРАТНО ПОМЕНЯТЬ ДАТУ

  final currentDate = DateTime.now();

  // final currentDate = DateTime.parse("2023-01-01 00:00:00.000");

  var test_text = "";
  late Future<Map<String, dynamic>> weather;

  @override
  void initState() {
    test_text = "";
    super.initState();
    edited = {};
    isUpdated = upt1();
    finder = '';
    readScheduleFile();
    // loadJsonData();
    loadCalendar();
    // weather = fetchWeather();
    finalSchedule = Map<String, List<Map<String, String>>>.from(scheduleData);

    // shortSchedule = stripSchedule(scheduleData);
  }

  Future<bool> doesFileExist(String filePath) async {
    return File(filePath).exists();
  }

  Map<String, List<Map<String, String>>> stripSchedule(
      Map<String, List<Map<String, String>>> finalSchedule) {
    Map<String, List<Map<String, String>>> temp = {};
    var t = DateTime.now();

    for (var el in finalSchedule.keys) {
      DateTime el_date = stringDateToTypeDate(el);
      // print(t.difference(el_date).inDays);
      if ((dataCompare(t, el_date) == true) &&
          (t.difference(el_date).inDays >= -14)) {
        temp[el] = List.from(finalSchedule[el]!);
      }
    }

    return temp;
  }

  Future<void> readScheduleFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/121111.json';
    final isExist = await doesFileExist(filePath);

    if (isExist) {
      loadJsonData();
    } else {
      String content = await rootBundle.loadString('assets/121111.json');
      final file = File(filePath);
      file.writeAsString(content);
      loadJsonData();
    }
  }

  Future<void> loadCalendar() async {
    try {
      String content = await rootBundle.loadString('assets/calendar.json');
      Map<String, dynamic> jsonData = jsonDecode(content);
      setState(() {
        calendar = jsonData.map((key, value) {
          if (value is Map<String, dynamic>) {
            Map<String, List<String>> dataMap = (value).map((subKey, subValue) {
              if (subValue is List<dynamic>) {
                List<String> subList =
                    subValue.map((item) => item.toString()).toList();
                return MapEntry(subKey, subList);
              } else {
                return MapEntry(subKey, <String>[]);
              }
            });
            return MapEntry(key, dataMap);
          } else {
            return MapEntry(key, <String, List<String>>{});
          }
        });
      });
    } catch (e) {
      print('Ошибка чтения файла JSON: $e');
    }
  }

  Future<void> loadJsonData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/121111.json';
      String content = await File(filePath).readAsStringSync();
      Map<String, dynamic> jsonData = jsonDecode(content);
      setState(() {
        scheduleData = jsonData.map((key, value) {
          if (value is List) {
            List<Map<String, String>> dataList = (value).map((item) {
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


  Future<http.Response> fetchSchedule() {
    return http.get(Uri.parse("https://handri.pythonanywhere.com/get_data"));
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
      readScheduleFile();
      return true;
    } else {
      return false;
    }
  }


  void findMe(bool flag) {
    setState(() {
      // readScheduleFile();
      finalSchedule = Map<String, List<Map<String, String>>>.from(scheduleData);

      Map<String, List<Map<String, String>>> temp =
          Map<String, List<Map<String, String>>>.from(scheduleData);

      for (var i = 0; i < scheduleData.length; i++) {
        var items = finalSchedule[scheduleData.keys.elementAt(i)];
        List<Map<String, String>>? tempList = [];
        for (var lesson in items!) {
          if ((lesson['subject']!
                  .toLowerCase()
                  .contains(finder.toLowerCase())) ||
              (finder == "") ||
              (lesson['teacher']!
                  .toLowerCase()
                  .contains(finder.toLowerCase())) ||
              (finalSchedule.keys.elementAt(i).contains(finder)) ||
              (lesson['type']!.toLowerCase().contains(finder.toLowerCase()))) {
            tempList.add(lesson);
          }
        }
        temp.update(finalSchedule.keys.elementAt(i), (value) => tempList);
      }
      finalSchedule = temp;
      if (finder != "") {
        finalSchedule.removeWhere((key, value) => value.isEmpty);
      }
      // shortSchedule = stripSchedule(scheduleData);
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (scheduleData.isNotEmpty) {
    //   Iterable<String> k = scheduleData.keys;
    //
    //   for (var i = 0; i < scheduleData.length; i++) {
    //     String stDate = k.elementAt(i);
    //     if (dataCompare(currentDate, stringDateToTypeDate(stDate)) == true) {
    //       rightIndex = i;
    //     }
    //   }
    // }

    findMe(false);
    final medText = Theme.of(context);

    // ГЛАВНЫЙ ЭКРАН

    return FutureBuilder<bool>(
        future: isUpdated,
        builder: (context, snapshot) {




          return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ThemeSwitcher(),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      onChanged: (String value) {
                        finder = value;
                        findMe(true);
                        // setState(() {});
                      },
                      decoration: const InputDecoration(
                        hintText: 'Я помогу в поиске',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  (snapshot.hasData == true && finalSchedule.isEmpty == false)
                      ? Icon(Icons.check)
                      : Icon(Icons.update_disabled_rounded),
                ],
              ),
            ),
            body: Center(
              child: (finalSchedule.isEmpty)
                  ? Row(
                      children: [
                        // Text("${snapshot.data}"),
                        const CircularProgressIndicator(),
                      ],
                    )
                  : Align(
                      alignment: Alignment.topLeft,
                      child: ListView(
                        // itemExtent: 700,
                        children: [
                          // Text("${snapshot.data}"),
                          // Text(currentDate.toString()),
                          for (var el in finalSchedule.keys) ...[
                            if (dataCompare(
                                    currentDate, stringDateToTypeDate(el)) ==
                                true)
                              Column(
                                children: [
                                  dayTitle(el, finalSchedule[el]!, context,
                                      calendar),
                                  for (var i = 0;
                                      i < finalSchedule[el]!.length;
                                      i++) ...[
                                    dayLesson(
                                        widget.themeProvider,
                                        finalSchedule[el]![i],
                                        finalSchedule,
                                        context)
                                  ],
                                ],
                              )
                          ]
                        ],
                      )),
            ),
          );
        });
  }
}
