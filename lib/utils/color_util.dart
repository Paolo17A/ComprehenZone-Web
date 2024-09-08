import 'package:flutter/material.dart';

class CustomColors {
  /*static const stoneGrey = Color.fromARGB(255, 186, 177, 160);
  static const apricotOrange = Color.fromARGB(255, 250, 158, 100);
  static const tangerine = Color.fromARGB(255, 253, 140, 62); */
  /*static const pearlWhite = Color.fromARGB(255, 232, 229, 224);
  static const paleCyan = Color.fromARGB(255, 63, 204, 204);
  static const lightGreen = Color.fromARGB(255, 150, 242, 107);
  static const limeGreen = Color.fromARGB(255, 140, 217, 26);
  static const goldenrodYellow = Color.fromARGB(255, 242, 214, 73);*/

  static const backgroundBlue = Color.fromARGB(255, 2, 90, 123);
  static const olympicBlue = Color.fromARGB(255, 1, 171, 233); //  Containers
  static const mediumSea = Color.fromARGB(255, 1, 106, 145);
  static const navigatorBlue = Color.fromARGB(255, 15, 136, 180);
  static const dirtyPearl = Color.fromARGB(255, 189, 194, 235);
  static const correctGreen = Color.fromARGB(255, 31, 202, 80);
  static const wrongRed = Color.fromARGB(255, 192, 52, 52);
  static const pastelYellow = Color.fromARGB(255, 223, 228, 121);
  static const pastelGreen = Color.fromARGB(255, 137, 228, 121);
  static const pastelBlueGrey = Color.fromARGB(255, 121, 164, 228);
  static const pastelOrange = Color.fromARGB(255, 228, 121, 123);
  static const pastelPink = Color.fromARGB(255, 252, 161, 243);
  static const grimGrey = Color.fromARGB(255, 28, 42, 55);
  static const midnightBlue = Color.fromARGB(255, 34, 60, 95);
  static const grass = Color.fromARGB(255, 3, 166, 106);
  static const pearlWhite = Color.fromARGB(255, 232, 229, 224);

  static Color getQuarterColor(String quarter) {
    switch (quarter) {
      case '1':
        return pastelYellow;
      case '2':
        return pastelGreen;
      case '3':
        return pastelBlueGrey;
      default:
        return pastelOrange;
    }
  }

  static Color getLetterColor(String choice) {
    switch (choice) {
      case 'a':
        return pastelOrange;
      case 'b':
        return pastelGreen;
      case 'c':
        return pastelBlueGrey;
      default:
        return pastelPink;
    }
  }
}
