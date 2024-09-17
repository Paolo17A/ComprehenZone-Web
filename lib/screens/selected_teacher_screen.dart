import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../providers/user_type_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class SelectedTeacherScreen extends ConsumerStatefulWidget {
  final String teacherID;
  const SelectedTeacherScreen({super.key, required this.teacherID});

  @override
  ConsumerState<SelectedTeacherScreen> createState() =>
      _SelectedTeacherScreenState();
}

class _SelectedTeacherScreenState extends ConsumerState<SelectedTeacherScreen> {
  String formattedName = '';
  List<DocumentSnapshot> sectionDocs = [];
  List<DocumentSnapshot> moduleDocs = [];
  List<DocumentSnapshot> quizDocs = [];

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
        if (ref.read(userTypeProvider).userType != UserTypes.admin) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        final user = await getThisUserDoc(widget.teacherID);
        final userData = user.data() as Map<dynamic, dynamic>;
        formattedName =
            '${userData[UserFields.firstName]} ${userData[UserFields.lastName]}';
        List<dynamic> assignedSections = userData[UserFields.assignedSections];
        if (assignedSections.isNotEmpty) {
          sectionDocs = await getTheseSectionDocs(assignedSections);
        }

        moduleDocs = await getTeacherModuleDocs(widget.teacherID);
        quizDocs = await getAllTeacherQuizDocs(widget.teacherID);
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('Error getting selected teacher data: $error')));
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
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            adminLeftNavigator(context, path: GoRoutes.teachers),
            bodyBlueBackgroundContainer(context,
                child: SingleChildScrollView(
                  child: horizontal5Percent(context,
                      child: Column(
                        children: [
                          _backButton(),
                          teacherDataCyanContainer(),
                          const Gap(40),
                          _modulesContent(),
                          _quizzesContent(),
                          const Gap(40),
                        ],
                      )),
                ))
          ])),
    );
  }

  Widget _backButton() {
    return Row(children: [
      all20Pix(
          child: ElevatedButton(
              onPressed: () => GoRouter.of(context).goNamed(GoRoutes.teachers),
              style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.midnightBlue),
              child: whiteInterBold('BACK')))
    ]);
  }

  Widget teacherDataCyanContainer() {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
          color: CustomColors.olympicBlue, border: Border.all(width: 5)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          blackInterBold(formattedName, fontSize: 40),
          const Gap(20),
          blackInterBold(
              'Assigned Sections: ${sectionDocs.isEmpty ? 'N/A' : ''}',
              fontSize: 24),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sectionDocs.map((section) {
                final sectionData = section.data() as Map<dynamic, dynamic>;
                return blackInterRegular(sectionData[SectionFields.name],
                    textAlign: TextAlign.left, fontSize: 24);
              }).toList())
        ],
      ),
    );
  }

  //============================================================================
  //MODULES=====================================================================
  //============================================================================
  Widget _modulesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vertical10Pix(child: blackInterBold('CREATED MODULES', fontSize: 32)),
        viewContentContainer(context,
            child: Column(
              children: [
                _modulesLabelRow(),
                moduleDocs.isNotEmpty
                    ? _moduleEntries()
                    : viewContentUnavailable(context,
                        text: 'THIS TEACHER HAS NOT YET CREATED ANY MODULES'),
              ],
            )),
      ],
    );
  }

  Widget _modulesLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexLabelTextCell('Title', 1),
      viewFlexLabelTextCell('Content', 2),
      viewFlexLabelTextCell('Quarter', 1),
    ]);
  }

  Widget _moduleEntries() {
    return SizedBox(
      height: 550,
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: moduleDocs.length,
          itemBuilder: (context, index) {
            return _teacherModuleEntry(moduleDocs[index]);
          }),
    );
  }

  Widget _teacherModuleEntry(DocumentSnapshot moduleDoc) {
    final moduleData = moduleDoc.data() as Map<dynamic, dynamic>;
    String title = moduleData[ModuleFields.title];
    String content = moduleData[ModuleFields.content];
    num quarter = moduleData[ModuleFields.quarter];
    return viewContentEntryRow(context, children: [
      viewFlexTextCell(title, flex: 1),
      viewFlexTextCell(content, flex: 2),
      viewFlexTextCell(quarter.toString(), flex: 1),
    ]);
  }

  //============================================================================
  //QUIZZES=====================================================================
  //============================================================================
  Widget _quizzesContent() {
    return vertical20Pix(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          blackInterBold('CREATED QUIZZES', fontSize: 32),
          viewContentContainer(context,
              child: Column(
                children: [
                  _quizzesLabelRow(),
                  quizDocs.isNotEmpty
                      ? _quizEntries()
                      : viewContentUnavailable(context,
                          text: 'THIS TEACHER HAS NOT YET CREATED ANY QUIZZES')
                ],
              )),
        ],
      ),
    );
  }

  Widget _quizzesLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexLabelTextCell('Title', 2),
      viewFlexLabelTextCell('Quiz Type', 1),
      viewFlexLabelTextCell('Actions', 2)
    ]);
  }

  Widget _quizEntries() {
    return SizedBox(
      height: 550,
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quizDocs.length,
          itemBuilder: (context, index) {
            return _teacherQuizEntry(quizDocs[index]);
          }),
    );
  }

  Widget _teacherQuizEntry(DocumentSnapshot quizDoc) {
    final quizData = quizDoc.data() as Map<dynamic, dynamic>;
    String title = quizData[ModuleFields.title];
    String quizType = quizData[QuizFields.quizType];
    return viewContentEntryRow(context, children: [
      viewFlexTextCell(title, flex: 2),
      viewFlexTextCell(quizType, flex: 1),
      viewFlexActionsCell([
        editEntryButton(context,
            onPress: () => GoRouter.of(context).goNamed(GoRoutes.editQuiz,
                pathParameters: {PathParameters.quizID: quizDoc.id})),
      ], flex: 2)
    ]);
  }
}
