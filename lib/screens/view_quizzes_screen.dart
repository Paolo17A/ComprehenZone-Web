import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/providers/quizzes_provider.dart';
import 'package:comprehenzone_web/providers/user_type_provider.dart';
import 'package:comprehenzone_web/utils/color_util.dart';
import 'package:comprehenzone_web/utils/firebase_util.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/go_router_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class ViewQuizzesScreen extends ConsumerStatefulWidget {
  const ViewQuizzesScreen({super.key});

  @override
  ConsumerState<ViewQuizzesScreen> createState() => _ViewQuizzesScreenState();
}

class _ViewQuizzesScreenState extends ConsumerState<ViewQuizzesScreen> {
  List<DocumentSnapshot> quizDocs = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
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
        if (ref.read(userTypeProvider).userType == UserTypes.admin) {
          ref.read(quizzesProvider).setQuizDocs(await getAllQuizDocs());
        } else if (ref.read(userTypeProvider).userType == UserTypes.teacher) {
          ref.read(quizzesProvider).setQuizDocs(await getAllUserQuizDocs());
        } else {
          final user = await getCurrentUserDoc();
          final userData = user.data() as Map<dynamic, dynamic>;
          List<dynamic> assignedSections =
              userData[UserFields.assignedSections];
          List<DocumentSnapshot> teacherDocs =
              await getSectionTeacherDoc(assignedSections.first);
          String teacherID = teacherDocs.first.id;
          quizDocs = await getAllAssignedQuizDocs(teacherID);
        }
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting quiz docs: $error')));
        ref.read(loadingProvider).toggleLoading(false);
      }
    });
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
                  ? adminLeftNavigator(context, path: GoRoutes.quizzes)
                  : ref.read(userTypeProvider).userType == UserTypes.teacher
                      ? teacherLeftNavigator(context, path: GoRoutes.quizzes)
                      : studentLeftNavigator(context, path: GoRoutes.quizzes),
              bodyGradientContainer(context,
                  child: SingleChildScrollView(
                    child: horizontal5Percent(context,
                        child: ref.read(userTypeProvider).userType ==
                                UserTypes.student
                            ? _studentQuizzes()
                            : _quizzesContent()),
                  ))
            ],
          )),
    );
  }

  Widget _studentQuizzes() {
    return Column(
      children: [
        vertical20Pix(child: blackInterBold('ASSIGNED QUIZZES', fontSize: 32)),
        vertical20Pix(
          child: Container(
              width: double.maxFinite,
              decoration: BoxDecoration(border: Border.all(width: 2)),
              padding: const EdgeInsets.all(10),
              child: quizDocs.isNotEmpty
                  ? Center(
                      child: Wrap(
                        runSpacing: 10,
                        spacing: 10,
                        children: quizDocs
                            .map((quizDoc) => _quizEntryFutureBuilder(quizDoc))
                            .toList(),
                      ),
                    )
                  : all20Pix(
                      child: blackInterBold(
                          'You have no assigned quizzes to take.'))),
        ),
      ],
    );
  }

  Widget _quizEntryFutureBuilder(DocumentSnapshot quizDoc) {
    final quizData = quizDoc.data() as Map<dynamic, dynamic>;
    String title = quizData[QuizFields.title];
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      decoration: BoxDecoration(
          color: CustomColors.pearlWhite, border: Border.all(width: 2)),
      padding: const EdgeInsets.all(10),
      child: FutureBuilder(
        future: getQuizResult(quizDoc.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return blackInterRegular('Error getting quiz status');
          } else if (!snapshot.hasData) {
            return _quizEntryWidget(
                quizID: quizDoc.id, title: title, isDone: false);
          }
          final quizResult = snapshot.data!.id;
          final quizResultData = snapshot.data!.data() as Map<dynamic, dynamic>;

          return _quizEntryWidget(
              quizID: quizDoc.id,
              title: title,
              isDone: true,
              quizResultID: quizResult,
              grade: quizResultData[QuizResultFields.grade]);
        },
      ),
    );
  }

  Widget _quizEntryWidget(
      {required String quizID,
      required String title,
      required bool isDone,
      String quizResultID = '',
      num grade = 0}) {
    return vertical10Pix(
      child: TextButton(
        onPressed: () {
          if (isDone) {
            print('VIEW RESULTS');
            /*NavigatorRoutes.selectedQuizResult(context,
                quizResultID: quizResultID);*/
            GoRouter.of(context).goNamed(GoRoutes.selectedQuizResult,
                pathParameters: {PathParameters.quizResultID: quizResultID});
          } else {
            print('WILL ANSWER PALANG');
            //NavigatorRoutes.answerQuiz(context, quizID: quizID);
            GoRouter.of(context).goNamed(GoRoutes.answerQuiz,
                pathParameters: {PathParameters.quizID: quizID});
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          /*mainAxisAlignment:
              isDone ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,*/
          children: [
            blackInterBold(title,
                fontSize: 28,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis),
            if (isDone) blackInterBold('$grade/10')
          ],
        ),
      ),
    );
  }

  Widget _quizzesContent() {
    return Column(
      children: [
        _quizzesHeader(),
        viewContentContainer(context,
            child: Column(
              children: [
                _quizzesLabelRow(),
                ref.read(quizzesProvider).quizDocs.isNotEmpty
                    ? _quizEntries()
                    : viewContentUnavailable(context,
                        text: 'NO AVAILABLE QUIZZES')
              ],
            )),
      ],
    );
  }

  Widget _quizzesHeader() {
    return vertical20Pix(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        blackInterBold('QUIZZES', fontSize: 40),
        //if (ref.read(userTypeProvider).userType == UserTypes.teacher)
        ElevatedButton(
            onPressed: () => GoRouter.of(context).goNamed(GoRoutes.addQuiz),
            child: blackInterBold('NEW QUIZ'))
      ]),
    );
  }

  Widget _quizzesLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexLabelTextCell('Title', 2),
      viewFlexLabelTextCell('Quiz Type', 1),
      if (ref.read(userTypeProvider).userType == UserTypes.admin)
        viewFlexLabelTextCell('Teacher', 1),
      viewFlexLabelTextCell('Actions', 2)
    ]);
  }

  Widget _quizEntries() {
    return SizedBox(
      height: 550,
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ref.read(quizzesProvider).quizDocs.length,
          itemBuilder: (context, index) {
            return ref.read(userTypeProvider).userType == UserTypes.admin
                ? _globalQuizEntry(ref.read(quizzesProvider).quizDocs[index])
                : _teacherQuizEntry(ref.read(quizzesProvider).quizDocs[index]);
          }),
    );
  }

  Widget _globalQuizEntry(DocumentSnapshot quizDoc) {
    final quizData = quizDoc.data() as Map<dynamic, dynamic>;
    String title = quizData[QuizFields.title];
    String quizType = quizData[QuizFields.quizType];
    String teacherID = quizData[QuizFields.teacherID];
    bool isGlobal = quizData[QuizFields.isGlobal];
    return viewContentEntryRow(context, children: [
      viewFlexTextCell(title, flex: 2),
      viewFlexTextCell(quizType, flex: 1),
      viewFlexActionsCell([
        isGlobal
            ? blackInterBold('GLOBAL QUIZ', fontSize: 20)
            : FutureBuilder(
                future: getThisUserDoc(teacherID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData ||
                      snapshot.hasError) return snapshotHandler(snapshot);
                  final teacherData =
                      snapshot.data!.data() as Map<dynamic, dynamic>;
                  String formattedName =
                      '${teacherData[UserFields.firstName]} ${teacherData[UserFields.lastName]}';
                  return blackInterBold(formattedName, fontSize: 20);
                },
              )
      ], flex: 1),
      viewFlexActionsCell([
        //viewEntryButton(context, onPress: () {}),
        if (isGlobal)
          editEntryButton(context,
              onPress: () => GoRouter.of(context).goNamed(GoRoutes.editQuiz,
                  pathParameters: {PathParameters.quizID: quizDoc.id})),
      ], flex: 2)
    ]);
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
