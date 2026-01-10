import 'package:flutter/material.dart';
import 'package:iep_app/core/constans/colors.dart';
import 'package:iep_app/core/constans/fonts.dart';
import 'package:url_launcher/url_launcher.dart';

AppColorScheme colors = AppColors.light;

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: colors.secText)),
        title: Text(
          'Contact Us',
          style: AppTextStyles.size18weight5(colors.text),
        ),
        centerTitle: true,
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get in Touch',
                style: AppTextStyles.size26weight5(colors.text),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.call, color: colors.primary),
                title: Text(
                  'Phone:',
                  style: AppTextStyles.size16weight5(colors.text),
                ),
                subtitle: Text(
                  '+962 7 9000 1234',
                  style: AppTextStyles.size12weight4(colors.text),
                ),
              ),

              SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.mail, color: colors.primary),
                title: Text(
                  'Email:',
                  style: AppTextStyles.size16weight5(colors.text),
                ),
                subtitle: GestureDetector(
                  onTap: () => launchUrl(
                    Uri(scheme: 'mailto', path: 'info@iep-company.com'),
                  ),
                  child: Text(
                    'info@iep-company.com',
                    style: AppTextStyles.size12weight4(colors.blue),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.location_city, color: colors.primary),
                title: Text(
                  'Address:',
                  style: AppTextStyles.size16weight5(colors.text),
                ),
                subtitle: Text(
                  'Amman, Jordan - Abdali Boulevard',
                  style: AppTextStyles.size12weight4(colors.text),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 20),
              Text(
                'Follow Us',
                style: AppTextStyles.size16weight5(colors.text),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _socialIcon(
                    Icons.facebook,
                    'https://facebook.com/iepcompany',
                  ),
                  const SizedBox(width: 16),
                  _socialIcon(
                    Icons.camera_alt,
                    'https://instagram.com/iepcompany',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, String url) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(url)),
      child: CircleAvatar(
        backgroundColor: colors.primary,
        child: Icon(icon, color: colors.background),
      ),
    );
  }
}
