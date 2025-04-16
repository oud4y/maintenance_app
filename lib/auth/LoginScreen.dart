import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maintenance_app/helper/helper_function.dart';
import 'package:maintenance_app/auth/SignupScreen.dart';
import 'package:maintenance_app/screens/DashboardScreen.dart';
import 'package:maintenance_app/service/Database_service.dart';
import 'package:maintenance_app/service/auth_service.dart';
import 'package:maintenance_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import '../screens/forgotPassword.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black45.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(10.0),
              ),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
              ),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFC107),
                      ),
                    ),
                    Text(
                      'welcome back !',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFFFFF8DC),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),

      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor),
      )
          : Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: Colors.white,
          ),
          SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 120,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          decoration: textInputDecoration.copyWith(
                            hintText: "Email...",
                            suffixIcon: const Icon(Icons.email_outlined,
                                color: Colors.black12),
                          ),
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                          validator: (val) {
                            return RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(val!)
                                ? null
                                : "Please enter a valid email";
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45.withOpacity(0.3),
                            spreadRadius: 3,
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        obscureText: true,
                        decoration: textInputDecoration.copyWith(
                          hintText: "Password...",
                          suffixIcon: const Icon(Icons.lock_outline,
                              color: Colors.black12),
                        ),
                        onChanged: (val) {
                          setState(() {
                            password = val;
                          });
                        },
                        validator: (val) {
                          if (val!.length < 6) {
                            return "Password must be at least 6 characters";
                          } else {
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Text.rich(
                          TextSpan(
                            text: "Forgot Password",
                            style: GoogleFonts.robotoCondensed(
                              textStyle: const TextStyle(
                                color: Color(0xFFFFC107),
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => nextScreen(
                                  context, const ForgotPasswordPage()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    child: GestureDetector(
                      onTap: login,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFF1976D2),
                            borderRadius: BorderRadius.circular(30)),
                        child: Center(
                            child: Text(
                              "Log in",
                              style: GoogleFonts.robotoCondensed(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 21,
                              ),
                            )),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account ? ",
                        style: GoogleFonts.robotoCondensed(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 21),
                      ),
                      Text.rich(
                        // Wrap TextSpan in Text.rich
                        TextSpan(
                          text: "Register here",
                          style: GoogleFonts.robotoCondensed(
                            textStyle: const TextStyle(
                              color: Color(0xFF1976D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 21,
                            ),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () =>
                                nextScreen(context, const SignupPage()),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      print("Form validated");
      setState(() {
        _isLoading = true;
      });

      try {
        print("Calling authService.loginWithUserNameandPassword");
        dynamic result = await authService.loginWithUserNameandPassword(email, password);

        if (result is User) {
          print("Login successful");
          QuerySnapshot snapshot = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
              .gettingUserData(email);

          print("User data fetched: ${snapshot.docs[0]['userName']}");
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(snapshot.docs[0]['userName']);
          await HelperFunctions.saveUserIdSF(snapshot.docs[0]['uid']);
          if (!mounted) return;
          nextScreenRemove(context, DashboardScreen());
        } else {
          print("Login failed: $result");
          showSnackbar(context, Colors.red, result);
        }
      } catch (e) {
        print("Error during login: $e");
        showSnackbar(context, Colors.red, "An error occurred: $e");
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      print("Form validation failed");
    }
  }
}
