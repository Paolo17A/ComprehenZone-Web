import 'dart:typed_data';

import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/utils/go_router_util.dart';
import 'package:comprehenzone_web/widgets/custom_button_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_text_field_widget.dart';
import 'package:comprehenzone_web/widgets/custom_text_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../providers/user_type_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/dropdown_widget.dart';

class AddModuleScreen extends ConsumerStatefulWidget {
  const AddModuleScreen({super.key});

  @override
  ConsumerState<AddModuleScreen> createState() => _AddModuleScreenState();
}

class _AddModuleScreenState extends ConsumerState<AddModuleScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final List<Uint8List?> documentFiles = [];
  final List<String> documentNames = [];
  final List<TextEditingController> fileNameControllers = [];
  final List<TextEditingController> downloadLinkControllers = [];
  int selectedQuarter = 1;

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        documentFiles.add(result.files.first.bytes);
        documentNames.add(result.files.first.name);
      });
    }
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
        ref.read(userTypeProvider).setUserType(await getCurrentUserType());
        if (ref.read(userTypeProvider).userType == UserTypes.admin) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting current user type: $error')));
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
              teacherLeftNavigator(context, path: GoRoutes.modules),
              bodyBlueBackgroundContainer(context,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _backButton(),
                        horizontal5Percent(context,
                            child: Column(children: [
                              newLessonHeader(),
                              Gap(4),
                              borderedOlympicBlueContainer(
                                child: Column(
                                  children: [
                                    _lessonTitle(),
                                    _lessonContent(),
                                    _additionalDocuments(),
                                    _additionalResources(),
                                    _quarterDropdown()
                                  ],
                                ),
                              ),
                              all20Pix(
                                  child: blueBorderElevatedButton(
                                      label: 'ADD MODULE',
                                      onPress: () => addNewModule(context, ref,
                                          titleController: titleController,
                                          contentController: contentController,
                                          documentFiles: documentFiles,
                                          documentNames: documentNames,
                                          fileNameControllers:
                                              fileNameControllers,
                                          downloadLinkControllers:
                                              downloadLinkControllers,
                                          selectedQuarter: selectedQuarter,
                                          gradeLevel: '5')))
                            ])),
                      ],
                    ),
                  ))
            ],
          )),
    );
  }

  Widget _backButton() {
    return Row(children: [
      all20Pix(
          child: backButton(context,
              onPress: () => GoRouter.of(context).goNamed(GoRoutes.modules)))
    ]);
  }

  Widget newLessonHeader() {
    return borderedOlympicBlueContainer(
        child: blackInterBold('NEW MODULE', fontSize: 28));
  }

  Widget _lessonTitle() {
    return vertical10Pix(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Module Title', fontSize: 18),
          CustomTextField(
              text: 'Module Title',
              controller: titleController,
              textInputType: TextInputType.text,
              displayPrefixIcon: null,
              textColor: Colors.black),
        ],
      ),
    );
  }

  Widget _lessonContent() {
    return vertical10Pix(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Module Content', fontSize: 18),
          CustomTextField(
              text: 'Module Content',
              controller: contentController,
              textInputType: TextInputType.multiline,
              displayPrefixIcon: null,
              textColor: Colors.black),
        ],
      ),
    );
  }

  Widget _additionalDocuments() {
    return vertical20Pix(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              interText('Additional Documents', fontWeight: FontWeight.bold),
              ElevatedButton(
                onPressed: _pickDocument,
                style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                child: interText('+',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20),
              )
            ],
          ),
          if (documentFiles.isNotEmpty)
            vertical10Pix(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: documentFiles.length,
                    itemBuilder: (context, index) {
                      return vertical10Pix(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  blackInterBold('Resource # ${index + 1}'),
                                  interText(documentNames[index]),
                                ]),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  documentFiles.removeAt(index);
                                  documentNames.removeAt(index);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder()),
                              child: const Icon(Icons.delete_rounded,
                                  color: Colors.black),
                            )
                          ],
                        ),
                      );
                    }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _additionalResources() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              interText('Additional Resources', fontWeight: FontWeight.bold),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    fileNameControllers.add(TextEditingController());
                    downloadLinkControllers.add(TextEditingController());
                  });
                },
                style: ElevatedButton.styleFrom(shape: const CircleBorder()),
                child: interText('+',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20),
              )
            ],
          ),
          if (downloadLinkControllers.isNotEmpty)
            vertical10Pix(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: downloadLinkControllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Resource # ${index + 1}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w300)),
                                    CustomTextField(
                                        text: 'Name',
                                        controller: fileNameControllers[index],
                                        textInputType: TextInputType.text,
                                        displayPrefixIcon: null,
                                        textColor: Colors.black),
                                    const SizedBox(height: 10),
                                    CustomTextField(
                                        text: 'URL',
                                        controller:
                                            downloadLinkControllers[index],
                                        textInputType: TextInputType.url,
                                        displayPrefixIcon: null),
                                  ]),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  fileNameControllers.removeAt(index);
                                  downloadLinkControllers.removeAt(index);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder()),
                              child: const Icon(Icons.delete_rounded,
                                  color: Colors.black),
                            )
                          ],
                        ),
                      );
                    }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _quarterDropdown() {
    return vertical10Pix(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        interText('Quarter', fontSize: 18),
        Container(
          decoration: BoxDecoration(
              border: Border.all(), borderRadius: BorderRadius.circular(10)),
          child: dropdownWidget('QUARTER', (number) {
            setState(() {
              selectedQuarter = int.parse(number!);
            });
          }, ['1', '2', '3', '4'], selectedQuarter.toString(), false),
        ),
      ],
    ));
  }
}
