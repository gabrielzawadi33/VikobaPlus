import 'package:flutter/material.dart';

import 'authentication.dart';
import 'loan.dart';
import 'memb.dart';
import 'returns.dart';
import 'screens/mapato_matumiziTabScreen.dart';
import 'screens/profileScreen.dart';
import 'screens/report.dart';
import 'screens/tabs_screen.dart';
import 'taarifa.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AuthScreen.routeName,
      routes: {
        AuthScreen.routeName: (context) => AuthScreen(),
        TabsScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String?>?;
          return TabsScreen(
            token: args?['token'],
            memberId: args?['memberId'],
            userOccupation: args?['userOccupation'],
          );
        },
        LoanTrackerScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String?>?;
          return LoanTrackerScreen(
            token: args?['token'],
            memberId: args?['memberId'],
            userOccupation: args?['userOccupation'],
          );
        },
        MyMembersPage.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String?>?;
          return MyMembersPage(
            token: args?['token'],
            memberId: args?['memberId'],
            userOccupation: args?['userOccupation'],
          );
        },
        LoanPage.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String?>?;
          return LoanPage(
            title: args?['title'] ?? '',
            token: args?['token'],
            memberId: args?['memberId'],
            userOccupation: args?['userOccupation'],
          );
        },
        MyReportPage.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String?>?;
          return MyReportPage(
            title: args?['title'] ?? '',
            token: args?['token'],
            memberId: args?['memberId'],
            userOccupation: args?['userOccupation'],
          );
        },
        ProfileScreen.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String?>?;
          return ProfileScreen(
            token: args?['token'],
            memberId: args?['memberId'],
          );
        },
        TaarifaApp.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String?>?;
          return TaarifaApp(
            token: args?['token'],
            memberId: args?['memberId'],
            userOccupation: args?['userOccupation'],
          );
        },
        TabApp.routeName: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, String?>?;
          return TabApp(
            token: args?['token'],
            userOccupation: args?['userOccupation'],
          );
        },
      },
    );
  }
}
