import 'package:flutter/material.dart';

import 'main.dart';
import 'dayLesson.dart';

import 'package:week_of_year/week_of_year.dart';



ListTile dayTitle(String date,List<Map<String, String>> lessons, BuildContext context, Map<String, Map<String, List<String>>> calendar) {
  final normDate = stringDateToTypeDate(date);
  final odd = normDate.weekOfYear % 2 == 0 ? '(чт)' : '(нч)';
  return ListTile(
    onTap: () {
      Navigator.push(
        context,
        SizeRoute(
          page: calendarTest(
            calendar: calendar,
            date: date,
          ),
        ),
      );
    },

    title: Container(
        padding: const EdgeInsets.only(top: 2, left: 0, bottom: 2, right: 0),
        decoration: BoxDecoration(
            // color: Colors.deepPurple.shade50,
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(15)),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$odd ${wek[normDate.weekday.toString()]} $date',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        )),
  );
}




ListTile dayTitleNoCal(String date,List<Map<String, String>> lessons, BuildContext context) {
  final normDate = stringDateToTypeDate(date);
  final odd = normDate.weekOfYear % 2 == 0 ? '(чт)' : '(нч)';
  return ListTile(

    title: Container(
        padding: const EdgeInsets.only(top: 2, left: 0, bottom: 2, right: 0),
        decoration: BoxDecoration(
          // color: Colors.deepPurple.shade50,
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(15)),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$odd ${wek[normDate.weekday.toString()]} $date',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        )),
  );
}




