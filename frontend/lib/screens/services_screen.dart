import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medical_record.dart';
import '../providers/medical_record_provider.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});
  
  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicalRecordProvider>(context, listen: false).loadServices();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicalRecordProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services Hospitaliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddServiceDialog(context),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.services.isEmpty
              ? _buildEmptyServices()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: provider.services.length,
                  itemBuilder: (context, index) {
                    return _buildServiceCard(provider.services[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildServiceCard(HospitalService service) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _showServiceDetails(service),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icone du service
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getServiceColor(service.name).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getServiceIcon(service.name),
                  size: 30,
                  color: _getServiceColor(service.name),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Nom du service
              Text(
                service.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Localisation
              if (service.location.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        service.location,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              
              const Spacer(),
              
              // Téléphone
              if (service.phone.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      service.phone,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyServices() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.local_hospital,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun service hospitalier',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ajoutez les services de votre établissement',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _showAddServiceDialog(context),
            child: const Text('Ajouter un service'),
          ),
        ],
      ),
    );
  }
  
  IconData _getServiceIcon(String serviceName) {
    final name = serviceName.toLowerCase();
    
    if (name.contains('urgence') || name.contains('urgence')) {
      return Icons.local_hospital;
    } else if (name.contains('radiologie') || name.contains('scanner')) {
      return Icons.scanner;
    } else if (name.contains('laboratoire') || name.contains('analyse')) {
      return Icons.biotech;
    } else if (name.contains('chirurgie') || name.contains('opération')) {
      return Icons.medical_services;
    } else if (name.contains('pédiatrie') || name.contains('enfant')) {
      return Icons.child_care;
    } else if (name.contains('maternité') || name.contains('naissance')) {
      return Icons.family_restroom;
    } else if (name.contains('cardiaque') || name.contains('cœur')) {
      return Icons.favorite;
    } else if (name.contains('neurologie') || name.contains('cerveau')) {
      return Icons.psychology;
    } else {
      return Icons.medical_services;
    }
  }
  
  Color _getServiceColor(String serviceName) {
    final name = serviceName.toLowerCase();
    
    if (name.contains('urgence')) {
      return Colors.red;
    } else if (name.contains('radiologie')) {
      return Colors.blue;
    } else if (name.contains('laboratoire')) {
      return Colors.green;
    } else if (name.contains('chirurgie')) {
      return Colors.purple;
    } else if (name.contains('pédiatrie')) {
      return Colors.pink;
    } else if (name.contains('maternité')) {
      return Colors.orange;
    } else {
      return Colors.blueGrey;
    }
  }
  
  void _showServiceDetails(HospitalService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.8,
          minChildSize: 0.4,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // En-tête
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getServiceColor(service.name).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            _getServiceIcon(service.name),
                            size: 35,
                            color: _getServiceColor(service.name),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (service.location.isNotEmpty)
                                Text(
                                  service.location,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 30),
                    
                    // Description
                    if (service.description.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DESCRIPTION',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(service.description),
                          const Divider(height: 30),
                        ],
                      ),
                    
                    // Contact
                    const Text(
                      'CONTACT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    if (service.phone.isNotEmpty)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.phone, color: Colors.grey),
                        title: const Text('Téléphone'),
                        subtitle: Text(service.phone),
                      ),
                    
                    if (service.location.isNotEmpty)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.location_on, color: Colors.grey),
                        title: const Text('Localisation'),
                        subtitle: Text(service.location),
                      ),
                    
                    const Divider(height: 30),
                    
                    // Statistiques (à implémenter)
                    const Text(
                      'STATISTIQUES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildServiceStat('Patients', '24'),
                        _buildServiceStat('RDV/jour', '8'),
                        _buildServiceStat('Capacité', '85%'),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('FERMER'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _showEditServiceDialog(service);
                            },
                            child: const Text('MODIFIER'),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildServiceStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  void _showAddServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final descriptionController = TextEditingController();
        final locationController = TextEditingController();
        final phoneController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Nouveau Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du service',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Localisation (bâtiment, étage)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone interne',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANNULER'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    await Provider.of<MedicalRecordProvider>(context, listen: false)
                        .createService({
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'location': locationController.text,
                      'phone': phoneController.text,
                    });
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Service ajouté avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('AJOUTER'),
            ),
          ],
        );
      },
    );
  }
  
  void _showEditServiceDialog(HospitalService service) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: service.name);
        final descriptionController = TextEditingController(text: service.description);
        final locationController = TextEditingController(text: service.location);
        final phoneController = TextEditingController(text: service.phone);
        
        return AlertDialog(
          title: const Text('Modifier le Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du service',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Localisation',
                    border: OutlineInputBorder(),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANNULER'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    await Provider.of<MedicalRecordProvider>(context, listen: false)
                        .updateService(service.id, {
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'location': locationController.text,
                      'phone': phoneController.text,
                    });
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Service modifié avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('MODIFIER'),
            ),
          ],
        );
      },
    );
  }
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final searchController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Rechercher un service'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Nom du service...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANNULER'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implémenter la recherche
                Navigator.pop(context);
              },
              child: const Text('RECHERCHER'),
            ),
          ],
        );
      },
    );
  }
}