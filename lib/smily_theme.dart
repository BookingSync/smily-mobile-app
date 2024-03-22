import 'package:flutter/material.dart';

class SmilyTheme {
  // DEFAULT VALUES
  static const double defaultTextSize = 14;
  static const FontWeight defaultTextWeight = FontWeight.normal;
  static const EdgeInsets defaultButtonPadding = EdgeInsets.fromLTRB(15, 14, 15, 14);
  static const double defaultRadius = 8;
  static const double defaultButtonGap = 6;
  static const Color defaultIconColor = Color.fromRGBO(29, 200, 202, 1);
static const Color defaultIconBackground = Color.fromRGBO(245, 249, 250, 1);

  // MODAL
  static const Color modalTitleColor = Color.fromRGBO(41, 44, 51, 1);
  static const double modalTitleSize = 18;
  static const FontWeight modalTitleWeight = FontWeight.bold;

  static const Color modalTextColor = Color.fromRGBO(41, 44, 51, 1);
  static const double modalTextSize = defaultTextSize;
  static const FontWeight modalTextWeight = defaultTextWeight;

  static const double modalRadius = defaultRadius;

  // BUTTONS

static const double defaultButtonWidth = 183;
static const double defaultButtonHeight = 49;
static const FontWeight defaultButtonWeight = FontWeight.bold;

  // BUTTONS - Default button
  static const Color buttonDefaultColor = Color.fromRGBO(98, 12, 147, 1);
  static const Color buttonDefaultBackground = Colors.white;
  static const double buttonDefaultSize = defaultTextSize;
  static const FontWeight buttonDefaultWeight = defaultButtonWeight;

  static final ButtonStyle buttonDefaultStyle = TextButton.styleFrom(
    backgroundColor: buttonDefaultBackground,
    textStyle: const TextStyle(
      color: buttonDefaultColor,
      fontSize: buttonDefaultSize,
      fontWeight: buttonDefaultWeight
    ),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(defaultRadius)),),
    padding: defaultButtonPadding,
    side: const BorderSide(width: 1, color: buttonDefaultColor),
  );
  static const TextStyle buttonDefaultTextStyle = TextStyle(
    color: buttonDefaultColor,
    fontSize: buttonDefaultSize,
    fontWeight: buttonDefaultWeight,
  );

  // BUTTONS - Primary button

  static const Color buttonPrimaryColor = Colors.white;
  static const Color buttonPrimaryBackground = Color.fromRGBO(61, 181, 89, 1);
  static const double buttonPrimarySize = defaultTextSize;
  static const FontWeight buttonPrimaryWeight = defaultButtonWeight;

  static final ButtonStyle buttonPrimaryStyle = TextButton.styleFrom(
    backgroundColor: buttonPrimaryBackground,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(defaultRadius)),),
    padding: defaultButtonPadding,
    side: const BorderSide(width: 0)
  );
  static const TextStyle buttonPrimaryTextStyle = TextStyle(
    color: buttonPrimaryColor,
    fontSize: buttonPrimarySize,
    fontWeight: buttonPrimaryWeight,
  );
}
