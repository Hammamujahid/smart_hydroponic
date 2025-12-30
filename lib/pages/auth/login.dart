import 'package:flutter/material.dart';
import 'package:smart_hydroponic/bottom_bar.dart';
import 'package:smart_hydroponic/pages/auth/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: const Color(0xFF41877F),
        body: Column(
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
              padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 45),
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
                      padding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      width: screenWidth,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Email",
                        ),
                      )),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    width: screenWidth,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Password",
                      ),
                      obscureText: true,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => const BottomBar()));
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
                          "Login",
                          style: TextStyle(
                              fontFamily: "PlusJakartaSans",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF1F5F9)),
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
                                    builder: (context) => RegisterPage()));
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
        ));
  }
}
