import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:flutter/material.dart';

class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page one")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                // Push to registered route two
                final result = await Fluent.get<NavigationApi>().pushTo("two");
                if (result != null) {
                  debugPrint("Result: $result");
                }
              },
              child: const Text("Push to second page"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to page two
                Fluent.get<NavigationApi>().navigateTo("two");
              },
              child: const Text("Navigate to second page"),
            ),
          ],
        ),
      ),
    );
  }
}
