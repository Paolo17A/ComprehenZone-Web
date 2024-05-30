import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/providers/sections_provider.dart';
import 'package:comprehenzone_web/utils/color_util.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        if (userType == UserTypes.teacher) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        ref.read(sectionsProvider).setSectionDocs(await getAllSectionDocs());
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
    return Scaffold(
      body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              adminLeftNavigator(context, path: GoRoutes.sections),
              bodyGradientContainer(context,
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
        blackInterBold('SECTIONS', fontSize: 40),
        ElevatedButton(
            onPressed: showAddSectionDialog,
            child: blackInterBold('NEW SECTION'))
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
                pathParameters: {PathParamters.sectionID: sectionDoc.id})),
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
                    vertical20Pix(
                        child: ElevatedButton(
                            onPressed: () => addNewSection(context, ref,
                                nameController: nameController),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.paleCyan),
                            child: blackInterBold('CREATE SECTION')))
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
                    blackInterBold('NEW SECTION', fontSize: 40),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: regularTextField(
                            label: 'Section Name',
                            textController: nameController)),
                    vertical20Pix(
                        child: ElevatedButton(
                            onPressed: () => editThisSection(context, ref,
                                sectionID: sectionDoc.id,
                                nameController: nameController),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: CustomColors.paleCyan),
                            child: blackInterBold('EDIT SECTION')))
                  ],
                ),
              ),
            ));
  }
}
