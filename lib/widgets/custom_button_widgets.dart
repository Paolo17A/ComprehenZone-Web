import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/color_util.dart';
import '../utils/go_router_util.dart';
import 'custom_padding_widgets.dart';
import 'custom_text_widgets.dart';

Widget blueBorderElevatedButton(
    {required String label,
    required Function onPress,
    double? width,
    double? height}) {
  return all10Pix(
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color.fromARGB(255, 28, 74, 145))),
      child: ElevatedButton(
          onPressed: () => onPress(), child: blackInterRegular(label)),
    ),
  );
}

Widget loginButton({required Function onPress}) {
  return blueBorderElevatedButton(label: 'LOG-IN', onPress: () => onPress());
}

Widget registerButton({required Function onPress}) {
  return all10Pix(
      child: Container(
    width: double.infinity,
    decoration: BoxDecoration(
        border: Border.all(width: 3), borderRadius: BorderRadius.circular(10)),
    child: TextButton(
        onPressed: () => onPress(),
        child: blackInterBold('REGISTER', fontSize: 20)),
  ));
}

Widget sendPasswordResetEmailButton({required Function onPress}) {
  return all10Pix(
      child: ElevatedButton(
          onPressed: () => onPress(),
          child: whiteInterRegular('SEND PASSWORD RESET EMAIL')));
}

Widget submitButton(BuildContext context,
    {required String label, required Function onPress}) {
  return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () => onPress(),
        style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.midnightBlue),
        child: whiteInterRegular(label),
      ));
}

Widget backButton(BuildContext context, {required Function onPress}) {
  return ElevatedButton(
      onPressed: () => onPress(),
      style: ElevatedButton.styleFrom(
          backgroundColor: CustomColors.olympicBlue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: CustomColors.midnightBlue, width: 2))),
      child: whiteInterBold('BACK'));
}

Widget viewEntryButton(BuildContext context, {required Function onPress}) {
  return ElevatedButton(
      onPressed: () {
        onPress();
      },
      child: const Icon(Icons.visibility, color: CustomColors.midnightBlue));
}

Widget editEntryButton(BuildContext context, {required Function onPress}) {
  return ElevatedButton(
      onPressed: () {
        onPress();
      },
      child: const Icon(Icons.edit, color: CustomColors.midnightBlue));
}

Widget restoreEntryButton(BuildContext context, {required Function onPress}) {
  return ElevatedButton(
      onPressed: () {
        onPress();
      },
      child: const Icon(Icons.restore, color: CustomColors.dirtyPearl));
}

Widget deleteEntryButton(BuildContext context, {required Function onPress}) {
  return ElevatedButton(
      onPressed: () {
        onPress();
      },
      child: const Icon(Icons.delete, color: CustomColors.midnightBlue));
}

Widget uploadImageButton(String label, Function selectImage) {
  return ElevatedButton(
      onPressed: () => selectImage(),
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      child: Padding(
          padding: const EdgeInsets.all(7), child: whiteInterBold(label)));
}

Widget logOutButton(BuildContext context) {
  return all20Pix(
      child: ElevatedButton(
          onPressed: () {
            FirebaseAuth.instance.signOut().then((value) {
              GoRouter.of(context).goNamed(GoRoutes.home);
              GoRouter.of(context).pushReplacementNamed(GoRoutes.home);
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: whiteInterBold('LOG-OUT')));
}

Widget borderedOlympicBlueContainer({required Widget child}) {
  return Container(
      decoration: BoxDecoration(
          color: CustomColors.olympicBlue,
          border: Border.all(color: CustomColors.navigatorBlue, width: 4)),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: child);
}
