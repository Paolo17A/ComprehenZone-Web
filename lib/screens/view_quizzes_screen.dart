import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/providers/quizzes_provider.dart';
import 'package:comprehenzone_web/providers/user_type_provider.dart';
import 'package:comprehenzone_web/utils/firebase_util.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/delete_entry_dialog_util.dart';
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
        } else {
          ref.read(quizzesProvider).setQuizDocs(await getAllUserQuizDocs());
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
                  : teacherLeftNavigator(context, path: GoRoutes.quizzes),
              bodyGradientContainer(context,
                  child: SingleChildScrollView(
                    child:
                        horizontal5Percent(context, child: _quizzesContent()),
                  ))
            ],
          )),
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
        viewEntryButton(context, onPress: () {}),
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
        deleteEntryButton(context,
            onPress: () => displayDeleteEntryDialog(context,
                message: 'Are you sure you wish to delete this quiz? ',
                deleteEntry: () {}))
      ], flex: 2)
    ]);
  }
}
