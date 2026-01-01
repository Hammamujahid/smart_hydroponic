// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:smart_hydroponic/pages/auth/login.dart';
import 'package:smart_hydroponic/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: const Color(0xFF41877F),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(45, 15, 45, 35),
              width: screenWidth,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: Color(0xFF41877F),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text("Back to login",
                            style: TextStyle(
                                fontFamily: "PlusJakartaSans",
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF41877F))),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Row(
                    children: [
                      Text(
                        "Sign Up",
                        style: TextStyle(
                            fontFamily: "PlusJakartaSans",
                            fontWeight: FontWeight.w600,
                            fontSize: 30,
                            color: Color(0xFF41877F)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      width: screenWidth,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                            hintText: "Email", border: InputBorder.none),
                      )),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    width: screenWidth,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                          hintText: "Password", border: InputBorder.none),
                      obscureText: true,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    width: screenWidth,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                          hintText: "Confirm Password",
                          border: InputBorder.none),
                      obscureText: true,
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      width: screenWidth,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          hintText: "Username",
                          border: InputBorder.none,
                        ),
                      )),
                  GestureDetector(
                    onTap: () async {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      final confirmPassword =
                          _confirmPasswordController.text.trim();
                      final username = _usernameController.text.trim();

                      if (email.isEmpty ||
                          password.isEmpty ||
                          confirmPassword.isEmpty ||
                          username.isEmpty) {
                        // Show error if any field is empty
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill in all fields"),
                          ),
                        );
                        return;
                      }

                      if (password != confirmPassword) {
                        // Show error if passwords do not match
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Passwords do not match"),
                          ),
                        );
                        return;
                      }

                      try {
                        await AuthService().register(
                          email: email,
                          password: password,
                          username: username,
                        );

                        if (!mounted) return;

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 30),
                      width: screenWidth,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF41877F),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                              fontFamily: "PlusJakartaSans",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF1F5F9)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
