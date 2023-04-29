import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:flutter/material.dart';

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page two")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Fluent.get<NavigationApi>().pop(true);
          },
          child: const Text("Go back to previous page"),
        ),
      ),
    );
  }
}
