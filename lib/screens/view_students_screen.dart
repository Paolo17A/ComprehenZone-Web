import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/users_provider.dart';
import 'package:comprehenzone_web/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/left_navigator_widget.dart';

class ViewStudentsScreen extends ConsumerStatefulWidget {
  const ViewStudentsScreen({super.key});

  @override
  ConsumerState<ViewStudentsScreen> createState() => _ViewStudentsScreenState();
}

class _ViewStudentsScreenState extends ConsumerState<ViewStudentsScreen> {
  final passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final goRouter = GoRouter.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        if (!hasLoggedInUser()) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        String userType = await getCurrentUserType();
        if (userType == UserTypes.teacher) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        ref.read(usersProvider).setUserDocs(await getAllStudentDocs());
        for (var userDoc in ref.read(usersProvider).userDocs) {
          final userData = userDoc.data() as Map<dynamic, dynamic>;
          if (!userData.containsKey(UserFields.gradeLevel)) {
            await FirebaseFirestore.instance
                .collection(Collections.users)
                .doc(userDoc.id)
                .update({UserFields.gradeLevel: '5'});
          }
          if (!userData.containsKey(UserFields.moduleProgresses)) {
            await FirebaseFirestore.instance
                .collection(Collections.users)
                .doc(userDoc.id)
                .update({
              UserFields.moduleProgresses: {
                'quarter1': {},
                'quarter2': {},
                'quarter3': {},
                'quarter4': {}
              }
            });
          }
          if (!userData.containsKey(UserFields.speechIndex)) {
            await FirebaseFirestore.instance
                .collection(Collections.users)
                .doc(userDoc.id)
                .update({UserFields.speechIndex: 1});
          }
        }
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting all students: $error')));
        ref.read(loadingProvider).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      body: stackedLoadingContainer(
        context,
        ref.read(loadingProvider).isLoading,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            adminLeftNavigator(context, path: GoRoutes.students),
            bodyBlueBackgroundContainer(
              context,
              child: SingleChildScrollView(
                child: horizontal5Percent(context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        vertical20Pix(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                              borderedOlympicBlueContainer(
                                  child: blackInterBold('STUDENT ACCOUNTS',
                                      fontSize: 28)),
                              ElevatedButton(
                                  onPressed: () => GoRouter.of(context)
                                      .goNamed(GoRoutes.addStudent),
                                  child: blackInterRegular('ADD STUDENT'))
                            ])),
                        viewContentContainer(context,
                            child: Column(
                              children: [
                                _studentsLabelRow(),
                                ref.read(usersProvider).userDocs.isNotEmpty
                                    ? _studentEntries()
                                    : viewContentUnavailable(context,
                                        text: 'NO AVAILABLE STUDENTS'),
                              ],
                            )),
                      ],
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _studentsLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexLabelTextCell('Name', 2),
      viewFlexLabelTextCell('Grade Level', 1),
      viewFlexLabelTextCell('Actions', 3)
    ]);
  }

  Widget _studentEntries() {
    return SizedBox(
        height: 550,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: ref.read(usersProvider).userDocs.length,
            itemBuilder: (context, index) {
              return _userEntry(ref.read(usersProvider).userDocs[index], index);
            }));
  }

  Widget _userEntry(DocumentSnapshot userDoc, int index) {
    final userData = userDoc.data() as Map<dynamic, dynamic>;
    String formattedName =
        '${userData[UserFields.firstName]} ${userData[UserFields.lastName]}';
    String gradeLevel = userData[UserFields.gradeLevel];

    return viewContentEntryRow(context, children: [
      viewFlexTextCell(formattedName, flex: 2),
      viewFlexTextCell(gradeLevel, flex: 1),
      viewFlexActionsCell([
        viewEntryButton(context,
            onPress: () => GoRouter.of(context).goNamed(
                GoRoutes.selectedStudent,
                pathParameters: {PathParameters.studentID: userDoc.id})),
        ElevatedButton(
            onPressed: () => GoRouter.of(context).goNamed(
                GoRoutes.editSelectedProfile,
                pathParameters: {PathParameters.userID: userDoc.id}),
            child: blackInterBold('EDIT PROFILE')),
        ElevatedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) {
                  passwordController.clear();
                  return Dialog(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          blackInterBold('CHANGE PASSWORD', fontSize: 28),
                          passwordTextField(
                              label: 'New Password',
                              passwordController: passwordController),
                          all20Pix(
                            child: ElevatedButton(
                                onPressed: () {
                                  changeUserPassword(context, ref,
                                      userType: UserTypes.student,
                                      userID: userDoc.id,
                                      passwordController: passwordController);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomColors.midnightBlue),
                                child: whiteInterBold('CHANGE PASSWORD')),
                          )
                        ],
                      ),
                    ),
                  );
                });
          },
          child: blackInterBold('CHANGE PASSWORD'),
        )
      ], flex: 3)
    ]);
  }
}
