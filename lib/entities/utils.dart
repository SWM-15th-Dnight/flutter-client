import '../common/const/data.dart';

Future<void> setEmailPassword(String email, String password) async {
  await storage.write(key: USER_EMAIL_KEY, value: email);
  await storage.write(key: USER_PASSWORD_KEY, value: password);
}
