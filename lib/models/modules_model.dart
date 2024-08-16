import '../utils/string_util.dart';

class ModulesModel {
  int index;
  String title;
  String documentPath;
  int pagesCount;
  ModulesModel(
      {required this.index,
      required this.title,
      required this.documentPath,
      required this.pagesCount});
}

final List<ModulesModel> Grade5Quarter1Modules = [
  ModulesModel(
      index: 1,
      title: 'Using Complex Sentences to Show a Cause and Effect Relationship',
      documentPath: DocumentPaths.grade5quarter1Lesson1,
      pagesCount: 19),
  ModulesModel(
      index: 2,
      title: 'Inferring the Meaning of Words with Affixes Using Context Clues',
      documentPath: DocumentPaths.grade5quarter1Lesson2,
      pagesCount: 21),
  ModulesModel(
      index: 3,
      title: 'Inferring the Meaning of Blended Words Using Context Clues',
      documentPath: DocumentPaths.grade5quarter1Lesson3,
      pagesCount: 16),
  ModulesModel(
      index: 4,
      title: 'Inferring the Meaning of Clipped Words Using Context Clues',
      documentPath: DocumentPaths.grade5quarter1Lesson4,
      pagesCount: 16),
];

final List<ModulesModel> Grade6Quarter2Modules = [
  ModulesModel(
      index: 1,
      title: 'Explore Significant Information',
      documentPath: DocumentPaths.grade6quarter2Lesson1,
      pagesCount: 15),
  ModulesModel(
      index: 2,
      title: 'Recognizing Propaganda Devices',
      documentPath: DocumentPaths.grade6quarter2Lesson2,
      pagesCount: 16),
  ModulesModel(
      index: 3,
      title: 'Getting Immersed in Multimedia information',
      documentPath: DocumentPaths.grade6quarter2Lesson3,
      pagesCount: 21),
];
