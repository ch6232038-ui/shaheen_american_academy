import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  Future<void> _openWhatsApp() async {
    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/923029207115',
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> _openEmail() async {
    final Uri emailUrl = Uri(
      scheme: 'mailto',
      path: 'ch6232038@gmail.com',
      query: 'subject=Shaheen American Academy Support',
    );

    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.support_agent,
              size: 90,
              color: Colors.blue,
            ),
            const SizedBox(height: 15),
            const Text(
              'How can we help you?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you have any problem or need help using '
              'Shaheen American Academy, please contact us.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 3,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.help_outline),
                ),
                title: const Text(
                  'Help',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: const Text(
                  'Get help about courses and lectures',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Help'),
                        content: const Text(
                          'You can select a course from the course list '
                          'and open its lectures. If you face any problem '
                          'while using the application, please contact '
                          'our support team.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 15),
            Card(
              elevation: 3,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.support_agent),
                ),
                title: const Text(
                  'Support',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: const Text(
                  'Contact our support team',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Contact Support',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ListTile(
                              leading: const Icon(
                                Icons.chat,
                                color: Colors.green,
                              ),
                              title: const Text('WhatsApp'),
                              subtitle: const Text(
                                '03029207115',
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _openWhatsApp();
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.email,
                                color: Colors.blue,
                              ),
                              title: const Text('Email'),
                              subtitle: const Text(
                                'ch6232038@gmail.com',
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _openEmail();
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Shaheen American Academy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'We are here to help you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
