#!/bin/bash

# Flutter
flutter config --no-analytics

# Melos
flutter pub global activate melos

# Very Good CLI
flutter pub global activate very_good_cli
very_good --analytics false