import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/auth_provider.dart';
import 'package:smart_hydroponic/presentation/screens/auth/authgate.dart';
import 'package:smart_hydroponic/presentation/screens/auth/register.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    width: screenWidth,
                    padding: const EdgeInsetsGeometry.all(30),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello!",
                          style: TextStyle(
                              fontFamily: "PlusJakartaSans",
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF1F5F9)),
                        ),
                        Text(
                          "Welcome to Smart Hydroponic",
                          style: TextStyle(
                              fontFamily: "PlusJakartaSans",
                              fontSize: 14,
                              color: Color(0xFFF1F5F9)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 35, horizontal: 45),
                    width: screenWidth,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Row(
                          children: [
                            Text(
                              "Login",
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
                                hintText: "Email",
                                border: InputBorder.none,
                              ),
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
                              hintText: "Password",
                              border: InputBorder.none,
                            ),
                            obscureText: true,
                          ),
                        ),
                        GestureDetector(
                          onTap: _loading
                              ? null
                              : () async {
                                  setState(() => _loading = true);

                                  try {
                                    await ref.read(authProvider).login(
                                          email: _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim(),
                                        );

                                    Navigator.pushAndRemoveUntil(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const AuthGate()),
                                      (route) => false,
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  } finally {
                                    setState(() => _loading = false);
                                  }
                                },
                          child: Container(
                            margin: const EdgeInsets.only(top: 30),
                            width: screenWidth,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _loading
                                  ? Colors.grey
                                  : const Color(0xFF41877F),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: _loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        fontFamily: "PlusJakartaSans",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFF1F5F9),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: screenWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Dont have account? ",
                                style: TextStyle(
                                    fontFamily: "PlusJakartaSans",
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterPage()));
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      fontFamily: "PlusJakartaSans",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF41877F)),
                                ),
                              )
                            ],
                          ),
                        )
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
