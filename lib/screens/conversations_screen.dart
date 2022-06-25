import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../models/conversations.dart';
import '../models/users.dart';
import '../providers/is_loading_provider.dart';
import '../screen_arguments/chat_screen_arguments.dart';
import '../services/auth_services.dart';
import '../services/db_services.dart';
import '../services/notification_services.dart';
import 'chat_screen.dart';
import 'contacts_screen.dart';
import 'settings_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  static const routeName = '/conversationsScreen';

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with WidgetsBindingObserver {
  late DbServices db;
  List<Users?>? conversationUsers;
  late List<Users?> users;
  List<Conversations?>? conversations;

  @override
  void initState() {
    super.initState();

    LocalNotificationService.initialize(context);

    db = DbServices();
    WidgetsBinding.instance.addObserver(this);
    getDeviceTokens();
    db.userStatusOnline();

    //Gives the message on which user taps and it open the app from terminated
    //state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final routeFromMessage = message.data["route"];
        final routeNames = routeFromMessage.split(",");
        final Map<int, String> splitRoutes = {
          for (int i = 0; i < routeNames.length; i++) i: routeNames[i]
        };
        Navigator.of(context).pushNamed("conversationsScreen");

        if (splitRoutes[0] == ChatScreen.routeName) {
          Navigator.of(context).pushNamed(splitRoutes[0]!,
              arguments: ChatScreenArguments(splitRoutes[1]!, splitRoutes[2]!));
        }
      }
    });

    //Called when the app is in foreground
    FirebaseMessaging.onMessage.listen((message) {
      LocalNotificationService.display(message);
    });

    //Called when the app is in background but not terminated
    //And user taps on notification from notification tray
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final routeFromMessage = message.data["route"];
      final routeNames = routeFromMessage.split(",");
      final Map<int, String> splitRoutes = {
        for (int i = 0; i < routeNames.length; i++) i: routeNames[i]
      };

      if (splitRoutes[0] == ChatScreen.routeName) {
        Navigator.of(context).pushNamed(splitRoutes[0]!,
            arguments: ChatScreenArguments(splitRoutes[1]!, splitRoutes[2]!));
      }
    });
  }

  Future<void> getDeviceTokens() async {
    String? token = await FirebaseMessaging.instance.getToken();

    // Save the initial token to the database
    await db.saveTokenToDatabase(token!);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(db.saveTokenToDatabase);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      db.userStatusOnline();
    } else {
      db.userStatusOffline();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<List<Conversations?>?>.value(
          value: db.getConversations(),
          initialData: null,
        ),
      ],
      child: Builder(
        builder: (context) {
          List<Conversations?>? conversations =
              Provider.of<List<Conversations?>?>(context) ?? [];
          users = Provider.of<List<Users>?>(context) ?? [];
          conversationUsers = getConversationUsers(users, conversations);

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text('Chats'),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 130,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign out'),
                    onTap: () async {
                      Provider.of<IsLoading>(context, listen: false)
                          .changeToFalse();
                      signOut(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pushNamed(context, SettingsScreen.routeName);
                    },
                  ),
                ],
              ),
            ),
            body: ListView.builder(
                itemCount: conversations.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 16),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Card(
                    child: InkWell(
                      onTap: () async {
                        Navigator.pushNamed(
                          context,
                          ChatScreen.routeName,
                          arguments: ChatScreenArguments(
                              conversationUsers![index]!.userId!,
                              conversations[index]!.chatid!),
                        );
                        await db
                            .updateSeenStatus(conversations[index]!.userId!);
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          maxRadius: 30,
                          backgroundImage:
                              conversationUsers?[index]?.image == ""
                                  ? null
                                  : NetworkImage(
                                      conversationUsers?[index]?.image ?? ''),
                          child: conversationUsers?[index]?.image == ""
                              ? Text(
                                  conversationUsers?[index]
                                          ?.name![0]
                                          .toUpperCase() ??
                                      '',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 25),
                                )
                              : Container(),
                        ),
                        title: Text(
                          conversationUsers?[index]?.name! ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          conversations[index]!.message!,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 13,
                              color: conversations[index]!.status == 'unseen'
                                  ? Colors.blue
                                  : Colors.grey.shade600,
                              fontWeight:
                                  conversations[index]!.status == 'unseen'
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                        ),
                        trailing: Text(
                          DateFormat('yy/MM/dd hh:mm').format(
                              DateTime.parse(conversations[index]!.sendTime!)),
                          style: TextStyle(
                              fontSize: 12,
                              color: conversations[index]!.status == 'unseen'
                                  ? Colors.blue
                                  : Colors.grey.shade600,
                              fontWeight:
                                  conversations[index]!.status == 'unseen'
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                        ),
                      ),
                    ),
                  );
                }),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, ContactsScreen.routeName);
              },
              child: const Icon(Icons.contacts),
            ),
          );
        },
      ),
    );
  }
}
