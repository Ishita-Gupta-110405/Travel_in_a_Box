import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Offset _mousePos = const Offset(0, 0);
  int _imageIndex = 0;
  Timer? _timer;

  final List<String> _bgImages = [
    'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?q=80&w=2073',
    'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?q=80&w=2070',
    'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?q=80&w=2094',
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?q=80&w=2070',
    'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=2070',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() => _imageIndex = (_imageIndex + 1) % _bgImages.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MouseRegion(
        cursor: SystemMouseCursors.none,
        onHover: (event) => setState(() => _mousePos = event.localPosition),
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(seconds: 2),
              child: Image.network(
                _bgImages[_imageIndex],
                key: ValueKey<int>(_imageIndex),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, e, s) => Container(color: Colors.black),
              ),
            ),
            Container(color: Colors.black.withOpacity(0.5)),
            CustomPaint(
              size: Size.infinite,
              painter: LaserBeamPainter(_mousePos),
            ),
            _buildLaserGlow(),
            // Diagnostic Widget
            Builder(
                builder: (context) {
                  return Image.asset(
                    'assets/logo.png',
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        "Error: $error", // This will tell us the exact reason it failed
                        style: TextStyle(color: Colors.red, fontSize: 10),
                      );
                    },
                  );
                }
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("TRAVEL IN A BOX",
                              style: GoogleFonts.monoton(color: Colors.white, fontSize: 28, letterSpacing: 2)
                          ),
                          const SizedBox(height: 10),
                          const Text("Sign in to your luxury escape",
                              style: TextStyle(color: Color(0xFF4FC3F7), fontWeight: FontWeight.bold)
                          ),
                          const SizedBox(height: 40),
                          _buildTextField(_emailController, "Email", Icons.email_outlined, false),
                          const SizedBox(height: 20),
                          _buildTextField(_passwordController, "Password", Icons.lock_outline, true),
                          const SizedBox(height: 30),
                          _isLoading
                              ? const CircularProgressIndicator(color: Color(0xFF4FC3F7))
                              : _buildLoginButton(),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                  "New traveler?",
                                  style: TextStyle(color: Colors.white70, fontSize: 14)
                              ),
                              TextButton(
                                onPressed: () {
                                  // FIXED: Navigate to Register page instead of logging in here
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: const Text(
                                    "REGISTER NOW",
                                    style: TextStyle(
                                        color: Color(0xFF4FC3F7),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1
                                    )
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaserGlow() {
    return Positioned(
      left: _mousePos.dx - 100,
      top: _mousePos.dy - 100,
      child: IgnorePointer(
        child: Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                    colors: [Color(0x664FC3F7), Colors.transparent]
                )
            )
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPass) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFF4FC3F7)),
        filled: true,
        fillColor: Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3F7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () async {
          setState(() => _isLoading = true);
          try {
            await AuthService().signInWithEmailPassword(
                _emailController.text.trim(),
                _passwordController.text.trim()
            );
            if (mounted) Navigator.pushReplacementNamed(context, '/main');
          } catch (e) {
            String errorMsg = e.toString().toLowerCase();
            String displayMsg = "Login failed.";
            if (errorMsg.contains('invalid-credential')) displayMsg = "Invalid email or password.";

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(displayMsg)));
            }
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        },
        child: const Text("UNBOX ADVENTURE",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 1.5)
        ),
      ),
    );
  }
}

class LaserBeamPainter extends CustomPainter {
  final Offset mousePos;
  LaserBeamPainter(this.mousePos);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x884FC3F7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawLine(Offset(size.width, 0), mousePos, paint);

    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(size.width, 0), mousePos, innerPaint);
  }

  @override
  bool shouldRepaint(LaserBeamPainter oldDelegate) => oldDelegate.mousePos != mousePos;
}