import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/users.dart';
import '../services/storage_service.dart';

class SelectProfileButton extends StatelessWidget {
  const SelectProfileButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    StorageServices storage = StorageServices();
    Users? currentUser = Provider.of<Users?>(context);
    return PopupMenuButton(
        elevation: 20,
        enabled: true,
        onSelected: (value) async {
          if (value == "Camera") {
            XFile? file = await storage.pickCameraPhoto();
            if (file != null) {
              storage.uploadProfile(currentUser!.userId!, file);
            }
          } else if (value == "Gallery") {
            XFile? file = await storage.pickGalleryPhoto();
            if (file != null) {
              storage.uploadProfile(currentUser!.userId!, file);
            }
          }
        },
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.lightBlue,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.camera,
            color: Colors.white,
            size: 60,
          ),
        ),
        itemBuilder: (context) => [
              const PopupMenuItem(
                value: "Camera",
                child: Text("Use Camera"),
              ),
              const PopupMenuItem(
                value: "Gallery",
                child: Text("Choose from Gallery"),
              ),
            ]);
  }
}
