import 'package:Raspisanie/darkThemeThings.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'main.dart';

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

Color darken(Color color, [double amount = .8]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

ListTile dayLesson(ThemeProvider themeProvider, Map<String, String> lesson,
    Map<String, List<Map<String, String>>> scheduleData, BuildContext context) {

  Map<String, Color> colorize = {};
  if (!themeProvider.isDarkMode) {
    colorize = {
      '(Лекционные занятия)': Colors.cyan.shade50
          .harmonizeWith(Theme.of(context).colorScheme.secondary),
      '(Лаб.  занятия - 17)': Colors.orange.shade50
          .harmonizeWith(Theme.of(context).colorScheme.secondary),
      '(Практические занятия)': Colors.green.shade50
          .harmonizeWith(Theme.of(context).colorScheme.secondary),
      '(КП)': Colors.red.shade100
          .harmonizeWith(Theme.of(context).colorScheme.secondary),
      '(Практика)': Colors.green.shade50
          .harmonizeWith(Theme.of(context).colorScheme.secondary),
      '(Экзамен)': Colors.red.shade100
          .harmonizeWith(Theme.of(context).colorScheme.secondary),
      '(КР)': Colors.red.shade100
          .harmonizeWith(Theme.of(context).colorScheme.secondary),
      '(ДЗ)': Colors.red.shade100
          .harmonizeWith(Theme.of(context).colorScheme.secondary),
      '(зч)': Colors.red.shade100
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
          .withAlpha(a),
      '(Практика)':darken(Colors.green.shade50, k)
          .harmonizeWith(Theme.of(context).colorScheme.primary)
          .withAlpha(a),
      '(КП)': darken(Colors.red.shade50, k)
          .harmonizeWith(Theme.of(context).colorScheme.primary)
          .withAlpha(a),
      '(Экзамен)': darken(Colors.red.shade50, k)
          .harmonizeWith(Theme.of(context).colorScheme.primary)
          .withAlpha(a),
      '(КР)': darken(Colors.red.shade50, k)
          .harmonizeWith(Theme.of(context).colorScheme.primary)
          .withAlpha(a),
      '(ДЗ)': darken(Colors.red.shade50, k)
          .harmonizeWith(Theme.of(context).colorScheme.primary)
          .withAlpha(a),
      '(зч)': darken(Colors.red.shade50, k)
          .harmonizeWith(Theme.of(context).colorScheme.primary)
          .withAlpha(a)
    };
  }

  return ListTile(

    onTap: () {
      Navigator.push(
        context,
        SizeRoute(
            page: AllSubject(
                themeProvider: themeProvider,
                name: lesson['subject'] ?? '',
                scheduleData: scheduleData)),
      );
    },
    title: Container(
        padding: const EdgeInsets.only(left: 15, top: 5),
        decoration: BoxDecoration(
          color: colorize[lesson['type']],
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${lesson["time"]} | ${lesson["location"]}'),
          ],
        )),
    subtitle: Container(
      padding: const EdgeInsets.only(left: 15, bottom: 5),
      decoration: BoxDecoration(
        color: colorize[lesson['type']],
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${lesson["subject"]}'),
          Text('${lesson["type"]}'),
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
