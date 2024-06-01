import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/providers/modules_provider.dart';
import 'package:comprehenzone_web/providers/user_type_provider.dart';
import 'package:comprehenzone_web/utils/firebase_util.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/delete_entry_dialog_util.dart';
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
        } else {
          ref.read(modulesProvider).setModuleDocs(await getAllUserModuleDocs());
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
                  : teacherLeftNavigator(context, path: GoRoutes.modules),
              bodyGradientContainer(context,
                  child: SingleChildScrollView(
                    child:
                        horizontal5Percent(context, child: _modulesContent()),
                  ))
            ],
          )),
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
      if (ref.read(userTypeProvider).userType == UserTypes.admin)
        viewFlexLabelTextCell('Teacher', 1),
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
    return viewContentEntryRow(context, children: [
      viewFlexTextCell(title, flex: 1),
      viewFlexTextCell(content, flex: 2),
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
      viewFlexActionsCell([viewEntryButton(context, onPress: () {})], flex: 2)
    ]);
  }

  Widget _teacherModuleEntry(DocumentSnapshot moduleDoc) {
    final moduleData = moduleDoc.data() as Map<dynamic, dynamic>;
    String title = moduleData[ModuleFields.title];
    String content = moduleData[ModuleFields.content];
    return viewContentEntryRow(context, children: [
      viewFlexTextCell(title, flex: 1),
      viewFlexTextCell(content, flex: 2),
      viewFlexActionsCell([
        editEntryButton(context,
            onPress: () => GoRouter.of(context).goNamed(GoRoutes.editModule,
                pathParameters: {PathParameters.moduleID: moduleDoc.id})),
        deleteEntryButton(context,
            onPress: () => displayDeleteEntryDialog(context,
                message: 'Are you sure you wish to delete this quiz? ',
                deleteEntry: () {}))
      ], flex: 2)
    ]);
  }
}
