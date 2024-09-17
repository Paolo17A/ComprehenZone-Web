import 'package:comprehenzone_web/utils/go_router_util.dart';
import 'package:comprehenzone_web/widgets/custom_button_widgets.dart';
import 'package:comprehenzone_web/widgets/custom_text_widgets.dart';
import 'package:comprehenzone_web/widgets/left_navigator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../models/speech_model.dart';
import '../providers/loading_provider.dart';
import '../providers/user_type_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';

class SpeechSelectScreen extends ConsumerStatefulWidget {
  const SpeechSelectScreen({super.key});

  @override
  ConsumerState<SpeechSelectScreen> createState() => _SpeechSelectScreenState();
}

class _SpeechSelectScreenState extends ConsumerState<SpeechSelectScreen> {
  int currentSpeechIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        final userDoc = await getCurrentUserDoc();
        final userData = userDoc.data() as Map<dynamic, dynamic>;
        ref.read(userTypeProvider).setUserType(await getCurrentUserType());
        if (ref.read(userTypeProvider).userType != UserTypes.student) {
          ref.read(loadingProvider).toggleLoading(false);
          GoRouter.of(context).goNamed(GoRoutes.home);
          return;
        }
        currentSpeechIndex = userData[UserFields.speechIndex];
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        ref.read(loadingProvider).toggleLoading(false);
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('Error getting current speech index: $error')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              studentLeftNavigator(context, path: GoRoutes.speechSelect),
              bodyBlueBackgroundContainer(
                context,
                child: SingleChildScrollView(
                  child: horizontal5Percent(
                    context,
                    child: Column(
                      children: [
                        Gap(20),
                        borderedOlympicBlueContainer(
                          child: Column(
                            children: [_speechHeader(), _speechButtons()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _speechHeader() {
    return vertical20Pix(
        child: blackInterBold('PRACTICE YOUR SPEECH', fontSize: 32));
  }

  Widget _speechButtons() {
    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: speechCategories.length,
        itemBuilder: (context, index) {
          return vertical10Pix(
              child: ElevatedButton(
                  onPressed: () async {
                    if (currentSpeechIndex == index + 1) {
                      GoRouter.of(context).goNamed(GoRoutes.selectedSpeech,
                          pathParameters: {
                            PathParameters.index: (index + 1).toString()
                          });
                    } else if (currentSpeechIndex > index + 1) {
                      GoRouter.of(context).goNamed(
                          GoRoutes.selectedSpeechResult,
                          pathParameters: {
                            PathParameters.speechResultID:
                                await getThisSpeechResultIDByIndex(index + 1)
                          });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('You have not yet unlocked this lesson. ')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColors.dirtyPearl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //mainAxisSize: MainAxisSize.min,
                    children: [
                      //Expanded(child: child)
                      //Gap(MediaQuery.of(context).size.width * 0.25),
                      blackInterBold('${(index + 1).toString()}.\t\t',
                          fontSize: 20, textAlign: TextAlign.left),
                      blackInterBold('${speechCategories[index].category}',
                          fontSize: 20,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left),
                    ],
                  )));
        });
  }
}
