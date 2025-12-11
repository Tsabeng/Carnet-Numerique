import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/appointment_service.dart';
import '../providers/user_provider.dart';
import '../models/appointment.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedView = 'day'; // day, week, month

  @override
  Widget build(BuildContext context) {
    final appointmentService = Provider.of<AppointmentService>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    final isDoctor = userProvider.isDoctor;
    final userId = userProvider.currentUserId ?? '';
    
    final userAppointments = isDoctor
        ? appointmentService.getAppointmentsByDoctorId(userId)
        : appointmentService.getAppointmentsByPatientId(userId);

    final todayAppointments = appointmentService.getTodayAppointments();
    final upcomingAppointments = appointmentService.getUpcomingAppointments();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier des rendez-vous'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAppointmentDialog(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedView = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'day', child: Text('Vue jour')),
              const PopupMenuItem(value: 'week', child: Text('Vue semaine')),
              const PopupMenuItem(value: 'month', child: Text('Vue mois')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête du calendrier
          _buildCalendarHeader(),
          
          // Vue sélectionnée
          Expanded(
            child: _selectedView == 'day'
                ? _buildDayView(userAppointments)
                : _selectedView == 'week'
                    ? _buildWeekView(userAppointments)
                    : _buildMonthView(userAppointments),
          ),
          
          // Rendez-vous du jour
          if (todayAppointments.isNotEmpty)
            _buildTodayAppointments(todayAppointments),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAppointmentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          Column(
            children: [
              Text(
                DateFormat('EEEE', 'fr_FR').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('dd MMMM yyyy', 'fr_FR').format(_selectedDate),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayView(List<Appointment> appointments) {
    final dayAppointments = appointments.where((apt) {
      return apt.dateTime.year == _selectedDate.year &&
             apt.dateTime.month == _selectedDate.month &&
             apt.dateTime.day == _selectedDate.day;
    }).toList();

    return dayAppointments.isEmpty
        ? const Center(child: Text('Aucun rendez-vous ce jour'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dayAppointments.length,
            itemBuilder: (context, index) {
              final apt = dayAppointments[index];
              return _buildAppointmentCard(apt);
            },
          );
  }

  Widget _buildWeekView(List<Appointment> appointments) {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (int i = 0; i < 7; i++)
          _buildDayColumn(
            startOfWeek.add(Duration(days: i)),
            appointments,
          ),
      ],
    );
  }

  Widget _buildDayColumn(DateTime date, List<Appointment> appointments) {
    final dayAppointments = appointments.where((apt) {
      return apt.dateTime.year == date.year &&
             apt.dateTime.month == date.month &&
             apt.dateTime.day == date.day;
    }).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE dd', 'fr_FR').format(date),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            if (dayAppointments.isEmpty)
              const Text('Aucun rendez-vous', style: TextStyle(color: Colors.grey))
            else
              ...dayAppointments.map((apt) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildAppointmentCard(apt, compact: true),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthView(List<Appointment> appointments) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: 35, // 5 semaines
      itemBuilder: (context, index) {
        final date = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          1,
        ).add(Duration(days: index - DateTime(
          _selectedDate.year,
          _selectedDate.month,
          1,
        ).weekday + 1));

        final dayAppointments = appointments.where((apt) {
          return apt.dateTime.year == date.year &&
                 apt.dateTime.month == date.month &&
                 apt.dateTime.day == date.day;
        }).toList();

        return Card(
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _selectedView = 'day';
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontWeight: date.day == DateTime.now().day
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: date.month == _selectedDate.month
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                  if (dayAppointments.isNotEmpty)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodayAppointments(List<Appointment> appointments) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aujourd\'hui',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          ...appointments.map((apt) => _buildAppointmentCard(apt, compact: true)),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment apt, {bool compact = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: _getStatusColor(apt.status),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            _getAppointmentIcon(apt.type),
            color: _getStatusColor(apt.status),
          ),
        ),
        title: Text(
          compact ? apt.patientName : '${apt.patientName} - ${apt.type}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${apt.formattedTime} - ${apt.reason ?? ''}'),
            if (!compact) Text('Statut: ${apt.status}'),
          ],
        ),
        trailing: compact ? null : const Icon(Icons.arrow_forward),
        onTap: () => _showAppointmentDetails(apt),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green.shade100;
      case 'scheduled':
        return Colors.blue.shade100;
      case 'pending':
        return Colors.orange.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  IconData _getAppointmentIcon(String type) {
    switch (type) {
      case 'consultation':
        return Icons.medical_services;
      case 'urgence':
        return Icons.local_hospital;
      case 'suivi':
        return Icons.update;
      default:
        return Icons.event;
    }
  }

  void _showAppointmentDetails(Appointment apt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rendez-vous - ${apt.type}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Patient', apt.patientName),
              _buildDetailRow('Date', apt.formattedDate),
              _buildDetailRow('Heure', apt.formattedTime),
              _buildDetailRow('Type', apt.type),
              _buildDetailRow('Statut', apt.status),
              _buildDetailRow('Motif', apt.reason ?? 'Non spécifié'),
              if (apt.notes != null) _buildDetailRow('Notes', apt.notes!),
            ],
          ),
        ),
        actions: [
          if (apt.status != 'cancelled' && apt.status != 'completed')
            TextButton(
              onPressed: () => _updateAppointmentStatus(apt, 'cancelled'),
              child: const Text('Annuler', style: TextStyle(color: Colors.red)),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog(BuildContext context) {
    final patientController = TextEditingController();
    final reasonController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Nouveau rendez-vous'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: patientController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du patient',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() => selectedDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (time != null) {
                                setState(() => selectedTime = time);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Heure',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(selectedTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Motif',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
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
                    if (patientController.text.isNotEmpty &&
                        reasonController.text.isNotEmpty) {
                      final appointment = Appointment(
                        id: 'APT${DateTime.now().millisecondsSinceEpoch}',
                        patientId: 'PAT001', // À relier à la recherche patient
                        patientName: patientController.text,
                        doctorId: Provider.of<UserProvider>(context, listen: false).currentUserId ?? '',
                        doctorName: 'Dr. ${Provider.of<UserProvider>(context, listen: false).currentUserName ?? ''}',
                        dateTime: DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        ),
                        type: 'consultation',
                        status: 'scheduled',
                        reason: reasonController.text,
                        notes: notesController.text,
                        createdAt: DateTime.now(),
                      );
                      
                      Provider.of<AppointmentService>(context, listen: false)
                          .addAppointment(appointment);
                      
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Rendez-vous créé avec succès'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateAppointmentStatus(Appointment apt, String newStatus) {
    Provider.of<AppointmentService>(context, listen: false).updateAppointment(
      apt.id,
      Appointment(
        id: apt.id,
        patientId: apt.patientId,
        patientName: apt.patientName,
        doctorId: apt.doctorId,
        doctorName: apt.doctorName,
        dateTime: apt.dateTime,
        duration: apt.duration,
        type: apt.type,
        status: newStatus,
        notes: apt.notes,
        reason: apt.reason,
        createdAt: apt.createdAt,
      ),
    );
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rendez-vous ${newStatus == 'cancelled' ? 'annulé' : 'confirmé'}'),
        backgroundColor: newStatus == 'cancelled' ? Colors.red : Colors.green,
      ),
    );
  }
}