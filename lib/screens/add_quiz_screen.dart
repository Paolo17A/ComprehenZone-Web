import 'package:comprehenzone_web/widgets/custom_button_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_text_field_widget.dart';
import 'package:comprehenzone_web/widgets/custom_text_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../providers/loading_provider.dart';
import '../providers/user_type_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../utils/string_util.dart';
import '../widgets/string_choices_radio_widget.dart';

class AddQuizScreen extends ConsumerStatefulWidget {
  const AddQuizScreen({super.key});

  @override
  ConsumerState<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends ConsumerState<AddQuizScreen> {
  int currentQuestion = 0;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  List<dynamic> quizQuestions = [];
  //  MULTIPLE CHOICE VARIABLES
  final List<TextEditingController> _choicesControllers = [];
  final List<String> choiceLetters = ['a', 'b', 'c', 'd'];
  String? _correctChoiceString;
  final GlobalKey<ChoicesRadioWidgetState> stringChoice = GlobalKey();

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _questionController.dispose();
    for (var choice in _choicesControllers) {
      choice.dispose();
    }
    //_identificationController.dispose();
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      _choicesControllers.add(TextEditingController());
    }
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
        if (ref.read(userTypeProvider).userType == UserTypes.student) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting current user type: $error')));
        ref.read(loadingProvider).toggleLoading(false);
      }
    });
  }

  void previousQuestion() {
    if (currentQuestion == 0) {
      return;
    }
    setState(() {
      currentQuestion--;
      _questionController.text =
          quizQuestions[currentQuestion][QuestionFields.question];
      _choicesControllers[0].text =
          quizQuestions[currentQuestion][QuestionFields.options]['a'];
      _choicesControllers[1].text =
          quizQuestions[currentQuestion][QuestionFields.options]['b'];
      _choicesControllers[2].text =
          quizQuestions[currentQuestion][QuestionFields.options]['c'];
      _choicesControllers[3].text =
          quizQuestions[currentQuestion][QuestionFields.options]['d'];
      _correctChoiceString =
          quizQuestions[currentQuestion][QuestionFields.answer];
      stringChoice.currentState?.setChoice(_correctChoiceString!);
    });
  }

  void nextQuestion() {
    //  VALIDATION GUARDS
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please provide a title for this quiz.')));
      return;
    }
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide a question.')));
      return;
    }
    if (_correctChoiceString == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Please select a correct answer from the four choices.')));
      return;
    }
    for (int i = 0; i < _choicesControllers.length; i++) {
      if (_choicesControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please provide four choices to choose from.')));
        return;
      }
    }
    //  Create a multiple choice question map
    Map<String, dynamic> easyQuestionEntry = {
      QuestionFields.question: _questionController.text.trim(),
      QuestionFields.options: {
        'a': _choicesControllers[0].text.trim(),
        'b': _choicesControllers[1].text.trim(),
        'c': _choicesControllers[2].text.trim(),
        'd': _choicesControllers[3].text.trim()
      },
      QuestionFields.answer: _correctChoiceString
    };
    if (currentQuestion == quizQuestions.length) {
      quizQuestions.add(easyQuestionEntry);
    } else {
      quizQuestions[currentQuestion] = easyQuestionEntry;
    }

    //  STORE THE INPUTTED DATA AND REBUILD THE WIDGET
    setState(() {
      currentQuestion++;
      if (currentQuestion == 10) {
        //currentQuestion--;
        addNewQuiz(context, ref,
            titleController: _titleController,
            quizQuestions: quizQuestions,
            gradeLevel: '5');
        return;
      }
      if (currentQuestion <= quizQuestions.length - 1) {
        Map<dynamic, dynamic> selectedQuestion = quizQuestions[currentQuestion];
        _questionController.text = selectedQuestion[QuestionFields.question];
        for (int i = 0; i < _choicesControllers.length; i++) {
          _choicesControllers[i].text =
              selectedQuestion[QuestionFields.options][choiceLetters[i]];
        }
        _correctChoiceString = selectedQuestion[QuestionFields.answer];
        stringChoice.currentState?.setChoice(_correctChoiceString!);
      } else {
        _questionController.clear();
        for (TextEditingController choice in _choicesControllers) {
          choice.clear();
        }
        _correctChoiceString = null;
        stringChoice.currentState?.resetChoice();
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ref.read(userTypeProvider).userType == UserTypes.admin
                  ? adminLeftNavigator(context, path: GoRoutes.quizzes)
                  : teacherLeftNavigator(context, path: GoRoutes.quizzes),
              bodyBlueBackgroundContainer(context,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _backButton(),
                        horizontal5Percent(context,
                            child: Column(
                              children: [
                                newQuizHeader(),
                                Container(
                                  decoration: BoxDecoration(
                                      color: CustomColors.olympicBlue,
                                      border: Border.all(
                                          width: 4,
                                          color: CustomColors.navigatorBlue)),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      _quizTitle(),
                                      _quizInputContainer(),
                                      _navigatorButtons()
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ))
            ],
          )),
    );
  }

  Widget _backButton() {
    return all20Pix(
      child: Row(
        children: [
          backButton(context,
              onPress: () => GoRouter.of(context).goNamed(GoRoutes.quizzes)),
        ],
      ),
    );
  }

  Widget newQuizHeader() {
    return vertical20Pix(
      child: borderedOlympicBlueContainer(
          child: blackInterBold('NEW QUIZ', fontSize: 28)),
    );
  }

  Widget _quizTitle() {
    return vertical10Pix(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        blackInterBold('QUIZ TITLE', fontSize: 18),
        CustomTextField(
            text: 'Quiz Title',
            controller: _titleController,
            textInputType: TextInputType.text,
            displayPrefixIcon: null,
            textColor: Colors.black),
      ]),
    );
  }

  Widget _quizInputContainer() {
    return Column(
      children: [
        Row(children: [
          interText('Question #${currentQuestion + 1}',
              fontWeight: FontWeight.bold)
        ]),
        const Gap(5),
        CustomTextField(
            text: 'Question',
            controller: _questionController,
            textInputType: TextInputType.text,
            displayPrefixIcon: null,
            textColor: Colors.black),
        const SizedBox(height: 15),
        _multipleChoiceQuestionInput(),
      ],
    );
  }

  Widget _multipleChoiceQuestionInput() {
    return Column(
      children: [
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _choicesControllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      interText(choiceLetters[index],
                          fontWeight: FontWeight.bold),
                      const Gap(8),
                      Expanded(
                        child: CustomTextField(
                            text: 'Choice',
                            controller: _choicesControllers[index],
                            textInputType: TextInputType.text,
                            displayPrefixIcon: null,
                            textColor: Colors.black),
                      )
                    ]),
              );
            }),
        vertical20Pix(
          child: StringChoicesRadioWidget(
              key: stringChoice,
              initialString: _correctChoiceString,
              choiceSelectCallback: (stringVal) {
                if (stringVal != null) {
                  setState(() {
                    _correctChoiceString = stringVal;
                  });
                }
              },
              choiceLetters: choiceLetters),
        ),
      ],
    );
  }

  Widget _navigatorButtons() {
    return vertical10Pix(
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      ElevatedButton(
          onPressed: previousQuestion, child: blackInterRegular('PREVIOUS')),
      ElevatedButton(
          onPressed: nextQuestion,
          child: blackInterRegular(currentQuestion == 9 ? 'SUBMIT' : 'NEXT'))
    ]));
  }
}
