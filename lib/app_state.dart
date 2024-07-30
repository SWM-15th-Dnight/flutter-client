import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:table_calendar/table_calendar.dart';

User? user;
String? idToken; // Firebase Auth, idToken;

class AppState extends ChangeNotifier {
  // TableCalendar
  final CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? selectedDay;

  Future<void> UpdateFocusedDay(DateTime focusedDay) async {
    print('onPageChanged: $focusedDay, $focusedDay');
    //_focusedDay = focusedDay;

    if (focusedDay == DateTime.now().month) {
      focusedDay = DateTime.now();
    } else {
      focusedDay = DateTime(focusedDay.year, focusedDay.month, 1);
    }
    print('result: $focusedDay');
    notifyListeners();
  }

  Future<void> signIn(String provider) async {
    idToken = null; // init when login
    if (provider == 'google') {
      user = await signInWithGoogle();
    } else if (provider == 'microsoft') {
      user = await signInWithMicrosoft();
    }
    idToken = await user?.getIdToken();
    notifyListeners();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    user = null;
    notifyListeners();
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Sign out from any existing Google account
      await GoogleSignIn(signInOption: SignInOption.standard).signOut();

      const List<String> scopes = <String>[
        'email',
        'https://www.googleapis.com/auth/calendar',
      ];

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn(signInOption: SignInOption.standard).signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      printLongString("(test) google's idToken: ${googleAuth?.idToken}");

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((userCredential) => userCredential.user);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> signInWithMicrosoft() async {
    try {
      final microsoftProvider = OAuthProvider('microsoft.com');
      final String tenant = dotenv.env['MS_TENANT_ID']!;
      microsoftProvider.setCustomParameters({'tenant': tenant});

      final UserCredential userCredential;

      if (kIsWeb) {
        userCredential =
            await FirebaseAuth.instance.signInWithPopup(microsoftProvider);
      } else {
        userCredential =
            await FirebaseAuth.instance.signInWithProvider(microsoftProvider);
      }

      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }
}

void printLongString(String text) {
  final RegExp pattern = RegExp('.{1,800}'); // Adjust the chunk size as needed
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}
