import 'package:comprehenzone_web/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../models/speech_model.dart';
import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/go_router_util.dart';
import '../utils/numbers_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/left_navigator_widget.dart';

class SpeechResultScreen extends ConsumerStatefulWidget {
  final String speechResultID;
  const SpeechResultScreen({super.key, required this.speechResultID});

  @override
  ConsumerState<SpeechResultScreen> createState() => _SpeechResultScreenState();
}

class _SpeechResultScreenState extends ConsumerState<SpeechResultScreen> {
  String userType = UserTypes.admin;
  List<dynamic> sentenceResults = [];
  int speechIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        final userDoc = await getCurrentUserDoc();
        final userData = userDoc.data() as Map<dynamic, dynamic>;
        userType = userData[UserFields.userType];
        final speechResultDoc =
            await getThisSpeechResult(widget.speechResultID);
        final speechResultData =
            speechResultDoc.data() as Map<dynamic, dynamic>;
        speechIndex = speechResultData[SpeechResultFields.speechIndex];
        sentenceResults = speechResultData[SpeechResultFields.speechResults];
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting speech results: $error')));
        ref.read(loadingProvider).toggleLoading(false);
        navigator.pop();
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
            if (userType == UserTypes.admin)
              adminLeftNavigator(context, path: GoRoutes.students)
            else if (userType == UserTypes.teacher)
              teacherLeftNavigator(context, path: GoRoutes.sections)
            else if (userType == UserTypes.student)
              studentLeftNavigator(context, path: GoRoutes.home),
            bodyGradientContainer(
              context,
              child: SingleChildScrollView(
                child: horizontal5Percent(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _backButton(),
                      vertical20Pix(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: CustomColors.midnightBlue),
                          //height: 60,
                          width: double.infinity,
                          child: Center(
                              child: all20Pix(
                            child: whiteInterBold(
                                'Average pronounciation accuracy: ${calculateAverageConfidence(sentenceResults).toStringAsFixed(2)}%',
                                fontSize: 24),
                          )),
                        ),
                      ),
                      if (sentenceResults.isNotEmpty)
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: sentenceResults.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(6),
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 60, 118, 141),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      whiteInterBold(
                                          '${index + 1}. ${getSpeeechByIndex(speechIndex)!.sentences[index]}',
                                          fontSize: 20,
                                          textAlign: TextAlign.left),
                                      whiteInterBold(
                                          'Confidence Level: ${(sentenceResults[index][SpeechFields.confidence] as double).toStringAsFixed(2)}%'),
                                      Gap(16),
                                      Container(
                                        width: double.infinity,
                                        //height: 100,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Wrap(
                                              children: (sentenceResults[index][
                                                          SpeechFields
                                                              .breakdown]
                                                      as List<dynamic>)
                                                  .map((word) {
                                            final wordData =
                                                word as Map<String, dynamic>;
                                            return Text(
                                              '${wordData.keys.first} ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: wordData.values.first
                                                      ? Colors.green
                                                      : Colors.red),
                                            );
                                          }).toList()),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            })
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backButton() {
    return vertical10Pix(
      child: ElevatedButton(
          onPressed: () => GoRouter.of(context).goNamed(GoRoutes.home),
          style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors.midnightBlue),
          child: whiteInterBold('BACK')),
    );
  }
}
