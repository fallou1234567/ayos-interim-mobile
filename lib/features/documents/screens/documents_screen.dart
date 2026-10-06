import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            16,
            18,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),

              const SizedBox(height: 25),

              const Text(
                'DOSSIER ADMINISTRATIF',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Mes documents',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Transmettez vos fichiers en toute sécurité. AYOS contrôle les dates, valide les pièces et gère l’activation du profil.',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 18),

              _verificationCard(),

              const SizedBox(height: 10),

              _documentCard(
                icon: Icons.description_outlined,
                title: 'Pièce d’identité',
                date: '12 mars 2029',
                status: 'Valide',
                statusColor: AppColors.green,
              ),

              const SizedBox(height: 8),

              _documentCard(
                icon: Icons.description_outlined,
                title: 'Carte Vitale',
                date: 'À jour',
                status: 'Vérifié',
                statusColor: AppColors.green,
              ),

              const SizedBox(height: 8),

              _documentCard(
                icon: Icons.description_outlined,
                title: 'RIB',
                date: 'À jour',
                status: 'Vérifié',
                statusColor: AppColors.green,
              ),

              const SizedBox(height: 8),

              _documentCard(
                icon: Icons.description_outlined,
                title: 'Titre de séjour',
                date: 'Expire dans 10 jours',
                status: 'Expire bientôt',
                statusColor: AppColors.orange,
                warning: true,
              ),

              const SizedBox(height: 20),

              _confidentialityCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Image.asset(
          'assets/images/logo2.png',
          width: 70,
        ),

        const Spacer(),

        _headerIcon(Icons.wb_sunny_outlined),
        const SizedBox(width: 8),
        _headerIcon(Icons.notifications_none),

        const SizedBox(width: 8),

        const CircleAvatar(
          radius: 19,
          backgroundColor: AppColors.navy,
          child: Text(
            'FD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _verificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: AppColors.orange,
                size: 16,
              ),

              SizedBox(width: 8),

              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    '3 documents vérifiés sur 4',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 3),

                  Text(
                    'Votre dossier presque complet.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.75,
              minHeight: 4,
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation(
                AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentCard({
    required IconData icon,
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    bool warning = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: warning
                  ? const Color(0xFFFFF2DC)
                  : AppColors.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 16,
              color: warning
                  ? AppColors.orange
                  : AppColors.navy,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          Text(
            status,
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),

          const SizedBox(width: 6),

          const Icon(
            Icons.chevron_right,
            size: 17,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _confidentialityCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF4DDB5),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 16,
            color: AppColors.orange,
          ),

          SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Vos données restent confidentielles',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Vous transmettez vos pièces ; seule l’équipe AYOS renseigne les échéances, les vérifie et réactive un profil bloqué.',
                  style: TextStyle(
                    fontSize: 7,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Icon(
        icon,
        size: 17,
        color: AppColors.textSecondary,
      ),
    );
  }
}