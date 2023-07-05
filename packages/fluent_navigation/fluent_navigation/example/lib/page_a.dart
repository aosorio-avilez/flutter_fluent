import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:flutter/material.dart';

class PageOne extends StatelessWidget {
  const PageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Page A",
            style: TextStyle(fontSize: 24),
          ),
          ElevatedButton(
            onPressed: () => Fluent.get<NavigationApi>().pushTo("c"),
            child: const Text("Go to Page C"),
          ),
        ],
      ),
    );
  }
}
