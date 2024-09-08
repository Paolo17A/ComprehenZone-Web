import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/utils/go_router_util.dart';
import 'package:comprehenzone_web/widgets/custom_button_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/dropdown_widget.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_text_widgets.dart';

class AddStudentScreen extends ConsumerStatefulWidget {
  const AddStudentScreen({super.key});

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final idNumberController = TextEditingController();
  String gradeLevel = '5';

  List<DocumentSnapshot> sectionDocs = [];
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
        sectionDocs = await getAllSectionDocs();
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
              adminLeftNavigator(context, path: GoRoutes.students),
              bodyBlueBackgroundContainer(context,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _backButton(),
                        horizontal5Percent(context,
                            child: Column(
                              children: [
                                newStudentHeader(),
                                Gap(4),
                                userFieldsContainer(),
                                Gap(20)
                              ],
                            )),
                      ],
                    ),
                  )),
            ],
          )),
    );
  }

  Widget _backButton() {
    return Row(children: [
      all20Pix(
          child: backButton(context,
              onPress: () => GoRouter.of(context).goNamed(GoRoutes.students)))
    ]);
  }

  Widget newStudentHeader() {
    return borderedOlympicBlueContainer(
        child: SizedBox(
            width: double.infinity,
            child: blackInterBold('NEW STUDENT', fontSize: 40)));
  }

  Widget userFieldsContainer() {
    return Container(
      decoration: BoxDecoration(
        color: CustomColors.olympicBlue,
        border: Border.all(color: CustomColors.navigatorBlue, width: 4),
      ),
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
          gradeLevelDropdown(),
          all20Pix(
              child: ElevatedButton(
                  onPressed: () => addNewUser(context, ref,
                      userType: UserTypes.student,
                      emailController: emailController,
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                      firstNameController: firstNameController,
                      lastNameController: lastNameController,
                      idNumberController: idNumberController,
                      sectionID: selectedSectionID,
                      gradeLevel: gradeLevel),
                  child: blackInterBold('ADD NEW STUDENT')))
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
                        child: all20Pix(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              blackInterBold('Select this student\'s section',
                                  fontSize: 24),
                              Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: sectionDocs.map((section) {
                                    final sectionData =
                                        section.data() as Map<dynamic, dynamic>;
                                    return vertical10Pix(
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
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
                                      ),
                                    );
                                  }).toList()),
                            ],
                          ),
                        ))));
              },
              child: blackInterBold(selectedSectionName.isNotEmpty
                  ? selectedSectionName
                  : 'SELECT A SECTION')),
        )
      ]),
    );
  }

  Widget gradeLevelDropdown() {
    return all10Pix(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        blackInterBold('Grade Level', fontSize: 20),
        Container(
          decoration: BoxDecoration(
              border: Border.all(), borderRadius: BorderRadius.circular(10)),
          child: dropdownWidget(gradeLevel, (newVal) {
            if (newVal == null) return;
            setState(() {
              gradeLevel = newVal;
            });
          }, ['5', '6'], gradeLevel, false),
        )
      ]),
    );
  }
}
