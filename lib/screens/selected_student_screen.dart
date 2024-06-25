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
  double averageGrade = 0;
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
            bodyGradientContainer(context,
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
          color: CustomColors.paleCyan, border: Border.all(width: 5)),
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
                    'Average Grade: ${averageGrade.toStringAsFixed(1)}%')
            ],
          ),
          blackInterRegular(sectionName, fontSize: 24),
          const Gap(20),
          blackInterBold('SCORES', fontSize: 30),
          quizResultDocs.isNotEmpty
              ? quizResults()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    blackInterBold(
                        'This student has not yet answered any quizzes.')
                  ],
                )
        ],
      ),
    );
  }

  Widget quizResults() {
    return Column(
        children: quizResultDocs
            .map((quizResult) =>
                quizResultEntry(context, quizResultDoc: quizResult))
            .toList());
  }
}
