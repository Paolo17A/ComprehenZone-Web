import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/utils/color_util.dart';
import 'package:comprehenzone_web/utils/go_router_util.dart';
import 'package:comprehenzone_web/utils/string_util.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_text_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../utils/firebase_util.dart';

class SelectedStudentScreen extends ConsumerStatefulWidget {
  final String studentID;
  const SelectedStudentScreen({super.key, required this.studentID});

  @override
  ConsumerState<SelectedStudentScreen> createState() =>
      _SelectedStudentScreenState();
}

class _SelectedStudentScreenState extends ConsumerState<SelectedStudentScreen> {
  String formattedName = '';
  String sectionName = '';
  List<DocumentSnapshot> quizResultDocs = [];
  List<DocumentSnapshot> speechResultDocs = [];
  double averageGrade = 0;
  Map<dynamic, dynamic> moduleProgresses = {};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        final student = await getThisUserDoc(widget.studentID);
        final studentData = student.data() as Map<dynamic, dynamic>;
        formattedName =
            '${studentData[UserFields.firstName]} ${studentData[UserFields.lastName]}';
        String sectionID =
            (studentData[UserFields.assignedSections] as List<dynamic>).first;
        moduleProgresses = studentData[UserFields.moduleProgresses];
        if (sectionID.isNotEmpty) {
          final section = await getThisSectionDoc(sectionID);
          final sectionData = section.data() as Map<dynamic, dynamic>;
          sectionName = sectionData[SectionFields.name];
        }
        quizResultDocs = await getStudentQuizResults(widget.studentID);
        double sum = 0;
        for (var quizResult in quizResultDocs) {
          final quizResultData = quizResult.data() as Map<dynamic, dynamic>;
          sum += quizResultData[QuizResultFields.grade];
        }
        averageGrade = (sum / quizResultDocs.length) * 10;
        speechResultDocs = await getStudentSpeechResults(widget.studentID);
        speechResultDocs.sort((a, b) {
          final aData = a.data() as Map<dynamic, dynamic>;
          final bData = b.data() as Map<dynamic, dynamic>;
          return (aData[SpeechResultFields.speechIndex] as num)
              .compareTo(bData[SpeechResultFields.speechIndex] as num);
        });
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content:
                Text('Error getting selected student quiz results: $error')));
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
          Row(children: [
            adminLeftNavigator(context, path: GoRoutes.students),
            bodyBlueBackgroundContainer(context,
                child: SingleChildScrollView(
                  child: all20Pix(
                      child: Column(
                    children: [
                      _backButton(),
                      studentDataCyanContainer(),
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
              onPressed: () => GoRouter.of(context).goNamed(GoRoutes.students),
              style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.midnightBlue),
              child: whiteInterBold('BACK')))
    ]);
  }

  Widget studentDataCyanContainer() {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
          color: CustomColors.olympicBlue, border: Border.all(width: 5)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              blackInterBold(formattedName, fontSize: 40),
              if (quizResultDocs.isNotEmpty)
                blackInterBold(
                    'Average Grade: ${averageGrade.toStringAsFixed(1)}%',
                    fontSize: 32)
            ],
          ),
          blackInterRegular(sectionName, fontSize: 24),
          _quizScores(),
          _speechScores(),
          const Gap(4),
          if (!ref.read(loadingProvider).isLoading) _studentModuleProgress(),
        ],
      ),
    );
  }

  Widget _quizScores() {
    return vertical20Pix(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          blackInterBold('QUIZ SCORES', fontSize: 30),
          quizResultDocs.isNotEmpty
              ? Column(
                  children: quizResultDocs
                      .map((quizResult) =>
                          quizResultEntry(context, quizResultDoc: quizResult))
                      .toList())
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  blackInterBold(
                      'This student has not yet answered any quizzes.')
                ])
        ],
      ),
    );
  }

  Widget _speechScores() {
    return vertical20Pix(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        blackInterBold('SPEECH SCORES', fontSize: 30),
        speechResultDocs.isNotEmpty
            ? Column(
                children: speechResultDocs
                    .map((speechResultDoc) =>
                        speechResultEntry(context, speechResultDoc))
                    .toList())
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                blackInterBold('This student has not yet taken any oral tests.')
              ])
      ],
    ));
  }

  Widget _studentModuleProgress() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      blackInterBold('MODULE PROGRESS', fontSize: 30),
      _quarterModulesContainer('1st Quarter', 'quarter1'),
      _quarterModulesContainer('2nd Quarter', 'quarter2'),
      _quarterModulesContainer('3rd Quarter', 'quarter3'),
      _quarterModulesContainer('4th Quarter', 'quarter4'),
    ]);
  }

  Widget _quarterModulesContainer(String label, String quarterKey) {
    Map<dynamic, dynamic> quarterModules = moduleProgresses[quarterKey];
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      padding: EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [blackInterBold(label, fontSize: 20)],
            )),
        quarterModules.isNotEmpty
            ? Column(
                children: quarterModules.entries
                    .map((entry) => Row(
                          children: [
                            blackInterBold('Module ${entry.key}: ',
                                fontSize: 16),
                            blackInterRegular(
                                '\t\t\tProgress: ${((entry.value[ModuleProgressFields.progress] * 100) as double).toStringAsFixed(2)}%')
                          ],
                        ))
                    .toList())
            : blackInterRegular('This student has no progress for $label')
      ]),
    );
  }
}
