import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          padding: const EdgeInsets.all(40.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hubungi Kami',
                  style: textTheme.displayLarge,
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContactInfo(
                            context,
                            icon: Icons.location_on,
                            title: 'Alamat Kami',
                            details:
                                'Jl. Kebudayaan No. 123, Jakarta Pusat,\nIndonesia, 10110',
                          ),
                          const SizedBox(height: 24),
                          _buildContactInfo(
                            context,
                            icon: Icons.phone,
                            title: 'Telepon',
                            details: '+62 21 1234 5678',
                          ),
                          const SizedBox(height: 24),
                          _buildContactInfo(
                            context,
                            icon: Icons.email,
                            title: 'Email',
                            details: 'info@lontarfoundation.org',
                          ),
                           const SizedBox(height: 24),
                          _buildContactInfo(
                            context,
                            icon: Icons.access_time,
                            title: 'Jam Operasional',
                            details: 'Senin - Jumat: 09:00 - 17:00 WIB',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lokasi Lontar Foundation', style: textTheme.titleLarge),
                          const SizedBox(height: 12),
                          Container(
                            height: 400,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(25),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: const Center(
                              child: SizedBox(
                                width: double.infinity,
                                height: 400,
                                child: HtmlElementView(
                                  viewType: 'google-maps-lontar',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, {required IconData icon, required String title, required String details}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(details, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
} 