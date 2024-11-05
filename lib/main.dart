import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'screen/main_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Meminta izin notif
  if (Platform.isAndroid) {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    androidPlugin?.requestPermission();
  }

  // Inisialisasi flutter local notifications
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Inisialisasi WorkManager
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask("dueDateReminderTask", "checkDueDates", frequency: const Duration(days: 1));

  runApp(const FinanceTrackerApp());
}

// Callback workmanager
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    await checkForDueDates();
    return Future.value(true);
  });
}

// Cek tanggal jatuh tempo
Future<void> checkForDueDates() async {
  final now = DateTime.now();
  final threeDaysFromNow = now.add(const Duration(days: 3));

  final querySnapshot = await FirebaseFirestore.instance
      .collection('installments')
      .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
      .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(threeDaysFromNow))
      .where('isPaid', isEqualTo: false)
      .get();

  for (final doc in querySnapshot.docs) {
    final data = doc.data();
    final dueDate = (data['dueDate'] as Timestamp).toDate();
    await showDueDateNotification(dueDate);
  }
}

// Memunculkan notif
Future<void> showDueDateNotification(DateTime dueDate) async {
  try {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'installment_due_channel',
      'Installment Due',
      channelDescription: 'Reminder for installments due soon',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
      'Installment Due Soon',
      'An installment is due on ${DateFormat('dd MMM yyyy').format(dueDate)}. Don\'t forget to pay!',
      platformChannelSpecifics,
    );
  } catch (e) {
    print("Error showing notification: $e");
  }
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FinanceTrackerScreen(),
      ),
    );
  }
}
