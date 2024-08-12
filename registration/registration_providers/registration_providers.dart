import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/registration/registration_services/registration_services.dart';

final authenticationProvider = Provider<Registration>((ref) {
  return Registration();
},
name: 'authenticationProvider');

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authenticationProvider).authStateChange;
});