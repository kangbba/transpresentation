import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement signup logic
              },
              child: Text('Sign up'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // TODO: Implement Google login logic
              },
              child: Text('Sign up with Google'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement Facebook login logic
              },
              child: Text('Sign up with Facebook'),
            ),
            TextButton(
              onPressed: () {
                // Switch to the Login screen
                Navigator.pop(context);
              },
              child: Text('Already have an account? Log in.'),
            ),
          ],
        ),
      ),
    );
  }
}