// ignore_for_file: avoid_print, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../models/users.dart';
import '../providers/emoji_showing_provider.dart';
import '../providers/is_uploading_provider.dart';
import '../providers/text_time_provider.dart';
import '../providers/youtube_player_provider.dart';
import '../screen_arguments/chat_screen_arguments.dart';
import '../services/db_services.dart';
import '../services/storage_service.dart';
import '../widgets/chat_box.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/emoji_selection_drawer.dart';
import '../widgets/youtube_player.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  static const routeName = '/chatScreen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController mess;
  late ScrollController? controller;
  late DbServices db;
  late StorageServices st;
  late bool emojiShowing;
  late ChatScreenArguments args =
      ModalRoute.of(context)!.settings.arguments as ChatScreenArguments;
  List<Message>? chats;
  late List<Users?> users;
  late Users chatUser;
  late bool isExpanded;
  late bool isUploading;
  late bool isPlaying;
  late int chatsLength;
  late String youtubeId;

  @override
  void initState() {
    controller = ScrollController();
    mess = TextEditingController();
    db = DbServices();
    st = StorageServices();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<List<Message>?>.value(
          value: db.getMessages(args.chatid),
          initialData: null,
        ),
        StreamProvider<Users?>.value(
          value: db.getCurrentUser(),
          initialData: null,
        ),
      ],
      child: Builder(
        builder: (context) {
          chats = Provider.of<List<Message>?>(context);
          users = Provider.of<List<Users>?>(context) ?? [];
          chatUser = getChatUser(users, args.userId);
          isExpanded = Provider.of<IsExpanded>(context).isExpanded;
          isUploading = Provider.of<IsUpLoading>(context).isUpLoading;
          emojiShowing = Provider.of<EmojiShowing>(context).emojiShowing;
          isPlaying = Provider.of<IsPlaying>(context).isPlaying;
          youtubeId = Provider.of<IsPlaying>(context).id;
          chatsLength = chats?.length ?? 0;
          return WillPopScope(
            onWillPop: () async {
              if (isPlaying == true) {
                Provider.of<IsPlaying>(context, listen: false).changeToFalse();
                return false;
              }
              if (emojiShowing == false) {
                try {
                  await db.updateSeenStatus(args.userId);
                } on Exception catch (e) {
                  print("E: $e");
                }
                return true;
              } else {
                Provider.of<EmojiShowing>(context, listen: false)
                    .changeToFalse();
                return false;
              }
            },
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  flexibleSpace: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () async {
                              if (isPlaying == true) {
                                Provider.of<IsPlaying>(context, listen: false)
                                    .changeToFalse();
                              }
                              Navigator.pop(context);
                              try {
                                await db.updateSeenStatus(args.userId);
                              } on Exception catch (e) {
                                print("EXCEPTION: $e");
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          CircleAvatar(
                            backgroundImage:
                                chatUser.image == "" || chatUser.image == null
                                    ? null
                                    : NetworkImage(chatUser.image!),
                            child: chatUser.image == "" ||
                                    chatUser.image == null
                                ? Text(
                                    chatUser.name?[0].toUpperCase() ?? "",
                                    style: const TextStyle(color: Colors.white),
                                  )
                                : Container(),
                            backgroundColor: Colors.green,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  chatUser.name ?? "",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  chatUser.status ?? "",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: Column(
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Stack(
                        children: <Widget>[
                          ListView.builder(
                            reverse: true,
                            itemCount: chatsLength,
                            shrinkWrap: true,
                            controller: controller,
                            padding: const EdgeInsets.only(top: 10, bottom: 75),
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ChatMessage(
                                      message: chats![index], args: args),
                                  isExpanded
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                chats![index].to == args.userId
                                                    ? MainAxisAlignment.end
                                                    : MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                DateFormat('dd-MM hh:mm aa')
                                                    .format(DateTime.parse(
                                                        chats![index]
                                                                .sendTime ??
                                                            "")),
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              );
                            },
                          ),
                          isUploading == true
                              ? Container(
                                  width: double.infinity,
                                  height: 50,
                                  color: const Color(0xDD5F96D8),
                                  child: Center(
                                    child: Text(
                                      'Sending Attachment...',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText2!
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                )
                              : Container(),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ChatBox(args: args, mess: mess),
                          ),
                          isPlaying == true
                              ? MyYoutubePlayer(id: youtubeId)
                              : Container(),
                          isPlaying == true
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (isPlaying == true) {
                                      Provider.of<IsPlaying>(context,
                                              listen: false)
                                          .changeToFalse();
                                    }
                                  })
                              : Container(),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Offstage(
                        offstage: !emojiShowing,
                        child: SizedBox(
                          height: 250,
                          child: EmojiSelectionDrawer(
                            mess: mess,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    mess.dispose();
    controller?.dispose();
    super.dispose();
  }
}
