import 'package:flutter/material.dart';
import 'package:iep_app/mvc/models/user_model.dart';
import 'package:iep_app/mvc/providers/user_provider.dart';
import 'package:iep_app/mvc/views/auth/email_verify.dart';
import 'package:iep_app/mvc/views/layout/blocked_user_screen.dart';
import 'package:iep_app/mvc/views/layout/layout.dart';
import 'package:iep_app/mvc/views/on_boarding/first.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iep_app/firebase_options.dart';

void main() async {
  // === connect to Firebase ===
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // === run our App ===
  runApp(
    // === to use providers ===
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const Main(),
    ), // rebuild widgets with user information
  );
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "IEP Application",
      debugShowCheckedModeBanner: false,
      // === using userProvider to listen to changes ===
      home: Consumer<UserProvider>(
        //----------> listen to changes scop
        // *context, to point the widget on the tree
        // *userProvider, object form the userProvider
        // *last parameter, to optimize the performance, so if there widget no need to built again will sent in child arg
        builder: (context, userProvider, _) {
          // === checking if still in firebase ===
          if (userProvider.isAuthLoading) {
            // === if still checking then return curcular spanner to user ===
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // === if still didn't login ===
          if (userProvider.user == null) {
            return OnboardPage1();
          }

          // === checking if the user blocked by admin or not ===
          if (userProvider.isBlocked) {
            return BlockedUserScreen();
          }

          // === check if the user verified his email or not ===
          if (!userProvider.isEmailVerified &&
              userProvider.currentUser?.role == UserRole.user) {
            // admin emails are not real
            return AppVerifyEmailPage();
          }

          // === if the user logged in and he is not blocked ===
          return Layout();
        },
      ),
    );
  }
}
