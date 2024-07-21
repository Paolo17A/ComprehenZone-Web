class ImagePaths {
  static const comprehenzoneLogo = 'assets/images/COMPREHENZONE LOGO.png';
  static const gradientBG = 'assets/images/FRONT PAGE BG.jpg';
  static const schoolBG = 'assets/images/school bg.jpg';
  static const schoolLogo = 'assets/images/school logo.jpg';
}

class DocumentPaths {
  static const grade5quarter1Lesson1 =
      'assets/documents/Grade5Quarter1Lesson1.pdf';
  static const grade5quarter1Lesson2 =
      'assets/documents/Grade5Quarter1Lesson2.pdf';
  static const grade5quarter1Lesson3 =
      'assets/documents/Grade5Quarter1Lesson3.pdf';
  static const grade5quarter1Lesson4 =
      'assets/documents/Grade5Quarter1Lesson4.pdf';
  static const grade6quarter2Lesson1 =
      'assets/documents/Grade6Quarter2Lesson1.pdf';
  static const grade6quarter2Lesson2 =
      'assets/documents/Grade6Quarter2Lesson2.pdf';
  static const grade6quarter2Lesson3 =
      'assets/documents/Grade6Quarter2Lesson3.pdf';
}

class StorageFields {
  static const verificationImages = 'verificationImages';
  static const profilePics = 'profilePics';
  static const moduleDocuments = 'moduleDocuments';
}

class Collections {
  static const String users = 'users';
  static const String sections = 'sections';
  static const String faqs = 'faqs';
  static const String modules = 'modules';
  static const String quizzes = 'quizzes';
  static const String quizResults = 'quizResults';
}

class UserTypes {
  static const String student = 'STUDENT';
  static const String teacher = 'TEACHER';
  static const String admin = 'ADMIN';
}

class UserFields {
  static const String email = 'email';
  static const String password = 'password';
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String userType = 'userType';
  static const String profileImageURL = 'profileImageURL';
  static const String birthDate = 'birthDate';
  static const String contactNumber = 'contactNumber';
  static const String assignedSections = 'assignedSections';
  static const String idNumber = 'idNumber';
  static const String gradeLevel = 'gradeLevel';
  static const String moduleProgresses = 'moduleProgresses';
}

class SectionFields {
  static const String name = 'name';
  static const String teacherID = 'teacherID';
  //static const String studentIDs = 'studentIDs';
}

class ModuleFields {
  static const String teacherID = 'teacherID';
  static const String sectionID = 'sectionID';
  static const String title = 'title';
  static const String content = 'content';
  static const String dateCreated = 'dateCreated';
  static const String dateLastModified = 'dateLastModified';
  static const String additionalDocuments = 'additionalDocuments';
  static const String additionalResources = 'additionalResources';
  static const String quarter = 'quarter';
}

class AdditionalResourcesFields {
  static const String fileName = 'fileName';
  static const String downloadLink = 'downloadLink';
}

class QuizFields {
  static const String isGlobal = 'isGlobal';
  static const String isActive = 'isActive';
  static const String teacherID = 'teacherID';
  static const String quizType = 'quizType';
  static const String title = 'title';
  static const String questions = 'questions';
  static const String dateCreated = 'dateCreated';
  static const String dateLastModified = 'dateLastModified';
}

class QuestionFields {
  static const String question = 'question';
  static const String options = 'options';
  static const String answer = 'answer';
}

class QuizTypes {
  static const String multipleChoice = 'MULTIPLE-CHOICE';
  static const String trueOrFalse = 'TRUE-FALSE';
  static const String identification = 'IDENTIFICATION';
}

class QuizResultFields {
  static const String studentID = 'studentID';
  static const String quizID = 'quizID';
  static const String answers = 'answers';
  static const String grade = 'grade';
}

class ModuleProgressFields {
  static const String quarter = 'quarter';
  static const String title = 'title';
  static const String progress = 'progress';
}

class PathParameters {
  static const sectionID = 'sectionID';
  static const userID = 'userID';
  static const moduleID = 'moduleID';
  static const quizID = 'quizID';
  static const studentID = 'studentID';
  static const teacherID = 'teacherID';
  static const quizResultID = 'quizResultID';
}
