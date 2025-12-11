// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../providers/user_provider.dart';
import '../providers/patient_provider.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String? conversationId;
  final String? recipientId;
  final String? recipientName;

  const ChatScreen({
    super.key,
    this.conversationId,
    this.recipientId,
    this.recipientName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    final currentUserId = userProvider.currentUserId ?? '';
    
    // Trouver la conversation
    Conversation? conversation;
    if (widget.conversationId != null) {
      conversation = chatService.getConversation(widget.conversationId!);
    } else if (widget.recipientId != null) {
      conversation = chatService.getConversationBetween(currentUserId, widget.recipientId!);
    }
    
    final messages = conversation?.messages ?? [];
    final recipientName = widget.recipientName ?? 
                         (conversation?.getOtherParticipantName(currentUserId) ?? 'Inconnu');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipientName),
            const SizedBox(height: 2),
            const Text(
              'En ligne',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => _showContactOptions(recipientName),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showChatOptions(conversation),
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête médical
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.medical_services, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Communication médicale sécurisée',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.info, size: 20),
                  onPressed: _showSecurityInfo,
                ),
              ],
            ),
          ),
          
          // Messages
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.message,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucun message',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Envoyez votre premier message',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isCurrentUser = message.senderId == currentUserId;
                      
                      return _buildMessageBubble(message, isCurrentUser);
                    },
                  ),
          ),
          
          // Zone de saisie
          _buildMessageInput(currentUserId, conversation),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser)
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                message.senderName.substring(0, 1),
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      message.senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blue : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isCurrentUser ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message.formattedTime,
                        style: TextStyle(
                          fontSize: 10,
                          color: isCurrentUser ? Colors.white70 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser)
            const SizedBox(width: 8),
          if (isCurrentUser)
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                'M',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(String currentUserId, Conversation? conversation) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () => _showAttachmentOptions(),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Tapez votre message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              onSubmitted: (text) => _sendMessage(currentUserId, conversation),
            ),
          ),
          IconButton(
            icon: _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.send),
            onPressed: _isLoading
                ? null
                : () => _sendMessage(currentUserId, conversation),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String currentUserId, Conversation? conversation) async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      final recipientId = widget.recipientId ?? 
                         (conversation?.getOtherParticipant(currentUserId) ?? '');
      
      if (recipientId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de trouver le destinataire'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await Provider.of<ChatService>(context, listen: false).sendMessage(
        senderId: currentUserId,
        receiverId: recipientId,
        content: message,
      );
      
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Image'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter la sélection d'image
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Document PDF'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter la sélection de PDF
              },
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Ordonnance'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Créer une ordonnance
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Annuler'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactOptions(String recipientName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contacter $recipientName'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Appeler'),
              subtitle: Text('Passer un appel vocal'),
            ),
            ListTile(
              leading: Icon(Icons.video_call),
              title: Text('Visioconférence'),
              subtitle: Text('Appel vidéo sécurisé'),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle: Text('Envoyer un email'),
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

  void _showChatOptions(Conversation? conversation) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Effacer la conversation'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(conversation);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Désactiver les notifications'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Informations de sécurité'),
              onTap: () {
                Navigator.pop(context);
                _showSecurityInfo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Fermer'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Conversation? conversation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer la conversation'),
        content: const Text('Voulez-vous vraiment effacer toute la conversation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversation effacée'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Effacer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSecurityInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sécurité des messages'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vos messages sont sécurisés :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Chiffrement de bout en bout'),
              Text('• Stockage sécurisé'),
              Text('• Conformité RGPD'),
              Text('• Historique conservé 10 ans'),
              SizedBox(height: 16),
              Text(
                'Ce canal est réservé aux communications médicales.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}