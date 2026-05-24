import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String error = '';
  bool loading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Join SpendWise to manage your money better',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                  onChanged: (val) => setState(() => name = val),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val!.isEmpty) return 'Enter an email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                  onChanged: (val) => setState(() => email = val),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) => val!.length < 6 ? 'Password must be 6+ chars' : null,
                  onChanged: (val) => setState(() => password = val),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  obscureText: _obscurePassword,
                  decoration: const InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_reset, color: AppTheme.primaryColor),
                  ),
                  validator: (val) => val != password ? 'Passwords do not match' : null,
                  onChanged: (val) => setState(() => confirmPassword = val),
                ),
                const SizedBox(height: 40),
                if (loading)
                  const CircularProgressIndicator(color: AppTheme.primaryColor)
                else
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                          error = '';
                        });
                        String? result = await _auth.register(name, email, password);
                        if (result != null) {
                          setState(() {
                            error = result;
                            loading = false;
                          });
                        } else {
                          if (mounted) Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text('Create Account'),
                  ),
                if (error.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error,
                      style: const TextStyle(color: AppTheme.errorColor, fontSize: 14.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
