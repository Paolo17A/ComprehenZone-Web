import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/providers/user_type_provider.dart';
import 'package:comprehenzone_web/utils/string_util.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

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
        //  In case user refreshed the screen and the provider is reset
        if (ref.read(userTypeProvider).userType.isEmpty) {
          String userType = await getCurrentUserType();
          ref.read(userTypeProvider).setUserType(userType);
        }
        if (ref.read(userTypeProvider).userType == UserTypes.admin) {
          //  Get Global Data
        } else {
          //  Get Section-wide Data
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
        bodyGradientContainer(context,
            child: SingleChildScrollView(
              child: horizontal5Percent(context,
                  child: Column(
                    children: [
                      //  blackInterBold('ADMIN DASHBOARD', fontSize: 60),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          FutureBuilder(
                              future: getAllSectionDocs(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (!snapshot.hasData ||
                                    snapshot.hasError) {
                                  return const Text('Error retrieving data');
                                }
                                int sectionCount = snapshot.data!.length;
                                return analyticReportWidget(context,
                                    count: sectionCount.toString(),
                                    demographic: 'Sections',
                                    displayIcon:
                                        const Icon(Icons.security_outlined),
                                    onPress: () => GoRouter.of(context)
                                        .goNamed(GoRoutes.sections));
                              }),
                          FutureBuilder(
                              future: getAllTeacherDocs(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (!snapshot.hasData ||
                                    snapshot.hasError) {
                                  return const Text('Error retrieving data');
                                }
                                int teacherCount = snapshot.data!.length;
                                return analyticReportWidget(context,
                                    count: teacherCount.toString(),
                                    demographic: 'Teachers',
                                    displayIcon: const Icon(Icons.person_2),
                                    onPress: () => GoRouter.of(context)
                                        .goNamed(GoRoutes.teachers));
                              }),
                          FutureBuilder(
                              future: getAllStudentDocs(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (!snapshot.hasData ||
                                    snapshot.hasError) {
                                  return const Text('Error retrieving data');
                                }
                                int studentCount = snapshot.data!.length;
                                return analyticReportWidget(context,
                                    count: studentCount.toString(),
                                    demographic: 'Students',
                                    displayIcon: const Icon(Icons.people),
                                    onPress: () => GoRouter.of(context)
                                        .goNamed(GoRoutes.students));
                              }),
                          FutureBuilder(
                              future: getAllModuleDocs(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (!snapshot.hasData ||
                                    snapshot.hasError) {
                                  return const Text('Error retrieving data');
                                }
                                int moduleCount = snapshot.data!.length;
                                return analyticReportWidget(context,
                                    count: moduleCount.toString(),
                                    demographic: 'Modules',
                                    displayIcon: const Icon(Icons.book),
                                    onPress: () => GoRouter.of(context)
                                        .goNamed(GoRoutes.modules));
                              }),
                          FutureBuilder(
                              future: getAllQuizDocs(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (!snapshot.hasData ||
                                    snapshot.hasError) {
                                  return const Text('Error retrieving data');
                                }
                                int quizzesCount = snapshot.data!.length;
                                return analyticReportWidget(context,
                                    count: quizzesCount.toString(),
                                    demographic: 'Quizzes',
                                    displayIcon: const Icon(Icons.quiz),
                                    onPress: () => GoRouter.of(context)
                                        .goNamed(GoRoutes.quizzes));
                              }),
                        ],
                      )
                    ],
                  )),
            ))
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
        bodyGradientContainer(context,
            child: SingleChildScrollView(
              child: horizontal5Percent(context,
                  child: Center(
                      child: blackInterBold('OWNER DASHBOARD', fontSize: 60))),
            ))
      ],
    );
  }

//==============================================================================
//STUDENT=======================================================================
//==============================================================================
  Widget studentDashboard() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      studentLeftNavigator(context, path: GoRoutes.home),
      bodyGradientContainer(context,
          child: SingleChildScrollView(
            child: horizontal5Percent(context,
                child: blackInterBold('STUDENT DASHBOARD')),
          ))
    ]);
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
