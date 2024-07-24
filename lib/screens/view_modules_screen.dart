import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/providers/modules_provider.dart';
import 'package:comprehenzone_web/providers/user_type_provider.dart';
import 'package:comprehenzone_web/utils/color_util.dart';
import 'package:comprehenzone_web/utils/firebase_util.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/go_router_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class ViewModulesScreen extends ConsumerStatefulWidget {
  const ViewModulesScreen({super.key});

  @override
  ConsumerState<ViewModulesScreen> createState() => _ViewModulesScreenState();
}

class _ViewModulesScreenState extends ConsumerState<ViewModulesScreen> {
  List<DocumentSnapshot> firstQuarterModuleDocs = [];
  List<DocumentSnapshot> secondQuarterModuleDocs = [];
  List<DocumentSnapshot> thirdQuarterModuleDocs = [];
  List<DocumentSnapshot> fourthQuarterModuleDocs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final goRouter = GoRouter.of(context);

      try {
        ref.read(loadingProvider).toggleLoading(true);
        if (!hasLoggedInUser()) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        ref.read(userTypeProvider).setUserType(await getCurrentUserType());
        if (ref.read(userTypeProvider).userType == UserTypes.admin) {
          ref.read(modulesProvider).setModuleDocs(await getAllModuleDocs());
          for (var moduleDoc in ref.read(modulesProvider).moduleDocs) {
            final moduleData = moduleDoc.data() as Map<dynamic, dynamic>;
            if (!moduleData.containsKey(ModuleFields.gradeLevel)) {
              await FirebaseFirestore.instance
                  .collection(Collections.modules)
                  .doc(moduleDoc.id)
                  .update({ModuleFields.gradeLevel: '5'});
            }
          }
        } else if (ref.read(userTypeProvider).userType == UserTypes.teacher) {
          ref.read(modulesProvider).setModuleDocs(await getAllUserModuleDocs());
        } else {
          final user = await getCurrentUserDoc();
          final userData = user.data() as Map<dynamic, dynamic>;
          List<dynamic> assignedSections =
              userData[UserFields.assignedSections];
          List<DocumentSnapshot> teacherDocs =
              await getSectionTeacherDoc(assignedSections.first);
          String teacherID = teacherDocs.first.id;
          firstQuarterModuleDocs =
              await getAllAssignedQuarterModuleDocs(teacherID, 1);
          secondQuarterModuleDocs =
              await getAllAssignedQuarterModuleDocs(teacherID, 2);
          thirdQuarterModuleDocs =
              await getAllAssignedQuarterModuleDocs(teacherID, 3);
          fourthQuarterModuleDocs =
              await getAllAssignedQuarterModuleDocs(teacherID, 4);
        }
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting module docs: $error')));
        ref.read(loadingProvider).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(userTypeProvider);
    return Scaffold(
      body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ref.read(userTypeProvider).userType == UserTypes.admin
                  ? adminLeftNavigator(context, path: GoRoutes.modules)
                  : ref.read(userTypeProvider).userType == UserTypes.teacher
                      ? teacherLeftNavigator(context, path: GoRoutes.modules)
                      : studentLeftNavigator(context, path: GoRoutes.modules),
              bodyGradientContainer(context,
                  child: SingleChildScrollView(
                    child: horizontal5Percent(context,
                        child: ref.read(userTypeProvider).userType ==
                                UserTypes.student
                            ? _studentModules()
                            : _modulesContent()),
                  ))
            ],
          )),
    );
  }

  //============================================================================
  //=STUDENTS===================================================================
  //============================================================================

  Widget _studentModules() {
    return vertical20Pix(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _firstQuarterModules(),
        _secondQuarterModules(),
        _thirdQuarterModules(),
        _fourthQuarterModules(),
      ]),
    );
  }

  Widget _firstQuarterModules() {
    return vertical20Pix(
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(width: 2), color: CustomColors.paleCyan),
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            blackInterBold('1ST QUARTER MODULES', fontSize: 20),
            firstQuarterModuleDocs.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: firstQuarterModuleDocs
                        .map((moduleDoc) => moduleEntry(moduleDoc))
                        .toList())
                : blackInterRegular('No assigned modules for this quarter.')
          ])),
    );
  }

  Widget _secondQuarterModules() {
    return vertical20Pix(
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(width: 2), color: CustomColors.paleCyan),
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            blackInterBold('2ND QUARTER MODULES', fontSize: 20),
            secondQuarterModuleDocs.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: secondQuarterModuleDocs
                        .map((moduleDoc) => moduleEntry(moduleDoc))
                        .toList())
                : blackInterRegular('No assigned modules for this quarter.')
          ])),
    );
  }

  Widget _thirdQuarterModules() {
    return vertical20Pix(
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(width: 2), color: CustomColors.paleCyan),
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            blackInterBold('3RD QUARTER MODULES', fontSize: 20),
            secondQuarterModuleDocs.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: thirdQuarterModuleDocs
                        .map((moduleDoc) => moduleEntry(moduleDoc))
                        .toList())
                : blackInterRegular('No assigned modules for this quarter.')
          ])),
    );
  }

  Widget _fourthQuarterModules() {
    return vertical20Pix(
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(width: 2), color: CustomColors.paleCyan),
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            blackInterBold('4TH QUARTER MODULES', fontSize: 20),
            fourthQuarterModuleDocs.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: fourthQuarterModuleDocs
                        .map((moduleDoc) => moduleEntry(moduleDoc))
                        .toList())
                : blackInterRegular('No assigned modules for this quarter.')
          ])),
    );
  }

  Widget moduleEntry(DocumentSnapshot moduleDoc) {
    final moduleData = moduleDoc.data() as Map<dynamic, dynamic>;
    String title = moduleData[ModuleFields.title];
    return InkWell(
      onTap: () => GoRouter.of(context).goNamed(GoRoutes.selectedModule,
          pathParameters: {PathParameters.moduleID: moduleDoc.id}),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        decoration: BoxDecoration(
            color: CustomColors.pearlWhite, border: Border.all(width: 2)),
        padding: const EdgeInsets.all(10),
        child: blackInterBold(title),
      ),
    );
  }

  Widget _modulesContent() {
    return Column(
      children: [
        _modulesHeader(),
        viewContentContainer(context,
            child: Column(
              children: [
                _modulesLabelRow(),
                ref.read(modulesProvider).moduleDocs.isNotEmpty
                    ? _moduleEntries()
                    : viewContentUnavailable(context,
                        text: 'NO AVAILABLE MODULES'),
              ],
            )),
      ],
    );
  }

  Widget _modulesHeader() {
    return vertical20Pix(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        blackInterBold('MODULES', fontSize: 40),
        if (ref.read(userTypeProvider).userType == UserTypes.teacher)
          ElevatedButton(
              onPressed: () => GoRouter.of(context).goNamed(GoRoutes.addModule),
              child: blackInterBold('NEW MODULE'))
      ]),
    );
  }

  Widget _modulesLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexLabelTextCell('Title', 1),
      viewFlexLabelTextCell('Content', 2),
      viewFlexLabelTextCell('Quarter', 1),
      if (ref.read(userTypeProvider).userType == UserTypes.admin)
        viewFlexLabelTextCell('Teacher', 1),
      if (ref.read(userTypeProvider).userType == UserTypes.teacher)
        viewFlexLabelTextCell('Actions', 2)
    ]);
  }

  Widget _moduleEntries() {
    return SizedBox(
      height: 550,
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ref.read(modulesProvider).moduleDocs.length,
          itemBuilder: (context, index) {
            return ref.read(userTypeProvider).userType == UserTypes.admin
                ? _globalModuleEntry(
                    ref.read(modulesProvider).moduleDocs[index])
                : _teacherModuleEntry(
                    ref.read(modulesProvider).moduleDocs[index]);
          }),
    );
  }

  Widget _globalModuleEntry(DocumentSnapshot moduleDoc) {
    final moduleData = moduleDoc.data() as Map<dynamic, dynamic>;
    String title = moduleData[ModuleFields.title];
    String content = moduleData[ModuleFields.content];
    String teacherID = moduleData[ModuleFields.teacherID];
    num quarter = moduleData[ModuleFields.quarter];
    return viewContentEntryRow(context, children: [
      viewFlexTextCell(title, flex: 1),
      viewFlexTextCell(content, flex: 2),
      viewFlexTextCell(quarter.toString(), flex: 1),
      viewFlexActionsCell([
        FutureBuilder(
          future: getThisUserDoc(teacherID),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData ||
                snapshot.hasError) return snapshotHandler(snapshot);
            final teacherData = snapshot.data!.data() as Map<dynamic, dynamic>;
            String formattedName =
                '${teacherData[UserFields.firstName]} ${teacherData[UserFields.lastName]}';
            return blackInterBold(formattedName);
          },
        )
      ], flex: 1),
      //viewFlexActionsCell([viewEntryButton(context, onPress: () {})], flex: 2)
    ]);
  }

  Widget _teacherModuleEntry(DocumentSnapshot moduleDoc) {
    final moduleData = moduleDoc.data() as Map<dynamic, dynamic>;
    String title = moduleData[ModuleFields.title];
    String content = moduleData[ModuleFields.content];
    num quarter = moduleData[ModuleFields.quarter];
    return viewContentEntryRow(context, children: [
      viewFlexTextCell(title, flex: 1),
      viewFlexTextCell(content, flex: 2),
      viewFlexTextCell(quarter.toString(), flex: 1),
      viewFlexActionsCell([
        editEntryButton(context,
            onPress: () => GoRouter.of(context).goNamed(GoRoutes.editModule,
                pathParameters: {PathParameters.moduleID: moduleDoc.id})),
        /*deleteEntryButton(context,
            onPress: () => displayDeleteEntryDialog(context,
                message: 'Are you sure you wish to delete this module? ',
                deleteEntry: () {}))*/
      ], flex: 2)
    ]);
  }
}
