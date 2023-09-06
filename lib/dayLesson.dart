import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';
import 'dart:convert';
import 'dart:io';
import 'package:week_of_year/week_of_year.dart';

final colorize = {
  '(Лекционные занятия)': Colors.blue.shade50,
  '(Лаб.  занятия - 17)': Colors.orange.shade50,
  '(Практические занятия)': Colors.green.shade50
};


class SizeRoute extends PageRouteBuilder {
  final Widget page;
  SizeRoute({required this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        ),
  );
}


ListTile dayLesson(Map<String, String> lesson,
    Map<String, List<Map<String, String>>> scheduleData, BuildContext context) {
  return ListTile(
    title: Container(
        padding: EdgeInsets.only(left: 15, top: 5),
        decoration: BoxDecoration(
          color: colorize[lesson['type']],
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${lesson["time"]}'),
            MaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  SizeRoute(page: AllSubject(name: lesson['subject']?? '', scheduleData: scheduleData)),
                );
              },
              child: Icon(Icons.arrow_drop_down),
              shape: CircleBorder(),
            ),
          ],
        )),
    subtitle: Container(
      padding: EdgeInsets.only(left: 15, bottom: 5),
      decoration: BoxDecoration(
        color: colorize[lesson['type']],
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${lesson["subject"]}'),
          Text('${lesson["type"]}'),
          Text('${lesson["location"]}'),
          Text('${lesson["teacher"]}'),
        ],
      ),
    ),
  );
}


// стандартный переход
// MaterialPageRoute(
// builder: (context) {
// return AllSubject(
// name: lesson['subject']!, scheduleData: scheduleData,);
// },
// )