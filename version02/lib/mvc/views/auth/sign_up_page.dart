import 'package:flutter/material.dart';
import 'package:iep_app/mvc/controllers/auth/sign_up_controller.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:iep_app/mvc/views/auth/widgets/form_button.dart';
import 'package:iep_app/mvc/views/auth/widgets/text_field2.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _controller = SignupController();
  final _formKey = GlobalKey<FormState>(); // for validation

  @override
  void dispose() {
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
              children: [
                const SizedBox(height: 40),

                Text(
                  "Create Account",
                  style: AppTextStyles.size26weight5(colors.primary),
                ),

                const SizedBox(height: 10),

                Text(
                  "Create an account so you can explore all the existing jobs",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.size14weight5(colors.text),
                ),

                const SizedBox(height: 40),

                // === First name + Last name ===
                Row(
                  children: [
                    Expanded(
                      child: AppTextField2(
                        textInside: "First name",
                        controller: _controller.firstNameController,
                        validator: (value) =>
                            _controller.validateFirstName(value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField2(
                        textInside: "Last name",
                        controller: _controller.lastNameController,
                        validator: (value) =>
                            _controller.validateLastName(value),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // === email ===
                AppTextField2(
                  textInside: "Email",
                  controller: _controller.emailController,
                  validator: (value) => _controller.validateEmail(value),
                ),
                const SizedBox(height: 18),

                // === mobile number ===
                AppTextField2(
                  textInside: "Mobile Number",
                  controller: _controller.mobileController,
                  validator: (value) => _controller.validateMobil(value),
                ),
                const SizedBox(height: 18),

                // === Date of Birth (Year, Month, Day) ===
                Row(
                  children: [
                    Expanded(
                      child: AppTextField2(
                        textInside: "Year",
                        controller: _controller.yearController,
                        validator: (value) => _controller.validateYear(value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField2(
                        textInside: "Month",
                        controller: _controller.monthController,
                        validator: (value) => _controller.validateMonth(value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField2(
                        textInside: "Day",
                        controller: _controller.dayController,
                        validator: (value) => _controller.validateDay(value),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // === password ===
                AppTextField2(
                  textInside: "Password",
                  obscure: true,
                  controller: _controller.passwordController,
                  validator: (value) => _controller.validatePassword(value),
                ),
                const SizedBox(height: 18),

                // === confirm password ===
                AppTextField2(
                  textInside: "Confirm Password",
                  obscure: true,
                  controller: _controller.confirmPasswordController,
                  validator: (value) => _controller.validateConfirmPassword(
                    value,
                    _controller.passwordController.text,
                  ),
                ),

                const SizedBox(height: 30),

                // === listenableBuilder is listen to _controller changes(for isLoading) ===
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    // Sign up Button
                    return AppFormButton(
                      buttonText: "Sign up",
                      isloading: _controller.isLoading,
                      onPressed: () => _controller.signUp(context, _formKey),
                    );
                  },
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: AppTextStyles.size14weight4(colors.text),
                    ),
                    TextButton(
                      onPressed: () => _controller.onHaveAccountTap(context),
                      child: Text(
                        "Login",
                        style: AppTextStyles.size14weight5(colors.blue),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
