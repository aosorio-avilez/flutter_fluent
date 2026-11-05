import 'package:fluent_cms_api/fluent_cms_api.dart';
import 'package:flutter/foundation.dart';

/// Page-scoped reactive store backed by per-key [ValueNotifier]s for surgical
/// widget rebuilds, form validation, and state preservation across refreshes.
class PageScopedReactiveStore implements CmsPageStore {
  /// Creates a [PageScopedReactiveStore] with optional [initialValues].
  PageScopedReactiveStore({
    Map<String, dynamic>? initialValues,
  }) {
    if (initialValues != null) {
      for (final entry in initialValues.entries) {
        _valueNotifiers[entry.key] = ValueNotifier<Object?>(entry.value);
      }
    }
  }

  final Map<String, ValueNotifier<Object?>> _valueNotifiers =
      <String, ValueNotifier<Object?>>{};
  final Map<String, ValueNotifier<String?>> _errorNotifiers =
      <String, ValueNotifier<String?>>{};
  final Map<String, CmsFieldValidator> _validators =
      <String, CmsFieldValidator>{};
  final Set<String> _userMutatedKeys = <String>{};

  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  @override
  T? getValue<T>(String key) {
    if (_isDisposed) return null;
    final val = _valueNotifiers[key]?.value;
    if (val is T) return val;
    return null;
  }

  @override
  void setValue(String key, Object? value) {
    if (_isDisposed) return;
    _userMutatedKeys.add(key);
    final existing = _valueNotifiers[key];
    if (existing != null) {
      existing.value = value;
    } else {
      _valueNotifiers[key] = ValueNotifier<Object?>(value);
    }

    if (_validators.containsKey(key)) {
      validateKey(key);
    }
  }

  @override
  ValueListenable<Object?> listenKey(String key) {
    final existing = _valueNotifiers[key];
    if (existing != null) {
      return existing;
    }
    final created = ValueNotifier<Object?>(null);
    if (!_isDisposed) {
      _valueNotifiers[key] = created;
    }
    return created;
  }

  @override
  void registerValidator(String key, CmsFieldValidator validator) {
    if (_isDisposed) return;
    _validators[key] = validator;
  }

  @override
  String? validateKey(String key) {
    if (_isDisposed) return null;
    final validator = _validators[key];
    if (validator == null) return null;

    final currentValue = _valueNotifiers[key]?.value;
    final error = validator(currentValue);
    _setError(key, error);
    return error;
  }

  @override
  bool validateAll() {
    if (_isDisposed) return false;
    var allValid = true;
    for (final entry in _validators.entries) {
      final error = validateKey(entry.key);
      if (error != null) {
        allValid = false;
      }
    }
    return allValid;
  }

  @override
  ValueListenable<String?> listenError(String key) {
    final existing = _errorNotifiers[key];
    if (existing != null) {
      return existing;
    }
    final created = ValueNotifier<String?>(null);
    if (!_isDisposed) {
      _errorNotifiers[key] = created;
    }
    return created;
  }

  void _setError(String key, String? error) {
    final existing = _errorNotifiers[key];
    if (existing != null) {
      existing.value = error;
    } else {
      _errorNotifiers[key] = ValueNotifier<String?>(error);
    }
  }

  @override
  Map<String, dynamic> toMap() {
    final snapshot = <String, dynamic>{};
    if (_isDisposed) return snapshot;
    for (final entry in _valueNotifiers.entries) {
      snapshot[entry.key] = entry.value.value;
    }
    return snapshot;
  }

  @override
  void restoreState(Map<String, dynamic> snapshot) {
    if (_isDisposed) return;
    for (final entry in snapshot.entries) {
      final existing = _valueNotifiers[entry.key];
      if (existing != null) {
        existing.value = entry.value;
      } else {
        _valueNotifiers[entry.key] = ValueNotifier<Object?>(entry.value);
      }
      _userMutatedKeys.add(entry.key);
    }
  }

  @override
  void clear({bool preserveUserState = false}) {
    if (_isDisposed) return;
    for (final entry in _valueNotifiers.entries) {
      if (preserveUserState && _userMutatedKeys.contains(entry.key)) {
        continue;
      }
      entry.value.value = null;
    }
    if (!preserveUserState) {
      _userMutatedKeys.clear();
      for (final entry in _errorNotifiers.entries) {
        entry.value.value = null;
      }
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    for (final entry in _valueNotifiers.entries) {
      entry.value.dispose();
    }
    for (final entry in _errorNotifiers.entries) {
      entry.value.dispose();
    }
    _valueNotifiers.clear();
    _errorNotifiers.clear();
    _validators.clear();
    _userMutatedKeys.clear();
  }
}
