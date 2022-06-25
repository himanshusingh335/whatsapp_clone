import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/conversations.dart';
import '../models/users.dart';
import '../screen_arguments/chat_screen_arguments.dart';
import '../services/db_services.dart';
import 'chat_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);
  static const routeName = '/contactsScreen';

  @override
  Widget build(BuildContext context) {
    DbServices db = DbServices();
    return MultiProvider(
      providers: [
        StreamProvider<List<Conversations?>?>.value(
          value: db.getConversations(), // gets stream of conversations
          initialData: null,
        ),
      ],
      child: Builder(
        builder: (context) {
          List<Users>? userList = Provider.of<List<Users>?>(context) ?? [];
          List<Conversations?>? conversations =
              Provider.of<List<Conversations?>?>(context) ?? [];
          String chatid = "";
          return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              title: const Text('Start a chat with: '),
            ),
            body: ListView.builder(
                itemCount: userList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: InkWell(
                      onTap: () {
                        for (int i = 0; i < conversations.length; i++) {
                          if (userList[index].userId ==
                              conversations[i]?.userId) {
                            chatid = conversations[i]!.chatid!;
                          }
                        }
                        if (chatid == "") {
                          chatid =
                              DateTime.now().microsecondsSinceEpoch.toString();
                        }
                        Navigator.pushNamed(
                          context,
                          ChatScreen.routeName,
                          arguments: ChatScreenArguments(
                              userList[index].userId!, chatid),
                        );
                        chatid = "";
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue,
                          backgroundImage: userList[index].image == ""
                              ? null
                              : NetworkImage(userList[index].image!),
                          child: userList[index].image == ""
                              ? Text(
                                  userList[index]
                                      .name![0]
                                      .toString()
                                      .toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 25),
                                )
                              : Container(),
                        ),
                        title: Text('${userList[index].name}'),
                        subtitle: Text(
                          '${userList[index].email}',
                        ),
                      ),
                    ),
                  );
                }),
          );
        },
      ),
    );
  }
}
