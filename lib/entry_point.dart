import 'package:flai_quiz/api/base_api_dio.dart';
import 'package:flai_quiz/api/quiz_api_dio.dart';
import 'package:flai_quiz/get_page_by_route_name.dart';
import 'package:flai_quiz/mixins/set_state_after_frame.dart';
import 'package:flai_quiz/models/quiz.dart';
import 'package:flai_quiz/ui/custom_theme.dart';
import 'package:flai_quiz/ui/quiz_success_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'get_bloc_providers.dart';

void initAllApis() {
  initApis(
    ApiInitializer(
      apis: [
        QuizApiDio(),
      ],
      modelDeserializers: {
        Query: Query.deserialize,
        Question: Question.deserialize,
      },
    ),
  );
}

class EntryPoint extends StatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "[NAVIGATOR KEY]");

  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint>
    with WidgetsBindingObserver, SetStateAfterFrame {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initAllApis();
    _initSettings();
  }

  Future _initSettings() async {
    await SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    safeSetState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: getBlocProviders(context),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return MaterialApp(
            navigatorKey: EntryPoint.navigatorKey,
            debugShowCheckedModeBanner: true,
            showPerformanceOverlay: false,
            title: '',
            onGenerateRoute: (RouteSettings routeSettings) {
              bool fullScreenDialog = isFullscreenDialog(
                routeSettings.name,
              );
              bool maintain = maintainState(
                routeSettings.name,
              );

              return CupertinoPageRoute(
                builder: (BuildContext context) {
                  final page = getPageByRouteName(
                    routeSettings.name,
                    routeSettings.arguments,
                  );
                  return page;
                },
                maintainState: maintain,
                fullscreenDialog: fullScreenDialog,
                settings: routeSettings,
                //title: routeSettings.name,
              );
            },
            builder: (BuildContext c, Widget? widget) {
              final MediaQueryData data = MediaQuery.of(c);

              final child = Stack(
                children: <Widget>[
                  widget ?? SizedBox.shrink(),
                  QuizSuccessOverlay(),
                ],
              );
              return CustomThemeData(
                theme: LightTheme(),
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}
