import 'conversations.dart';

class Users {
  String? userId;
  String? email;
  String? name;
  String? image;
  String? status;

  Users({this.userId, this.email, this.name, this.image, this.status});

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
        userId: json['userId'],
        name: json['name'],
        email: json['email'],
        image: json['image'],
        status: json['status']);
  }
}

List<Users?>? getConversationUsers(
    List<Users?> allUsers, List<Conversations?> userIds) {
  List<Users?>? filteredUsers = [];
  for (int i = 0; i < userIds.length; i++) {
    for (int j = 0; j < allUsers.length; j++) {
      if (userIds[i]!.userId == allUsers[j]!.userId) {
        filteredUsers.add(allUsers[j]);
      }
    }
  }
  return filteredUsers;
}

Users getChatUser(List<Users?> allUsers, String? userId) {
  Users filteredUser = Users();
  for (int i = 0; i < allUsers.length; i++) {
    if (userId! == allUsers[i]!.userId) {
      filteredUser = allUsers[i]!;
    }
  }
  return filteredUser;
}
