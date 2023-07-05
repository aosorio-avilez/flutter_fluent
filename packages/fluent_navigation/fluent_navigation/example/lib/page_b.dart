import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:flutter/material.dart';

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Page B",
            style: TextStyle(fontSize: 24),
          ),
          ElevatedButton(
            onPressed: () => Fluent.get<NavigationApi>().navigateTo("d"),
            child: const Text("Go to Page D"),
          ),
        ],
      ),
    );
  }
}
