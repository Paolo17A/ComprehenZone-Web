import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/providers/user_type_provider.dart';
import 'package:comprehenzone_web/utils/go_router_util.dart';
import 'package:comprehenzone_web/widgets/custom_button_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_text_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';

class SelectedQuizResultScreen extends ConsumerStatefulWidget {
  final String quizResultID;
  const SelectedQuizResultScreen({super.key, required this.quizResultID});

  @override
  ConsumerState<SelectedQuizResultScreen> createState() =>
      _SelectedQuizResultScreenState();
}

class _SelectedQuizResultScreenState
    extends ConsumerState<SelectedQuizResultScreen> {
  num grade = 0;
  String studentID = '';
  List<dynamic> userAnswers = [];
  String quizTitle = '';
  List<dynamic> quizQuestions = [];

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
        final userDoc = await getCurrentUserDoc();
        final userData = userDoc.data() as Map<dynamic, dynamic>;
        ref.read(userTypeProvider).setUserType(userData[UserFields.userType]);
        final quizResult = await FirebaseFirestore.instance
            .collection(Collections.quizResults)
            .doc(widget.quizResultID)
            .get();
        final quizResultData = quizResult.data() as Map<dynamic, dynamic>;
        grade = quizResultData[QuizResultFields.grade];
        userAnswers = quizResultData[QuizResultFields.answers];
        studentID = quizResultData[QuizResultFields.studentID];
        String quizID = quizResultData[QuizResultFields.quizID];

        //  Get Quiz Data
        final quiz = await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(quizID)
            .get();
        final quizData = quiz.data() as Map<dynamic, dynamic>;
        quizTitle = quizData[QuizFields.title];
        final quizContent = quizData[QuizFields.questions];
        quizQuestions = jsonDecode(quizContent);
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('error getting selected quiz result: $error')));
        ref.read(loadingProvider).toggleLoading(false);
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                studentLeftNavigator(context, path: GoRoutes.quizzes),
                bodyBlueBackgroundContainer(context,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _backButton(),
                          horizontal5Percent(context,
                              child: Column(children: [
                                _quizTitle(),
                                borderedOlympicBlueContainer(
                                    child: Column(
                                  children: [
                                    _quizScore(),
                                    _questionsAndAnswers()
                                  ],
                                ))
                              ])),
                        ],
                      ),
                    ))
              ],
            )));
  }

  Widget _backButton() {
    return Row(children: [
      all20Pix(
          child: backButton(context, onPress: () {
        if (ref.read(userTypeProvider).userType == UserTypes.student) {
          GoRouter.of(context).goNamed(GoRoutes.quizzes);
        } else {
          GoRouter.of(context).goNamed(GoRoutes.selectedStudent,
              pathParameters: {PathParameters.studentID: studentID});
        }
      }))
    ]);
  }

  Widget _quizTitle() {
    return vertical20Pix(
        child: borderedOlympicBlueContainer(
            child: blackInterBold(quizTitle, fontSize: 28)));
  }

  Widget _quizScore() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
          color: CustomColors.dirtyPearl,
          border: Border.all(width: 3),
          borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: ((MediaQuery.of(context).size.width * 0.7) / 10) * grade,
                decoration: BoxDecoration(
                    color: CustomColors.correctGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(1, 0), spreadRadius: 1, blurRadius: 4)
                    ]),
              )),
          Center(
              child: blackInterBold(
                  'You got ${grade.toString()} out of ${quizQuestions.length.toString()} items correct.',
                  fontSize: 20)),
        ],
      ),
    );
  }

  Widget _questionsAndAnswers() {
    return vertical20Pix(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(width: 3),
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(15),
        child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quizQuestions.length,
            itemBuilder: (context, index) {
              String formattedQuestion =
                  '${index + 1}. ${(quizQuestions[index][QuestionFields.question].toString())}';
              bool isCorrect = userAnswers[index].toString().toLowerCase() ==
                  quizQuestions[index][QuestionFields.answer]
                      .toString()
                      .toLowerCase();
              String yourAnswer =
                  'Your Answer: ${userAnswers[index]}) ${quizQuestions[index][QuestionFields.options][userAnswers[index]]}';
              String correctAnswer =
                  'Correct Answer: ${quizQuestions[index][QuestionFields.answer]}) ${quizQuestions[index][QuestionFields.options][quizQuestions[index][QuestionFields.answer]]}';

              return vertical10Pix(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 2),
                      borderRadius: BorderRadius.circular(5)),
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      blackInterBold(formattedQuestion),
                      const Gap(7),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                            color: isCorrect
                                ? CustomColors.correctGreen
                                : CustomColors.wrongRed,
                            border: Border.all(width: 2),
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            interText(yourAnswer,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            if (!isCorrect)
                              interText(correctAnswer,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
