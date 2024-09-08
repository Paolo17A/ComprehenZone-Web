import 'package:flutter/material.dart';

import 'color_util.dart';

ThemeData themeData = ThemeData(
  colorSchemeSeed: CustomColors.dirtyPearl,
  scaffoldBackgroundColor: CustomColors.backgroundBlue,
  appBarTheme: const AppBarTheme(
      actionsIconTheme: IconThemeData(color: CustomColors.midnightBlue),
      backgroundColor: CustomColors.grass,
      toolbarHeight: 40),
  dividerTheme: DividerThemeData(color: CustomColors.midnightBlue),
  snackBarTheme:
      const SnackBarThemeData(backgroundColor: CustomColors.midnightBlue),
  dialogBackgroundColor: CustomColors.olympicBlue,
  dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
          side: BorderSide(width: 2), borderRadius: BorderRadius.circular(30))),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: CustomColors.dirtyPearl)),
);
