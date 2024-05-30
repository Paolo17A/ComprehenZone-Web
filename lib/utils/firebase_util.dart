//==============================================================================
//USERS=========================================================================
//==============================================================================
// ignore_for_file: unnecessary_cast

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/sections_provider.dart';
import 'package:comprehenzone_web/providers/verification_image_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/loading_provider.dart';
import '../providers/user_type_provider.dart';
import '../providers/users_provider.dart';
import 'go_router_util.dart';
import 'string_util.dart';

bool hasLoggedInUser() {
  return FirebaseAuth.instance.currentUser != null;
}

Future logInUser(BuildContext context, WidgetRef ref,
    {required TextEditingController emailController,
    required TextEditingController passwordController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final goRouter = GoRouter.of(context);
  try {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all given fields.')));
      return;
    }
    ref.read(loadingProvider).toggleLoading(true);
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
    final userDoc = await getCurrentUserDoc();
    final userData = userDoc.data() as Map<dynamic, dynamic>;

    if (userData[UserFields.userType] == UserTypes.student) {
      await FirebaseAuth.instance.signOut();
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text(
              'Only admins and teachers may log-in to the web platform.')));
      ref.read(loadingProvider.notifier).toggleLoading(false);
      return;
    }

    if (!userData[UserFields.isVerified]) {
      await FirebaseAuth.instance.signOut();
      scaffoldMessenger.showSnackBar(const SnackBar(
          content:
              Text('Your account has not yet been verified by the admin')));
      ref.read(loadingProvider.notifier).toggleLoading(false);
      return;
    }

    //  reset the password in firebase in case client reset it using an email link.
    if (userData[UserFields.password] != passwordController.text) {
      await FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({UserFields.password: passwordController.text});
    }
    ref.read(userTypeProvider).setUserType(userData[UserFields.userType]);
    ref.read(loadingProvider.notifier).toggleLoading(false);
    goRouter.goNamed(GoRoutes.home);
    goRouter.pushReplacementNamed(GoRoutes.home);
  } catch (error) {
    scaffoldMessenger
        .showSnackBar(SnackBar(content: Text('Error logging in: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future registerNewUser(BuildContext context, WidgetRef ref,
    {required String userType,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController idNumberController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final goRouter = GoRouter.of(context);
  try {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        idNumberController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all given fields.')));
      return;
    }
    if (!emailController.text.contains('@') ||
        !emailController.text.contains('.com')) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please input a valid email address')));
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('The passwords do not match')));
      return;
    }
    if (passwordController.text.length < 6) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('The password must be at least six characters long')));
      return;
    }
    if (ref.read(verificationImageProvider).verificationImage == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Please upload an image of your faculty ID.')));
      return;
    }
    //  Create user with Firebase Auth
    ref.read(loadingProvider).toggleLoading(true);
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(), password: passwordController.text);

    //  Create new document is Firestore database
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      UserFields.email: emailController.text.trim(),
      UserFields.password: passwordController.text,
      UserFields.firstName: firstNameController.text.trim(),
      UserFields.lastName: lastNameController.text.trim(),
      UserFields.userType: userType,
      UserFields.profileImageURL: '',
      UserFields.idNumber: idNumberController.text.trim(),
      UserFields.isVerified: false,
      UserFields.assignedSection: ''
    });

    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.verificationImages)
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('${FirebaseAuth.instance.currentUser!.uid}.png');
    final uploadTask = storageRef
        .putData(ref.read(verificationImageProvider).verificationImage!);
    final taskSnapshot = await uploadTask;
    final String verificationImage = await taskSnapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({UserFields.verificationImage: verificationImage});
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully registered new user')));
    await FirebaseAuth.instance.signOut();
    ref.read(loadingProvider).toggleLoading(false);
    ref.read(verificationImageProvider).resetVerificationImage();
    goRouter.goNamed(GoRoutes.home);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error registering new user: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future<DocumentSnapshot> getCurrentUserDoc() async {
  return await getThisUserDoc(FirebaseAuth.instance.currentUser!.uid);
}

Future<DocumentSnapshot> getThisUserDoc(String userID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.users)
      .doc(userID)
      .get();
}

Future<String> getCurrentUserType() async {
  final userDoc = await getCurrentUserDoc();
  final userData = userDoc.data() as Map<dynamic, dynamic>;
  return userData[UserFields.userType];
}

Future<List<DocumentSnapshot>> getAllTeacherDocs() async {
  final users = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.teacher)
      .get();
  return users.docs.map((user) => user as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAllStudentDocs() async {
  final users = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.student)
      .get();
  return users.docs.map((user) => user as DocumentSnapshot).toList();
}

Future approveThisUserRegistration(BuildContext context, WidgetRef ref,
    {required String userID, required String userType}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider).toggleLoading(true);
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(userID)
        .update({UserFields.isVerified: true});
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully approved this user\'s registration.')));
    ref.read(usersProvider).setUserDocs(userType == UserTypes.teacher
        ? await getAllTeacherDocs()
        : await getAllStudentDocs());
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Error approving this user\'s registration.: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future denyThisUserRegistration(BuildContext context, WidgetRef ref,
    {required String userID, required String userType}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider).toggleLoading(true);

    //  Store admin's current data locally then sign out
    final currentUser = await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final currentUserData = currentUser.data() as Map<dynamic, dynamic>;
    String userEmail = currentUserData[UserFields.email];
    String userPassword = currentUserData[UserFields.password];
    await FirebaseAuth.instance.signOut();

    //  Log-in to the collector account to be deleted
    final collector = await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(userID)
        .get();
    final collectorData = collector.data() as Map<dynamic, dynamic>;
    String collectorEmail = collectorData[UserFields.email];
    String collectorPassword = collectorData[UserFields.password];
    final collectorToDelete = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: collectorEmail, password: collectorPassword);
    await collectorToDelete.user!.delete();

    //  Log-back in to admin account
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: userEmail, password: userPassword);

    //  Delete valid IDs from Firebase Storage
    await FirebaseStorage.instance
        .ref()
        .child(StorageFields.verificationImages)
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('${FirebaseAuth.instance.currentUser!.uid}.png')
        .delete();

    //  Delete collector document from users Firestore collection
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(userID)
        .delete();
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully denied this user\'s registration.')));
    ref.read(usersProvider).setUserDocs(userType == UserTypes.teacher
        ? await getAllTeacherDocs()
        : await getAllStudentDocs());
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Error denying this user\'s registration: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future<List<DocumentSnapshot>> getSectionStudentDocs(String sectionID) async {
  final students = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.student)
      .where(UserFields.assignedSection, isEqualTo: sectionID)
      .get();
  return students.docs.map((student) => student as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getSectionTeacherDoc(String sectionID) async {
  final teachers = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.teacher)
      .where(UserFields.assignedSection, isEqualTo: sectionID)
      .get();
  return teachers.docs.map((teacher) => teacher as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getStudentsWithNoSectionDocs() async {
  final students = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.student)
      .where(UserFields.assignedSection, isEqualTo: '')
      .where(UserFields.isVerified, isEqualTo: true)
      .get();
  return students.docs.map((student) => student as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAvailableTeacherDocs() async {
  final teachers = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.teacher)
      .where(UserFields.assignedSection, isEqualTo: '')
      .where(UserFields.isVerified, isEqualTo: true)
      .get();
  return teachers.docs.map((student) => student as DocumentSnapshot).toList();
}

//==============================================================================
//SECTIONS======================================================================
//==============================================================================

Future<List<DocumentSnapshot>> getAllSectionDocs() async {
  final sections =
      await FirebaseFirestore.instance.collection(Collections.sections).get();
  return sections.docs.map((user) => user as DocumentSnapshot).toList();
}

Future<DocumentSnapshot> getThisSectionDoc(String sectionID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.sections)
      .doc(sectionID)
      .get();
}

Future addNewSection(BuildContext context, WidgetRef ref,
    {required TextEditingController nameController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final goRouter = GoRouter.of(context);
  if (nameController.text.isEmpty || nameController.text.trim().length < 2) {
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text(
            'Please input a valid section name that is at least two characters long')));
    return;
  }
  try {
    ref.read(loadingProvider).toggleLoading(true);
    goRouter.pop();
    await FirebaseFirestore.instance
        .collection(Collections.sections)
        .add({SectionFields.name: nameController.text.trim()});
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully added new section.')));
    ref.read(sectionsProvider).setSectionDocs(await getAllSectionDocs());
    ref.read(loadingProvider).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error adding new section: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future editThisSection(BuildContext context, WidgetRef ref,
    {required String sectionID,
    required TextEditingController nameController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final goRouter = GoRouter.of(context);
  if (nameController.text.isEmpty || nameController.text.trim().length < 2) {
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text(
            'Please input a valid section name that is at least two characters long')));
    return;
  }
  try {
    ref.read(loadingProvider).toggleLoading(true);
    goRouter.pop();
    await FirebaseFirestore.instance
        .collection(Collections.sections)
        .doc(sectionID)
        .update({SectionFields.name: nameController.text.trim()});
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully edited this section.')));
    ref.read(sectionsProvider).setSectionDocs(await getAllSectionDocs());
    ref.read(loadingProvider).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error editing this section: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future assignUserToSection(BuildContext context, WidgetRef ref,
    {required String sectionID, required userID}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final goRouter = GoRouter.of(context);
  try {
    ref.read(loadingProvider).toggleLoading(true);
    goRouter.pop();
    List<DocumentSnapshot> sectionTeacher =
        await getSectionTeacherDoc(sectionID);
    if (sectionTeacher.isNotEmpty) {
      final oldTeacherID = sectionTeacher.first.id;
      await FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(oldTeacherID)
          .update({UserFields.assignedSection: ''});
    }
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(userID)
        .update({UserFields.assignedSection: sectionID});
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully assigned user to this section')));

    //  TEACHERS
    final teachers = await getSectionTeacherDoc(sectionID);
    if (teachers.isNotEmpty) {
      final teacherData = teachers.first.data() as Map<dynamic, dynamic>;
      ref.read(sectionsProvider).setAssignedTeacherName(
          '${teacherData[UserFields.firstName]} ${teacherData[UserFields.lastName]}');
    }
    ref
        .read(sectionsProvider)
        .setAvailableTeacherDocs(await getAvailableTeacherDocs());

    //  STUDENTS
    ref
        .read(sectionsProvider)
        .setSectionStudentDocs(await getSectionStudentDocs(sectionID));
    ref
        .read(sectionsProvider)
        .setStudentsWithNoSectionDocs(await getStudentsWithNoSectionDocs());
    ref.read(loadingProvider).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error assigning user to section: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}
