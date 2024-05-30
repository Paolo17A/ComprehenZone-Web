import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/color_util.dart';
import '../utils/go_router_util.dart';
import 'custom_padding_widgets.dart';
import 'custom_text_widgets.dart';

Widget loginButton({required Function onPress}) {
  return all10Pix(
      child: Container(
    width: double.infinity,
    decoration: BoxDecoration(
        border: Border.all(width: 3), borderRadius: BorderRadius.circular(10)),
    child: TextButton(
        onPressed: () => onPress(),
        child: blackInterBold('LOG-IN', fontSize: 20)),
  ));
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
        child: whiteInterRegular(label),
      ));
}

Widget backButton(BuildContext context, {required Function onPress}) {
  return ElevatedButton(
      onPressed: () => onPress(),
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: whiteInterRegular('BACK'));
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
      child: const Icon(Icons.edit, color: CustomColors.pearlWhite));
}

Widget restoreEntryButton(BuildContext context, {required Function onPress}) {
  return ElevatedButton(
      onPressed: () {
        onPress();
      },
      child: const Icon(Icons.restore, color: CustomColors.pearlWhite));
}

Widget deleteEntryButton(BuildContext context, {required Function onPress}) {
  return ElevatedButton(
      onPressed: () {
        onPress();
      },
      child: const Icon(Icons.delete, color: CustomColors.pearlWhite));
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

Widget navigatorButtons(BuildContext context,
    {required int pageNumber,
    required Function? onPrevious,
    required Function? onNext,
    Color fontColor = Colors.black}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        pageButton(context,
            label: 'PREV', onPress: onPrevious, fontColor: fontColor),
        Padding(
          padding: const EdgeInsets.all(5.5),
          child:
              Text(pageNumber.toString(), style: TextStyle(color: fontColor)),
        ),
        pageButton(context,
            label: 'NEXT', onPress: onNext, fontColor: fontColor)
      ],
    ),
  );
}

Widget pageButton(BuildContext context,
    {required Function? onPress,
    required String label,
    Color fontColor = Colors.black}) {
  return Container(
    decoration:
        BoxDecoration(border: Border.all(color: CustomColors.midnightBlue)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextButton(
          onPressed: onPress != null ? () => onPress() : null,
          style: TextButton.styleFrom(
              foregroundColor: fontColor, disabledForegroundColor: Colors.grey),
          child: Text(label)),
    ),
  );
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
