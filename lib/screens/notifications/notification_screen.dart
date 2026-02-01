import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:remindus/blocs/user/user_bloc.dart';
import 'package:remindus/generated/assets.dart';
import 'package:remindus/models/notification_model.dart';
import 'package:remindus/services/notification_service.dart';
import 'package:remindus/theme/app_colors.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Mark all as read when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeFamilyId = context.read<UserBloc>().state;
      if (activeFamilyId is UserLoadedState) {
        _notificationService.markAllAsRead(activeFamilyId.activeFamilyId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final activeFamilyId = context.select<UserBloc, String?>((bloc) {
      final state = bloc.state;
      return (state is UserLoadedState) ? state.activeFamilyId : null;
    });

    return Scaffold(
      backgroundColor: appColors.bgColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.bgColorMap),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(appColors),
              Expanded(
                child: activeFamilyId == null
                    ? const Center(child: CircularProgressIndicator())
                    : _buildNotificationList(activeFamilyId, appColors),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic appColors) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: appColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: appColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(String userId, dynamic appColors) {
    return StreamBuilder<List<NotificationModel>>(
      stream: _notificationService.getNotificationsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading notifications',
              style: TextStyle(color: appColors.textSecondary),
            ),
          );
        }

        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
          return _buildEmptyState(appColors);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationCard(
              notifications[index],
              appColors,
              userId,
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(dynamic appColors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: appColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: appColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see notifications here',
            style: TextStyle(
              fontSize: 14,
              color: appColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    dynamic appColors,
    String userId,
  ) {
    return Dismissible(
      key: Key(notification.id ?? ''),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: appColors.errorRed,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (notification.id != null) {
          _notificationService.deleteNotification(userId, notification.id!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appColors.bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? Colors.transparent
                : appColors.primary.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationIcon(notification.type, appColors),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: appColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: appColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimestamp(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: appColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(String type, dynamic appColors) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'reminder':
        iconData = Icons.notifications_active;
        iconColor = appColors.primary;
        break;
      case 'low_stock':
        iconData = Icons.inventory_2_outlined;
        iconColor = appColors.errorRed;
        break;
      case 'guardian_invitation':
        iconData = Icons.person_add;
        iconColor = Color(0xFF4A7C59);
        break;
      case 'new_medicine':
        iconData = Icons.medical_services_outlined;
        iconColor = appColors.primary;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = appColors.textSecondary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: iconColor, size: 22),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      final DateTime dateTime = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM d, yyyy').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }
}
