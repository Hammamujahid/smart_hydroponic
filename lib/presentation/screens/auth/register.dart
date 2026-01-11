import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/auth_provider.dart';
import 'package:smart_hydroponic/presentation/screens/auth/login.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
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
    ref.listen<AuthProvider>(authProvider, (prev, next) {
      if (next.status == AuthStatus.success) {
        ref.read(authProvider).reset();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }

      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: const Color(0xFF41877F),
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
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
                          onTap: () {
                            ref.read(authProvider).register(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  confirmPassword:
                                      _confirmPasswordController.text.trim(),
                                  username: _usernameController.text.trim(),
                                );
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
              ),
            ),
          );
        }));
  }
}
