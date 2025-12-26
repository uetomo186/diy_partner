import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../repositories/user_repository.dart';

class UserState {
  final String? profileImagePath;
  final String userName;

  UserState({this.profileImagePath, this.userName = 'User Name'});

  UserState copyWith({String? profileImagePath, String? userName}) {
    return UserState(
      profileImagePath: profileImagePath ?? this.profileImagePath,
      userName: userName ?? this.userName,
    );
  }
}

class UserNotifier extends AsyncNotifier<UserState> {
  final _repository = UserRepository();

  @override
  Future<UserState> build() async {
    return _repository.loadUser();
  }

  Future<void> updateUserName(String newName) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.saveUserName(newName);
      return state.value!.copyWith(userName: newName);
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await _cropImage(pickedFile);
      if (croppedFile != null) {
        // Persist image
        final directory = await getApplicationDocumentsDirectory();
        final fileName = p.basename(croppedFile.path);
        final savedImage = await File(
          croppedFile.path,
        ).copy('${directory.path}/$fileName');

        await _repository.saveProfileImage(savedImage.path);

        state = AsyncData(
          state.value!.copyWith(profileImagePath: savedImage.path),
        );
      }
    }
  }

  Future<CroppedFile?> _cropImage(XFile pickedFile) async {
    return await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, UserState>(
  UserNotifier.new,
);
