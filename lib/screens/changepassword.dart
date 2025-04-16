import 'package:maintenance_app/auth/LoginScreen.dart';
import 'package:maintenance_app/screens/ProfileScreen.dart';
import 'package:maintenance_app/service/auth_service.dart';
import 'package:maintenance_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String currentPassword = "";
  String newPassword = "";
  String confirmPassword = "";
  AuthService authService = AuthService();

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await authService.changePassword(currentPassword, newPassword);
        showSnackbar(context, Colors.green, 'Password changed successfully');
        await authService.signOut(context);
        nextScreenRemove(context, const LoginPage());
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'invalid-credential':
            errorMessage = 'The current password is incorrect. Please try again.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many requests. Please try again later.';
            break;
          default:
            errorMessage = 'An error occurred: ${e.message}';
        }
        showSnackbar(context, Colors.red, errorMessage);
      } catch (e) {
        showSnackbar(context, Colors.red, 'An error occurred: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1976D2), // Changed here
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPasswordField(
                  hint: "Current Password",
                  onChanged: (value) => setState(() => currentPassword = value),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter your Current password' : null,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  hint: "New Password",
                  onChanged: (value) => setState(() => newPassword = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your new password';
                    }
                    if (value.length < 6) {
                      return "New password must be at least 6 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  hint: "Confirm Password",
                  onChanged: (value) => setState(() => confirmPassword = value),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your confirm password';
                    }
                    if (value != newPassword) {
                      return 'Confirm passwords do not match the new password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2), // Changed here
                  ),
                  onPressed: _changePassword,
                  child: const Text(
                    'Change Password',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hint,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          obscureText: true,
          decoration: textInputDecoration.copyWith(
            hintText: hint,
            suffixIcon: const Icon(Icons.lock_outline, color: Colors.black12),
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }
}
