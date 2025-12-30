import 'package:flutter/material.dart';
import 'package:smart_hydroponic/pages/auth/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
                  const SizedBox(height: 30,),
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
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Email",
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
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Password",
                      ),
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
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                      ),
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
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Username",
                        ),
                      )),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()));
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
