import 'package:flutter/material.dart';

class MedicalNotification {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  bool isRead;

  MedicalNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key}); // Updated for modern super parameters

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Mock data matching the AfyaFlow hospital system context
  final List<MedicalNotification> _notifications = [
    MedicalNotification(
      id: '1',
      title: 'Appointment Confirmed',
      description: 'Your appointment with Dr. Kamau Njoroge tomorrow at 10:00 AM has been successfully booked.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      icon: Icons.calendar_today_rounded,
      iconColor: const Color(0xFF009688), // Teal
      iconBgColor: const Color(0xFF009688).withValues(alpha: 0.1),
      isRead: false,
    ),
    MedicalNotification(
      id: '2',
      title: 'Lab Results Ready',
      description: 'Your recent Blood Test results from Kenyatta National Hospital have been uploaded. View them in My Records.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.science_rounded,
      iconColor: Colors.redAccent,
      iconBgColor: Colors.redAccent.withValues(alpha: 0.1),
      isRead: false,
    ),
    MedicalNotification(
      id: '3',
      title: 'Medication Reminder',
      description: 'Time to take your Amoxicillin dosage. Take 1 tablet with water after your meal.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      icon: Icons.medical_services_rounded,
      iconColor: Colors.orange,
      iconBgColor: Colors.orange.withValues(alpha: 0.1),
      isRead: true,
    ),
    MedicalNotification(
      id: '4',
      title: 'Invoice Settled',
      description: 'Payment for your consultation on 12 May 2025 has been processed successfully. Invoice ref: #AF-9921.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.receipt_long_rounded,
      iconColor: Colors.purple,
      iconBgColor: Colors.purple.withValues(alpha: 0.1),
      isRead: true,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF009688),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(0xFF009688),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'All caught up!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              'You have no new notifications.',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _notifications.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return InkWell(
            onTap: () {
              setState(() {
                notification.isRead = true;
              });
            },
            child: Container(
              color: notification.isRead ? Colors.transparent : const Color(0xFFEDF7F6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!notification.isRead)
                    Padding(
                      padding: const EdgeInsets.only(top: 14, right: 8),
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: const Color(0xFF009688),
                      ),
                    )
                  else
                    const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: notification.iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      notification.icon,
                      color: notification.iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Fixed this line
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            Text(
                              _formatTime(notification.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
