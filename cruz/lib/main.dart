import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/auth_provider.dart';
import 'provider/grading_provider.dart';
import 'provider/todo_provider.dart';
import 'screens/student_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GradingProvider>(
          create: (_) => GradingProvider(),
          update: (_, auth, grading) {
            grading!.updateService(
              auth.dbService,
              auth.currentUser?.role,
              auth.currentUser?.studentId,
            );
            return grading;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TodoProvider>(
          create: (_) => TodoProvider(),
          update: (_, auth, todo) {
            todo!.updateService(
              auth.dbService,
              auth.currentUser?.uid,
            );
            return todo;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Cruz Academy Portal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F0C20),
          primaryColor: const Color(0xFF9E77F3),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF9E77F3),
            brightness: Brightness.dark,
            primary: const Color(0xFF9E77F3),
            secondary: const Color(0xFF00E676),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F0C20),
            elevation: 0,
          ),
        ),
        home: const StudentDashboard(),
      ),
    );
  }
}
