import 'dart:convert';

import 'dart:io';

import 'dart:math';

import 'package:Raspisanie/file_work.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week_of_year/date_week_extensions.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'darkThemeThings.dart';
import 'dayLesson.dart';
import 'dayTile.dart';
import 'schedule_module.dart';

import 'memorialCard.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('group', '121111');
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(
        preferences: prefs,
      ),
    ),
  );
}

double textScaleFactor(BuildContext context, {double maxTextScaleFactor = 2}) {
  final width = MediaQuery.of(context).size.width;
  double val = (width / 1400) * maxTextScaleFactor;
  return max(1, min(val, maxTextScaleFactor));
}

class MyApp extends StatefulWidget {
  SharedPreferences preferences;

  MyApp({super.key, required this.preferences});

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
        home: ScheduleListView(widget.preferences, themeProvider),
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
  SharedPreferences preferences;

  ScheduleListView(
    this.preferences,
    this.themeProvider, {
    super.key,
  });

  @override
  _ScheduleListViewState createState() => _ScheduleListViewState();
}

class _ScheduleListViewState extends State<ScheduleListView> {
  late Schedule scheduleManager;

  // Map<String, List<Map<String, String>>> scheduleData = {};

  Map<String, Map<String, List<String>>> calendar = {};

  Map<String, dynamic> edited = {};
  var rightIndex = 0;
  String finder = '';
  Map<String, List<Map<String, String>>> finalSchedule = {};

  late Future<bool> isUpdated;

  // НАДО БУДЕТ ОБРАТНО ПОМЕНЯТЬ ДАТУ

  final currentDate = DateTime.now();

  // final currentDate = DateTime.parse("2023-01-01 00:00:00.000");

  var test_text = "";
  late Future<Map<String, dynamic>> weather;
  late String group;
  late SharedPreferences prefs;

  Future<void> get_group() async {
    prefs = await SharedPreferences.getInstance();

    // if( prefs.getKeys().contains('group') == false) {
    //   prefs.setString('group', '121111');
    // }
    group = prefs.getString('group')!;
  }

  @override
  void initState() {
    super.initState();

    String? group = widget.preferences.getString('group');
    if (group == null) {
      group = '121111';
      widget.preferences.setString('group', '121111');
    }
    scheduleManager = Schedule(group);
    isUpdated = scheduleManager.updateSchedule();

    test_text = "";

    edited = {};

    finder = '';
    loadCalendar();
    // weather = fetchWeather();
    scheduleManager.loadSchedule();
    scheduleManager.mainSchedule;
    finalSchedule = Map<String, List<Map<String, String>>>.from(
        scheduleManager.mainSchedule);

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
      DateTime elDate = stringDateToTypeDate(el);
      // print(t.difference(el_date).inDays);
      if ((dataCompare(t, elDate) == true) &&
          (t.difference(elDate).inDays >= -14)) {
        temp[el] = List.from(finalSchedule[el]!);
      }
    }

    return temp;
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

  Future<http.Response> fetchSchedule(String group) {
    return http
        .get(Uri.parse("https://handri.pythonanywhere.com/get_data/$group"));
  }

  void findMe(bool flag) {
    setState(() {
      // readScheduleFile();
      finalSchedule = Map<String, List<Map<String, String>>>.from(
          scheduleManager.mainSchedule);

      Map<String, List<Map<String, String>>> temp =
          Map<String, List<Map<String, String>>>.from(
              scheduleManager.mainSchedule);

      for (var i = 0; i < scheduleManager.mainSchedule.length; i++) {
        var items =
            finalSchedule[scheduleManager.mainSchedule.keys.elementAt(i)];
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
    findMe(false);
    final medText = Theme.of(context);

    // ГЛАВНЫЙ ЭКРАН
    return FutureBuilder<bool>(
        future: isUpdated,
        builder: (context, snapshot) {
          return Scaffold(
            drawer: Drawer(
              child: SafeArea(
                child: Column(
                  children: [
                    const DrawerHeader(child: Text('Настройки')),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ThemeSwitcher(),
                        Spacer(),
                        Text("Тёмная тема"),
                      ],
                    ),
                    TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20),
                        hintText: scheduleManager.group,
                      ),
                      onSubmitted: (String value) {
                        widget.preferences.setString('group', value);
                        setState(() {
                          scheduleManager.group = value;
                          scheduleManager.updateSchedule();
                          scheduleManager.loadSchedule();
                          // upt1();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      onSubmitted: (String value) {
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
                      ? const Icon(Icons.check)
                      : const Icon(Icons.update_disabled_rounded),
                ],
              ),
            ),
            body: Center(
              child: (scheduleManager.mainSchedule.isEmpty)
                  // ? const CircularProgressIndicator()
                  // ? Text(scheduleManager.mainSchedule.toString())
                  ? RefreshIndicator(
                      child: ListView(
                        children: [const CircularProgressIndicator()],
                      ),
                      onRefresh: () async {
                        setState(() {
                          scheduleManager.loadSchedule();
                          finalSchedule =
                              Map<String, List<Map<String, String>>>.from(
                                  scheduleManager.mainSchedule);
                        });
                        return Future.delayed(Duration(seconds: 3));
                      })
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
