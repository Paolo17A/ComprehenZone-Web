import 'package:comprehenzone_web/screens/add_module_screen.dart';
import 'package:comprehenzone_web/screens/edit_module_screen.dart';
import 'package:comprehenzone_web/screens/home_screen.dart';
import 'package:comprehenzone_web/screens/register_screen.dart';
import 'package:comprehenzone_web/screens/selected_section_screen.dart';
import 'package:comprehenzone_web/screens/view_modules_screen.dart';
import 'package:comprehenzone_web/screens/view_sections_screen.dart';
import 'package:comprehenzone_web/screens/view_students_screen.dart';
import 'package:comprehenzone_web/screens/view_teachers_screen.dart';
import 'package:comprehenzone_web/utils/string_util.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class GoRoutes {
  static const home = '/';
  static const register = 'register';
  static const forgotPassword = 'forgotPassword';
  static const sections = 'sections';
  static const selectedSection = 'selectedSection';
  static const teachers = 'teachers';
  static const students = 'students';
  static const quizzes = 'quizzes';
  static const modules = 'modules';
  static const addModule = 'addModule';
  static const editModule = 'editModule';
}

final goRoutes = GoRouter(initialLocation: GoRoutes.home, routes: [
  GoRoute(
      name: GoRoutes.home,
      path: GoRoutes.home,
      pageBuilder: (context, state) =>
          customTransition(context, state, const HomeScreen()),
      routes: [
        GoRoute(
            name: GoRoutes.register,
            path: GoRoutes.register,
            pageBuilder: (context, state) =>
                customTransition(context, state, const RegisterScreen())),
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
            name: GoRoutes.students,
            path: GoRoutes.students,
            pageBuilder: (context, state) =>
                customTransition(context, state, const ViewStudentsScreen())),
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
                    moduleID: state.pathParameters[PathParameters.moduleID]!)))
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
