import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/providers/sections_provider.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/user_type_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/left_navigator_widget.dart';

class ViewSectionsScreen extends ConsumerStatefulWidget {
  const ViewSectionsScreen({super.key});

  @override
  ConsumerState<ViewSectionsScreen> createState() => _ViewSectionsScreenState();
}

class _ViewSectionsScreenState extends ConsumerState<ViewSectionsScreen> {
  final nameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

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
        String userType = await getCurrentUserType();
        if (userType == UserTypes.student) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        ref.read(userTypeProvider).setUserType(userType);
        if (ref.read(userTypeProvider).userType == UserTypes.admin) {
          //  Get Global Data

          ref.read(sectionsProvider).setSectionDocs(await getAllSectionDocs());
        } else {
          //  Get Section-wide Data
          final user = await getCurrentUserDoc();
          final userData = user.data() as Map<dynamic, dynamic>;
          List<dynamic> assignedSections =
              userData[UserFields.assignedSections];
          if (assignedSections.isNotEmpty) {
            await getTheseSectionDocs(userData[UserFields.assignedSections]);
            ref.read(sectionsProvider).setSectionDocs(await getTheseSectionDocs(
                userData[UserFields.assignedSections]));
          }
        }
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting all teachers: $error')));
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
                      child: horizontal5Percent(context,
                          child: _sectionsContent())))
            ],
          )),
    );
  }

  Widget _sectionsContent() {
    return Column(
      children: [
        _sectionsHeader(),
        viewContentContainer(context,
            child: Column(
              children: [
                _sectionLabelRow(),
                ref.read(sectionsProvider).sectionDocs.isNotEmpty
                    ? _sectionEntries()
                    : viewContentUnavailable(context,
                        text: 'NO AVAILABLE SECTIONS'),
              ],
            )),
      ],
    );
  }

  Widget _sectionsHeader() {
    return vertical20Pix(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        borderedOlympicBlueContainer(
            child: blackInterBold('SECTIONS', fontSize: 28)),
        if (ref.read(userTypeProvider).userType == UserTypes.admin)
          ElevatedButton(
              onPressed: showAddSectionDialog,
              child: blackInterBold('ADD NEW SECTION'))
      ]),
    );
  }

  Widget _sectionLabelRow() {
    return viewContentLabelRow(context, children: [
      viewFlexLabelTextCell('Section', 4),
      viewFlexLabelTextCell('Actions', 2)
    ]);
  }

  Widget _sectionEntries() {
    return SizedBox(
      height: 550,
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ref.read(sectionsProvider).sectionDocs.length,
          itemBuilder: (context, index) {
            return _sectionEntry(ref.read(sectionsProvider).sectionDocs[index]);
          }),
    );
  }

  Widget _sectionEntry(DocumentSnapshot sectionDoc) {
    final sectionData = sectionDoc.data() as Map<dynamic, dynamic>;
    String name = sectionData[SectionFields.name];

    return viewContentEntryRow(context, children: [
      viewFlexTextCell(name, flex: 4),
      viewFlexActionsCell([
        viewEntryButton(context,
            onPress: () => GoRouter.of(context).goNamed(
                GoRoutes.selectedSection,
                pathParameters: {PathParameters.sectionID: sectionDoc.id})),
        if (ref.read(userTypeProvider).userType == UserTypes.admin)
          editEntryButton(context,
              onPress: () => showEditSectionDialog(sectionDoc)),
      ], flex: 2)
    ]);
  }

  void showAddSectionDialog() {
    nameController.clear();
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
                            ])),
                    blackInterBold('NEW SECTION', fontSize: 40),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: regularTextField(
                            label: 'Section Name',
                            textController: nameController)),
                    vertical10Pix(
                      child: blueBorderElevatedButton(
                          label: 'CREATE SECTION',
                          onPress: () => addNewSection(context, ref,
                              nameController: nameController)),
                    )
                  ],
                ),
              ),
            ));
  }

  void showEditSectionDialog(DocumentSnapshot sectionDoc) {
    final sectionData = sectionDoc.data() as Map<dynamic, dynamic>;
    nameController.text = sectionData[SectionFields.name];
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
                            ])),
                    blackInterBold('NEW SECTION', fontSize: 28),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: regularTextField(
                            label: 'Section Name',
                            textController: nameController)),
                    vertical20Pix(
                        child: blueBorderElevatedButton(
                            label: 'EDIT SECTION',
                            onPress: () => editThisSection(context, ref,
                                sectionID: sectionDoc.id,
                                nameController: nameController)))
                  ],
                ),
              ),
            ));
  }
}
