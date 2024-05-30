import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/providers/user_type_provider.dart';
import 'package:comprehenzone_web/utils/string_util.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/left_navigator_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  //  LOG-IN
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        ref.read(loadingProvider).toggleLoading(true);
        if (!hasLoggedInUser()) {
          ref.read(loadingProvider.notifier).toggleLoading(false);
          return;
        }
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        Fluttertoast.showToast(msg: 'Error initializing home screen: $error');
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
            SingleChildScrollView(
              child: Center(
                  child: hasLoggedInUser()
                      ? ref.read(userTypeProvider).userType == UserTypes.admin
                          ? adminDashboard()
                          : teacherDashboard()
                      : _logInContainer()),
            )));
  }

//==============================================================================
//ADMIN=========================================================================
//==============================================================================
  Widget adminDashboard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        adminLeftNavigator(context, path: GoRoutes.home),
        Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(ImagePaths.gradientBG),
                    fit: BoxFit.cover)),
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: horizontal5Percent(context,
                  child: Center(
                    child: blackInterBold('ADMIN DASHBOARD', fontSize: 60),
                  )),
            )),
      ],
    );
  }

//==============================================================================
//TEACHER=======================================================================
//==============================================================================
  Widget teacherDashboard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        teacherLeftNavigator(context, path: GoRoutes.home),
        Container(
          color: CustomColors.pearlWhite,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: horizontal5Percent(context,
                child: Center(
                    child: blackInterBold('OWNER DASHBOARD', fontSize: 60))),
          ),
        ),
      ],
    );
  }

//==============================================================================
//LOG-IN========================================================================
//==============================================================================
  Widget _logInContainer() {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(ImagePaths.schoolBG), fit: BoxFit.fill)),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.greenAccent.withOpacity(0.2),
        ),
        Positioned(
          right: 0,
          child: loginFieldsContainer(context, ref,
              emailController: emailController,
              passwordController: passwordController),
        )
      ],
    );
  }
}
