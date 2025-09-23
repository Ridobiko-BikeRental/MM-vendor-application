import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yumquick/view/auth/bloc/auth_event.dart';
import 'package:yumquick/view/auth/bloc/auth_state.dart';
import 'package:yumquick/view/widget/app_colors.dart';

import '../bloc/auth_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  TextStyle _titleStyle() => TextStyle(
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    fontSize: 15,
  );

  Widget _socialIcon(IconData icon, double size) {
    return CircleAvatar(
      radius: 21,
      backgroundColor: const Color(0xFFFFF3CD),
      child: Icon(icon, color: AppColors.primary, size: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Processing...")));
        } else if (state is AuthSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.pop(
            context,
          ); // After signup success, go back to login screen
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        // bottomNavigationBar: _BottomNavBarStyled(),
        body: Column(
          children: [
            // HEADER
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Vendor New Account",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // FORM
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -50),
                child: Container(
                  // height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    // boxShadow: [
                    //   BoxShadow(color: Colors.black12, blurRadius: 10),
                    // ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Full name", style: _titleStyle()),
                        const SizedBox(height: 7),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Full name",
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
                        Text("Email", style: _titleStyle()),
                        const SizedBox(height: 7),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email",
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
                        Text("Password", style: _titleStyle()),
                        const SizedBox(height: 7),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Password",
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscure = !_obscure;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
                        Text("Mobile number", style: _titleStyle()),
                        const SizedBox(height: 7),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3CD),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Mobile number",
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 13),
                        Center(
                          child: Text.rich(
                            TextSpan(
                              text: "By continuing, you agree to the\n",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.text,
                              ),
                              children: [
                                TextSpan(
                                  text: "Terms of Use",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(
                                  text: " and ",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.text,
                                  ),
                                ),
                                TextSpan(
                                  text: "Privacy Policy.",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // SIGNUP BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            onPressed: () {
                              final fullName = _fullNameController.text.trim();
                              final email = _emailController.text.trim();
                              final mobile = _mobileController.text.trim();
                              final password = _passwordController.text.trim();

                              if (fullName.isEmpty ||
                                  email.isEmpty ||
                                  // mobile.isEmpty ||
                                  password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please fill all fields"),
                                  ),
                                );
                                return;
                              }

                              context.read<AuthBloc>().add(
                                SignupRequested(
                                  fullName,
                                  email,
                                  mobile,
                                  password,
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Center(
                          child: Text(
                            "or sign up with",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialIcon(Icons.g_mobiledata, 27),
                            const SizedBox(width: 15),
                            _socialIcon(Icons.facebook, 22),
                            const SizedBox(width: 15),
                            _socialIcon(Icons.fingerprint, 22),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(
                                // fontSize: 12,
                                color: AppColors.text,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(
                                  context,
                                ); // Go back to login screen
                              },
                              child: const Text(
                                "Log in",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
