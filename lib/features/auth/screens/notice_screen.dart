
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  bool _confirmed = false;

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Notice d’information',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.navy,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: AppColors.navy,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Notice d’information des salariés AYOSTAFF',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'AYOS-SOLUTIONS · Version 1.0 · '
                        '1er novembre 2026',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      _section(
                        '1. Qui traite vos données',
                        'AYOSTAFF est exploité par AYOS-SOLUTIONS. '
                        'Pour la gestion des comptes, des salariés et des '
                        'missions, AYOS-SOLUTIONS traite les données '
                        'personnelles nécessaires à son activité. Un hôtel '
                        'peut également être responsable des informations '
                        'qu’il saisit pour organiser ses missions. '
                        'Les rôles sont précisés dans les contrats applicables.\n\n'
                        'Contact : dev@ayos-solutions.net · '
                        '+33 7 66 58 49 98 · https://www.ayos-solutions.fr/',
                      ),

                      _section(
                        '2. Données utilisées',
                        'AYOSTAFF peut contenir vos coordonnées, votre '
                        'profil professionnel, vos expériences, qualifications, '
                        'compétences, disponibilités, justificatifs '
                        'administratifs, missions, horaires prévus et pointés, '
                        'corrections de pointage, évaluations, échanges de '
                        'service et traces de connexion ou d’actions '
                        'administratives.\n\n'
                        'Les documents administratifs peuvent inclure une '
                        'pièce d’identité, un RIB ou d’autres justificatifs '
                        'nécessaires. Leur accès est limité aux personnes '
                        'habilitées chez AYOS. Un hôtel ne consulte pas '
                        'automatiquement les copies de ces documents.',
                      ),

                      _section(
                        '3. Pourquoi ces données sont utilisées',
                        'Ces données servent à créer et sécuriser votre '
                        'compte, vérifier votre profil et les documents '
                        'obligatoires, organiser vos disponibilités, proposer '
                        'des missions adaptées, gérer leur acceptation et '
                        'leur réalisation, suivre et valider les heures, '
                        'traiter les signalements et corrections, gérer les '
                        'évaluations et respecter les obligations '
                        'administratives, sociales ou comptables.',
                      ),

                      _section(
                        '4. Fonctionnement des missions',
                        'Les principaux critères d’éligibilité sont la '
                        'correspondance entre le métier recherché et votre '
                        'profil, votre disponibilité et la validité des '
                        'documents requis. AYOS peut intervenir manuellement '
                        'sur les propositions et affectations.\n\n'
                        'Les notes attribuées par les hôtels ne vous empêchent '
                        'pas automatiquement de recevoir des missions. Un '
                        'document obligatoire manquant ou expiré peut vous '
                        'rendre temporairement inéligible aux missions '
                        'concernées. Le système aide à organiser les missions '
                        'mais ne prend pas seul de décision définitive sur '
                        'votre emploi.',
                      ),

                      _section(
                        '5. Pointage et corrections',
                        'L’application distingue les horaires prévus, les '
                        'heures que vous pointez et les heures validées. '
                        'Vous pouvez pointer à partir de cinq minutes avant '
                        'l’horaire prévu. Si vous avez réellement commencé '
                        'plus tôt, signalez-le à AYOS pour vérification et '
                        'régularisation. Signalez également toute erreur. '
                        'Une correction ne doit pas effacer l’heure initiale : '
                        'l’historique indique la modification, son auteur, '
                        'sa date et son motif.',
                      ),

                      _section(
                        '6. Qui peut consulter les données',
                        'Les personnes AYOS habilitées accèdent aux données '
                        'selon leurs fonctions. L’hôtel reçoit les informations '
                        'nécessaires à la préparation et au suivi de la mission. '
                        'Brevo transmet les courriels, SMS ou notifications '
                        'de service. AWS héberge l’application et les données '
                        'dans la région déclarée Paris (eu-west-3).\n\n'
                        'Les développeurs habilités d’AYOS-SOLUTIONS résidant '
                        'au Sénégal peuvent accéder à distance aux données '
                        'nécessaires à leurs fonctions techniques. Ces accès '
                        'sont limités aux besoins professionnels et tracés. '
                        'Les données restent hébergées en France.',
                      ),

                      _section(
                        '7. Sécurité',
                        'Les accès sont limités par compte et par rôle. '
                        'Les données des salariés et des hôtels sont séparées. '
                        'Les documents ne sont pas publics ; leur stockage et '
                        'leur téléchargement sont protégés. Les opérations '
                        'sensibles sont journalisées. Des sauvegardes protégées '
                        'sont réalisées et les mesures techniques sont '
                        'régulièrement vérifiées et mises à jour.',
                      ),

                      _section(
                        '8. Conservation',
                        'Les données sont conservées pendant la durée '
                        'nécessaire à la gestion du compte et des missions, '
                        'puis supprimées ou archivées à accès restreint si '
                        'une obligation légale ou la défense de droits le '
                        'justifie.\n\n'
                        'La notice indique notamment un an pour les documents '
                        'de comptabilisation des heures, cinq ans pour certains '
                        'documents sociaux et généralement dix ans pour les '
                        'pièces comptables. Les journaux de sécurité sont '
                        'généralement conservés de six mois à un an, sauf '
                        'justification particulière.',
                      ),

                      _section(
                        '9. Vos droits',
                        'Vous pouvez demander l’accès à vos données, leur '
                        'rectification, leur effacement lorsque celui-ci est '
                        'applicable, la limitation du traitement, vous opposer '
                        'à certains traitements ou demander la portabilité '
                        'lorsque les conditions sont remplies.\n\n'
                        'Contact : contact@ayos-solutions.net · '
                        '+33 7 66 58 49 98 · https://www.ayos-solutions.fr/\n\n'
                        'Vous pouvez également déposer une réclamation auprès '
                        'de la CNIL : https://www.cnil.fr/. Certains effacements '
                        'peuvent être limités par des obligations légales.',
                      ),

                      _section(
                        '10. Réclamation, incident et mises à jour',
                        'En cas d’erreur, d’accès inhabituel ou de problème '
                        'de confidentialité, prévenez rapidement '
                        'dev@ayos-solutions.net.\n\n'
                        'La version et la date de la notice sont indiquées '
                        'dans AYOSTAFF. AYOS-SOLUTIONS vous informera des '
                        'changements importants selon les modalités adaptées.',
                      ),

                      const Text(
                        'AYOSTAFF · AYOS-SOLUTIONS',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: _confirmed,
                      onChanged: (value) {
                        setState(() {
                          _confirmed = value ?? false;
                        });
                      },
                      activeColor: AppColors.navy,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Je confirme avoir lu et compris la notice '
                        'd’information.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirmed
                            ? () => Navigator.of(context).pop(true)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor:
                              AppColors.navy.withValues(alpha: 0.35),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('Continuer'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
