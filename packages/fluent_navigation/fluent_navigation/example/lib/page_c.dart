import 'package:flutter/material.dart';

class PageC extends StatelessWidget {
  const PageC({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page C"),
      ),
      body: const Center(
        child: Text(
          "Page C",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
