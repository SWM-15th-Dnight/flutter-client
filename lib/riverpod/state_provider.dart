import 'package:flutter_riverpod/flutter_riverpod.dart';

final isClickedProvider = StateProvider<bool>((ref) => false);
final signInValidateProvider = StateProvider<String>((ref) => '');
