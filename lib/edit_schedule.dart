import 'dart:convert';

import 'dayLesson.dart';
import 'file_work.dart';
import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';

// Future<Map<String, List<Map<String, String>>>>

class Add_new_lesson extends StatefulWidget {
  List<Map<String, String>> lessons;
  String date;
  BuildContext context;

  Add_new_lesson({super.key, required this.lessons, required this.context, required this.date});

  @override
  State<Add_new_lesson> createState() => _Add_new_lessonState();
}

class _Add_new_lessonState extends State<Add_new_lesson> {
  Map<String, dynamic> edited = {};

  List<bool> flags = [];
  int leng = 0;
  Map<String, dynamic> b = {};
  String c = "";

  @override
  void initState() {
    leng = widget.lessons.length;
    edited = {};
    c = "";
    for (var i = 0; i < leng; i++) {
      flags.add(true);
    }
    super.initState();
  }

  Future<void> getEdited(CounterStorage storage) async {
    final text = await storage.readCounter();
    Map<String, dynamic> jsonData = jsonDecode(text);

    setState(() {
      edited = jsonData;
    });
  }

  Future<void> Test(CounterStorage storage) async {
    final text = await storage.readCounter();
    final temp = text;
    Map<String, dynamic> n = jsonDecode(text);

    setState(() {
      // c = text;
      b = n;
    });
  }

  Future<void> write(CounterStorage storage, String text) async {
    await storage.writeCounter(text);
  }

  @override
  Widget build(BuildContext context) {
    CounterStorage storage = CounterStorage();
    setState(() {
      getEdited(storage);
    });

    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    Map<String, Color> colorize = {};
    if ((!isDarkMode)) {
      colorize = {
        '(Лекционные занятия)': Colors.cyan.shade50
            .harmonizeWith(Theme.of(context).colorScheme.secondary),
        '(Лаб.  занятия - 17)': Colors.orange.shade50
            .harmonizeWith(Theme.of(context).colorScheme.secondary),
        '(Практические занятия)': Colors.green.shade50
            .harmonizeWith(Theme.of(context).colorScheme.secondary)
      };
    } else {
      double k = 0.4;
      int a = 70;

      colorize = {
        '(Лекционные занятия)': darken(Colors.cyan.shade50, k)
            .harmonizeWith(Theme.of(context).colorScheme.primary)
            .withAlpha(a),
        '(Лаб.  занятия - 17)': darken(Colors.orange.shade50, k)
            .harmonizeWith(Theme.of(context).colorScheme.primary)
            .withAlpha(a),
        '(Практические занятия)': darken(Colors.green.shade50, k)
            .harmonizeWith(Theme.of(context).colorScheme.primary)
            .withAlpha(a)
      };
    }

    var a = {
      "basic_edited": {
        "(чт) Понедельник": {
          "isChanged": "false",
          "state": ""
        },
        "(чт) Вторник": {
          "isChanged": "false",
          "state": ""
        },
        "(чт) Среда": {
          "isChanged": "false",
          "state": ""
        },
        "(чт) Четверг": {
          "isChanged": "false",
          "state": ""
        },
        "(чт) Пятница": {
          "isChanged": "false",
          "state": ""
        },
        "(чт) Суббота": {
          "isChanged": "false",
          "state": ""
        },
        "(чт) Воскресенье": {
          "isChanged": "false",
          "state": ""
        },
        "(нч) Понедельник": {
          "isChanged": "true",
          "state": "true, true, true, false"
        },
        "(нч) Вторник": {
          "isChanged": "false",
          "state": ""
        },
        "(нч) Среда": {
          "isChanged": "false",
          "state": ""
        },
        "(нч) Четверг": {
          "isChanged": "false",
          "state": ""
        },
        "(нч) Пятница": {
          "isChanged": "false",
          "state": ""
        },
        "(нч) Суббота": {
          "isChanged": "false",
          "state": ""
        },
        "(нч) Воскресенье": {
          "isChanged": "false",
          "state": ""
        },



      }

    };
    // write(storage, jsonEncode(a));
    getEdited(storage);

    return Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
                onPressed: () {
                  write(storage, jsonEncode(a));
                },
                child: Text("write")),
            ElevatedButton(
                onPressed: () {
                  Test(storage);
                },
                child: Text("read"))
          ],
        ),
        body: (edited.isEmpty)
            ? const CircularProgressIndicator()
            : ListView.builder(
                itemCount: widget.lessons.length,
                itemBuilder: (context, index) {

                  var lk = "".trim();
                  List<bool> switchList = [];
                  final date = edited["basic_edited"][widget.date];
                  if( date["isChanged"]== 'true'){
                    lk = "lk";
                    final temp = date["state"].trim().split(",");
                    lk = "$temp";
                    for(var item in temp) {
                      switchList.add((item == "true" ||item == " true" || item == "true ")? true : false);
                    }

                  } else {
                    lk = "not lk";
                    switchList = flags;
                  }

                  return ListTile(
                    title: Container(
                        padding:
                            const EdgeInsets.only(left: 15, top: 5, right: 15),
                        decoration: BoxDecoration(
                          color: colorize[widget.lessons[index]['type']],
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${widget.lessons[index]["time"]}'),
                            Switch(
                                value: switchList[index],
                                onChanged: (value) {
                                  switchList[index] = value;
                                  edited["basic_edited"][widget.date]["isChanged"] = "true";
                                  edited["basic_edited"][widget.date]["state"] = switchList.toString().substring(1, switchList.toString().length-1);
                                  setState(() {

                                    write(storage, jsonEncode(edited));

                                  });
                                })
                          ],
                        )),
                    subtitle: Container(
                      padding:
                          const EdgeInsets.only(left: 15, bottom: 5, right: 15),
                      decoration: BoxDecoration(
                        color: colorize[widget.lessons[index]['type']],
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${widget.lessons[index]["subject"]}'),
                          Text('${widget.lessons[index]["type"]}'),
                          Text('${widget.lessons[index]["location"]}'),
                          Text('${widget.lessons[index]["teacher"]}'),
                          Text("$switchList"),
                          Text("${edited["basic_edited"][widget.date]}")
                        ],
                      ),
                    ),
                  );
                }));
  }
}
