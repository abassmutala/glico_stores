import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glico_stores/constants/app_colors.dart';
import 'package:glico_stores/constants/ui_constants.dart';

final ThemeData glicoLightTheme = _glicoLightTheme();

ThemeData _glicoLightTheme() {
  const CupertinoTextThemeData appleBase = CupertinoTextThemeData();
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    useMaterial3: true,
    textTheme: _glicoLightTextTheme(base.textTheme),
    scaffoldBackgroundColor: kGlicoScaffoldBackground,
    appBarTheme: base.appBarTheme.copyWith(
        color: kGlicoWhiteBackground,
        foregroundColor: Colors.black,
        centerTitle: true),
    textSelectionTheme: TextSelectionThemeData(
        selectionColor: base.colorScheme.primary.withOpacity(0.25)),
    tabBarTheme: base.tabBarTheme.copyWith(
      labelStyle:
          base.textTheme.bodyLarge!.copyWith(fontFamily: 'DM_Sans'),
      labelColor: base.textTheme.bodyLarge!.color,
      unselectedLabelColor: base.textTheme.bodyLarge!.color!.withOpacity(0.7),
      unselectedLabelStyle: base.textTheme.bodyLarge!.copyWith(
        fontFamily: 'DM_Sans',
        color: kGlicoDisabledFlatButton,
      ),
    ),
    sliderTheme: base.sliderTheme.copyWith(
      trackHeight: 1.0,
      thumbColor: kGlicoAccent,
      activeTrackColor: kGlicoAccent,
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
        selectedIconTheme: base.iconTheme.copyWith(color: kGlicoAccent),
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
      primaryContrastingColor: kGlicoAccent,
      textTheme: _glicoCupertinoLightTextTheme(appleBase),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return kGlicoAccent;
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
          return kGlicoAccent;
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
          return kGlicoAccent;
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return kGlicoAccent;
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
        appleBase.navTitleTextStyle.copyWith(fontFamily: 'DM_Sans'),
    navLargeTitleTextStyle: appleBase.navLargeTitleTextStyle
        .copyWith(fontFamily: 'DM_Sans'),
    tabLabelTextStyle:
        appleBase.tabLabelTextStyle.copyWith(fontFamily: 'DM_Sans'),
  );
}

TextTheme _glicoLightTextTheme(TextTheme base) {
  return base
      .copyWith(
        displayMedium: base.displayMedium!.copyWith(
          fontFamily: 'DM_Sans',
        ),
        displaySmall: base.displaySmall!.copyWith(
          fontFamily: 'DM_Sans',
        ),
        headlineMedium: base.headlineMedium!.copyWith(
          fontFamily: 'DM_Sans',
          // fontSize: 35.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        headlineSmall: base.headlineSmall!.copyWith(
          fontFamily: 'DM_Sans',
          // fontSize: 24.0,
          fontWeight: FontWeight.w500,
        ),
        titleLarge: base.titleLarge!.copyWith(
          fontFamily: 'DM_Sans',
          // fontSize: 20.0,
          // fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleMedium: base.titleMedium!.copyWith(
          fontFamily: 'DM_Sans',
          fontSize: 17.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: base.titleSmall!.copyWith(
          fontFamily: 'DM_Sans',
          // fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: base.bodyLarge!.copyWith(
          fontFamily: 'DM_Sans',
          // fontSize: 17,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        bodyMedium: base.bodyLarge!.copyWith(
          fontFamily: 'DM_Sans',
          // fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        labelLarge: base.labelLarge!.copyWith(
          fontFamily: 'DM_Sans',
          fontSize: 17.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.0,
          color: kGlicoAccent,
        ),
        bodySmall: base.bodySmall!.copyWith(
          fontFamily: 'DM_Sans',
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
  // secondaryContainer: kGlicoAccent,
  background: kGlicoBackground,
  surface: kGlicoWhiteBackground,
  error: kGlicoError,
  // onError: kGlicoOnLightSurface,
);
