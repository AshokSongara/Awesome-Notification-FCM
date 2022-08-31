import 'package:awesome_notification_fcm/accept_call_page.dart';
import 'package:awesome_notification_fcm/reject_call_page.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

import 'routes.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  final String title = 'Awesome Notifications Basic Demo';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _firebaseAppToken = '';
  bool _notificationsAllowed = false;
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    // Here you ensure to request the user permission, but do not do so
    // directly. Ask the user permission before in a personalized pop up dialog
    // this is more friendly to the user
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      _notificationsAllowed = isAllowed;
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Here you get the token every time its changed by firebase process or by a new installation
    AwesomeNotifications().fcmTokenStream.listen((String newFcmToken) {
      print("New FCM token: " + newFcmToken);
    });

    AwesomeNotifications()
        .createdStream
        .listen((ReceivedNotification notification) {
      print("Notification created: " +
          (notification.title ??
              notification.body ??
              notification.id.toString()));
    });

    AwesomeNotifications()
        .displayedStream
        .listen((ReceivedNotification notification) {
      print("Notification displayed: " +
          (notification.title ??
              notification.body ??
              notification.id.toString()));
    });

    AwesomeNotifications()
        .dismissedStream
        .listen((ReceivedAction dismissedAction) {
      print("Notification dismissed: " +
          (dismissedAction.title ??
              dismissedAction.body ??
              dismissedAction.id.toString()));
    });

    AwesomeNotifications().actionStream.listen((ReceivedAction receivedAction) {
      print("Action received!");

      if (receivedAction.buttonKeyPressed == 'accept') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AcceptCallPage(),
          ),
        );
      } else if (receivedAction.buttonKeyPressed == 'reject') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RejectCallPage(),
          ),
        );
      } else {
        // Avoid to open the notification details page twice
        Navigator.pushNamedAndRemoveUntil(
            context,
            PAGE_NOTIFICATION_DETAILS,
            (route) =>
                (route.settings.name != PAGE_NOTIFICATION_DETAILS) ||
                route.isFirst,
            arguments: receivedAction);
      }
    });

    initializeFirebaseService();

    super.initState();
  }

  Future<void> initializeFirebaseService() async {
    String firebaseAppToken;
    bool isFirebaseAvailable;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      isFirebaseAvailable = await AwesomeNotifications().isFirebaseAvailable;

      if (isFirebaseAvailable) {
        try {
          firebaseAppToken = await AwesomeNotifications().firebaseAppToken;
          debugPrint('Firebase token: $firebaseAppToken');
        } on Exception {
          firebaseAppToken = 'failed';
          debugPrint('Firebase failed to get token');
        }
      } else {
        firebaseAppToken = 'unavailable';
        debugPrint('Firebase is not available on this project');
      }
    } on Exception {
      isFirebaseAvailable = false;
      firebaseAppToken = 'Firebase is not available on this project';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      _firebaseAppToken = firebaseAppToken;
      return;
    }

    setState(() {
      _firebaseAppToken = firebaseAppToken;
    });
  }

  Future<void> requestUserPermission() async {
    showDialog(
        context: context,
        builder: (_) => NetworkGiffyDialog(
              buttonOkText:
                  Text('Allow', style: TextStyle(color: Colors.white)),
              buttonCancelText:
                  Text('Later', style: TextStyle(color: Colors.white)),
              buttonCancelColor: Colors.grey,
              buttonOkColor: Colors.deepPurple,
              buttonRadius: 0.0,
              image: Image.asset("assets/images/animated-bell.gif",
                  fit: BoxFit.cover),
              title: Text('Get Notified!',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
              description: Text(
                'Allow Awesome Notifications to send to you beautiful notifications!',
                textAlign: TextAlign.center,
              ),
              entryAnimation: EntryAnimation.DEFAULT,
              onCancelButtonPressed: () async {
                Navigator.of(context).pop();
                _notificationsAllowed =
                    await AwesomeNotifications().isNotificationAllowed();
                setState(() {
                  _notificationsAllowed = _notificationsAllowed;
                });
              },
              onOkButtonPressed: () async {
                Navigator.of(context).pop();
                await AwesomeNotifications()
                    .requestPermissionToSendNotifications();
                _notificationsAllowed =
                    await AwesomeNotifications().isNotificationAllowed();
                setState(() {
                  _notificationsAllowed = _notificationsAllowed;
                });
              },
            ));
  }

  void sendNotification() async {
    if (!_notificationsAllowed) {
      await requestUserPermission();
    }

    if (!_notificationsAllowed) {
      return;
    }

    AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 100,
          channelKey: "basic_channel",
          title: "Huston! The eagle has landed!",
          body:
              "A small step for a man, but a giant leap to Flutter's community!",
          showWhen: true,
          autoCancel: true,
          payload: {"secret": "Awesome Notifications Rocks!"}),
      actionButtons: <NotificationActionButton>[
        NotificationActionButton(key: 'accept', label: 'Accept'),
        NotificationActionButton(key: 'reject', label: 'Reject'),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              shrinkWrap: true,
              children: <Widget>[
                RaisedButton(
                    onPressed: () => requestUserPermission(),
                    child: Text('Request User Permission')),
                SizedBox(height: 20),
                RaisedButton(
                    onPressed: () => sendNotification(),
                    child: Text('Send a local notification')),
              ]),
        ));
  }
}
