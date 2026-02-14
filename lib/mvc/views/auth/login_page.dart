import 'package:flutter/material.dart';
import 'package:iep_app/mvc/controllers/auth/login_controller.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/views/auth/widgets/form_button.dart';
import 'package:iep_app/mvc/views/auth/widgets/text_field2.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = LoginController();
  final _formKey = GlobalKey<FormState>(); // for validation

  @override
  void dispose() {
    // dispose for TextEditingControllers
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.light;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Title
                Text(
                  "Login here",
                  style: AppTextStyles.size26weight5(colors.primary),
                ),

                const SizedBox(height: 10),

                Text(
                  "Welcome back you've\nbeen missed!",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.size14weight5(colors.text),
                ),

                const SizedBox(height: 40),

                // === Email ===
                AppTextField2(
                  textInside: "Email",
                  controller: _controller.emailController,
                  validator: (value) => _controller.validateEmail(value),
                ),

                const SizedBox(height: 20),

                // === Password ===
                AppTextField2(
                  textInside: "Password",
                  obscure: true,
                  controller: _controller.passwordController,
                  validator: (value) => _controller.validatePassword(value),
                ),
                const SizedBox(height: 10),

                // === forgot password ===
                Row(
                  children: [
                    Spacer(flex: 1),
                    InkWell(
                      onTap: () async =>
                          await _controller.forgetPassword(context),
                      child: Text(
                        "Forgot your password?",
                        style: AppTextStyles.size12weight4(colors.blue),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // === listenableBuilder is listen to _controller changes(for isLoading) ===
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    // Sign in Button
                    return AppFormButton(
                      buttonText: 'Login',
                      isloading: _controller.isLoading,
                      onPressed: () => _controller.login(context, _formKey),
                    );
                  },
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't Have An Account Yet?",
                      style: AppTextStyles.size14weight4(colors.text),
                    ),
                    TextButton(
                      onPressed: () => _controller.onCreateAccountEmailTap(context),
                      child: Text(
                        "Sign Up",
                        style: AppTextStyles.size14weight5(colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
