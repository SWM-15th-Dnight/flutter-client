import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/web.dart';

import 'package:mobile_client/app_state.dart';
import 'package:mobile_client/user/view/login_screen.dart';

import 'firebase_options.dart';

late final FirebaseApp app;

var logger = Logger();

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();

  app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    print('< App >');
    return ChangeNotifierProvider(
        create: (context) => AppState(),
        child: MaterialApp(
            title: 'App',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              fontFamily: 'NotoSans',
            ),
            debugShowCheckedModeBanner: false,
            home: LoginScreen()));
  }
}
