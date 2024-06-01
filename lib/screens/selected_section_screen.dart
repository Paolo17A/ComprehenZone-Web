import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/providers/sections_provider.dart';
import 'package:comprehenzone_web/utils/color_util.dart';
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

import '../providers/user_type_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';

class SelectedSectionScreen extends ConsumerStatefulWidget {
  final String sectionID;
  const SelectedSectionScreen({super.key, required this.sectionID});

  @override
  ConsumerState<SelectedSectionScreen> createState() =>
      _SelectedSectionScreenState();
}

class _SelectedSectionScreenState extends ConsumerState<SelectedSectionScreen> {
  String name = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final goRouter = GoRouter.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);

        //  In case user refreshed the screen and the provider is reset
        if (ref.read(userTypeProvider).userType.isEmpty) {
          ref.read(userTypeProvider).setUserType(await getCurrentUserType());
        }
        if (ref.read(userTypeProvider).userType == UserTypes.teacher) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        final sectionData = await getThisSectionDoc(widget.sectionID);
        name = sectionData[SectionFields.name];

        //  TEACHERS
        final teachers = await getSectionTeacherDoc(widget.sectionID);
        if (teachers.isNotEmpty) {
          final teacherData = teachers.first.data() as Map<dynamic, dynamic>;
          ref.read(sectionsProvider).setAssignedTeacherName(
              '${teacherData[UserFields.firstName]} ${teacherData[UserFields.lastName]}');
        }
        ref
            .read(sectionsProvider)
            .setAvailableTeacherDocs(await getAvailableTeacherDocs());

        //  STUDENTS
        ref.read(sectionsProvider).setSectionStudentDocs(
            await getSectionStudentDocs(widget.sectionID));
        ref
            .read(sectionsProvider)
            .setStudentsWithNoSectionDocs(await getStudentsWithNoSectionDocs());
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('Error getting selected section data: $error')));
        ref.read(loadingProvider).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(sectionsProvider);
    return Scaffold(
      body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              adminLeftNavigator(context, path: GoRoutes.sections),
              bodyGradientContainer(context,
                  child: SingleChildScrollView(
                    child: all20Pix(
                        child: Column(
                      children: [
                        _backButton(),
                        _newSectionHeader(),
                        _sectionTeacherContainer(),
                        _sectionStudentsContainer()
                      ],
                    )),
                  ))
            ],
          )),
    );
  }

  Widget _backButton() {
    return vertical20Pix(
      child: Row(
        children: [
          backButton(context,
              onPress: () => GoRouter.of(context).goNamed(GoRoutes.sections)),
        ],
      ),
    );
  }

  Widget _newSectionHeader() {
    return vertical20Pix(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
          color: CustomColors.paleCyan, border: Border.all(width: 3)),
      padding: const EdgeInsets.all(10),
      child: blackInterBold(name, fontSize: 32),
    ));
  }

  Widget _sectionTeacherContainer() {
    return vertical10Pix(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
          color: CustomColors.paleCyan, border: Border.all(width: 3)),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: blackInterBold(
                ref.read(sectionsProvider).assignedTeacherName.isNotEmpty
                    ? ref.read(sectionsProvider).assignedTeacherName
                    : 'No Assigned Teacher',
                textAlign: TextAlign.left,
                fontSize: 32),
          ),
          ElevatedButton(
              onPressed: showAvailableTeachers,
              child: blackInterBold('ASSIGN TEACHER'))
        ],
      ),
    ));
  }

  Widget _sectionStudentsContainer() {
    return vertical10Pix(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
          color: CustomColors.paleCyan, border: Border.all(width: 3)),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: blackInterBold(
                  'Section Students',
                  fontSize: 32,
                  textAlign: TextAlign.left,
                ),
              ),
              ElevatedButton(
                  onPressed: showAvailableStudents,
                  child: blackInterBold('ASSIGN STUDENT'))
            ],
          ),
          const Divider(color: Colors.black, thickness: 3),
          ref.read(sectionsProvider).sectionStudentDocs.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      ref.read(sectionsProvider).sectionStudentDocs.length,
                  itemBuilder: (context, index) {
                    final studentData = ref
                        .read(sectionsProvider)
                        .sectionStudentDocs[index]
                        .data() as Map<dynamic, dynamic>;
                    String formattedName =
                        '${studentData[UserFields.firstName]} ${studentData[UserFields.lastName]}';
                    return Row(children: [
                      const Gap(20),
                      blackInterBold(formattedName, fontSize: 28)
                    ]);
                  },
                )
              : blackInterRegular('No Assigned Students', fontSize: 40)
        ],
      ),
    ));
  }

  void showAvailableTeachers() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                  child: Column(
                children: [
                  blackInterBold('AVAILABLE TEACHERS', fontSize: 20),
                  ref.read(sectionsProvider).availableTeacherDocs.isNotEmpty
                      ? Column(
                          children: ref
                              .read(sectionsProvider)
                              .availableTeacherDocs
                              .map((teacher) {
                            final teacherData =
                                teacher.data() as Map<dynamic, dynamic>;
                            final teacherName =
                                '${teacherData[UserFields.firstName]} ${teacherData[UserFields.lastName]}';
                            return SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: vertical10Pix(
                                  child: ElevatedButton(
                                      onPressed: () => assignUserToSection(
                                          context, ref,
                                          sectionID: widget.sectionID,
                                          userID: teacher.id),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              CustomColors.paleCyan),
                                      child: blackInterBold(teacherName))),
                            );
                          }).toList(),
                        )
                      : blackInterBold('No Teachers Available')
                ],
              )),
            ));
  }

  void showAvailableStudents() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                  child: Column(
                children: [
                  blackInterBold('AVAILABLE STUDENTS', fontSize: 20),
                  ref
                          .read(sectionsProvider)
                          .studentsWithNoSectionDocs
                          .isNotEmpty
                      ? Column(
                          children: ref
                              .read(sectionsProvider)
                              .studentsWithNoSectionDocs
                              .map((student) {
                            final studentData =
                                student.data() as Map<dynamic, dynamic>;
                            final teacherName =
                                '${studentData[UserFields.firstName]} ${studentData[UserFields.lastName]}';
                            return SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: vertical10Pix(
                                  child: ElevatedButton(
                                      onPressed: () => assignUserToSection(
                                          context, ref,
                                          sectionID: widget.sectionID,
                                          userID: student.id),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              CustomColors.paleCyan),
                                      child: blackInterRegular(teacherName))),
                            );
                          }).toList(),
                        )
                      : blackInterBold('No Students Available')
                ],
              )),
            ));
  }
}
