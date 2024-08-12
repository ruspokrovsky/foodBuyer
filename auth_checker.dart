import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ya_bazaar/registration/user_prividers/user_providers.dart';
import 'package:ya_bazaar/res/home/home_providers/home_providers.dart';
import 'package:ya_bazaar/res/home/screens/home_page.dart';
import 'registration/registration_providers/registration_providers.dart';

class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    String whichUser = 'guest';

    ref.read(appLocaleProvider.notifier).buildLocale(ref, context.locale);

    return authState.when(
        data: (user) {

          if (user != null) {
            whichUser = user.uid;
          }

          ref.read(currentUserProvider.notifier).whichUser(whichUser:whichUser);

          return HomePage(currentUser: ref.watch(currentUserProvider));

        },
        loading: () => const SplashScreen(),
        error: (e, trace) => const Center(
          child: Text('error'),
        ));
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
