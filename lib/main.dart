import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'models/users.dart';
import 'providers/emoji_showing_provider.dart';
import 'providers/is_loading_provider.dart';
import 'providers/is_uploading_provider.dart';
import 'providers/recording_provider.dart';
import 'providers/text_time_provider.dart';
import 'providers/youtube_player_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/conversations_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/video_player_screen.dart';
import 'services/db_services.dart';

//Recieve messages when app is terminated and in background.
Future<void> backgroundMessageRecieveHandler(RemoteMessage message) async {
  // LocalNotificationService.display(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _enableCatcheDatabase();
  FirebaseMessaging.onBackgroundMessage(backgroundMessageRecieveHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DbServices db = DbServices();
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance
              .authStateChanges(), //to check user sign in state
          initialData: null,
        ),
        ChangeNotifierProvider<IsLoading>(
          create: (context) =>
              IsLoading(), // start or stop loading progress indicator
        ),
        ChangeNotifierProvider<IsUpLoading>(
          create: (context) =>
              IsUpLoading(), // change state if document/ media is being uploaded to firebase storage
        ),
        ChangeNotifierProvider<EmojiShowing>(
          create: (context) =>
              EmojiShowing(), //change state if emoji drawer is up
        ),
        ChangeNotifierProvider<IsExpanded>(
          create: (context) =>
              IsExpanded(), // change state to show or hide date
        ),
        ChangeNotifierProvider<IsPlaying>(
          create: (context) => IsPlaying(), // change state if audio is playing
        ),
        ChangeNotifierProvider<RecordingProvider>(
            create: (context) =>
                RecordingProvider()), //change state if audio is recording
        StreamProvider<List<Users>?>.value(
          value: db.getUsers(), // get list of all users
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Kudosware Chat',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        routes: {
          ChatScreen.routeName: (context) => const ChatScreen(),
          ConversationsScreen.routeName: (context) =>
              const ConversationsScreen(),
          LoginScreen.routeName: (context) => const LoginScreen(),
          ContactsScreen.routeName: (context) => const ContactsScreen(),
          SettingsScreen.routeName: (context) => const SettingsScreen(),
          SignupScreen.routeName: (context) => SignupScreen(),
          LandingScreen.routeName: (context) => const LandingScreen(),
          VideoPlayerScreen.routeName: (context) => const VideoPlayerScreen(),
        },
        initialRoute: LandingScreen.routeName,
      ),
    );
  }
}

void _enableCatcheDatabase() {
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true); //mobile
  FirebaseFirestore.instance.settings =
      const Settings(cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
}
