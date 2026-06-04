import 'dart:io';
import 'dart:ui';

import 'package:chat_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  String? _error;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      String? imageUrl;

      if (_selectedImage != null) {
        imageUrl = await _authService.uploadProfileImage(_selectedImage!.path);
      }

      final res = await _authService.register(
        _name.text.trim(),
        _email.text.trim(),
        _password.text,
        profilePic: imageUrl,
      );

      if (res['success'] == true) {
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 550),
            transitionsBuilder: (_, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        setState(() {
          _error = res['message'] ?? "Register failed";
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget buildGlow({
    required double top,
    required double left,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 100,
              spreadRadius: 12,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff0F172A),
                  Color(0xff111827),
                  Color(0xff1E1B4B),
                ],
              ),
            ),
          ),

          buildGlow(top: -60, left: -50, size: 220, color: Colors.deepPurple),

          buildGlow(top: 500, left: 260, size: 180, color: Colors.blue),

          buildGlow(top: 220, left: 280, size: 140, color: Colors.pinkAccent),

          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 20,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: Colors.white.withOpacity(0.06),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xff8B5CF6),
                                            Color(0xff6366F1),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.deepPurple
                                                .withOpacity(0.45),
                                            blurRadius: 25,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 42,
                                        backgroundColor: const Color(
                                          0xff111827,
                                        ),
                                        backgroundImage: _selectedImage != null
                                            ? FileImage(
                                                File(_selectedImage!.path),
                                              )
                                            : null,
                                        child: _selectedImage == null
                                            ? const Icon(
                                                Icons.person,
                                                size: 40,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ),

                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.deepPurple,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 28),

                               Text(
                                "Create Account",
                                style: GoogleFonts.lobster(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 28,
                                  color: Colors.white,
                                ),

                              ),

                              const SizedBox(height: 10),

                              Text(
                                "Create your account and\nstart chatting instantly",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lobster(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.white.withOpacity(0.65),
                                ),

                              ),

                              const SizedBox(height: 30),

                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                              CustomTextField.buildTextField(
                                controller: _name,
                                hint: "Full Name",
                                icon: Icons.person_outline,
                              ),

                              const SizedBox(height: 18),

                              CustomTextField.buildTextField(
                                controller: _email,
                                hint: "Email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 18),

                              CustomTextField.buildTextField(
                                controller: _password,
                                hint: "Password",
                                icon: Icons.lock_outline,
                                obscure: true,
                              ),

                              const SizedBox(height: 28),

                              _loading
                                  ? const CircularProgressIndicator()
                                  : SizedBox(
                                      width: double.infinity,
                                      height: 58,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xff7C3AED,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                        ),
                                        onPressed: _register,
                                        child: Text(
                                          "Register",
                                          style: GoogleFonts.lobster(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),

                                        ),
                                      ),
                                    ),

                              const SizedBox(height: 18),

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Already have an account? Login",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
