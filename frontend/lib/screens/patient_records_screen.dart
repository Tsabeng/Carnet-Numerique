import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medical_record.dart';
import '../providers/medical_record_provider.dart';

class PatientRecordsScreen extends StatelessWidget {
  final String patientId;
  final String patientName;
  final String? doctorId;
  
  const PatientRecordsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
    this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    final recordProvider = Provider.of<MedicalRecordProvider>(context);
    final records = recordProvider.getRecordsByPatientId(patientId);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Dossier de $patientName'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
         IconButton(
  icon: const Icon(Icons.add),
  onPressed: () {
    Navigator.pushNamed(
      context,
      '/create-record',
      arguments: {'patientId': patientId},
    );
  },
),
        ],
      ),
      body: records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.medical_services,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucun dossier médical',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pour $patientName',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                 ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(
      context,
      '/create-record',
      arguments: {'patientId': patientId},
    );
  },
  child: const Text('Créer le premier dossier'),
),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ExpansionTile(
                    leading: _getVisitTypeIcon(record.visitType),
                    title: Text(
                      record.visitType,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(record.formattedDate),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Service:', 'Service ${record.serviceId}'),
                            _buildInfoRow('Médecin:', record.doctorName),
                            const SizedBox(height: 10),
                            _buildSectionTitle('Symptômes'),
                            Text(record.symptoms),
                            const SizedBox(height: 10),
                            _buildSectionTitle('Diagnostic'),
                            Text(record.diagnosis),
                            const SizedBox(height: 10),
                            if (record.treatment.isNotEmpty) ...[
                              _buildSectionTitle('Traitement'),
                              Text(record.treatment),
                              const SizedBox(height: 10),
                            ],
                            if (record.prescription.isNotEmpty) ...[
                              _buildSectionTitle('Prescription'),
                              Text(record.prescription),
                              const SizedBox(height: 10),
                            ],
                            if (record.testResults.isNotEmpty) ...[
                              _buildSectionTitle('Tests médicaux'),
                              ...record.testResults.map((test) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: Text('• ${test['name']}:')),
                                      const SizedBox(width: 10),
                                      Text('${test['result']} ${test['unit'] ?? ''}'),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 10),
                            ],
                            if (record.notes.isNotEmpty) ...[
                              _buildSectionTitle('Notes'),
                              Text(record.notes),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.blue,
      ),
    );
  }
  
  Icon _getVisitTypeIcon(String visitType) {
    switch (visitType) {
      case 'EMERGENCY':
        return const Icon(Icons.local_hospital, color: Colors.red);
      case 'HOSPITALIZATION':
        return const Icon(Icons.hotel, color: Colors.orange);
      case 'FOLLOW_UP':
        return const Icon(Icons.update, color: Colors.green);
      default: // CONSULTATION
        return const Icon(Icons.medical_services, color: Colors.blue);
    }
  }
}