import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/utils/go_router_util.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              bodyGradientContainer(context,
                  child: SingleChildScrollView(
                    child: horizontal5Percent(context,
                        child: Column(
                          children: [
                            _backButton(),
                            newTeacherHeader(),
                            userFieldsContainer(),
                            all20Pix(
                                child: ElevatedButton(
                                    onPressed: () => addNewUser(context, ref,
                                        userType: UserTypes.teacher,
                                        emailController: emailController,
                                        passwordController: passwordController,
                                        confirmPasswordController:
                                            confirmPasswordController,
                                        firstNameController:
                                            firstNameController,
                                        lastNameController: lastNameController,
                                        idNumberController: idNumberController,
                                        sectionID: selectedSectionID),
                                    child: blackInterBold('ADD NEW TEACHER')))
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
    return blackInterBold('NEW TEACHER', fontSize: 40);
  }

  Widget userFieldsContainer() {
    return Container(
      decoration: BoxDecoration(
          color: CustomColors.midnightBlue.withOpacity(0.3),
          border: Border.all(),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          emailAddressTextField(emailController: emailController),
          passwordTextField(
              label: 'Password', passwordController: passwordController),
          passwordTextField(
              label: 'Confirm Password',
              passwordController: confirmPasswordController),
          const Divider(color: Colors.black),
          regularTextField(
              label: 'First Name', textController: firstNameController),
          regularTextField(
              label: 'Last Name', textController: lastNameController),
          numberTextField(
              label: 'ID Number', textController: idNumberController),
          sectionWidget()
        ],
      ),
    );
  }

  Widget sectionWidget() {
    return all10Pix(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        blackInterBold('Section', fontSize: 20),
        SizedBox(
          width: double.infinity,
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
