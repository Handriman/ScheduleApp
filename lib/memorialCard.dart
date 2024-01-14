import 'package:flutter/material.dart';

import 'main.dart';

import 'package:week_of_year/week_of_year.dart';


ListTile eventTile(String event, BuildContext context) {
  return ListTile(
    subtitle: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: Text(event,),
    ),
  );
}
