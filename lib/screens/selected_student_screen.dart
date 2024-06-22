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
          blackInterBold(formattedName, fontSize: 40),
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
            .map((quizResult) => quizResultEntry(quizResult))
            .toList());
  }

  Widget quizResultEntry(DocumentSnapshot quizResultDoc) {
    final quizResultData = quizResultDoc.data() as Map<dynamic, dynamic>;
    num grade = quizResultData[QuizResultFields.grade];
    String quizID = quizResultData[QuizResultFields.quizID];
    return FutureBuilder(
      future: getThisQuizDoc(quizID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.hasError) {
          return const Text('Error retrieving data');
        }
        final quizData = snapshot.data!.data() as Map<dynamic, dynamic>;
        String title = quizData[QuizFields.title];
        return Container(
          width: double.infinity,
          height: 70,
          decoration: BoxDecoration(border: Border.all(width: 2)),
          padding: const EdgeInsets.all(10),
          child: TextButton(
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    flex: 2,
                    child: blackInterBold(title,
                        fontSize: 16, overflow: TextOverflow.ellipsis)),
                Flexible(child: blackInterBold('$grade/10', fontSize: 20))
              ],
            ),
          ),
        );
      },
    );
  }
}
