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
        ref.read(sectionsProvider).setSectionStudentDocs([]);
        ref.read(loadingProvider).toggleLoading(true);

        //  In case user refreshed the screen and the provider is reset
        if (ref.read(userTypeProvider).userType.isEmpty) {
          ref.read(userTypeProvider).setUserType(await getCurrentUserType());
        }
        if (ref.read(userTypeProvider).userType == UserTypes.student) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        final sectionData = await getThisSectionDoc(widget.sectionID);
        name = sectionData[SectionFields.name];

        //  TEACHERS
        final teachers = await getSectionTeachersDoc(widget.sectionID);
        if (teachers.isNotEmpty) {
          ref
              .read(sectionsProvider)
              .setAssignedTeacherNames(teachers.map((teacher) {
                final teacherData = teacher.data() as Map<dynamic, dynamic>;
                String formattedName =
                    '${teacherData[UserFields.firstName]} ${teacherData[UserFields.lastName]}';
                return formattedName;
              }).toList());
        } else {
          ref.read(sectionsProvider).setAssignedTeacherNames([]);
        }
        ref.read(sectionsProvider).setAvailableTeacherDocs(
            await getAvailableTeacherDocs(widget.sectionID));

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
    ref.watch(userTypeProvider);
    return Scaffold(
      body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ref.read(userTypeProvider).userType == UserTypes.admin
                  ? adminLeftNavigator(context, path: GoRoutes.sections)
                  : teacherLeftNavigator(context, path: GoRoutes.sections),
              bodyBlueBackgroundContainer(context,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _backButton(),
                        horizontal5Percent(context,
                            child: Column(
                              children: [
                                _newSectionHeader(),
                                _sectionTeacherContainer(),
                                _sectionStudentsContainer()
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
        child: Row(children: [
      backButton(context,
          onPress: () => GoRouter.of(context).goNamed(GoRoutes.sections))
    ]));
  }

  Widget _newSectionHeader() {
    return vertical20Pix(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
          color: CustomColors.olympicBlue, border: Border.all(width: 3)),
      padding: const EdgeInsets.all(10),
      child: blackInterBold(name, fontSize: 28),
    ));
  }

  Widget _sectionTeacherContainer() {
    return vertical10Pix(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
          color: CustomColors.olympicBlue, border: Border.all(width: 3)),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: blackInterBold('Section Teachers',
                      fontSize: 28, textAlign: TextAlign.left)),
              if (ref.read(userTypeProvider).userType == UserTypes.admin)
                blueBorderElevatedButton(
                    label: 'ASSIGN TEACHER', onPress: showAvailableTeachers)
              /*ElevatedButton(
                    onPressed: showAvailableTeachers,
                    child: blackInterBold('ASSIGN TEACHER'))*/
            ],
          ),
          const Divider(color: Colors.black, thickness: 3),
          ref.read(sectionsProvider).assignedTeacherNames.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ref
                      .read(sectionsProvider)
                      .assignedTeacherNames
                      .map((teacher) => blackInterBold(teacher,
                          fontSize: 24, textAlign: TextAlign.left))
                      .toList(),
                )
              : blackInterBold('No Assigned Teacher',
                  textAlign: TextAlign.left, fontSize: 24),
        ],
      ),
    ));
  }

  Widget _sectionStudentsContainer() {
    return vertical10Pix(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(
          color: CustomColors.olympicBlue, border: Border.all(width: 3)),
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
                  fontSize: 28,
                  textAlign: TextAlign.left,
                ),
              ),
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
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //const Gap(20),
                          blackInterBold(formattedName, fontSize: 24),
                          FutureBuilder(
                              future: getStudentGradeAverage(ref
                                  .read(sectionsProvider)
                                  .sectionStudentDocs[index]
                                  .id),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    !snapshot.hasData ||
                                    snapshot.hasError) {
                                  return snapshotHandler(snapshot);
                                }
                                return blackInterBold(
                                    snapshot.data != null
                                        ? 'Average Grade: ${(snapshot.data! * 10).toStringAsFixed(1)}%'
                                        : 'Average Grade: N/A',
                                    fontSize: 26);
                              })
                        ]);
                  },
                )
              : blackInterRegular('No Assigned Students', fontSize: 24)
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
                                              CustomColors.backgroundBlue),
                                      child: whiteInterBold(teacherName))),
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
                                              CustomColors.backgroundBlue),
                                      child: blackInterRegular(teacherName))),
                            );
                          }).toList(),
                        )
                      : whiteInterBold('No Students Available')
                ],
              )),
            ));
  }
}
