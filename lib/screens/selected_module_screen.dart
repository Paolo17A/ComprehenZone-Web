import 'package:comprehenzone_web/providers/loading_provider.dart';
import 'package:comprehenzone_web/widgets/custom_miscellaneous_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_padding_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/user_type_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../utils/string_util.dart';
import '../utils/url_util.dart';
import '../widgets/custom_text_widgets.dart';

class SelectedModuleScreen extends ConsumerStatefulWidget {
  final String moduleID;
  const SelectedModuleScreen({super.key, required this.moduleID});

  @override
  ConsumerState<SelectedModuleScreen> createState() =>
      _SelectedModuleScreenState();
}

class _SelectedModuleScreenState extends ConsumerState<SelectedModuleScreen> {
  String title = '';
  String content = '';
  List<dynamic> additionalDocuments = [];
  List<dynamic> additionalResources = [];

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
        ref.read(userTypeProvider).setUserType(await getCurrentUserType());
        if (ref.read(userTypeProvider).userType != UserTypes.student) {
          ref.read(loadingProvider).toggleLoading(false);
          goRouter.goNamed(GoRoutes.home);
          return;
        }
        final module = await getThisModuleDoc(widget.moduleID);
        final moduleData = module.data() as Map<dynamic, dynamic>;
        title = moduleData[ModuleFields.title];
        content = moduleData[ModuleFields.content];
        additionalDocuments = moduleData[ModuleFields.additionalDocuments];
        additionalResources = moduleData[ModuleFields.additionalResources];
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting module data: $error')));
        ref.read(loadingProvider).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              studentLeftNavigator(context, path: GoRoutes.modules),
              SingleChildScrollView(
                child: bodyGradientContainer(context,
                    child: horizontal5Percent(context,
                        child: Column(children: [
                          _backButton(),
                          _title(),
                          _content(),
                          if (additionalDocuments.isNotEmpty)
                            _additionalDocuments(),
                          if (additionalResources.isNotEmpty)
                            _additionalResources()
                        ]))),
              )
            ],
          )),
    );
  }

  Widget _backButton() {
    return Row(children: [
      all20Pix(
          child: ElevatedButton(
              onPressed: () => GoRouter.of(context).goNamed(GoRoutes.modules),
              style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.midnightBlue),
              child: whiteInterBold('BACK')))
    ]);
  }

  Widget _title() {
    return vertical20Pix(
      child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: blackInterBold(title, fontSize: 30)),
    );
  }

  Widget _content() {
    return Container(
        width: MediaQuery.of(context).size.width * 0.8,
        //height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(border: Border.all()),
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: blackInterRegular(content,
              fontSize: 18, textAlign: TextAlign.left),
        ));
  }

  Widget _additionalDocuments() {
    return vertical10Pix(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          interText('Supplementary Documents',
              fontWeight: FontWeight.bold, fontSize: 14),
          Column(
            children: additionalDocuments.map((document) {
              Map<dynamic, dynamic> externalDocument =
                  document as Map<dynamic, dynamic>;
              return vertical10Pix(
                child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () => launchThisURL(externalDocument[
                            AdditionalResourcesFields.downloadLink]),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.midnightBlue),
                        child: whiteInterBold(
                            externalDocument[
                                AdditionalResourcesFields.fileName],
                            fontSize: 15))),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _additionalResources() {
    return vertical10Pix(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          interText('Additional Resources',
              fontWeight: FontWeight.bold, fontSize: 14),
          Column(
            children: additionalResources.map((resource) {
              Map<dynamic, dynamic> externalResource =
                  resource as Map<dynamic, dynamic>;
              return vertical10Pix(
                child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () async => launchThisURL(externalResource[
                            AdditionalResourcesFields.downloadLink]),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.midnightBlue),
                        child: whiteInterBold(
                            externalResource[
                                AdditionalResourcesFields.fileName],
                            fontSize: 15))),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
