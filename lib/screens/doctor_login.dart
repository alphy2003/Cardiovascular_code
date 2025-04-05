import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'doctor_signup.dart';
import 'selection_page.dart'; // Import SelectionPage

class DoctorLoginPage extends StatefulWidget {
  @override
  _DoctorLoginPageState createState() => _DoctorLoginPageState();
}

class _DoctorLoginPageState extends State<DoctorLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SelectionPage()),
                        );
                      },
                    ),
                  ),
                  // Logo
                  Image.asset('assets/logoname.png', height: 120),
                  const SizedBox(height: 30),

                  // Email Field
                  _buildTextField(emailController, 'Email', Icons.email, false),
                  const SizedBox(height: 16),

                  // Password Field
                  _buildTextField(passwordController, 'Password', Icons.lock, true),
                  const SizedBox(height: 20),

                  // Error Message
                  if (errorMessage.isNotEmpty) _errorMessageWidget(),

                  // Login Button
                  _buildLoginButton(),

                  const SizedBox(height: 12),

                  // Forgot Password
                  TextButton(
                    onPressed: () {
                      // Handle Forgot Password
                    },
                    child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
                  ),

                  const SizedBox(height: 10),

                  // Don't have an account? Sign Up
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DoctorSignUpPage()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // **Reusable Widgets**
  Widget _buildTextField(
      TextEditingController controller, String hintText, IconData icon, bool isPassword) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _errorMessageWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.red, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () async {
        String? message = await authService.signIn(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        if (message == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SelectionPage()),
          );
        } else {
          setState(() {
            errorMessage = message;
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
      ),
      child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
    );
  }
}
