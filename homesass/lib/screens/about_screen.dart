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
          'About Me',
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
                        'About Me',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'I am an experienced developer with over 5 years of experience in creating web and mobile applications. I specialize in full-cycle development, from backend to frontend and mobile applications.',
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
                        'Skills',
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
                        'Contacts',
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
                        'Website',
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
                        'Projects',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF212529),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProjectItem(
                        'Smart Home',
                        'Smart home system with relay and LED control via web and mobile application.',
                      ),
                      const SizedBox(height: 16),
                      _buildProjectItem(
                        'Mobile Applications',
                        'Cross-platform mobile application development using Flutter.',
                      ),
                      const SizedBox(height: 16),
                      _buildProjectItem(
                        'Web Applications',
                        'Creating modern web applications using React and Node.js.',
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
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open link: $url'),
              ),
            );
          }
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
