class ImagePaths {
  static const comprehenzoneLogo = 'assets/images/COMPREHENZONE LOGO.png';
  //static const gradientBG = 'assets/images/FRONT PAGE BG.jpg';
  static const schoolBG = 'assets/images/school bg.jpg';
  static const schoolLogo = 'assets/images/school logo.jpg';
}

class DocumentPaths {
  //  GRADE 5
  static const grade5quarter1Lesson1 =
      'assets/images/modules/Grade5Quarter1Lesson1/';
  static const grade5quarter1Lesson2 =
      'assets/images/modules/Grade5Quarter1Lesson2/';
  static const grade5quarter1Lesson3 =
      'assets/images/modules/Grade5Quarter1Lesson3/';
  static const grade5quarter1Lesson4 =
      'assets/images/modules/Grade5Quarter1Lesson4/';
  static const grade5quarter2Lesson1 =
      'assets/images/modules/Grade5Quarter2Lesson1/';
  static const grade5quarter2Lesson2 =
      'assets/images/modules/Grade5Quarter2Lesson2/';
  static const grade5quarter2Lesson3 =
      'assets/images/modules/Grade5Quarter2Lesson3/';
  static const grade5quarter2Lesson4 =
      'assets/images/modules/Grade5Quarter2Lesson4/';
  static const grade5quarter2Lesson5 =
      'assets/images/modules/Grade5Quarter2Lesson5/';
  static const grade5quarter2Lesson6 =
      'assets/images/modules/Grade5Quarter2Lesson6/';
  static const grade5quarter3Lesson1 =
      'assets/images/modules/Grade5Quarter3Lesson1/';
  static const grade5quarter3Lesson2 =
      'assets/images/modules/Grade5Quarter3Lesson2/';
  static const grade5quarter3Lesson3 =
      'assets/images/modules/Grade5Quarter3Lesson3/';
  static const grade5quarter3Lesson4 =
      'assets/images/modules/Grade5Quarter3Lesson4/';
  static const grade5quarter4Lesson1 =
      'assets/images/modules/Grade5Quarter4Lesson1/';
  static const grade5quarter4Lesson2 =
      'assets/images/modules/Grade5Quarter4Lesson2/';
  static const grade5quarter4Lesson3 =
      'assets/images/modules/Grade5Quarter4Lesson3/';
  static const grade5quarter4Lesson4 =
      'assets/images/modules/Grade5Quarter4Lesson4/';
  static const grade5quarter4Lesson5 =
      'assets/images/modules/Grade5Quarter4Lesson5/';
  //  GRADE 6
  static const grade6quarter1Lesson1 =
      'assets/images/modules/Grade6Quarter1Lesson1/';
  static const grade6quarter1Lesson2 =
      'assets/images/modules/Grade6Quarter1Lesson2/';
  static const grade6quarter2Lesson1 =
      'assets/images/modules/Grade6Quarter2Lesson1/';
  static const grade6quarter2Lesson2 =
      'assets/images/modules/Grade6Quarter2Lesson2/';
  static const grade6quarter2Lesson3 =
      'assets/images/modules/Grade6Quarter2Lesson3/';
  static const grade6quarter3Lesson1 =
      'assets/images/modules/Grade6Quarter3Lesson1/';
  static const grade6quarter3Lesson2 =
      'assets/images/modules/Grade6Quarter3Lesson2/';
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
  static const String speechResults = 'speechResults';
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
  static const String speechIndex = 'speechIndex';
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
  static const String gradeLevel = 'gradeLevel';
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
  static const String quarter = 'quarter';
  static const String gradeLevel = 'gradeLevel';
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

class SpeechResultFields {
  static const String studentID = 'studentID';
  static const String speechIndex = 'speechIndex';
  static const String speechResults = 'speechResults';
}

class SpeechFields {
  static const String breakdown = 'breakdown';
  static const String similarity = 'similarity';
  static const String confidence = 'confidence';
  static const String average = 'average';
}

class PathParameters {
  static const sectionID = 'sectionID';
  static const userID = 'userID';
  static const moduleID = 'moduleID';
  static const quizID = 'quizID';
  static const studentID = 'studentID';
  static const teacherID = 'teacherID';
  static const quizResultID = 'quizResultID';
  static const speechResultID = 'speechResultID';
  static const quarter = 'quarter';
  static const index = 'index';
  static const documentPath = 'documentPath';
}
