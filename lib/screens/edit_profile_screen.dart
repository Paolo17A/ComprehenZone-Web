import 'package:comprehenzone_web/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/loading_provider.dart';
import '../providers/user_type_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_field_widget.dart';
import '../widgets/left_navigator_widget.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
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
        final userDoc = await getCurrentUserDoc();
        final userData = userDoc.data() as Map<dynamic, dynamic>;

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
              ref.read(userTypeProvider).userType == UserTypes.admin
                  ? adminLeftNavigator(context, path: GoRoutes.profile)
                  : teacherLeftNavigator(context, path: GoRoutes.profile),
              bodyGradientContainer(
                context,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      horizontal5Percent(
                        context,
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Row(
                                  children: [
                                    vertical20Pix(
                                      child: backButton(context,
                                          onPress: () => GoRouter.of(context)
                                              .goNamed(GoRoutes.profile)),
                                    ),
                                  ],
                                ),
                                _editProfileHeader(),
                                _firstNameControllerWidget(),
                                _lasttNameControllerWidget(),
                              ],
                            ),
                            submitButton(context,
                                label: 'SAVE CHANGES',
                                onPress: () => editClientProfile(context, ref,
                                    firstNameController: firstNameController,
                                    lastNameController: lastNameController))
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
    return blackInterBold('EDIT PROFILE', fontSize: 50);
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
