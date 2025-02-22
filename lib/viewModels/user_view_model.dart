import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_getx/models/loginModels/user_data.dart';
import 'package:task_manager_getx/models/responseModel/success.dart';
import 'package:task_manager_getx/services/user_info_service.dart';

import '../models/loginModels/login_model.dart';

class UserViewModel extends GetxController {
  String _token = "";
  bool _isLoading = false;
  bool _isPasswordObscured = true;
  final ImagePicker _pickedImage = ImagePicker();
  String imageName = "";
  String base64Image = "";
  late Object response;
  UserData _userData = UserData(
    email: "",
    firstName: "",
    lastName: "",
    mobile: "",
    password: "",
  );

  bool get isPasswordObscured => _isPasswordObscured;

  bool get isLoading => _isLoading;

  UserData get userData => _userData;

  String get token => _token;

  set setIsPasswordObscured(bool value) {
    _isPasswordObscured = value;
    update();
  }

  set setToken(String token) => _token = token;

  set setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    update();
  }

  set setUserData(UserData userData) {
    _userData = userData;
    update();
  }

  Future<void> loadUserData(SharedPreferences preferences) async {
    setToken = preferences.getString("token")!;
    setUserData =
        UserData.fromJson(jsonDecode(preferences.getString("userData")!));
  }

  void saveUserData(
      LoginModel loginModel, SharedPreferences preferences, String password) {
    loginModel.data!.password = password;
    preferences.setString("token", loginModel.token.toString());
    preferences.setString("userData", jsonEncode(loginModel.data!.toJson()));
    setToken = loginModel.token.toString();
    setUserData = loginModel.data!;
  }

  Future<void> getImageFromGallery() async {
    XFile? pickedFile = await _pickedImage.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      imageName = pickedFile.name;
      convertImage(pickedFile);
      update();
    }
  }

  Future<bool> updateUserData({
    required String email,
    required String firstName,
    required String lastName,
    required String mobile,
    required String password,
  }) async {
    setIsLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (base64Image.isEmpty) {
      base64Image = _userData.photo!;
    }
    UserData userData = UserData(
      email: email,
      firstName: firstName,
      lastName: lastName,
      mobile: mobile,
      password: password,
      photo: base64Image,
    );
    response = await UserInfoService.updateUserProfile(token, userData);
    if (response is Success) {
      _userData = userData;
      preferences.setString("userData", jsonEncode(userData.toJson()));
      base64Image = "";
      imageName = "";
      setIsLoading = false;
      return true;
    }
    base64Image = "";
    imageName = "";
    setIsLoading = false;
    return false;
  }

  void convertImage(XFile pickedFile) {
    List<int> imageBytes = File(pickedFile.path).readAsBytesSync();
    base64Image = base64Encode(imageBytes);
  }
}
