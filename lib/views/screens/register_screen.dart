import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  Offset _mousePos = const Offset(0, 0);
  int _imageIndex = 0;
  Timer? _timer;

  final List<String> _bgImages = [
    'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?q=80&w=2070', // Maldives
    'https://images.unsplash.com/photo-1537996194471-e657df975ab4?q=80&w=2070', // Bali
    'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?q=80&w=2094', // Tokyo
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) setState(() => _imageIndex = (_imageIndex + 1) % _bgImages.length);
    });
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
              child: Image.network(_bgImages[_imageIndex], key: ValueKey(_imageIndex), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
            Container(color: Colors.black.withOpacity(0.6)),

            // The laser glow point
            Positioned(
              left: _mousePos.dx - 100, top: _mousePos.dy - 100,
              child: IgnorePointer(child: Container(width: 200, height: 200, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0x664FC3F7), Colors.transparent])))),
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
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.2))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("JOIN THE CLUB", style: GoogleFonts.monoton(color: Colors.white, fontSize: 28)),
                          const SizedBox(height: 30),
                          _buildField(_emailController, "Email", Icons.email_outlined, false),
                          const SizedBox(height: 20),
                          _buildField(_passwordController, "Password", Icons.lock_outline, true),
                          const SizedBox(height: 20),
                          _buildField(_confirmController, "Confirm Password", Icons.verified_user_outlined, true),
                          const SizedBox(height: 30),
                          _isLoading ? const CircularProgressIndicator() : _buildRegButton(),
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("BACK TO LOGIN", style: TextStyle(color: Color(0xFF4FC3F7))))
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

  Widget _buildField(TextEditingController controller, String hint, IconData icon, bool pass) {
    return TextField(
      controller: controller, obscureText: pass, style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: const Color(0xFF4FC3F7)), filled: true, fillColor: Colors.black26, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    );
  }

  Widget _buildRegButton() {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4FC3F7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: () async {
          if (_passwordController.text != _confirmController.text) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords don't match!")));
            return;
          }
          setState(() => _isLoading = true);
          // Assuming your AuthService has a signUp method
          await AuthService().registerWithEmailPassword(_emailController.text, _passwordController.text);
          setState(() => _isLoading = false);
          if (mounted) Navigator.pop(context);
        },
        child: const Text("CREATE ACCOUNT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}