import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/providers/user_type_provider.dart';
import 'package:comprehenzone_web/utils/go_router_util.dart';
import 'package:comprehenzone_web/utils/string_util.dart';
import 'package:comprehenzone_web/widgets/custom_button_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_text_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker_web/image_picker_web.dart';

import '../providers/profile_image_url_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String formattedName = '';
  //String profileImageURL = '';
  //String mobileNumber = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final goRouter = GoRouter.of(context);
      try {
        ref.read(loadingProvider.notifier).toggleLoading(true);
        if (!hasLoggedInUser()) {
          ref.read(loadingProvider.notifier).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        final userDoc = await getCurrentUserDoc();
        final userData = userDoc.data() as Map<dynamic, dynamic>;

        formattedName =
            '${userData[UserFields.firstName]} ${userData[UserFields.lastName]}';
        ref
            .read(profileImageURLProvider)
            .setImageURL(userData[UserFields.profileImageURL]);
        //mobileNumber = userData[UserFields.mobileNumber];

        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting user profile: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  Future _pickImage() async {
    final pickedFile = await ImagePickerWeb.getImageAsBytes();
    if (pickedFile == null) {
      return;
    }
    // ignore: use_build_context_synchronously
    addProfilePic(context, ref, selectedImage: pickedFile);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(userTypeProvider);
    return Scaffold(
      body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ref.read(userTypeProvider).userType == UserTypes.admin
                  ? adminLeftNavigator(context, path: GoRoutes.profile)
                  : ref.read(userTypeProvider).userType == UserTypes.teacher
                      ? teacherLeftNavigator(context, path: GoRoutes.profile)
                      : studentLeftNavigator(context, path: GoRoutes.profile),
              bodyBlueBackgroundContainer(context,
                  child:
                      SingleChildScrollView(child: profileDetailsContainer()))
            ],
          )),
    );
  }

  Widget profileDetailsContainer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: all20Pix(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProfileImage(
                            profileImageURL: ref
                                .read(profileImageURLProvider)
                                .profileImageURL),
                        const Gap(20),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              blueBorderElevatedButton(
                                  label: 'SELECT\nPROFILE PICTURE',
                                  onPress: _pickImage),
                              const Gap(10),
                              if (ref
                                  .read(profileImageURLProvider)
                                  .profileImageURL
                                  .isNotEmpty)
                                blueBorderElevatedButton(
                                    label: 'REMOVE\nPROFILE PICTURE',
                                    onPress: () =>
                                        removeProfilePic(context, ref))
                            ])
                      ],
                    ),
                    blackInterBold(formattedName, fontSize: 40),
                  ],
                ),
                blueBorderElevatedButton(
                    label: 'EDIT PROFILE PICTURE',
                    onPress: () =>
                        GoRouter.of(context).goNamed(GoRoutes.editProfile))
              ],
            ),
            const Divider(color: CustomColors.midnightBlue),
          ],
        ),
      ),
    );
  }
}
