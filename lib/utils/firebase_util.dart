//==============================================================================
//USERS=========================================================================
//==============================================================================
// ignore_for_file: unnecessary_cast

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/sections_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/loading_provider.dart';
import '../providers/profile_image_url_provider.dart';
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

    //  reset the password in firebase in case client reset it using an email link.
    if (userData[UserFields.password] != passwordController.text) {
      await FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({UserFields.password: passwordController.text});
    }
    if (userData[UserFields.email] != emailController.text) {
      await FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({UserFields.email: emailController.text});
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
      UserFields.assignedSections: [],
      if (userType == UserTypes.student)
        UserFields.moduleProgresses: {
          'quarter1': {},
          'quarter2': {},
          'quarter3': {},
          'quarter4': {}
        }
    });
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully registered new user')));
    await FirebaseAuth.instance.signOut();
    ref.read(loadingProvider).toggleLoading(false);
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

Future<List<DocumentSnapshot>> getSectionStudentDocs(String sectionID) async {
  final students = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.student)
      .where(UserFields.assignedSections, arrayContains: sectionID)
      .get();
  return students.docs.map((student) => student as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getSectionTeachersDoc(String sectionID) async {
  final teachers = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.teacher)
      .where(UserFields.assignedSections, arrayContains: sectionID)
      .get();
  return teachers.docs.map((teacher) => teacher as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getStudentsWithNoSectionDocs() async {
  final students = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.student)
      .where(UserFields.assignedSections, isEqualTo: []).get();
  return students.docs.map((student) => student as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAvailableTeacherDocs(String sectionID) async {
  final teachers = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.teacher)
      .get();

  final availableTeachers = teachers.docs.where((doc) {
    List assignedSections = doc[UserFields.assignedSections];
    return !assignedSections.contains(sectionID);
  }).toList();

  return availableTeachers;
}

Future addProfilePic(BuildContext context, WidgetRef ref,
    {required Uint8List selectedImage}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);

    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.profilePics)
        .child('${FirebaseAuth.instance.currentUser!.uid}.png');

    final uploadTask = storageRef.putData(selectedImage);
    final taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    // Update the user's data in Firestore with the image URL
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({UserFields.profileImageURL: downloadURL});
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully added new profile picture')));
    ref.read(profileImageURLProvider.notifier).setImageURL(downloadURL);
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error uploading new profile picture: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future<void> removeProfilePic(BuildContext context, WidgetRef ref) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({UserFields.profileImageURL: ''});

    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.profilePics)
        .child('${FirebaseAuth.instance.currentUser!.uid}.png');

    await storageRef.delete();
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully removed profile picture.')));
    ref.read(profileImageURLProvider).removeImageURL();
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error removing current profile pic: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future editClientProfile(BuildContext context, WidgetRef ref,
    {required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController emailController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final goRouter = GoRouter.of(context);
  if (firstNameController.text.isEmpty ||
      lastNameController.text.isEmpty ||
      emailController.text.isEmpty) {
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please fill up all given fields.')));
    return;
  }
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      UserFields.firstName: firstNameController.text.trim(),
      UserFields.lastName: lastNameController.text.trim(),
    });

    final userDoc = await getCurrentUserDoc();
    final userData = userDoc.data() as Map<dynamic, dynamic>;
    if (emailController.text != userData[UserFields.email]) {
      await FirebaseAuth.instance.currentUser!
          .verifyBeforeUpdateEmail(emailController.text.trim());

      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(
              'A verification email has been sent to the new email address')));
    }
    ref.read(loadingProvider.notifier).toggleLoading(false);
    goRouter.goNamed(GoRoutes.profile);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error editing client profile : $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future editThisProfile(BuildContext context, WidgetRef ref,
    {required String userID,
    required String userType,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final goRouter = GoRouter.of(context);
  if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please fill up all given fields.')));
    return;
  }
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(userID)
        .update({
      UserFields.firstName: firstNameController.text.trim(),
      UserFields.lastName: lastNameController.text.trim(),
    });
    ref.read(loadingProvider.notifier).toggleLoading(false);
    goRouter.goNamed(
        userType == UserTypes.teacher ? GoRoutes.teachers : GoRoutes.students);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error editing client profile : $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future addNewUser(BuildContext context, WidgetRef ref,
    {required String userType,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController idNumberController,
    required String sectionID,
    required String gradeLevel}) async {
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

    if (sectionID.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please select a section')));
      return;
    }

    //  Store admin's current data locally then sign out
    final currentUser = await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final currentUserData = currentUser.data() as Map<dynamic, dynamic>;
    String userEmail = currentUserData[UserFields.email];
    String userPassword = currentUserData[UserFields.password];
    await FirebaseAuth.instance.signOut();

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
      UserFields.assignedSections: [sectionID],
      if (userType == UserTypes.student) UserFields.gradeLevel: gradeLevel,
      if (userType == UserTypes.student)
        UserFields.moduleProgresses: {
          'quarter1': {},
          'quarter2': {},
          'quarter3': {},
          'quarter4': {}
        },
      if (userType == UserTypes.student) UserFields.speechIndex: 1
    });

    //  Log-back in to admin account
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: userEmail, password: userPassword);

    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully registered new user')));
    ref.read(loadingProvider).toggleLoading(false);
    if (userType == UserTypes.student) {
      goRouter.goNamed(GoRoutes.students);
    } else if (userType == UserTypes.teacher) {
      goRouter.goNamed(GoRoutes.teachers);
    }
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error registering new user: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future changeUserPassword(BuildContext context, WidgetRef ref,
    {required String userType,
    required String userID,
    required TextEditingController passwordController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  if (passwordController.text.length < 6) {
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('The password must be at least six characters long')));
    return;
  }
  try {
    GoRouter.of(context).pop();
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

    final selectedUser = await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(userID)
        .get();
    final selectedUserData = selectedUser.data() as Map<dynamic, dynamic>;

    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: selectedUserData[UserFields.email],
        password: selectedUserData[UserFields.password]);

    await FirebaseAuth.instance.currentUser!
        .updatePassword(passwordController.text);

    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({UserFields.password: passwordController.text});

    //  Log-back in to admin account
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: userEmail, password: userPassword);

    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully changed this user\'s password.')));
    ref.read(usersProvider).setUserDocs(userType == UserTypes.teacher
        ? await getAllTeacherDocs()
        : await getAllStudentDocs());
    ref.read(loadingProvider).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error changing user password: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future<List<DocumentSnapshot>> getSectionTeacherDoc(String sectionID) async {
  final teachers = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.teacher)
      .where(UserFields.assignedSections, arrayContains: sectionID)
      .get();
  return teachers.docs.map((teacher) => teacher as DocumentSnapshot).toList();
}

//==============================================================================
//SECTIONS======================================================================
//==============================================================================

Future<List<DocumentSnapshot>> getAllSectionDocs() async {
  final sections =
      await FirebaseFirestore.instance.collection(Collections.sections).get();
  return sections.docs.map((user) => user as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getTheseSectionDocs(
    List<dynamic> sectionIDs) async {
  final sections = await FirebaseFirestore.instance
      .collection(Collections.sections)
      .where(FieldPath.documentId, whereIn: sectionIDs)
      .get();
  return sections.docs.map((user) => user as DocumentSnapshot).toList();
}

Future<DocumentSnapshot> getThisSectionDoc(String sectionID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.sections)
      .doc(sectionID)
      .get();
}

Future<List<DocumentSnapshot>> getSectionsWithoutTeacher() async {
  final sections = await FirebaseFirestore.instance
      .collection(Collections.sections)
      .where(SectionFields.teacherID, isEqualTo: '')
      .get();
  return sections.docs.map((e) => e as DocumentSnapshot).toList();
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
        await getSectionTeachersDoc(sectionID);
    if (sectionTeacher.isNotEmpty) {
      final oldTeacherID = sectionTeacher.first.id;
      await FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(oldTeacherID)
          .update({
        UserFields.assignedSections: FieldValue.arrayRemove([sectionID])
      });
    }
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(userID)
        .update({
      UserFields.assignedSections: FieldValue.arrayUnion([sectionID])
    });
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully assigned user to this section')));

    //  TEACHERS
    final teachers = await getSectionTeachersDoc(sectionID);
    if (teachers.isNotEmpty) {
      ref
          .read(sectionsProvider)
          .setAssignedTeacherNames(teachers.map((teacher) {
            final teacherData = teacher.data() as Map<dynamic, dynamic>;
            String formattedName =
                '${teacherData[UserFields.firstName]} ${teacherData[UserFields.lastName]}';
            return formattedName;
          }).toList());
    }
    /*ref
        .read(sectionsProvider)
        .setAvailableTeacherDocs(await getAvailableTeacherDocs());*/

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

//==============================================================================
//MODULES=======================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getAllModuleDocs() async {
  final modules =
      await FirebaseFirestore.instance.collection(Collections.modules).get();
  return modules.docs.map((user) => user as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAllUserModuleDocs() async {
  final modules = await FirebaseFirestore.instance
      .collection(Collections.modules)
      .where(ModuleFields.teacherID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();
  return modules.docs.map((user) => user as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAllAssignedQuarterModuleDocs(
    String teacherID, int quarter) async {
  final modules = await FirebaseFirestore.instance
      .collection(Collections.modules)
      .where(ModuleFields.teacherID, isEqualTo: teacherID)
      .where(ModuleFields.quarter, isEqualTo: quarter)
      .get();
  return modules.docs.map((e) => e as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getTeacherModuleDocs(String teacherID) async {
  final modules = await FirebaseFirestore.instance
      .collection(Collections.modules)
      .where(ModuleFields.teacherID, isEqualTo: teacherID)
      .get();
  return modules.docs.map((user) => user as DocumentSnapshot).toList();
}

Future<DocumentSnapshot> getThisModuleDoc(String moduleID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.modules)
      .doc(moduleID)
      .get();
}

void addNewModule(BuildContext context, WidgetRef ref,
    {required TextEditingController titleController,
    required TextEditingController contentController,
    required List<Uint8List?> documentFiles,
    required List<String> documentNames,
    required List<TextEditingController> fileNameControllers,
    required List<TextEditingController> downloadLinkControllers,
    required int selectedQuarter,
    required String gradeLevel}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final goRouter = GoRouter.of(context);

  if (titleController.text.isEmpty || contentController.text.isEmpty) {
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Please provide a title and content for this lesson.')));
    return;
  }
  for (int i = 0; i < downloadLinkControllers.length; i++) {
    if (fileNameControllers[i].text.isEmpty ||
        downloadLinkControllers[i].text.isEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text(
              'Please fill up all additional resource fields or delete unused ones.')));
      return;
    } else if (!Uri.tryParse(downloadLinkControllers[i].text.trim())!
        .hasAbsolutePath) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('The URL provided in resource #${i + 1} is invalid')));
      return;
    }
  }
  try {
    ref.read(loadingProvider).toggleLoading(true);

    //  1. Create Module Document and indicate it's associated sections
    final moduleReference =
        await FirebaseFirestore.instance.collection(Collections.modules).add({
      ModuleFields.teacherID: FirebaseAuth.instance.currentUser!.uid,
      ModuleFields.title: titleController.text,
      ModuleFields.content: contentController.text,
      ModuleFields.dateCreated: DateTime.now(),
      ModuleFields.dateLastModified: DateTime.now(),
      ModuleFields.quarter: selectedQuarter,
      ModuleFields.gradeLevel: gradeLevel
    });

    List<Map<dynamic, dynamic>> additionalResources = [];
    for (int i = 0; i < downloadLinkControllers.length; i++) {
      additionalResources.add({
        AdditionalResourcesFields.fileName: fileNameControllers[i].text.trim(),
        AdditionalResourcesFields.downloadLink:
            downloadLinkControllers[i].text.trim()
      });
    }

    //  Handle Portfolio Entries
    List<Map<String, String>> documentEntries = [];
    for (int i = 0; i < documentFiles.length; i++) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(StorageFields.moduleDocuments)
          .child(moduleReference.id)
          .child(documentNames[i]);
      final uploadTask = storageRef.putData(documentFiles[i]!);
      final taskSnapshot = await uploadTask;
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();
      documentEntries.add({
        AdditionalResourcesFields.fileName: documentNames[i],
        AdditionalResourcesFields.downloadLink: downloadURL
      });
    }

    await FirebaseFirestore.instance
        .collection(Collections.modules)
        .doc(moduleReference.id)
        .update({
      ModuleFields.additionalResources: additionalResources,
      ModuleFields.additionalDocuments: documentEntries,
    });

    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully added new lesson.')));
    ref.read(loadingProvider).toggleLoading(false);

    goRouter.goNamed(GoRoutes.modules);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error adding new lesson: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

void editThisModule(BuildContext context, WidgetRef ref,
    {required String moduleID,
    required TextEditingController titleController,
    required TextEditingController contentController,
    required List<dynamic> documentFiles,
    required List<String> documentNames,
    required List<TextEditingController> fileNameControllers,
    required List<TextEditingController> downloadLinkControllers,
    required int selectedQuarter}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final goRouter = GoRouter.of(context);

  if (titleController.text.isEmpty || contentController.text.isEmpty) {
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Please provide a title and content for this lesson.')));
    return;
  }
  for (int i = 0; i < downloadLinkControllers.length; i++) {
    if (fileNameControllers[i].text.isEmpty ||
        downloadLinkControllers[i].text.isEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text(
              'Please fill up all additional resource fields or delete unused ones.')));
      return;
    } else if (!Uri.tryParse(downloadLinkControllers[i].text.trim())!
        .hasAbsolutePath) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('The URL provided in resource #${i + 1} is invalid')));
      return;
    }
  }
  try {
    ref.read(loadingProvider).toggleLoading(true);

    //  1. Create Module Document and indicate it's associated sections
    FirebaseFirestore.instance
        .collection(Collections.modules)
        .doc(moduleID)
        .update({
      ModuleFields.title: titleController.text,
      ModuleFields.content: contentController.text,
      ModuleFields.dateLastModified: DateTime.now(),
      ModuleFields.quarter: selectedQuarter
    });

    List<Map<dynamic, dynamic>> additionalResources = [];
    for (int i = 0; i < downloadLinkControllers.length; i++) {
      additionalResources.add({
        AdditionalResourcesFields.fileName: fileNameControllers[i].text.trim(),
        AdditionalResourcesFields.downloadLink:
            downloadLinkControllers[i].text.trim()
      });
    }

    //  Handle Document Entries
    List<Map<String, String>> documentEntries = [];
    for (int i = 0; i < documentFiles.length; i++) {
      //  The current file is unchanged
      if (documentFiles[i] is String) {
        continue;
      }
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(StorageFields.moduleDocuments)
          .child(moduleID)
          .child(documentNames[i]);
      final uploadTask = storageRef.putData(documentFiles[i] as Uint8List);
      final taskSnapshot = await uploadTask;
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();
      documentEntries.add({
        AdditionalResourcesFields.fileName: documentNames[i],
        AdditionalResourcesFields.downloadLink: downloadURL
      });
    }

    await FirebaseFirestore.instance
        .collection(Collections.modules)
        .doc(moduleID)
        .update({
      ModuleFields.additionalResources: additionalResources,
      ModuleFields.additionalDocuments: FieldValue.arrayUnion(documentEntries),
    });

    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully edited this module.')));
    ref.read(loadingProvider).toggleLoading(false);

    goRouter.goNamed(GoRoutes.modules);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error editing this module: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

//==============================================================================
//QUIZZES=======================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getAllQuizDocs() async {
  final quizzes =
      await FirebaseFirestore.instance.collection(Collections.quizzes).get();
  return quizzes.docs.map((user) => user as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAllUserQuizDocs() async {
  final quizzes = await FirebaseFirestore.instance
      .collection(Collections.quizzes)
      .where(QuizFields.teacherID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();
  return quizzes.docs.map((user) => user as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAllTeacherQuizDocs(String teacherID) async {
  final quizzes = await FirebaseFirestore.instance
      .collection(Collections.quizzes)
      .where(QuizFields.teacherID, isEqualTo: teacherID)
      .get();
  return quizzes.docs.map((user) => user as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAllAssignedQuizDocs(String teacherID) async {
  final sectionQuizzes = await FirebaseFirestore.instance
      .collection(Collections.quizzes)
      .where(QuizFields.teacherID, isEqualTo: teacherID)
      .get();
  final globalQuizzes = await FirebaseFirestore.instance
      .collection(Collections.quizzes)
      .where(QuizFields.isGlobal, isEqualTo: true)
      .get();
  return [...sectionQuizzes.docs, ...globalQuizzes.docs]
      .map((e) => e as DocumentSnapshot)
      .toList();
}

Future<DocumentSnapshot> getThisQuizDoc(String quizID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.quizzes)
      .doc(quizID)
      .get();
}

Future addNewQuiz(BuildContext context, WidgetRef ref,
    {required TextEditingController titleController,
    required List<dynamic> quizQuestions,
    required String gradeLevel}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final goRouter = GoRouter.of(context);
  try {
    ref.read(loadingProvider).toggleLoading(true);
    final customQuizzes =
        await FirebaseFirestore.instance.collection(Collections.quizzes).get();
    final existingQuiz = customQuizzes.docs.where((quiz) {
      final quizData = quiz.data();
      String title = quizData[QuizFields.title];
      return title == titleController.text.trim();
    }).toList();
    if (existingQuiz.isNotEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('A quiz with this title already exists')));
      ref.read(loadingProvider).toggleLoading(false);

      return;
    }
    String encodedQuiz = jsonEncode(quizQuestions);

    await FirebaseFirestore.instance.collection(Collections.quizzes).add({
      QuizFields.teacherID: FirebaseAuth.instance.currentUser!.uid,
      QuizFields.quizType: QuizTypes.multipleChoice,
      QuizFields.title: titleController.text.trim(),
      QuizFields.questions: encodedQuiz,
      QuizFields.dateCreated: DateTime.now(),
      QuizFields.dateLastModified: DateTime.now(),
      QuizFields.isGlobal:
          ref.read(userTypeProvider).userType == UserTypes.admin,
      QuizFields.isActive: true,
      QuizFields.gradeLevel: gradeLevel
    });

    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully added new quiz')));
    ref.read(loadingProvider).toggleLoading(false);
    goRouter.goNamed(GoRoutes.quizzes);
  } catch (error) {
    scaffoldMessenger
        .showSnackBar(SnackBar(content: Text('Error adding new quiz: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

void editThisQuiz(BuildContext context, WidgetRef ref,
    {required String quizID,
    required TextEditingController titleController,
    required List<dynamic> quizQuestions}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final goRouter = GoRouter.of(context);
  try {
    ref.read(loadingProvider).toggleLoading(true);

    final customLessons =
        await FirebaseFirestore.instance.collection(Collections.quizzes).get();
    final existingQuiz = customLessons.docs.where((lesson) {
      final quizData = lesson.data();
      String title = quizData[QuizFields.title];
      return title == titleController.text.trim();
    }).toList();
    if (existingQuiz.isNotEmpty && existingQuiz.first.id != quizID) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('A quiz with this title already exists')));
      ref.read(loadingProvider).toggleLoading(false);

      return;
    }
    String encodedQuiz = jsonEncode(quizQuestions);

    await FirebaseFirestore.instance
        .collection(Collections.quizzes)
        .doc(quizID)
        .update({
      QuizFields.title: titleController.text.trim(),
      QuizFields.questions: encodedQuiz,
      QuizFields.dateLastModified: DateTime.now()
    });

    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully edited this quiz')));
    goRouter.goNamed(GoRoutes.quizzes);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error editing this quiz: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future<DocumentSnapshot?> getQuizResult(String quizID) async {
  final QuerySnapshot result = await FirebaseFirestore.instance
      .collection(Collections.quizResults)
      .where(QuizResultFields.quizID, isEqualTo: quizID)
      .where(QuizResultFields.studentID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .limit(1)
      .get();

  if (result.docs.isNotEmpty) {
    return result.docs.first;
  } else {
    return null;
  }
}

void submitQuizAnswers(BuildContext context, WidgetRef ref,
    {required String quizID,
    required List<dynamic> selectedAnswers,
    required int correctAnswers}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final goRouter = GoRouter.of(context);
  //final navigator = Navigator.of(context);
  try {
    ref.read(loadingProvider).toggleLoading(true);

    final quizResultReference = await FirebaseFirestore.instance
        .collection(Collections.quizResults)
        .add({
      QuizResultFields.studentID: FirebaseAuth.instance.currentUser!.uid,
      QuizResultFields.quizID: quizID,
      QuizResultFields.answers: selectedAnswers,
      QuizResultFields.grade: correctAnswers,
    });

    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully submitted this quiz.')));
    ref.read(loadingProvider).toggleLoading(false);

    goRouter.goNamed(GoRoutes.selectedQuizResult,
        pathParameters: {PathParameters.quizResultID: quizResultReference.id});
    // navigator.pop();
    // navigator.pushReplacementNamed(NavigatorRoutes.studentSubmittables);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error submitting quiz answers: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

//==============================================================================
//QUIZ RESULTS==================================================================
//==============================================================================

Future<List<DocumentSnapshot>> getStudentQuizResults(String studentID) async {
  final quizResults = await FirebaseFirestore.instance
      .collection(Collections.quizResults)
      .where(QuizResultFields.studentID, isEqualTo: studentID)
      .get();
  return quizResults.docs.map((e) => e as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getUserQuizResults() async {
  final quizResults = await FirebaseFirestore.instance
      .collection(Collections.quizResults)
      .where(QuizResultFields.studentID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();
  return quizResults.docs.map((e) => e as DocumentSnapshot).toList();
}

Future<double?> getStudentGradeAverage(String studentID) async {
  final quizResults = await getStudentQuizResults(studentID);
  if (quizResults.isEmpty) {
    return null;
  }
  double sum = 0;
  for (var quizResult in quizResults) {
    final quizResultData = quizResult.data() as Map<dynamic, dynamic>;
    sum += quizResultData[QuizResultFields.grade];
  }
  return sum / quizResults.length;
}

//==============================================================================
//SPEECH RESULTS================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getStudentSpeechResults(String studentID) async {
  final speechResults = await FirebaseFirestore.instance
      .collection(Collections.speechResults)
      .where(SpeechResultFields.studentID, isEqualTo: studentID)
      .get();

  return speechResults.docs;
}

Future<DocumentSnapshot> getThisSpeechResult(String speechResultID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.speechResults)
      .doc(speechResultID)
      .get();
}
