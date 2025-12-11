import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_provider.dart';
import 'medical_records_screen.dart';
import 'create_record_screen.dart';
import '../models/patient.dart';

class PatientManagementScreen extends StatefulWidget {
  const PatientManagementScreen({super.key});

  @override
  State<PatientManagementScreen> createState() => _PatientManagementScreenState();
}

class _PatientManagementScreenState extends State<PatientManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    
    final filteredPatients = _searchQuery.isEmpty
        ? patientProvider.patients
        : patientProvider.searchPatients(_searchQuery);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des patients'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddPatientDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un patient...',
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
          
          // Statistiques
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildStatChip('Total', patientProvider.patients.length.toString()),
                const SizedBox(width: 10),
                _buildStatChip('Recherche', filteredPatients.length.toString()),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterOptions,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Liste des patients
          Expanded(
            child: filteredPatients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Aucun patient trouvé',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                              child: const Text('Afficher tous les patients'),
                            ),
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
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              patient.fullName.substring(0, 1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          title: Text(
                            patient.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Code: ${patient.id}'),
                              if (patient.birthDate != null)
                                Text('Né le: ${patient.birthDate}'),
                              if (patient.bloodType != null)
                                Text('Groupe: ${patient.bloodType}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              _handlePatientAction(value, patient);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility, size: 20),
                                    SizedBox(width: 8),
                                    Text('Voir dossier'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'add_record',
                                child: Row(
                                  children: [
                                    Icon(Icons.add, size: 20),
                                    SizedBox(width: 8),
                                    Text('Nouveau dossier'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Modifier'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'contact',
                                child: Row(
                                  children: [
                                    Icon(Icons.phone, size: 20),
                                    SizedBox(width: 8),
                                    Text('Contacter'),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MedicalRecordsScreen(
                                  patientId: patient.id,
                                  patientName: patient.fullName,
                                  isDoctorView: true,
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
        onPressed: _showAddPatientDialog,
        child: const Icon(Icons.person_add),
      ),
    );
  }
  
  Widget _buildStatChip(String label, String value) {
    return Chip(
      backgroundColor: Colors.blue.shade50,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }
  
  void _handlePatientAction(String action, dynamic patient) {
    switch (action) {
      case 'view':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicalRecordsScreen(
              patientId: patient.id,
              patientName: patient.fullName,
              isDoctorView: true,
            ),
          ),
        );
        break;
      case 'add_record':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateRecordScreen(
              patientId: patient.id,
            ),
          ),
        );
        break;
      case 'edit':
        _showEditPatientDialog(patient);
        break;
      case 'contact':
        _showContactOptions(patient);
        break;
      case 'delete':
        _showDeleteConfirmation(patient);
        break;
    }
  }
  
  void _showAddPatientDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final idController = TextEditingController();
        final nameController = TextEditingController();
        final birthDateController = TextEditingController();
        final bloodTypeController = TextEditingController();
        final phoneController = TextEditingController();
        final emailController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Nouveau patient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Code patient',
                    border: OutlineInputBorder(),
                    hintText: 'PATxxx',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: birthDateController,
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance (JJ/MM/AAAA)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bloodTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Groupe sanguin',
                    border: OutlineInputBorder(),
                    hintText: 'A+, O-, etc.',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
  if (idController.text.isNotEmpty && nameController.text.isNotEmpty) {
    Provider.of<PatientProvider>(context, listen: false).addPatient(
      Patient( // <-- Maintenant Patient est reconnu
        id: idController.text.toUpperCase(),
        fullName: nameController.text,
        birthDate: birthDateController.text,
        bloodType: bloodTypeController.text,
        phoneNumber: phoneController.text,
        email: emailController.text,
      ),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Patient ajouté avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }
},
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
  
  void _showEditPatientDialog(dynamic patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier patient'),
        content: const Text('Cette fonctionnalité sera disponible prochainement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showContactOptions(dynamic patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contacter ${patient.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (patient.phoneNumber != null)
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Téléphoner'),
                subtitle: Text(patient.phoneNumber!),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Lancer l'appel téléphonique
                },
              ),
            if (patient.email != null)
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Envoyer un email'),
                subtitle: Text(patient.email!),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Ouvrir l'appli email
                },
              ),
            const ListTile(
              leading: Icon(Icons.message),
              title: Text('Envoyer un SMS'),
              subtitle: Text('Envoyer un message texte'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(dynamic patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${patient.fullName} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Provider.of<PatientProvider>(context, listen: false)
                  .deletePatient(patient.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${patient.fullName} a été supprimé'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _showFilterOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer les patients'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.filter_list),
              title: Text('Tous les patients'),
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Consultés récemment'),
            ),
            ListTile(
              leading: Icon(Icons.warning),
              title: Text('Avec allergies'),
            ),
            ListTile(
              leading: Icon(Icons.medication),
              title: Text('Sous traitement'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}