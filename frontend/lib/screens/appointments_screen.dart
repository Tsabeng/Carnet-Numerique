import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../providers/appointment_provider.dart';
import '../providers/patient_provider.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});
  
  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'day'; // 'day', 'week', 'month'
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProvider>(context, listen: false).fetchAppointments();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppointmentProvider>(context);
    final todayAppointments = provider.getAppointmentsForDate(_selectedDate);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rendez-vous'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showCalendarPicker,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateAppointmentDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête avec date
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeDate(-1),
                ),
                Column(
                  children: [
                    Text(
                      DateFormat('EEEE', 'fr_FR').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMMM yyyy', 'fr_FR').format(_selectedDate),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeDate(1),
                ),
              ],
            ),
          ),
          
          // Statistiques du jour
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', todayAppointments.length.toString(), Colors.blue),
                _buildStatCard('Confirmés', 
                  todayAppointments.where((a) => a.status == 'CONFIRMED').length.toString(), 
                  Colors.green),
                _buildStatCard('En attente', 
                  todayAppointments.where((a) => a.status == 'PENDING').length.toString(), 
                  Colors.orange),
              ],
            ),
          ),
          
          // Liste des rendez-vous
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : todayAppointments.isEmpty
                    ? _buildEmptyAppointments()
                    : ListView.builder(
                        itemCount: todayAppointments.length,
                        itemBuilder: (context, index) {
                          return _buildAppointmentCard(todayAppointments[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateAppointmentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec heure et statut
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('HH:mm').format(appointment.appointmentDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: appointment.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.statusText,
                    style: TextStyle(
                      color: appointment.statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Informations patient
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.patient.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Service
            Row(
              children: [
                const Icon(Icons.local_hospital, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  appointment.service.name,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Raison du RDV
            if (appointment.reason.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.note, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.reason,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 12),
            
            // Actions
            Row(
              children: [
                // Bouton confirmer
                if (appointment.status == 'PENDING')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateAppointmentStatus(appointment.id, 'CONFIRMED'),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Confirmer'),
                    ),
                  ),
                
                // Bouton annuler
                if (appointment.status != 'CANCELLED')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateAppointmentStatus(appointment.id, 'CANCELLED'),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Annuler'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                
                // Bouton détails
                IconButton(
                  onPressed: () => _showAppointmentDetails(appointment),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyAppointments() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun rendez-vous',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            'Pour le ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _showCreateAppointmentDialog(context),
            child: const Text('Planifier un rendez-vous'),
          ),
        ],
      ),
    );
  }
  
  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }
  
  void _showCalendarPicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        setState(() => _selectedDate = date);
      }
    });
  }
  
  void _showAppointmentDetails(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
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
                    
                    // Titre
                    Text(
                      'Rendez-vous - ${DateFormat('dd/MM/yyyy HH:mm').format(appointment.appointmentDate)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Statut
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: appointment.statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appointment.statusText,
                          style: TextStyle(
                            color: appointment.statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const Divider(height: 30),
                    
                    // Informations patient
                    const Text(
                      'PATIENT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person, color: Colors.grey),
                      title: Text(appointment.patient.fullName),
                      subtitle: Text('${appointment.patient.age} ans • ${appointment.patient.phoneNumber}'),
                    ),
                    
                    const Divider(height: 20),
                    
                    // Service
                    const Text(
                      'SERVICE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.local_hospital, color: Colors.grey),
                      title: Text(appointment.service.name),
                      subtitle: Text(appointment.service.location),
                    ),
                    
                    const Divider(height: 20),
                    
                    // Date et heure
                    const Text(
                      'DATE ET HEURE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today, color: Colors.grey),
                      title: Text(DateFormat('dd MMMM yyyy', 'fr_FR').format(appointment.appointmentDate)),
                      subtitle: Text(DateFormat('HH:mm').format(appointment.appointmentDate)),
                    ),
                    
                    // Raison
                    if (appointment.reason.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 20),
                          const Text(
                            'RAISON DU RENDEZ-VOUS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(appointment.reason),
                        ],
                      ),
                    
                    // Notes
                    if (appointment.notes.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(height: 20),
                          const Text(
                            'NOTES',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(appointment.notes),
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
                              _showEditAppointmentDialog(appointment);
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
  
  void _showCreateAppointmentDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return CreateAppointmentScreen();
      },
    );
  }
  
  void _showEditAppointmentDialog(Appointment appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return EditAppointmentScreen(appointment: appointment);
      },
    );
  }
  
  void _updateAppointmentStatus(int appointmentId, String status) async {
    try {
      await Provider.of<AppointmentProvider>(context, listen: false)
          .updateAppointmentStatus(appointmentId, status);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rendez-vous ${status == 'CONFIRMED' ? 'confirmé' : 'annulé'}'),
          backgroundColor: status == 'CONFIRMED' ? Colors.green : Colors.red,
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
}