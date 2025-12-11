// lib/screens/conversations_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../providers/user_provider.dart';
import '../providers/patient_provider.dart';
import 'chat_screen.dart';
import '../models/conversation.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    final conversations = chatService.getConversationsForUser(userProvider.currentUserId ?? '');
    final unreadCount = chatService.getUnreadCount(userProvider.currentUserId ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          if (unreadCount > 0)
            Badge(
              label: Text(unreadCount.toString()),
              child: IconButton(
                icon: const Icon(Icons.message),
                onPressed: () {},
              ),
            ),
        ],
      ),
      body: conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.message,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune conversation',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _startNewConversation(context),
                    child: const Text('Nouvelle conversation'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                final currentUserId = userProvider.currentUserId ?? '';
                final otherParticipantName = conversation.getOtherParticipantName(currentUserId);
                final lastMessage = conversation.messages.isNotEmpty
                    ? conversation.messages.last
                    : null;
                
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        otherParticipantName.substring(0, 1),
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    title: Text(
                      otherParticipantName,
                      style: TextStyle(
                        fontWeight: conversation.hasUnreadMessages
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: lastMessage != null
                        ? Text(
                            lastMessage.content,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : const Text('Aucun message'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (lastMessage != null)
                          Text(
                            lastMessage.formattedTime,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        if (conversation.hasUnreadMessages)
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            conversationId: conversation.id,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewConversation(context),
        child: const Icon(Icons.message),
      ),
    );
  }

  void _startNewConversation(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    final isDoctor = userProvider.isDoctor;
    
    if (isDoctor) {
      // Pour les médecins: choisir un patient
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nouvelle conversation'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: patientProvider.patients.length,
              itemBuilder: (context, index) {
                final patient = patientProvider.patients[index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(patient.fullName),
                  subtitle: Text(patient.id),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          recipientId: patient.id,
                          recipientName: patient.fullName,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      );
    } else {
      // Pour les patients: choisir un médecin
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Contacter un médecin'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Dr. Martin'),
                subtitle: Text('Cardiologue'),
              ),
              ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('Dr. Sophie'),
                subtitle: Text('Généraliste'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        ),
      );
    }
  }
}