import 'package:comprehenzone_web/screens/add_module_screen.dart';
import 'package:comprehenzone_web/screens/add_quiz_screen.dart';
import 'package:comprehenzone_web/screens/add_student_screen.dart';
import 'package:comprehenzone_web/screens/add_teacher_screen.dart';
import 'package:comprehenzone_web/screens/answer_quiz_screen.dart';
import 'package:comprehenzone_web/screens/edit_module_screen.dart';
import 'package:comprehenzone_web/screens/edit_profile_screen.dart';
import 'package:comprehenzone_web/screens/edit_quiz_screen.dart';
import 'package:comprehenzone_web/screens/edit_selected_profile_screen.dart';
import 'package:comprehenzone_web/screens/home_screen.dart';
import 'package:comprehenzone_web/screens/profile_screen.dart';
import 'package:comprehenzone_web/screens/selected_global_module_screen.dart';
import 'package:comprehenzone_web/screens/selected_module_screen.dart';
import 'package:comprehenzone_web/screens/selected_quiz_result_screen.dart';
import 'package:comprehenzone_web/screens/selected_section_screen.dart';
import 'package:comprehenzone_web/screens/selected_student_screen.dart';
import 'package:comprehenzone_web/screens/selected_teacher_screen.dart';
import 'package:comprehenzone_web/screens/speech_result_screen.dart';
import 'package:comprehenzone_web/screens/view_modules_screen.dart';
import 'package:comprehenzone_web/screens/view_quizzes_screen.dart';
import 'package:comprehenzone_web/screens/view_sections_screen.dart';
import 'package:comprehenzone_web/screens/view_students_screen.dart';
import 'package:comprehenzone_web/screens/view_teachers_screen.dart';
import 'package:comprehenzone_web/utils/string_util.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class GoRoutes {
  static const home = '/';
  //static const register = 'register';
  static const forgotPassword = 'forgotPassword';
  static const sections = 'sections';
  static const selectedSection = 'selectedSection';
  static const teachers = 'teachers';
  static const addTeacher = 'addTeacher';
  static const selectedTeacher = 'selectedTeacher';
  static const students = 'students';
  static const addStudent = 'addStudent';
  static const selectedStudent = 'selectedStudent';
  static const modules = 'modules';
  static const addModule = 'addModule';
  static const editModule = 'editModule';
  static const selectedModule = 'selectedModule';
  static const selectedGlobalModule = 'selectedGlobalModule';
  static const quizzes = 'quizzes';
  static const addQuiz = 'addQuiz';
  static const editQuiz = 'editQuiz';
  static const profile = 'profile';
  static const editProfile = 'editProfile';
  static const editSelectedProfile = 'editSelectedProfile';
  static const answerQuiz = 'answerQuiz';
  static const selectedQuizResult = 'selectedQuizResult';
  static const selectedSpeechResult = 'selectedSpeechResult';
}

final goRoutes = GoRouter(initialLocation: GoRoutes.home, routes: [
  GoRoute(
      name: GoRoutes.home,
      path: GoRoutes.home,
      pageBuilder: (context, state) =>
          customTransition(context, state, const HomeScreen()),
      routes: [
        /*(GoRoute(
            name: GoRoutes.register,
            path: GoRoutes.register,
            pageBuilder: (context, state) =>
                customTransition(context, state, const RegisterScreen())),*/
        GoRoute(
            name: GoRoutes.sections,
            path: GoRoutes.sections,
            pageBuilder: (context, state) =>
                customTransition(context, state, const ViewSectionsScreen())),
        GoRoute(
            name: GoRoutes.selectedSection,
            path: '${GoRoutes.sections}/:${PathParameters.sectionID}',
            pageBuilder: (context, state) => customTransition(
                context,
                state,
                SelectedSectionScreen(
                    sectionID:
                        state.pathParameters[PathParameters.sectionID]!))),
        GoRoute(
            name: GoRoutes.teachers,
            path: GoRoutes.teachers,
            pageBuilder: (context, state) =>
                customTransition(context, state, const ViewTeachersScreen())),
        GoRoute(
            name: GoRoutes.addTeacher,
            path: GoRoutes.addTeacher,
            pageBuilder: (context, state) =>
                customTransition(context, state, const AddTeacherScreen())),
        GoRoute(
            name: GoRoutes.selectedTeacher,
            path: '${GoRoutes.teachers}/:${PathParameters.teacherID}',
            pageBuilder: (context, state) => customTransition(
                context,
                state,
                SelectedTeacherScreen(
                    teacherID:
                        state.pathParameters[PathParameters.teacherID]!))),
        GoRoute(
            name: GoRoutes.students,
            path: GoRoutes.students,
            pageBuilder: (context, state) =>
                customTransition(context, state, const ViewStudentsScreen())),
        GoRoute(
            name: GoRoutes.addStudent,
            path: GoRoutes.addStudent,
            pageBuilder: (context, state) =>
                customTransition(context, state, const AddStudentScreen())),
        GoRoute(
            name: GoRoutes.selectedStudent,
            path: '${GoRoutes.students}/:${PathParameters.studentID}',
            pageBuilder: (context, state) => customTransition(
                context,
                state,
                SelectedStudentScreen(
                    studentID:
                        state.pathParameters[PathParameters.studentID]!))),
        GoRoute(
            name: GoRoutes.modules,
            path: GoRoutes.modules,
            pageBuilder: (context, state) =>
                customTransition(context, state, const ViewModulesScreen())),
        GoRoute(
            name: GoRoutes.addModule,
            path: GoRoutes.addModule,
            pageBuilder: (context, state) =>
                customTransition(context, state, const AddModuleScreen())),
        GoRoute(
            name: GoRoutes.editModule,
            path: '${GoRoutes.modules}/:${PathParameters.moduleID}/edit',
            pageBuilder: (context, state) => customTransition(
                context,
                state,
                EditModuleScreen(
                    moduleID: state.pathParameters[PathParameters.moduleID]!))),
        GoRoute(
            name: GoRoutes.selectedModule,
            path: '${GoRoutes.modules}/:${PathParameters.moduleID}',
            pageBuilder: (context, state) => customTransition(
                context,
                state,
                SelectedModuleScreen(
                    moduleID: state.pathParameters[PathParameters.moduleID]!))),
        GoRoute(
            name: GoRoutes.selectedGlobalModule,
            path:
                '${GoRoutes.modules}/global/:${PathParameters.index}/:${PathParameters.quarter}',
            pageBuilder: (context, state) => customTransition(
                context,
                state,
                SelectedGlobalModuleScreen(
                    index: state.pathParameters[PathParameters.index]!,
                    quarter: state.pathParameters[PathParameters.quarter]!))),
        GoRoute(
            name: GoRoutes.quizzes,
            path: GoRoutes.quizzes,
            pageBuilder: (context, state) =>
                customTransition(context, state, const ViewQuizzesScreen())),
        GoRoute(
            name: GoRoutes.addQuiz,
            path: GoRoutes.addQuiz,
            pageBuilder: (context, state) =>
                customTransition(context, state, const AddQuizScreen())),
        GoRoute(
            name: GoRoutes.editQuiz,
            path: '${GoRoutes.quizzes}/:${PathParameters.quizID}/edit',
            pageBuilder: (context, state) => customTransition(
                context,
                state,
                EditQuizScreen(
                    quizID: state.pathParameters[PathParameters.quizID]!))),
        GoRoute(
            name: GoRoutes.profile,
            path: GoRoutes.profile,
            pageBuilder: (context, state) =>
                customTransition(context, state, const ProfileScreen())),
        GoRoute(
            name: GoRoutes.editProfile,
            path: GoRoutes.editProfile,
            pageBuilder: (context, state) =>
                customTransition(context, state, const EditProfileScreen())),
        GoRoute(
            name: GoRoutes.editSelectedProfile,
            path: '${GoRoutes.editSelectedProfile}/:${PathParameters.userID}',
            pageBuilder: (context, state) => customTransition(
                context,
                state,
                EditSelectedProfileScreen(
                    userID: state.pathParameters[PathParameters.userID]!))),
        GoRoute(
            name: GoRoutes.selectedQuizResult,
            path:
                '${GoRoutes.selectedQuizResult}/:${PathParameters.quizResultID}',
            pageBuilder: (context, state) => customTransition(
                context,
                state,
                SelectedQuizResultScreen(
                    quizResultID:
                        state.pathParameters[PathParameters.quizResultID]!))),
        GoRoute(
            name: GoRoutes.selectedSpeechResult,
            path:
                '${GoRoutes.selectedSpeechResult}/:${PathParameters.speechResultID}',
            pageBuilder: (context, state) => customTransition(
                context,
                state,
                SpeechResultScreen(
                    speechResultID:
                        state.pathParameters[PathParameters.speechResultID]!))),
        GoRoute(
            name: GoRoutes.answerQuiz,
            path: '${GoRoutes.answerQuiz}/:${PathParameters.quizID}',
            pageBuilder: (context, state) => customTransition(
                context,
                state,
                AnswerQuizScreen(
                    quizID: state.pathParameters[PathParameters.quizID]!)))
      ])
]);

CustomTransitionPage customTransition(
    BuildContext context, GoRouterState state, Widget widget) {
  return CustomTransitionPage(
      fullscreenDialog: true,
      key: state.pageKey,
      child: widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return easeInOutCircTransition(animation, child);
      });
}

FadeTransition easeInOutCircTransition(
    Animation<double> animation, Widget child) {
  return FadeTransition(
      opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
      child: child);
}
