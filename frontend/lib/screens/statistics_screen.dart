// REMPLACEZ TOUT LE FICHIER PAR :
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/patient_provider.dart';
import '../providers/medical_record_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'month';

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    final recordProvider = Provider.of<MedicalRecordProvider>(context);
    
    final totalPatients = patientProvider.patients.length;
    final totalRecords = recordProvider.records.length;
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques médicales'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Métriques clés
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMetricCard('Patients', totalPatients.toString(), Icons.people, Colors.blue),
                _buildMetricCard('Dossiers', totalRecords.toString(), Icons.folder, Colors.green),
                _buildMetricCard('Consultations', '12', Icons.medical_services, Colors.orange),
                _buildMetricCard('Aujourd\'hui', '3', Icons.today, Colors.purple),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Graphique simple (sans charts_flutter)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activité récente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSimpleBarChart(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Détails
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Détails',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Patients actifs', '${totalPatients}'),
                    _buildDetailRow('Dossiers créés', '${totalRecords}'),
                    _buildDetailRow('Consultations/mois', '12'),
                    _buildDetailRow('Taux de remplissage', '85%'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSimpleBarChart() {
    // Données fictives pour 7 jours
    final data = [
      {'day': 'Lun', 'value': 5},
      {'day': 'Mar', 'value': 3},
      {'day': 'Mer', 'value': 7},
      {'day': 'Jeu', 'value': 4},
      {'day': 'Ven', 'value': 6},
      {'day': 'Sam', 'value': 2},
      {'day': 'Dim', 'value': 1},
    ];
    
    final maxValue = data.map((d) => d['value'] as int).reduce((a, b) => a > b ? a : b);
    
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: data.map((item) {
              final value = item['value'] as int;
              final height = (value / maxValue) * 100;
              
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 30,
                    height: height,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Text(
                    item['day'].toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    value.toString(),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}