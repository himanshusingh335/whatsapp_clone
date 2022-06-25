import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../models/users.dart';
import '../services/auth_services.dart';
import '../services/db_services.dart';
import '../widgets/select_profile_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  static const routeName = '/settingsScreen';

  @override
  Widget build(BuildContext context) {
    DbServices db = DbServices();
    return MultiProvider(
      providers: [
        StreamProvider<Users?>.value(
          value: db.getCurrentUser(),
          initialData: null,
        ),
      ],
      child: Builder(builder: (context) {
        Users? currentUser = Provider.of<Users?>(context);
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Settings',
            ),
          ),
          body: Column(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 115,
                width: 115,
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(currentUser?.image! ??
                          'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                    ),
                    const Positioned(
                      bottom: 0,
                      right: -25,
                      child: SelectProfileButton(),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: SettingsList(
                  sections: [
                    SettingsSection(
                      title: const Text('Account'),
                      tiles: [
                        SettingsTile(
                            title: const Text('Email'),
                            description: Text(currentUser!.email!),
                            trailing: Text(checkVerifyEmail()),
                            leading: const Icon(Icons.email)),
                        SettingsTile(
                          title: const Text('Change Password'),
                          leading: const Icon(Icons.lock),
                          onPressed: (context) {
                            passwordReset(context);
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              passwordReset(context);
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Password Reset'),
                                      content: const Text(
                                          'An Email has been sent with the link to reset your password'),
                                      actions: [
                                        TextButton(
                                          child: const Text("OK"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    );
                                  });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
