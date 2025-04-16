import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maintenance_app/screens/DashboardScreen.dart';
import 'package:maintenance_app/service/Database_service.dart';
import 'package:maintenance_app/service/auth_service.dart';
import 'package:maintenance_app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import '../auth/LoginScreen.dart';
import '../helper/helper_function.dart';
import 'changepassword.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();
  String userName = "";
  String email = "";
  String phoneNumber = "";
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });

    DatabaseService dbService = DatabaseService();
    QuerySnapshot userSnap = await dbService.gettingUserData(email);
    if (userSnap.docs.isNotEmpty) {
      var userDoc = userSnap.docs[0];

      setState(() {
        userName = userDoc['userName'];
        phoneNumber = userDoc['phoneNumber'] ?? '';

        userNameController.text = userName;
        emailController.text = email;
        phoneNumberController.text = phoneNumber;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      DatabaseService dbService = DatabaseService();
      QuerySnapshot userSnap = await dbService.gettingUserData(email);
      if (userSnap.docs.isNotEmpty) {
        var userDoc = userSnap.docs[0];
        await dbService.userCollection.doc(userDoc.id).update({
          'userName': userName,
          'phoneNumber': phoneNumber,
        });

        await HelperFunctions.saveUserNameSF(userName);
        showSnackbar(context, Colors.green, 'Profile updated successfully');
        nextScreen(context, DashboardScreen());
      }
    }
  }

  Future<void> _loginout() async {
    await authService.signOut(context);
    nextScreenRemove(context, const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1976D2),
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        controller: userNameController,
                        decoration: textInputDecoration.copyWith(
                          hintText: "Username",
                          suffixIcon: const Icon(Icons.account_box_rounded, color: Colors.black12),
                        ),
                        onChanged: (val) {
                          setState(() {
                            userName = val;
                          });
                        },
                        validator: (val) {
                          if (val!.isNotEmpty) {
                            return null;
                          } else {
                            return "Username cannot be empty";
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        controller: emailController,
                        decoration: textInputDecoration.copyWith(
                          hintText: "Email...",
                          suffixIcon: const Icon(Icons.email_outlined, color: Colors.black12),
                        ),
                        onChanged: (val) {
                          setState(() {
                            email = val;
                          });
                        },
                        validator: (val) {
                          return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(val!)
                              ? null
                              : "Please enter a valid email";
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                        controller: phoneNumberController,
                        decoration: textInputDecoration.copyWith(
                          hintText: "Phone Number",
                          suffixIcon: const Icon(Icons.phone_android_rounded, color: Colors.black12),
                        ),
                        onChanged: (val) {
                          setState(() {
                            phoneNumber = val;
                          });
                        },
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return 'Please enter only digits';
                            }
                            if (value.length != 8) {
                              return 'Phone number must be 8 digits long';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save Profile', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1976D2), // Change button color to black
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    nextScreen(context, const ChangePasswordPage());
                  },
                  child: const Text('Change Password', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1976D2), // Change button color to black
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loginout,
                  child: const Text('Logout', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1976D2), // Change button color to black
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
