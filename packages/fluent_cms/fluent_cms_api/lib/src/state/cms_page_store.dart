import 'package:flutter/foundation.dart';

/// Function signature for synchronous field validation in [CmsPageStore].
/// Returns an error message when invalid, or `null` when valid.
typedef CmsFieldValidator = String? Function(Object? value);

/// Contract for a page-scoped reactive state store supporting two-way binding,
/// optimistic mutations, and form validation.
abstract class CmsPageStore {
  /// Creates a [CmsPageStore].
  const CmsPageStore();

  /// Retrieves the current value for [key] cast to [T], or `null` if absent
  /// or incompatible.
  T? getValue<T>(String key);

  /// Updates the value for [key] and notifies listeners registered on that key.
  void setValue(String key, Object? value);

  /// Returns a [ValueListenable] for surgical rebuilds on a single [key].
  ValueListenable<Object?> listenKey(String key);

  /// Registers a synchronous [validator] for [key].
  void registerValidator(String key, CmsFieldValidator validator);

  /// Executes the validator for [key] and returns the validation error, if any.
  String? validateKey(String key);

  /// Validates all registered keys and returns `true` if every key is valid.
  bool validateAll();

  /// Returns a [ValueListenable] emitting the current validation error for
  /// [key].
  ValueListenable<String?> listenError(String key);

  /// Exports a snapshot of all current key-value pairs in the store.
  Map<String, dynamic> toMap();

  /// Restores state values from a previous [snapshot].
  void restoreState(Map<String, dynamic> snapshot);

  /// Clears stored values. If [preserveUserState] is `true`, user-bound values
  /// are retained across refreshes.
  void clear({bool preserveUserState = false});

  /// Whether this store has been disposed.
  bool get isDisposed;

  /// Disposes all internal notifiers and active timers.
  void dispose();
}
