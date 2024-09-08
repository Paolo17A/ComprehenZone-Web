import 'dart:convert';

import 'package:comprehenzone_web/providers/user_type_provider.dart';
import 'package:comprehenzone_web/utils/go_router_util.dart';
import 'package:comprehenzone_web/widgets/custom_button_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_text_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/answer_button.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class AnswerQuizScreen extends ConsumerStatefulWidget {
  final String quizID;
  const AnswerQuizScreen({super.key, required this.quizID});

  @override
  ConsumerState<AnswerQuizScreen> createState() => _AnswerQuizScreenState();
}

class _AnswerQuizScreenState extends ConsumerState<AnswerQuizScreen> {
  //  DISPLAYS
  String title = '';
  List<dynamic> quizQuestions = [];
  List<dynamic> selectedAnswers = [];
  String subject = '';

  //  CORRECT ANSWER VARIABLES
  Map<String, dynamic>? easyOptions;
  int currentQuestionIndex = 0;

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
        final quiz = await getThisQuizDoc(widget.quizID);
        final quizData = quiz.data() as Map<dynamic, dynamic>;
        title = quizData[QuizFields.title];
        quizQuestions = jsonDecode(quizData[QuizFields.questions]);
        selectedAnswers = List.generate(quizQuestions.length, (index) => null);
        easyOptions =
            quizQuestions[currentQuestionIndex][QuestionFields.options];

        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting quiz data: $error')));
        ref.read(loadingProvider).toggleLoading(false);
      }
    });
  }

  void _answerQuestion(String selectedAnswer) {
    setState(() {
      _processIfAnswerAlreadySelected(selectedAnswer);
    });
  }

  void _processIfAnswerAlreadySelected(dynamic selectedAnswer) {
    if (selectedAnswers[currentQuestionIndex] != null &&
        selectedAnswers[currentQuestionIndex] == selectedAnswer) {
      selectedAnswers[currentQuestionIndex] = null;
    } else {
      selectedAnswers[currentQuestionIndex] = selectedAnswer;
    }
  }

  bool _checkIfSelected(dynamic selectedAnswer) {
    bool selectedValue = false;

    setState(() {
      if (selectedAnswers[currentQuestionIndex] != null &&
          selectedAnswers[currentQuestionIndex] == selectedAnswer) {
        selectedValue = true;
      }
    });
    return selectedValue;
  }

  void _previousQuestion() {
    if (currentQuestionIndex == 0) {
      return;
    }
    currentQuestionIndex--;
    setState(() {
      _updateOptions();
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex == quizQuestions.length - 1) {
      //  Check if all items have been answered
      for (int i = 0; i < selectedAnswers.length; i++) {
        if (selectedAnswers[i] == null) {
          setState(() {
            currentQuestionIndex = i;
            _updateOptions();
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('You have not yet answered question # ${i + 1}')));
          return;
        }
      }
      submitQuizAnswers(context, ref,
          selectedAnswers: selectedAnswers,
          quizID: widget.quizID,
          correctAnswers: countCorrectAnswers());
      return;
    }

    currentQuestionIndex++;
    setState(() {
      _updateOptions();
    });
  }

  int countCorrectAnswers() {
    int numCorrect = 0;
    for (int i = 0; i < quizQuestions.length; i++) {
      if (quizQuestions[i][QuestionFields.answer] == selectedAnswers[i]) {
        numCorrect++;
      }
    }
    return numCorrect;
  }

  void _updateOptions() {
    easyOptions = quizQuestions[currentQuestionIndex][QuestionFields.options];
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          Row(
            children: [
              studentLeftNavigator(context, path: GoRoutes.quizzes),
              bodyBlueBackgroundContainer(context,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _backButton(),
                        horizontal5Percent(
                          context,
                          child: Column(
                            children: [
                              _quizTitle(),
                              if (!ref.read(loadingProvider).isLoading &&
                                  quizQuestions.isNotEmpty)
                                _quizQuestionWidgets(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          )),
    );
  }

  Widget _backButton() {
    return Row(children: [
      all20Pix(
          child: backButton(context,
              onPress: () => GoRouter.of(context).goNamed(GoRoutes.quizzes)))
    ]);
  }

  Widget _quizTitle() {
    return vertical20Pix(
        child: borderedOlympicBlueContainer(
            child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: blackInterBold(title, fontSize: 28, textAlign: TextAlign.left),
    )));
  }

  Widget _quizQuestionWidgets() {
    return borderedOlympicBlueContainer(
      child: Column(
        children: [
          _questionContainer(
              '${currentQuestionIndex + 1}. ${quizQuestions[currentQuestionIndex][QuestionFields.question]}'),
          ...easyOptions!.entries.map((option) {
            return AnswerButton(
              letter: option.key,
              answer: '${option.key}) ${option.value}',
              onTap: () => _answerQuestion(option.key),
              isSelected: _checkIfSelected(option.key),
              color: CustomColors.getLetterColor(option.key),
            );
          }).toList(),
          _bottomNavigatorButtons()
        ],
      ),
    );
  }

  Widget _questionContainer(String question) {
    return vertical10Pix(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: blackInterRegular(question,
            fontSize: 20, textAlign: TextAlign.left),
      ),
    );
  }

  Widget _bottomNavigatorButtons() {
    return vertical10Pix(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              blueBorderElevatedButton(
                  label: '< PREV', onPress: _previousQuestion),
              blueBorderElevatedButton(label: 'NEXT >', onPress: _nextQuestion)
            ],
          ),
        ],
      ),
    );
  }
}
