import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/auth_provider.dart';
import 'package:smart_hydroponic/presentation/screens/auth/register.dart';
import 'package:toastification/toastification.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_loading) return;

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (email.isEmpty) {
      setState(() {
        _emailError = "Email is required";
      });
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _passwordError = "Password is required";
      });
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _emailError = "Invalid email format";
      });
      return;
    }

    if (email.toLowerCase() == "zerxonin@gmail.com") {
      setState(() {
        _emailError = "The account cannot be accessed";
      });
      return;
    }

    setState(() => _loading = true);

    await Future.delayed(const Duration(seconds: 1));

    try {
      await ref.read(authProvider).login(
            email: email,
            password: password,
          );

      if (!mounted) return;

      toastification.show(
        type: ToastificationType.success,
        context: context,
        title: const Text(
          'Login successful',
          style: TextStyle(fontFamily: 'PlusJakartaSans'),
        ),
        autoCloseDuration: const Duration(seconds: 3),
      );
    } on FirebaseAuthException catch (e)  {
      if (!mounted) return;

      setState(() {
        if (e.code == "user-not-found") {
          _emailError = "Email not registered";
        } else if (e.code == "wrong-password") {
          _passwordError = "Incorrect password";
        } else {
          _emailError = "Email or password is invalid";
          _passwordError = "Email or password is invalid";
        }
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/background2.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
            backgroundColor: Colors.transparent,
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
                        padding: const EdgeInsets.fromLTRB(30, 0, 30, 50),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello!",
                              style: TextStyle(
                                  fontFamily: "PlusJakartaSans",
                                  fontSize: 40,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF41877F)),
                            ),
                            Text(
                              "Welcome to Smart Hydroponic",
                              style: TextStyle(
                                  fontFamily: "PlusJakartaSans",
                                  fontSize: 14,
                                  color: Color(0xFF41877F)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 35, horizontal: 45),
                        width: screenWidth,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              offset: const Offset(0, -4),
                            ),
                          ],
                          color: Colors.transparent,
                          borderRadius: const BorderRadius.only(
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
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (value) {
                                    if (_emailError != null) {
                                      setState(() {
                                        _emailError = null;
                                      });
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Email",
                                    border: InputBorder.none,
                                  ),
                                )),
                            if (_emailError != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 20, top: 5),
                                    child: Text(
                                      _emailError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontFamily: "PlusJakartaSans",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
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
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  autocorrect: false,
                                  enableSuggestions: false,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _login(),
                                  onChanged: (value) {
                                    if (_passwordError != null) {
                                      setState(() {
                                        _passwordError = null;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                    border: InputBorder.none,
                                    suffixIcon: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                )),
                            if (_passwordError != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 20, top: 5),
                                    child: Text(
                                      _passwordError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontFamily: "PlusJakartaSans",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            AbsorbPointer(
                              absorbing: _loading,
                              child: GestureDetector(
                                onTap: _login,
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
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Color.fromARGB(255, 103, 103, 103)),
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
            })),
      ],
    );
  }
}
