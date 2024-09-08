import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/utils/go_router_util.dart';
import 'package:comprehenzone_web/widgets/custom_button_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_text_widgets.dart';

class AddTeacherScreen extends ConsumerStatefulWidget {
  const AddTeacherScreen({super.key});

  @override
  ConsumerState<AddTeacherScreen> createState() => _AddTeacherScreenState();
}

class _AddTeacherScreenState extends ConsumerState<AddTeacherScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final idNumberController = TextEditingController();

  List<DocumentSnapshot> availableSectionDocs = [];
  String selectedSectionID = '';
  String selectedSectionName = '';

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
        String userType = await getCurrentUserType();
        if (userType != UserTypes.admin) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        List<DocumentSnapshot> sectionDocs = await getAllSectionDocs();
        for (var section in sectionDocs) {
          final assignedTeacher = await FirebaseFirestore.instance
              .collection(Collections.users)
              .where(UserFields.assignedSections, arrayContains: section.id)
              .get();
          List<DocumentSnapshot> assignedTeacherDocs = assignedTeacher.docs;
          if (assignedTeacherDocs.isEmpty) {
            availableSectionDocs.add(section);
          }
        }
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting all students: $error')));
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              adminLeftNavigator(context, path: GoRoutes.teachers),
              bodyBlueBackgroundContainer(context,
                  child: SingleChildScrollView(
                    child: horizontal5Percent(context,
                        child: Column(
                          children: [
                            _backButton(),
                            newTeacherHeader(),
                            Gap(4),
                            userFieldsContainer(),
                          ],
                        )),
                  )),
            ],
          )),
    );
  }

  Widget _backButton() {
    return Row(children: [
      all20Pix(
          child: ElevatedButton(
              onPressed: () => GoRouter.of(context).goNamed(GoRoutes.teachers),
              style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.midnightBlue),
              child: whiteInterBold('BACK')))
    ]);
  }

  Widget newTeacherHeader() {
    return borderedOlympicBlueContainer(
        child: SizedBox(
            width: double.infinity,
            child: blackInterBold('NEW TEACHER', fontSize: 28)));
  }

  Widget userFieldsContainer() {
    return Container(
      decoration: BoxDecoration(
          color: CustomColors.olympicBlue,
          border: Border.all(width: 4, color: CustomColors.navigatorBlue)),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          emailAddressTextField(
              emailController: emailController, textColor: Colors.black),
          passwordTextField(
              label: 'Password',
              passwordController: passwordController,
              textColor: Colors.black),
          passwordTextField(
              label: 'Confirm Password',
              passwordController: confirmPasswordController,
              textColor: Colors.black),
          const Divider(color: Colors.black),
          regularTextField(
              label: 'First Name',
              textController: firstNameController,
              textColor: Colors.black),
          regularTextField(
              label: 'Last Name',
              textController: lastNameController,
              textColor: Colors.black),
          numberTextField(
              label: 'ID Number',
              textController: idNumberController,
              textColor: Colors.black),
          sectionWidget(),
          all20Pix(
              child: ElevatedButton(
                  onPressed: () => addNewUser(context, ref,
                      userType: UserTypes.teacher,
                      emailController: emailController,
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                      firstNameController: firstNameController,
                      lastNameController: lastNameController,
                      idNumberController: idNumberController,
                      sectionID: selectedSectionID,
                      gradeLevel: ''),
                  child: blackInterBold('ADD NEW TEACHER')))
        ],
      ),
    );
  }

  Widget sectionWidget() {
    return all10Pix(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        blackInterBold('Section', fontSize: 20),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(width: 2),
              borderRadius: BorderRadius.circular(30)),
          child: ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: ((context) => Dialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            blackInterBold('Select this teacher\'s section',
                                fontSize: 24),
                            availableSectionDocs.isNotEmpty
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children:
                                        availableSectionDocs.map((section) {
                                      final sectionData = section.data()
                                          as Map<dynamic, dynamic>;
                                      return vertical10Pix(
                                        child: ElevatedButton(
                                            onPressed: () {
                                              GoRouter.of(context).pop();
                                              setState(() {
                                                selectedSectionID = section.id;
                                                selectedSectionName =
                                                    sectionData[
                                                        SectionFields.name];
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    CustomColors.midnightBlue),
                                            child: whiteInterBold(sectionData[
                                                SectionFields.name])),
                                      );
                                    }).toList())
                                : blackInterBold(
                                    'There are currently no available sections to assign this teacher to.')
                          ],
                        ))));
              },
              child: blackInterBold(selectedSectionName.isNotEmpty
                  ? selectedSectionName
                  : 'SELECT A SECTION')),
        )
      ]),
    );
  }
}
