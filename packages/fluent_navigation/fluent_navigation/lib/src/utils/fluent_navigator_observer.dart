import 'package:flutter/widgets.dart';

/// Observer that tracks route changes (both imperative push/pop and declarative go)
/// and notifies listeners whenever the current route changes.
class FluentNavigatorObserver extends NavigatorObserver with ChangeNotifier {
  final List<Route<dynamic>> _routeStack = <Route<dynamic>>[];

  /// The currently active route on top of the stack.
  Route<dynamic>? get currentRoute => _routeStack.lastOrNull;

  /// The current path or route name of the top-most page route.
  String get currentPath {
    for (var i = _routeStack.length - 1; i >= 0; i--) {
      final name = _routeStack[i].settings.name;
      if (name != null && name.isNotEmpty) {
        return name.startsWith('/') ? name : '/$name';
      }
    }
    return '/';
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _routeStack.add(route);
    notifyListeners();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _routeStack.remove(route);
    notifyListeners();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _routeStack.remove(route);
    notifyListeners();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) {
      final index = _routeStack.indexOf(oldRoute);
      if (index != -1 && newRoute != null) {
        _routeStack[index] = newRoute;
      } else {
        _routeStack.remove(oldRoute);
        if (newRoute != null) {
          _routeStack.add(newRoute);
        }
      }
    } else if (newRoute != null) {
      _routeStack.add(newRoute);
    }
    notifyListeners();
  }
}
