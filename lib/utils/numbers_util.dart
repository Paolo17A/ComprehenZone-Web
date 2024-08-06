import 'string_util.dart';

double calculateAverageConfidence(List<dynamic> sentenceResults) {
  double sum = 0;

  for (var value in sentenceResults) {
    sum += value[SpeechFields.confidence];
  }

  return sum / sentenceResults.length;
}
