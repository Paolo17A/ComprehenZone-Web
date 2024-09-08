import 'package:comprehenzone_web/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_field_widget.dart';
import '../widgets/left_navigator_widget.dart';

class EditSelectedProfileScreen extends ConsumerStatefulWidget {
  final String userID;
  const EditSelectedProfileScreen({super.key, required this.userID});

  @override
  ConsumerState<EditSelectedProfileScreen> createState() =>
      _EditSelectedProfileScreenState();
}

class _EditSelectedProfileScreenState
    extends ConsumerState<EditSelectedProfileScreen> {
  String thisUserType = '';
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final goRouter = GoRouter.of(context);
      try {
        ref.read(loadingProvider.notifier).toggleLoading(true);
        if (!hasLoggedInUser()) {
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        String userType = await getCurrentUserType();
        if (userType != UserTypes.admin) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        final userDoc = await getThisUserDoc(widget.userID);
        final userData = userDoc.data() as Map<dynamic, dynamic>;
        thisUserType = userData[UserFields.userType];
        firstNameController.text = userData[UserFields.firstName];
        lastNameController.text = userData[UserFields.lastName];
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting user profile: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
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
              adminLeftNavigator(context,
                  path: thisUserType == UserTypes.teacher
                      ? GoRoutes.teachers
                      : GoRoutes.students),
              bodyBlueBackgroundContainer(
                context,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      horizontal5Percent(
                        context,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                vertical20Pix(
                                  child: backButton(context,
                                      onPress: () => GoRouter.of(context)
                                          .goNamed(
                                              thisUserType == UserTypes.teacher
                                                  ? GoRoutes.teachers
                                                  : GoRoutes.students)),
                                ),
                              ],
                            ),
                            _editProfileHeader(),
                            Gap(4),
                            borderedOlympicBlueContainer(
                                child: Column(
                              children: [
                                regularTextField(
                                    label: 'First Name',
                                    textController: firstNameController,
                                    textColor: Colors.black),
                                regularTextField(
                                    label: 'Last Name',
                                    textController: lastNameController,
                                    textColor: Colors.black),
                                vertical20Pix(
                                  child: blueBorderElevatedButton(
                                      label: 'Save Changes',
                                      onPress: () => editThisProfile(
                                          context, ref,
                                          userID: widget.userID,
                                          userType: thisUserType,
                                          firstNameController:
                                              firstNameController,
                                          lastNameController:
                                              lastNameController)),
                                ),
                              ],
                            ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _editProfileHeader() {
    return borderedOlympicBlueContainer(
        child: SizedBox(
            width: double.infinity,
            child: blackInterBold('EDIT PROFILE', fontSize: 28)));
  }

  Widget _firstNameControllerWidget() {
    return vertical20Pix(
        child: CustomTextField(
            text: 'First Name',
            controller: firstNameController,
            textInputType: TextInputType.name,
            displayPrefixIcon: const Icon(Icons.person)));
  }

  Widget _lasttNameControllerWidget() {
    return vertical20Pix(
        child: CustomTextField(
            text: 'Last Name',
            controller: lastNameController,
            textInputType: TextInputType.name,
            displayPrefixIcon: const Icon(Icons.person)));
  }
}
