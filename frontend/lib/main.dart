import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/forgetPassword_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  runApp(MyApp(initialRoute: token != null ? '/home' : '/'));
}

class MyApp extends StatelessWidget {

  final String initialRoute;
  
  const MyApp({super.key, required this.initialRoute});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: initialRoute,
      routes: {
        '/': (context) => LoginScreen(),
        '/forgetPassword': (context) => ForgetPasswordScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
