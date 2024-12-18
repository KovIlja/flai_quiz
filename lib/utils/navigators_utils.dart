import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flai_quiz/entry_point.dart';

NavigatorState get navigatorState {
  return EntryPoint.navigatorKey.currentState!;
}

BuildContext get appContext {
  return EntryPoint.navigatorKey.currentContext!;
}

void pop<T extends Object?>([T? result]) {
  if (navigatorState.canPop()) {
    if (kDebugMode) {
      print('NAV: pop()');
    }
    navigatorState.pop<T>(result);
  }
}

Future<bool> maybePop<T extends Object?>([T? result]) async {
  return navigatorState.maybePop<T>(result);
}

Future<T?> push<T extends Object?>(Route<T> route) {
  if (kDebugMode) {
    print('NAV: push(${route.runtimeType})');
  }
  return navigatorState.push<T>(route);
}

Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
  String routeName, {
  Object? arguments,
}) async {
  if (kDebugMode) {
    print('NAV: pushNamedAndRemoveUntil($routeName)');
  }
  return navigatorState.pushNamedAndRemoveUntil<T>(
    routeName,
    (route) => false,
    arguments: arguments,
  );
}

Future<T?> pushNamed<T extends Object?>(
  String routeName, {
  Object? arguments,
  bool popPrevious = false,
}) async {
  if (kDebugMode) {
    print('NAV: pushNamed($routeName)');
  }

  if (popPrevious) {
    pop();
  }
  return navigatorState.pushNamed<T>(
    routeName,
    arguments: arguments,
  );
}
