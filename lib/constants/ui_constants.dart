import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConstants {
  static const appName = "Bookiema";
}

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late Orientation orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
  }
}

// Screen Sizes
class ScreenSize {
  static double width = SizeConfig.screenWidth;
  static double height = SizeConfig.screenHeight;
}

class Doubles {
  static double scale = 1;

  static double get tiny => 4 * scale;
  static double get sm => 8 * scale;
  static double get med => 12 * scale;
  static double get lg => 16 * scale;
  static double get base => 24 * scale;
  static double get xl => 48 * scale;
}

class Corners {
  static BorderRadius tnyBorder = BorderRadius.all(tnyRadius);
  static Radius tnyRadius = Radius.circular(Doubles.tiny);
  static BorderRadius smBorder = BorderRadius.all(smRadius);
  static Radius smRadius = Radius.circular(Doubles.sm);
  static BorderRadius medBorder = BorderRadius.all(medRadius);
  static Radius medRadius = Radius.circular(Doubles.med);
  static BorderRadius lgBorder = BorderRadius.all(lgRadius);
  static Radius lgRadius = Radius.circular(Doubles.lg);
  static BorderRadius xlBorder = BorderRadius.all(xlRadius);
  static Radius xlRadius = Radius.circular(Doubles.xl);
  static Radius customRadius(double radius) => Radius.circular(radius);
  static BorderRadius customBorder(Radius radius) => BorderRadius.all(radius);
}

class Insets {
  static double scale = 1;
  static double offsetScale = 1;
  // Regular paddings

  static EdgeInsets get buttonPadding => EdgeInsets.symmetric(
        horizontal: Doubles.sm,
        vertical: Doubles.tiny,
      );
  static EdgeInsets get standardPadding => EdgeInsets.symmetric(
        horizontal: Doubles.lg,
        vertical: Doubles.sm,
      );
  static EdgeInsets get verticalPadding4 => EdgeInsets.symmetric(
        vertical: Doubles.tiny,
      );
  static EdgeInsets get verticalPadding8 => EdgeInsets.symmetric(
        vertical: Doubles.sm,
      );
  static EdgeInsets get horizontalPadding8 => EdgeInsets.symmetric(
        horizontal: Doubles.sm,
      );
  static EdgeInsets get horizontalPadding16 => EdgeInsets.symmetric(
        horizontal: Doubles.lg,
      );
  static EdgeInsets get verticalPadding12 => EdgeInsets.symmetric(
        vertical: Doubles.med,
      );
  static EdgeInsets get verticalPadding16 => EdgeInsets.symmetric(
        vertical: Doubles.lg,
      );
  static EdgeInsets get verticalPadding24 => EdgeInsets.symmetric(
        vertical: Doubles.base,
      );
  static EdgeInsets get verticalPadding48 => EdgeInsets.symmetric(
        vertical: Doubles.xl,
      );
  // Offset, used for the edge of the window, or to separate large sections in the app
  static double get offset => 40 * offsetScale;
}

class IconSizes {
  // static const double scale = 1;
  static const double med = 24;
  static const double largest = 100;
}

class Spacing {
  static double scale = 1;

  static double get xs => 4 * scale;

  static Widget get horizontalSpace4 => SizedBox(width: Doubles.tiny);
  static Widget get horizontalSpace8 => SizedBox(width: Doubles.sm);
  static Widget get horizontalSpace12 => SizedBox(width: Doubles.med);
  static Widget get horizontalSpace16 => SizedBox(width: Doubles.lg);
  static Widget get horizontalSpace24 => SizedBox(width: Doubles.base);
  static Widget get horizontalSpace48 => SizedBox(width: Doubles.xl);

  static Widget get verticalSpace4 => SizedBox(height: Doubles.tiny);
  static Widget get verticalSpace8 => SizedBox(height: Doubles.sm);
  static Widget get verticalSpace12 => SizedBox(height: Doubles.med);
  static Widget get verticalSpace16 => SizedBox(height: Doubles.lg);
  static Widget get verticalSpace24 => SizedBox(height: Doubles.base);
  static Widget get verticalSpace48 => SizedBox(height: Doubles.xl);

  static Widget verticalSpace(double height) => SizedBox(height: height);
}

class DateTimeFormats {
  static DateFormat day = DateFormat('d'); //10
  static DateFormat dateFormat = DateFormat('EEE, MMM d'); //Wed, Feb 10
  static DateFormat dayMonth = DateFormat('d MMM'); //10 Feb
  static DateFormat weekday = DateFormat('EEE'); //Wed
  static DateFormat fullMonth = DateFormat('MMMMM');
  static DateFormat fullYear = DateFormat('yyyy');
  static DateFormat longDate = DateFormat('EEE, MMM d y');
  static DateFormat monthYear = DateFormat('MMM y');
  static DateFormat fullDate = DateFormat('d LLLL y');
  static DateFormat dateTime = DateFormat('EEE, MMM d y; HH:mm:ss');
  static DateFormat shortDateTime = DateFormat('EEE, MMM d; HH:mm');
  static DateFormat hourMinute = DateFormat('Hm');
  static DateFormat longTimeFormat = DateFormat('jm');
}

class NumberFormats {
  static NumberFormat formattedNumberFormat = NumberFormat("#,###");
}

const divider12 = Divider(
  height: 12,
);
