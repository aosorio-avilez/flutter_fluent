import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Route extends Equatable {
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

  @override
  List<Object?> get props => [
        name,
        path,
        page,
        builder,
        initial,
      ];
}
