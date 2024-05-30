import 'package:comprehenzone_web/providers/verification_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () =>
                      GoRouter.of(context).goNamed(GoRoutes.forgotPassword),
                  child: blackInterRegular('Forgot Password?',
                      fontSize: 12, textDecoration: TextDecoration.underline))
            ],
          ),
          const Gap(30),
          loginButton(
              onPress: () => logInUser(context, ref,
                  emailController: emailController,
                  passwordController: passwordController)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            blackInterRegular('Don\'t have an account?', fontSize: 12),
            TextButton(
                onPressed: () =>
                    GoRouter.of(context).goNamed(GoRoutes.register),
                child: blackInterRegular('REGISTER',
                    fontSize: 12, textDecoration: TextDecoration.underline))
          ])
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
        decoration: BoxDecoration(
            color: backgroundColor,
            border: customBorder,
            borderRadius: customBorderRadius),
        child: ClipRRect(
          child: Center(
              child: SelectableText(text,
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
