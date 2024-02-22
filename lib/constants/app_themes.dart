import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/constants/app_colors.dart';
import '/constants/ui_constants.dart';

final ThemeData glicoLightTheme = _glicoLightTheme();

ThemeData _glicoLightTheme() {
  const CupertinoTextThemeData appleBase = CupertinoTextThemeData();
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    textTheme: _glicoLightTextTheme(base.textTheme),
    scaffoldBackgroundColor: kGlicoScaffoldBackground,
    appBarTheme: base.appBarTheme.copyWith(
        color: kGlicoWhiteBackground,
        foregroundColor: Colors.black,
        centerTitle: true),
    textSelectionTheme: TextSelectionThemeData(
        selectionColor: base.colorScheme.primary.withOpacity(0.25)),
    tabBarTheme: base.tabBarTheme.copyWith(
      labelStyle: base.textTheme.bodyLarge!.copyWith(fontFamily: 'Nunito'),
      labelColor: base.textTheme.bodyLarge!.color,
      unselectedLabelColor: base.textTheme.bodyLarge!.color!.withOpacity(0.7),
      unselectedLabelStyle: base.textTheme.bodyLarge!.copyWith(
        fontFamily: 'Nunito',
        color: kGlicoDisabledFlatButton,
      ),
    ),
    sliderTheme: base.sliderTheme.copyWith(
      trackHeight: 1.0,
      thumbColor: kGlicoSecondary,
      activeTrackColor: kGlicoSecondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return kGlicoDisabledButton;
          }
          if (states.contains(MaterialState.selected)) {
            return kGlicoPrimary;
          }
          return kGlicoPrimary;
        }),
        // textStyle: MaterialStateProperty.resolveWith<TextStyle?>(
        //     (Set<MaterialState> states) {
        //   if (states.contains(MaterialState.disabled)) {
        //     return base.textTheme.titleLarge!.copyWith(color: Colors.black87);
        //   }
        //   return base.textTheme.titleLarge!.copyWith(color: Colors.white);
        // }),
      ),
    ),
    iconTheme: base.iconTheme.copyWith(color: kGlicoOnSurface),
    cardTheme: base.cardTheme.copyWith(color: kGlicoWhiteBackground),
    bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        backgroundColor: kGlicoPrimary,
        selectedIconTheme: base.iconTheme.copyWith(color: kGlicoSecondary),
        unselectedItemColor: kGlicoOnSurface),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: kGlicoWhiteBackground),
    bottomSheetTheme: base.bottomSheetTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Corners.lgRadius,
          topRight: Corners.lgRadius,
        ),
      ),
    ),
    splashColor: kGlicoSplashColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    colorScheme: _glicoLightColorScheme,
    cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: kGlicoPrimary,
      primaryContrastingColor: kGlicoSecondary,
      textTheme: _glicoCupertinoLightTextTheme(appleBase),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return kGlicoSecondary;
        }
        return null;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return kGlicoSecondary;
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return kGlicoSecondary;
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return kGlicoSecondary;
        }
        return null;
      }),
    ),
  );
}

CupertinoTextThemeData _glicoCupertinoLightTextTheme(
  CupertinoTextThemeData appleBase,
) {
  return appleBase.copyWith(
    navTitleTextStyle:
        appleBase.navTitleTextStyle.copyWith(fontFamily: 'Nunito'),
    navLargeTitleTextStyle:
        appleBase.navLargeTitleTextStyle.copyWith(fontFamily: 'Nunito'),
    tabLabelTextStyle:
        appleBase.tabLabelTextStyle.copyWith(fontFamily: 'Nunito'),
  );
}

TextTheme _glicoLightTextTheme(TextTheme base) {
  return base
      .copyWith(
        displayMedium: base.displayMedium!.copyWith(
          fontFamily: 'Nunito',
        ),
        displaySmall: base.displaySmall!.copyWith(
          fontFamily: 'Nunito',
        ),
        headlineLarge: base.headlineLarge!.copyWith(
          fontFamily: 'Nunito',
          // fontSize: 35.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        headlineMedium: base.headlineMedium!.copyWith(
          fontFamily: 'Nunito',
          // fontSize: 35.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        headlineSmall: base.headlineSmall!.copyWith(
          fontFamily: 'Nunito',
          // fontSize: 24.0,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: base.titleLarge!.copyWith(
          fontFamily: 'Nunito',
          // fontSize: 20.0,
          // fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleMedium: base.titleMedium!.copyWith(
          fontFamily: 'Nunito',
          fontSize: 17.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: base.titleSmall!.copyWith(
          fontFamily: 'Nunito',
          // fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: base.bodyLarge!.copyWith(
          fontFamily: 'Nunito',
          // fontSize: 17,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        bodyMedium: base.bodyLarge!.copyWith(
          fontFamily: 'Nunito',
          // fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        labelLarge: base.labelLarge!.copyWith(
          fontFamily: 'Nunito',
          fontSize: 17.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.0,
          color: kGlicoSecondary,
        ),
        bodySmall: base.bodySmall!.copyWith(
          fontFamily: 'Nunito',
          // fontSize: 13.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
      )
      .apply(bodyColor: kGlicoOnSurface);
}

ColorScheme _glicoLightColorScheme = ColorScheme.fromSeed(
  seedColor: kGlicoPrimary,
  primary: kGlicoPrimary,
  // primaryContainer: kGlicoPrimaryVariant,
  secondary: kGlicoSecondary,
  // secondaryContainer: kGlicoSecondary,
  background: kGlicoBackground,
  surface: kGlicoWhiteBackground,
  error: kGlicoError,
  // onError: kGlicoOnLightSurface,
);
