import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/diary_screen.dart';
import '../screens/light_screen.dart';
import '../screens/level_screen.dart';
import '../screens/mypage_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

import '../models/diary.dart';
import '../screens/diary_edit_screen.dart';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionANavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'sectionANav');
final _sectionBNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'sectionBNav');
final _sectionCNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'sectionCNav');
final _sectionDNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'sectionDNav');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/diary',
  routes: <RouteBase>[
    GoRoute(
      path: '/diary/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final diary = state.extra as Diary?;
        return DiaryEditScreen(diary: diary);
      },
    ),
    // StatefulShellRoute maintains the state of each branch
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        // The route branch for the 1st Tab (Diary)
        StatefulShellBranch(
          navigatorKey: _sectionANavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/diary',
              builder: (BuildContext context, GoRouterState state) =>
                  const DiaryScreen(),
            ),
          ],
        ),
        // The route branch for the 2nd Tab (Light)
        StatefulShellBranch(
          navigatorKey: _sectionBNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/light',
              builder: (BuildContext context, GoRouterState state) =>
                  const LightScreen(),
            ),
          ],
        ),
        // The route branch for the 3rd Tab (Level)
        StatefulShellBranch(
          navigatorKey: _sectionCNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/level',
              builder: (BuildContext context, GoRouterState state) =>
                  const LevelScreen(),
            ),
          ],
        ),
        // The route branch for the 4th Tab (MyPage)
        StatefulShellBranch(
          navigatorKey: _sectionDNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/mypage',
              builder: (BuildContext context, GoRouterState state) =>
                  const MyPageScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
