import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Обо мне',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4361EE), Color(0xFF3F37C9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF4361EE),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Terentii Iulian',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Full-Stack Developer',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF6C757D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // About section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Обо мне',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Я опытный разработчик с более чем 5-летним опытом в создании веб и мобильных приложений. Специализируюсь на разработке полного цикла, от бэкенда до фронтенда и мобильных приложений.',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF212529),
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Skills section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Навыки',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildSkillTag('JavaScript'),
                          _buildSkillTag('TypeScript'),
                          _buildSkillTag('React'),
                          _buildSkillTag('Node.js'),
                          _buildSkillTag('Go'),
                          _buildSkillTag('Flutter'),
                          _buildSkillTag('Dart'),
                          _buildSkillTag('Python'),
                          _buildSkillTag('ESP32'),
                          _buildSkillTag('IoT'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Contact section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Контакты',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildContactItem(
                        context,
                        Icons.language,
                        'Веб-сайт',
                        'sinkdev.dev',
                        'https://sinkdev.dev/',
                      ),
                      const SizedBox(height: 12),
                      _buildContactItem(
                        context,
                        Icons.code,
                        'GitHub',
                        'yuliitezarygml',
                        'https://github.com/yuliitezarygml',
                      ),
                      const SizedBox(height: 12),
                      _buildContactItem(
                        context,
                        Icons.email,
                        'Email',
                        'terentii.iulian@gmail.com',
                        'mailto:terentii.iulian@gmail.com',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Projects section
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Проекты',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProjectItem(
                        'Умный дом',
                        'Система умного дома с управлением реле и светодиодами через веб и мобильное приложение.',
                      ),
                      const SizedBox(height: 16),
                      _buildProjectItem(
                        'Мобильные приложения',
                        'Разработка кроссплатформенных мобильных приложений с использованием Flutter.',
                      ),
                      const SizedBox(height: 16),
                      _buildProjectItem(
                        'Веб-приложения',
                        'Создание современных веб-приложений с использованием React и Node.js.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillTag(String skill) {
    return Chip(
      label: Text(
        skill,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF4361EE),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String url,
  ) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunch(uri.toString())) {
          await launch(uri.toString());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Не удалось открыть ссылку: $url'),
            ),
          );
        }
      },
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF4361EE),
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF212529),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF6C757D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF212529),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: const Color(0xFF212529),
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
