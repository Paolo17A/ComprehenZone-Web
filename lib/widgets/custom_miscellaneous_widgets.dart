import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/models/speech_model.dart';
import 'package:comprehenzone_web/providers/verification_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/section_model.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../utils/numbers_util.dart';
import '../utils/string_util.dart';
import 'custom_button_widgets.dart';
import 'custom_padding_widgets.dart';
import 'custom_text_field_widget.dart';
import 'custom_text_widgets.dart';

Widget stackedLoadingContainer(
    BuildContext context, bool isLoading, Widget child) {
  return Stack(children: [
    child,
    if (isLoading)
      Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.5),
          child: const Center(child: CircularProgressIndicator()))
  ]);
}

Widget switchedLoadingContainer(bool isLoading, Widget child) {
  return isLoading ? const Center(child: CircularProgressIndicator()) : child;
}

Widget bodyGradientContainer(BuildContext context, {required Widget child}) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.8,
    height: MediaQuery.of(context).size.height,
    decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage(ImagePaths.gradientBG), fit: BoxFit.cover)),
    child: child,
  );
}

Widget loginFieldsContainer(BuildContext context, WidgetRef ref,
    {required TextEditingController emailController,
    required TextEditingController passwordController}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(ImagePaths.gradientBG), fit: BoxFit.cover)),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          blackInterBold('Login', fontSize: 40),
          emailAddressTextField(emailController: emailController),
          all10Pix(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              blackInterBold('Password', fontSize: 18),
              CustomTextField(
                  text: 'Password',
                  controller: passwordController,
                  textInputType: TextInputType.visiblePassword,
                  onSearchPress: () => logInUser(context, ref,
                      emailController: emailController,
                      passwordController: passwordController),
                  displayPrefixIcon: const Icon(Icons.lock)),
            ],
          )),
          const Gap(30),
          loginButton(
              onPress: () => logInUser(context, ref,
                  emailController: emailController,
                  passwordController: passwordController)),
        ],
      ));
}

Widget registerFieldsContainer(BuildContext context, WidgetRef ref,
    {required String userType,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController idNumberController}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(ImagePaths.gradientBG), fit: BoxFit.cover)),
      child: SingleChildScrollView(
        child: all20Pix(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              blackInterBold('Register', fontSize: 40),
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
              const Divider(color: Colors.black),
              verificationImageUploadWidget(context, ref),
              const Divider(color: Colors.black),
              registerButton(
                  onPress: () => registerNewUser(context, ref,
                      userType: userType,
                      emailController: emailController,
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                      firstNameController: firstNameController,
                      lastNameController: lastNameController,
                      idNumberController: idNumberController)),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                blackInterRegular('Already have an account?', fontSize: 12),
                TextButton(
                    onPressed: () =>
                        GoRouter.of(context).goNamed(GoRoutes.home),
                    child: blackInterRegular('Login to your account',
                        fontSize: 12, textDecoration: TextDecoration.underline))
              ])
            ],
          ),
        ),
      ));
}

Widget emailAddressTextField({required TextEditingController emailController}) {
  return all10Pix(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        blackInterBold('Email Address', fontSize: 18),
        CustomTextField(
            text: 'Email Address',
            controller: emailController,
            textInputType: TextInputType.emailAddress,
            displayPrefixIcon: const Icon(Icons.email))
      ],
    ),
  );
}

Widget passwordTextField(
    {required String label,
    required TextEditingController passwordController}) {
  return all10Pix(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      blackInterBold(label, fontSize: 18),
      CustomTextField(
          text: label,
          controller: passwordController,
          textInputType: TextInputType.visiblePassword,
          displayPrefixIcon: const Icon(Icons.lock)),
    ],
  ));
}

Widget regularTextField(
    {required String label, required TextEditingController textController}) {
  return all10Pix(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      blackInterBold(label, fontSize: 18),
      CustomTextField(
          text: label,
          controller: textController,
          textInputType: TextInputType.name,
          displayPrefixIcon: null),
    ],
  ));
}

Widget numberTextField(
    {required String label, required TextEditingController textController}) {
  return all10Pix(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      blackInterBold(label, fontSize: 18),
      CustomTextField(
          text: label,
          controller: textController,
          textInputType: TextInputType.number,
          displayPrefixIcon: null),
    ],
  ));
}

Widget multiLineTextField(
    {required String label, required TextEditingController textController}) {
  return all10Pix(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      blackInterBold(label, fontSize: 18),
      CustomTextField(
          text: label,
          controller: textController,
          textInputType: TextInputType.multiline,
          displayPrefixIcon: null),
    ],
  ));
}

Widget verificationImageUploadWidget(
  BuildContext context,
  WidgetRef ref,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [blackInterBold('Faculty ID', fontSize: 18)]),
      if (ref.read(verificationImageProvider).verificationImage != null)
        vertical10Pix(
          child: Container(
            decoration:
                BoxDecoration(color: Colors.black, border: Border.all()),
            child: Image.memory(
              ref.read(verificationImageProvider).verificationImage!,
              width: double.infinity,
              height: MediaQuery.of(context).size.width * 0.15,
              fit: BoxFit.contain,
            ),
          ),
        ),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border.all(), borderRadius: BorderRadius.circular(10)),
        child: TextButton(
            onPressed: () =>
                ref.read(verificationImageProvider).setVerificationImage(),
            child: blackInterBold('SELECT FACULTY ID', fontSize: 12)),
      )
    ],
  );
}

Container viewContentContainer(BuildContext context, {required Widget child}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: CustomColors.paleCyan.withOpacity(0.5),
        border: Border.all(color: Colors.black),
      ),
      child: child);
}

Widget viewContentLabelRow(BuildContext context,
    {required List<Widget> children}) {
  return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Row(children: children));
}

Widget viewContentEntryRow(BuildContext context,
    {required List<Widget> children}) {
  return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      height: 50,
      child: Row(children: children));
}

Widget viewFlexTextCell(String text,
    {required int flex,
    backgroundColor = CustomColors.paleCyan,
    Color textColor = Colors.black,
    Border customBorder =
        const Border.symmetric(horizontal: BorderSide(width: 3)),
    BorderRadius? customBorderRadius}) {
  return Flexible(
    flex: flex,
    child: Container(
        height: 50,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: backgroundColor,
            border: customBorder,
            borderRadius: customBorderRadius),
        child: ClipRRect(
          child: Center(
              child: Text(text,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                  ))),
        )),
  );
}

Widget viewFlexLabelTextCell(String text, int flex) {
  return viewFlexTextCell(text,
      flex: flex,
      backgroundColor: CustomColors.paleCyan,
      textColor: Colors.black);
}

Widget viewFlexActionsCell(List<Widget> children,
    {required int flex,
    backgroundColor = CustomColors.paleCyan,
    Color textColor = Colors.black,
    Border customBorder =
        const Border.symmetric(horizontal: BorderSide(width: 3)),
    BorderRadius? customBorderRadius}) {
  return Flexible(
      flex: flex,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            border: customBorder,
            borderRadius: customBorderRadius,
            color: backgroundColor),
        child: Center(
            child: Wrap(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.spaceEvenly,
                spacing: 10,
                runSpacing: 10,
                children: children)),
      ));
}

Widget viewContentUnavailable(BuildContext context, {required String text}) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.65,
    child: Center(child: blackInterBold(text, fontSize: 44)),
  );
}

void showVerificationImageDialog(BuildContext context,
    {required String verificationImage}) {
  showDialog(
      context: context,
      builder: (_) => Dialog(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () => GoRouter.of(context).pop(),
                              child: blackInterBold('X'))
                        ]),
                  ),
                  vertical20Pix(
                    child: Container(
                      decoration: BoxDecoration(border: Border.all()),
                      child: Image.network(
                        verificationImage,
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.height * 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
}

Widget snapshotHandler(AsyncSnapshot snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
  } else if (!snapshot.hasData) {
    return const Text('No data found');
  } else if (snapshot.hasError) {
    return Text('Error gettin data: ${snapshot.error.toString()}');
  }
  return Container();
}

Widget buildProfileImage({required String profileImageURL}) {
  return profileImageURL.isNotEmpty
      ? CircleAvatar(
          radius: 70,
          backgroundColor: CustomColors.midnightBlue,
          backgroundImage: NetworkImage(profileImageURL),
        )
      : const CircleAvatar(
          radius: 70,
          backgroundColor: CustomColors.midnightBlue,
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: 80,
          ));
}

Widget analyticReportWidget(BuildContext context,
    {required String count,
    required String demographic,
    required Widget displayIcon,
    required Function? onPress}) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Container(
        width: 250,
        height: MediaQuery.of(context).size.height * 0.2,
        decoration: BoxDecoration(
            color: CustomColors.pearlWhite, border: Border.all(width: 3)),
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                blackInterBold(count, fontSize: 40),
                Container(
                  width: 150,
                  height: 45,
                  decoration: BoxDecoration(
                      color: CustomColors.grass, border: Border.all()),
                  child: TextButton(
                    onPressed: onPress != null ? () => onPress() : null,
                    child: Center(
                      child: whiteInterBold(demographic, fontSize: 15),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.05,
              child: Transform.scale(scale: 2, child: displayIcon))
        ])),
  );
}

Container breakdownContainer(BuildContext context, {required Widget child}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            offset: const Offset(0, 3), color: Colors.grey.withOpacity(0.5))
      ], borderRadius: BorderRadius.circular(20), color: Colors.white),
      child: Padding(padding: const EdgeInsets.all(11), child: child));
}

Widget sectionCountFutureBuilder() {
  return FutureBuilder(
      future: getAllSectionDocs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.hasError) {
          return const Text('Error retrieving data');
        }
        int sectionCount = snapshot.data!.length;
        return analyticReportWidget(context,
            count: sectionCount.toString(),
            demographic: 'Sections',
            displayIcon: const Icon(Icons.security_outlined),
            onPress: () => GoRouter.of(context).goNamed(GoRoutes.sections));
      });
}

Widget assignedSectionsCountFutureBuilder() {
  return FutureBuilder(
      future: getAllSectionDocs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.hasError) {
          return const Text('Error retrieving data');
        }
        int sectionCount = snapshot.data!.length;
        return analyticReportWidget(context,
            count: sectionCount.toString(),
            demographic: 'Sections',
            displayIcon: const Icon(Icons.security_outlined),
            onPress: () => GoRouter.of(context).goNamed(GoRoutes.sections));
      });
}

Widget teacherCountFutureBuilder() {
  return FutureBuilder(
      future: getAllTeacherDocs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.hasError) {
          return const Text('Error retrieving data');
        }
        int teacherCount = snapshot.data!.length;
        return analyticReportWidget(context,
            count: teacherCount.toString(),
            demographic: 'Teachers',
            displayIcon: const Icon(Icons.person_2),
            onPress: () => GoRouter.of(context).goNamed(GoRoutes.teachers));
      });
}

Widget studentCountFutureBuilder() {
  return FutureBuilder(
      future: getAllStudentDocs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.hasError) {
          return const Text('Error retrieving data');
        }
        int studentCount = snapshot.data!.length;
        return analyticReportWidget(context,
            count: studentCount.toString(),
            demographic: 'Students',
            displayIcon: const Icon(Icons.people),
            onPress: () => GoRouter.of(context).goNamed(GoRoutes.students));
      });
}

Widget modulesCountFutureBuilder() {
  return FutureBuilder(
      future: getAllModuleDocs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.hasError) {
          return const Text('Error retrieving data');
        }
        int moduleCount = snapshot.data!.length;
        return analyticReportWidget(context,
            count: moduleCount.toString(),
            demographic: 'Modules',
            displayIcon: const Icon(Icons.book),
            onPress: () => GoRouter.of(context).goNamed(GoRoutes.modules));
      });
}

Widget teacherModulesCountFutureBuilder() {
  return FutureBuilder(
      future: getAllUserModuleDocs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.hasError) {
          return const Text('Error retrieving data');
        }
        int moduleCount = snapshot.data!.length;
        return analyticReportWidget(context,
            count: moduleCount.toString(),
            demographic: 'Modules',
            displayIcon: const Icon(Icons.book),
            onPress: () => GoRouter.of(context).goNamed(GoRoutes.modules));
      });
}

Widget quizzesCountFutureBuilder() {
  return FutureBuilder(
      future: getAllQuizDocs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.hasError) {
          return const Text('Error retrieving data');
        }
        int quizzesCount = snapshot.data!.length;
        return analyticReportWidget(context,
            count: quizzesCount.toString(),
            demographic: 'Quizzes',
            displayIcon: const Icon(Icons.quiz),
            onPress: () => GoRouter.of(context).goNamed(GoRoutes.quizzes));
      });
}

Widget teacherQuizzesCountFutureBuilder() {
  return FutureBuilder(
      future: getAllUserQuizDocs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.hasError) {
          return const Text('Error retrieving data');
        }
        int quizzesCount = snapshot.data!.length;
        return analyticReportWidget(context,
            count: quizzesCount.toString(),
            demographic: 'Quizzes',
            displayIcon: const Icon(Icons.quiz),
            onPress: () => GoRouter.of(context).goNamed(GoRoutes.quizzes));
      });
}

Widget sectionsBarChart(BuildContext context,
    {required List<SectionModel> sectionModels}) {
  return sectionModels.isNotEmpty
      ? SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: SfCartesianChart(
              borderWidth: 2,
              //borderColor: Colors.black,
              plotAreaBorderColor: Colors.black,
              isTransposed: false,
              primaryXAxis: const CategoryAxis(
                axisLine: AxisLine(color: Colors.black),
                labelStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 10),
              ),
              primaryYAxis: const NumericAxis(
                  axisLine: AxisLine(color: Colors.black),
                  minimum: 0,
                  interval: 5,
                  borderColor: Colors.black,
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                  title: AxisTitle(
                      text: 'Students',
                      textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16))),
              title: const ChartTitle(
                  text: 'Section Student Count',
                  borderColor: Colors.black,
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 25)),
              series: <BarSeries<SectionModel, String>>[
                BarSeries<SectionModel, String>(
                    color: CustomColors.midnightBlue,
                    dataSource: sectionModels,
                    width: 0.5,
                    animationDuration: 0,
                    spacing: 0,
                    xValueMapper: (SectionModel sectionData, _) =>
                        sectionData.name,
                    yValueMapper: (SectionModel sectionData, _) =>
                        sectionData.students)
              ]),
        )
      : const Center(
          child: Text(
            'No sections available',
            style: TextStyle(
                color: CustomColors.midnightBlue,
                fontWeight: FontWeight.bold,
                fontSize: 30),
          ),
        );
}

Widget quizResultEntry(BuildContext context,
    {required DocumentSnapshot quizResultDoc}) {
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
          onPressed: () => GoRouter.of(context).goNamed(
              GoRoutes.selectedQuizResult,
              pathParameters: {PathParameters.quizResultID: quizResultDoc.id}),
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

Widget speechResultEntry(
    BuildContext context, DocumentSnapshot speechResultDoc) {
  final speechResultData = speechResultDoc.data() as Map<dynamic, dynamic>;
  List<dynamic> speechResults =
      speechResultData[SpeechResultFields.speechResults];
  int speechIndex = speechResultData[SpeechResultFields.speechIndex];
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(border: Border.all()),
    padding: EdgeInsets.all(10),
    child: TextButton(
      onPressed: () => GoRouter.of(context).goNamed(
          GoRoutes.selectedSpeechResult,
          pathParameters: {PathParameters.speechResultID: speechResultDoc.id}),
      child: Row(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            blackInterBold(getSpeeechByIndex(speechIndex)!.category,
                fontSize: 20),
            blackInterRegular(
                '${calculateAverageConfidence(speechResults).toStringAsFixed(2)}%',
                fontSize: 16)
          ]),
        ],
      ),
    ),
  );
}
