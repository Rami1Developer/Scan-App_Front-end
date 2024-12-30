  import 'package:flutter/material.dart';
  import 'package:scan_app/viewModels/login_view_model.dart';
  import 'package:scan_app/views/login.dart';
  import 'package:scan_app/views/user/my_home_page.dart';
  import 'package:provider/provider.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  void main() async {
    WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter environment is initialized.
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    runApp(
      MultiProvider(
        providers: [

          ChangeNotifierProvider(create: (_) => LoginViewModel()), // Provide LoginViewModel
        ],
        child: MyApp(initialIsLoggedIn: isLoggedIn),
      ),
    );
  }

  /// Main application widget
  class MyApp extends StatefulWidget {

    final bool initialIsLoggedIn;


    const MyApp({super.key, required this.initialIsLoggedIn});

    @override
    State<MyApp> createState() => _MyAppState();
  }

  class _MyAppState extends State<MyApp> {
  late bool isLoggedIn;
  @override
    void initState() {
      super.initState();
      isLoggedIn = widget.initialIsLoggedIn;
    }


    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
            useMaterial3: true,
          ),
        home: isLoggedIn
            ? MyHomePage()
            : LoginScreen(),

      );
    }
  }