import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import 'patient_records_screen.dart';

class PatientSearchScreen extends StatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  State<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    
    final filteredPatients = _searchQuery.isEmpty
        ? patientProvider.patients
        : patientProvider.patients.where((patient) {
            return patient.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   patient.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   (patient.phoneNumber?.contains(_searchQuery) ?? false);
          }).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher un patient'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nom, ID patient ou téléphone...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          
          // Liste des patients
          Expanded(
            child: filteredPatients.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 20),
                        Text(
                          'Aucun patient trouvé',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = filteredPatients[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            patient.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ID: ${patient.id}'),
                              if (patient.birthDate != null)
                                Text('Né le: ${patient.birthDate}'),
                              if (patient.bloodType != null)
                                Text('Groupe: ${patient.bloodType}'),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientRecordsScreen(
                                  patientId: patient.id,
                                  patientName: patient.fullName,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Ajouter un nouveau patient
          _showAddPatientDialog(context);
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
  
  void _showAddPatientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouveau patient'),
          content: const Text('Cette fonctionnalité sera bientôt disponible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}