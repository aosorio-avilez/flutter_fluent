import 'package:fluent_navigation/fluent_navigation.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fluent Navigation Example')),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Page A'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Page B'),
        ],
      ),
    );
  }

  void onTap(int value) {
    switch (value) {
      case 0:
        setState(() => selectedIndex = 0);
        return Fluent.get<NavigationApi>().navigateTo("a");
      case 1:
        setState(() => selectedIndex = 1);
        return Fluent.get<NavigationApi>().navigateTo("b");
      default:
        setState(() => selectedIndex = 0);
        return Fluent.get<NavigationApi>().navigateTo("a");
    }
  }
}
