import 'package:flutter/material.dart';
import 'package:test_app/page/loginpage.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Custom Grid Layout 
              Center(
                child: SizedBox(
                  width: 280,
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      // 1. Kotak Kiri Atas 
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F1E3A),
                          shape: BoxShape.circle,
                        ),
                      ),

                      // 2. Kotak Kanan Atas (Daun Ungu)
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E2F4F),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(80),
                            bottomLeft: Radius.circular(80),
                          ),
                        ),
                      ),

                      // 3. Kotak Kiri Tengah 
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          0,
                        ), // Persegi sesuai desain
                        child: Image.asset(
                          'asset/logo.png', 
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),

                      // 4. Kotak Kanan Tengah 
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFA7B6C0),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(80),
                            bottomRight: Radius.circular(80),
                          ),
                        ),
                      ),

                      // 5. Kotak Kiri Bawah 
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E2F4F),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(80),
                            bottomRight: Radius.circular(80),
                          ),
                        ),
                      ),

                      // 6. Kotak Kanan Bawah 
                      Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 99, 130, 151),
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(80),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Judul terpusat dengan gradasi 
              Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Fi',
                          style: TextStyle(color: Color(0xFF333333)),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) =>
                                const LinearGradient(
                                  colors: [
                                    Color(0xFF0F1E3A),
                                    Color(0xFF1E2F4F),
                                    Color(0xFFA7B6C0),
                                    Color(0xFFFFFFFF),
                                  ],
                                ).createShader(
                                  Rect.fromLTWH(
                                    0,
                                    0,
                                    bounds.width,
                                    bounds.height,
                                  ),
                                ),
                            child: const Text(
                              'Blog',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
