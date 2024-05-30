import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/users_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/loading_provider.dart';
import '../utils/delete_entry_dialog_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/left_navigator_widget.dart';

class ViewTeachersScreen extends ConsumerStatefulWidget {
  const ViewTeachersScreen({super.key});

  @override
  ConsumerState<ViewTeachersScreen> createState() => _ViewTeachersScreenState();
}

class _ViewTeachersScreenState extends ConsumerState<ViewTeachersScreen> {
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
        ref.read(usersProvider).setUserDocs(await getAllTeacherDocs());
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting all teachers: $error')));
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
            adminLeftNavigator(context, path: GoRoutes.teachers),
            bodyGradientContainer(
              context,
              child: SingleChildScrollView(
                child: horizontal5Percent(context,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        vertical20Pix(
                            child: Row(children: [
                          blackInterBold('TEACHER ACCOUNTS', fontSize: 40)
                        ])),
                        viewContentContainer(context,
                            child: Column(
                              children: [
                                _teachersLabelRow(),
                                ref.read(usersProvider).userDocs.isNotEmpty
                                    ? _teacherEntries()
                                    : viewContentUnavailable(context,
                                        text: 'NO AVAILABLE TEACHERS'),
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

  Widget _teachersLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexLabelTextCell('Name', 3),
      viewFlexLabelTextCell('Verification Status', 2),
      viewFlexLabelTextCell('Actions', 2)
    ]);
  }

  Widget _teacherEntries() {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
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
    bool accountVerified = userData[UserFields.isVerified];
    String verificationImage = userData[UserFields.verificationImage];

    return viewContentEntryRow(context, children: [
      viewFlexTextCell(formattedName, flex: 3),
      viewFlexActionsCell([
        if (accountVerified)
          blackInterBold('VERIFIED')
        else
          ElevatedButton(
              onPressed: () => showVerificationImageDialog(context,
                  verificationImage: verificationImage),
              child: blackInterBold('VIEW ID'))
      ], flex: 2),
      viewFlexActionsCell([
        if (accountVerified) viewEntryButton(context, onPress: () {}),
        if (!accountVerified)
          ElevatedButton(
              onPressed: () => approveThisUserRegistration(context, ref,
                  userID: userDoc.id, userType: UserTypes.teacher),
              child: const Icon(
                Icons.check,
                color: Colors.black,
              )),
        if (!accountVerified)
          ElevatedButton(
              onPressed: () => displayDeleteEntryDialog(context,
                  message:
                      'Are you sure you want to deny this user\'s registration?',
                  deleteWord: 'Deny',
                  deleteEntry: () => denyThisUserRegistration(context, ref,
                      userID: userDoc.id, userType: UserTypes.teacher)),
              child: const Icon(
                Icons.block,
                color: Colors.black,
              ))
      ], flex: 2)
    ]);
  }
}
