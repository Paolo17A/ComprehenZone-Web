import 'package:comprehenzone_web/screens/home_screen.dart';
import 'package:comprehenzone_web/screens/register_screen.dart';
import 'package:comprehenzone_web/screens/selected_section_screen.dart';
import 'package:comprehenzone_web/screens/view_sections_screen.dart';
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
            path: '${GoRoutes.sections}/:${PathParamters.sectionID}',
            pageBuilder: (context, state) => customTransition(
                context,
                state,
                SelectedSectionScreen(
                    sectionID:
                        state.pathParameters[PathParamters.sectionID]!))),
        GoRoute(
            name: GoRoutes.teachers,
            path: GoRoutes.teachers,
            pageBuilder: (context, state) =>
                customTransition(context, state, const ViewTeachersScreen()))
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
