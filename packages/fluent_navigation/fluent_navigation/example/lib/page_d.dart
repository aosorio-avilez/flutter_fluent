import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:flutter/material.dart';

class PageD extends StatelessWidget {
  const PageD({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Page D",
            style: TextStyle(fontSize: 24),
          ),
          ElevatedButton(
            onPressed: () => Fluent.get<NavigationApi>().pop(),
            child: const Text("Go back"),
          ),
        ],
      ),
    );
  }
}
