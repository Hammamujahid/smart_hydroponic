import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_hydroponic/presentation/providers/auth_provider.dart';
import 'package:smart_hydroponic/presentation/providers/user_provider.dart';
import 'package:smart_hydroponic/presentation/screens/auth/authgate.dart';
import 'package:toastification/toastification.dart';

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
  bool _loading = false;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _usernameError;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    if (_loading) return;

    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final username = _usernameController.text.trim();

    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _usernameError = null;
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

    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = "Confirm password is required";
      });
      return;
    }

    if (username.isEmpty) {
      setState(() {
        _usernameError = "Username is required";
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

    if (password.length < 6) {
      setState(() {
        _passwordError = "Password must be at least 6 characters";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _confirmPasswordError = "Passwords do not match";
      });
      return;
    }

    if (username.length < 3) {
      setState(() {
        _usernameError = "Username must be at least 3 characters";
      });
      return;
    }

    setState(() => _loading = true);

    await Future.delayed(const Duration(seconds: 1));

    try {
      await ref.read(authProvider).register(
            email: email,
            password: password,
            username: username,
          );

      final uid = ref.read(authProvider).uid;

      if (uid != null) {
        await ref.read(userProvider).getUserById(uid);
      }

      if (!mounted) return;

      toastification.show(
        type: ToastificationType.success,
        context: context,
        title: const Text(
          'Registration successful\nWelcome!',
          style: TextStyle(fontFamily: 'PlusJakartaSans'),
        ),
        autoCloseDuration: const Duration(seconds: 3),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        if (e.code == 'email-already-in-use') {
          _emailError = "Email already in use";
        } else if (e.code == 'invalid-email') {
          _emailError = "Invalid email";
        } else if (e.code == 'weak-password') {
          _passwordError = "Password too weak";
        } else {
          _emailError = "Registration failed";
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
    _confirmPasswordController.dispose();
    _usernameController.dispose();
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
        )),
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
                        padding: const EdgeInsets.fromLTRB(45, 15, 45, 35),
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
                                  onChanged: (value) {
                                    if (_emailError != null) {
                                      setState(() {
                                        _emailError = null;
                                      });
                                    }
                                  },
                                  decoration: const InputDecoration(
                                      hintText: "Email",
                                      border: InputBorder.none),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
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
                                obscureText: _obscurePassword,
                                autocorrect: false,
                                enableSuggestions: false,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
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
                                onChanged: (value) {
                                  if (_confirmPasswordError != null) {
                                    setState(() {
                                      _confirmPasswordError = null;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "Confirm Password",
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: _obscureConfirmPassword,
                                autocorrect: false,
                                enableSuggestions: false,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            if (_confirmPasswordError != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 20, top: 5),
                                    child: Text(
                                      _confirmPasswordError!,
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
                                  controller: _usernameController,
                                  decoration: const InputDecoration(
                                    hintText: "Username",
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    if (_usernameError != null) {
                                      setState(() {
                                        _usernameError = null;
                                      });
                                    }
                                  },
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _register(),
                                )),
                            if (_usernameError != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 20, top: 5),
                                    child: Text(
                                      _usernameError!,
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
                                onTap: _register,
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
                                            "Sign Up",
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
