import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:flutter/material.dart';

class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page one")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Push to registered route two
            getApi<NavigationApi>().pushTo("two");
          },
          child: const Text("Navigate to second page"),
        ),
      ),
    );
  }
}
