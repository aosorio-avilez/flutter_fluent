import 'package:flutter/material.dart';

/// Definition of a fluent route
class FluentRoute {
  const FluentRoute(
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
