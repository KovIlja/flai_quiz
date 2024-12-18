import 'package:flai_quiz/ui/color_base.dart';
import 'package:flai_quiz/utils/navigators_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class CustomTheme {
  String get name;

  CustomColorsBase get colors;

  TextStyle get normalTextStyle => TextStyle(
        fontSize: 17.0,
        fontWeight: kIsWeb ? FontWeight.w300 : FontWeight.w400,
        color: colors.iconColor,
      );
  TextStyle get boldTextStyle => TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
        color: colors.iconColor,
      );
  TextStyle get simpleWhiteButtonTextStyle => TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      );
  TextStyle get headerTextStyle => TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      );
  TextStyle get toggleButtonSelectedStyle => TextStyle(
        fontSize: 17.0,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      );
}

class LightTheme extends CustomTheme {
  static final CustomColorsBase _colors = CustomColorsBase();

  @override
  String get name => 'light_theme';

  @override
  CustomColorsBase get colors => _colors;
}

CustomTheme get theme {
  return CustomThemeData.of(appContext);
}

class CustomThemeData extends InheritedWidget {
  final CustomTheme theme;
  @override
  final Widget child;

  const CustomThemeData({super.key, required this.theme, required this.child})
      : super(child: child);

  @override
  bool updateShouldNotify(CustomThemeData oldWidget) {
    return oldWidget.theme.name != theme.name;
  }

  static CustomTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CustomThemeData>()!.theme;
}
