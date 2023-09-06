import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';

import 'dart:convert';
import 'dart:io';
import 'package:week_of_year/week_of_year.dart';



ListTile dayTitle(String date) {
  final norm_date = stringDateToTypeDate(date);
  final odd = norm_date.weekOfYear % 2 == 0 ? '(чт)' : '(нч)';
  return ListTile(
    title: Container(
        padding: EdgeInsets.only(top: 5, left: 0, bottom: 5, right: 0),
        decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(15)),
        child: Center(
          child: Text(
            '$odd ${wek[norm_date.weekday.toString()]} $date',
            style: TextStyle(color: Colors.black, fontSize: 25),
          ),
        )),
  );
}




