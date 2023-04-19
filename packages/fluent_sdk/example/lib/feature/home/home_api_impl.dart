import 'package:flutter/material.dart';

import 'home_api.dart';

class HomeApiImpl extends HomeApi {
  @override
  Widget getHomePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fluent SDK Demo"),
      ),
      body: const Center(
        child: Text("Hello from Fluent SDK"),
      ),
    );
  }
}
