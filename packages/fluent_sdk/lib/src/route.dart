import 'package:flutter/material.dart';

class Route {
  const Route(
    this.name,
    this.path, {
    this.page,
    this.builder,
    this.initial = false,
  });

  final String name;
  final String path;
  final Widget? page;
  final Widget Function(Map<String, String>?, Map<String, String>?)? builder;
  final bool initial;
}
