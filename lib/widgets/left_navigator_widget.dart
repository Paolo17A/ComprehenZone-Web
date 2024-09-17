import 'package:comprehenzone_web/utils/string_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/color_util.dart';
import '../utils/go_router_util.dart';

Widget adminLeftNavigator(BuildContext context, {required String path}) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.2,
    height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(color: CustomColors.navigatorBlue),
    child: Column(
      children: [
        Flexible(
            child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
                color: CustomColors.grimGrey,
                child: Image.asset(ImagePaths.comprehenzoneLogo, height: 200)),
            listTile(context,
                label: 'Dashboard', thisPath: GoRoutes.home, currentPath: path),
            listTile(context,
                label: 'Sections',
                thisPath: GoRoutes.sections,
                currentPath: path),
            listTile(context,
                label: 'Teachers',
                thisPath: GoRoutes.teachers,
                currentPath: path),
            listTile(context,
                label: 'Students',
                thisPath: GoRoutes.students,
                currentPath: path),
            listTile(context,
                label: 'Modules',
                thisPath: GoRoutes.modules,
                currentPath: path),
            listTile(context,
                label: 'Quizzes',
                thisPath: GoRoutes.quizzes,
                currentPath: path),
            const Divider(),
            listTile(context,
                label: 'Profile',
                thisPath: GoRoutes.profile,
                currentPath: path),
          ],
        )),
        ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.black),
            title: const Text('Log Out',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            onTap: () {
              FirebaseAuth.instance.signOut().then((value) {
                GoRouter.of(context).goNamed(GoRoutes.home);
                GoRouter.of(context).pushReplacementNamed(GoRoutes.home);
              });
            })
      ],
    ),
  );
}

Widget teacherLeftNavigator(BuildContext context, {required String path}) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.2,
    height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(color: CustomColors.navigatorBlue),
    child: Column(
      children: [
        Flexible(
            child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
                color: CustomColors.grimGrey,
                child: Image.asset(ImagePaths.comprehenzoneLogo, height: 200)),
            listTile(context,
                label: 'Dashboard', thisPath: GoRoutes.home, currentPath: path),
            listTile(context,
                label: 'Sections',
                thisPath: GoRoutes.sections,
                currentPath: path),
            listTile(context,
                label: 'Modules',
                thisPath: GoRoutes.modules,
                currentPath: path),
            listTile(context,
                label: 'Quizzes',
                thisPath: GoRoutes.quizzes,
                currentPath: path),
            const Divider(),
            listTile(context,
                label: 'Profile',
                thisPath: GoRoutes.profile,
                currentPath: path),
          ],
        )),
        ListTile(
            leading: const Icon(
              Icons.exit_to_app,
              color: Colors.black,
            ),
            title: const Text('Log Out',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            onTap: () {
              FirebaseAuth.instance.signOut().then((value) {
                GoRouter.of(context).goNamed(GoRoutes.home);
                GoRouter.of(context).pushReplacementNamed(GoRoutes.home);
              });
            })
      ],
    ),
  );
}

Widget studentLeftNavigator(BuildContext context, {required String path}) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.2,
    height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(color: CustomColors.navigatorBlue),
    child: Column(
      children: [
        Flexible(
            child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
                color: CustomColors.grimGrey,
                child: Image.asset(ImagePaths.comprehenzoneLogo, height: 200)),
            listTile(context,
                label: 'Dashboard', thisPath: GoRoutes.home, currentPath: path),
            listTile(context,
                label: 'Modules',
                thisPath: GoRoutes.modules,
                currentPath: path),
            listTile(context,
                label: 'Quizzes',
                thisPath: GoRoutes.quizzes,
                currentPath: path),
            listTile(context,
                label: 'Speech',
                thisPath: GoRoutes.speechSelect,
                currentPath: path),
            const Divider(),
            listTile(context,
                label: 'Profile',
                thisPath: GoRoutes.profile,
                currentPath: path),
          ],
        )),
        ListTile(
            leading: const Icon(
              Icons.exit_to_app,
              color: Colors.black,
            ),
            title: const Text('Log Out',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            onTap: () {
              FirebaseAuth.instance.signOut().then((value) {
                GoRouter.of(context).goNamed(GoRoutes.home);
                GoRouter.of(context).pushReplacementNamed(GoRoutes.home);
              });
            })
      ],
    ),
  );
}

Widget listTile(BuildContext context,
    {required String label,
    required String thisPath,
    required String currentPath,
    double fontSize = 12,
    bool isBold = true}) {
  return Container(
      decoration: BoxDecoration(
          color: thisPath == currentPath ? CustomColors.olympicBlue : null,
          border: thisPath == currentPath
              ? Border.all(color: CustomColors.navigatorBlue, width: 2)
              : null,
          boxShadow: thisPath == currentPath
              ? [
                  BoxShadow(
                      color: CustomColors.grimGrey,
                      offset: Offset(0, 1),
                      spreadRadius: 1,
                      blurRadius: 1)
                ]
              : null),
      child: ListTile(
          title: Text(label,
              style: GoogleFonts.martelSans(
                  textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight:
                          isBold ? FontWeight.bold : FontWeight.normal))),
          onTap: () {
            if (thisPath.isEmpty || thisPath == currentPath) {
              return;
            }
            GoRouter.of(context).goNamed(thisPath);
            if (thisPath == GoRoutes.home) {
              GoRouter.of(context).pushReplacementNamed(thisPath);
            }
          }));
}
