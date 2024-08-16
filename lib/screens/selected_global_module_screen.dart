import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/models/modules_model.dart';
import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/user_type_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_text_widgets.dart';

class SelectedGlobalModuleScreen extends ConsumerStatefulWidget {
  final String quarter;
  final String index;
  const SelectedGlobalModuleScreen(
      {super.key, required this.quarter, required this.index});

  @override
  ConsumerState<SelectedGlobalModuleScreen> createState() =>
      _SelectedGlobalModuleScreenState();
}

class _SelectedGlobalModuleScreenState
    extends ConsumerState<SelectedGlobalModuleScreen> {
  Map<dynamic, dynamic> moduleProgresses = {};
  List<String> imagePagePaths = [];
  num currentProgress = 0;
  int currentPage = 0;
  String title = '';

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
        ref.read(userTypeProvider).setUserType(await getCurrentUserType());
        if (ref.read(userTypeProvider).userType != UserTypes.student) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        final user = await getCurrentUserDoc();
        final userData = user.data() as Map<dynamic, dynamic>;
        moduleProgresses = userData[UserFields.moduleProgresses];
        String gradeLevel = userData[UserFields.gradeLevel];
        Map<dynamic, dynamic> quarterMap = moduleProgresses[
            '${ModuleProgressFields.quarter}${widget.quarter}'];
        if (quarterMap.containsKey(widget.index)) {
          currentProgress =
              quarterMap[widget.index][ModuleProgressFields.progress];
        } else {
          quarterMap[widget.index] = {ModuleProgressFields.progress: 0.0};
          moduleProgresses['${ModuleProgressFields.quarter}${widget.quarter}'] =
              quarterMap;
          await FirebaseFirestore.instance
              .collection(Collections.users)
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({UserFields.moduleProgresses: moduleProgresses});
        }
        ModulesModel? currentModel;

        if (widget.quarter == '1') {
          currentModel = Grade5Quarter1Modules.where(
                  (element) => element.index.toString() == widget.index)
              .firstOrNull;
        } else if (widget.quarter == '2') {
          currentModel = Grade6Quarter2Modules.where(
                  (element) => element.index.toString() == widget.index)
              .firstOrNull;
        }

        if (currentModel == null) {
          ref.read(loadingProvider).toggleLoading(false);
          scaffoldMessenger
              .showSnackBar(SnackBar(content: Text('No Module Model Found')));
          // goRouter.goNamed(GoRoutes.modules);
          return;
        }
        for (int i = 0; i < currentModel.pagesCount; i++) {
          imagePagePaths.add(
              '${currentModel.documentPath}Grade${gradeLevel}Quarter${widget.quarter}Lesson${widget.index}P${i + 1}.png');
        }

        title = currentModel.title;
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        ref.read(loadingProvider).toggleLoading(false);
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('Error loading selected global module: $error')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(userTypeProvider);
    return Scaffold(
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            studentLeftNavigator(context, path: GoRoutes.modules),
            SingleChildScrollView(
                child: bodyGradientContainer(context,
                    child: horizontal5Percent(context,
                        child: Column(children: [
                          _backButton(),
                          titleWidgets(),
                          pageWidgets()
                        ]))))
          ])),
    );
  }

  Widget _backButton() {
    return Row(children: [
      all20Pix(
          child: ElevatedButton(
              onPressed: () => GoRouter.of(context).goNamed(GoRoutes.modules),
              style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.midnightBlue),
              child: whiteInterBold('BACK')))
    ]);
  }

  Widget titleWidgets() {
    return Column(children: [blackInterBold(title, fontSize: 40)]);
  }

  Widget pageWidgets() {
    return all20Pix(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        TextButton(
            onPressed: currentPage == 0
                ? null
                : () {
                    if (currentPage == 0) return;
                    setState(() {
                      currentPage--;
                    });
                  },
            child: blackInterBold('<', fontSize: 60)),
        if (imagePagePaths.isNotEmpty)
          Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(imagePagePaths[currentPage])))),
        TextButton(
            onPressed: currentPage == imagePagePaths.length - 1
                ? null
                : () {
                    num newCurrentProgress =
                        (currentPage + 1) / imagePagePaths.length;
                    if (newCurrentProgress > currentProgress) {
                      print('NEW PROGRESS: ${newCurrentProgress}');
                      moduleProgresses[
                              '${ModuleProgressFields.quarter}${widget.quarter}']
                          [widget
                              .index][ModuleProgressFields
                          .progress] = newCurrentProgress;
                      FirebaseFirestore.instance
                          .collection(Collections.users)
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update(
                              {UserFields.moduleProgresses: moduleProgresses});
                      currentProgress = newCurrentProgress;
                    }
                    setState(() {
                      currentPage++;
                    });
                  },
            child: blackInterBold('>', fontSize: 60)),
      ]),
    );
  }
}
