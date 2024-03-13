import 'package:flutter/material.dart';




ListTile eventTile(String event, BuildContext context) {
  return ListTile(
    subtitle: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: const BorderRadius.all(Radius.circular(15))),
      child: Text(event,),
    ),
  );
}
