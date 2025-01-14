import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_getx/models/loginModels/user_data.dart';
import 'package:task_manager_getx/models/responseModel/failure.dart';
import 'package:task_manager_getx/utils/app_assets.dart';
import 'package:task_manager_getx/utils/app_color.dart';
import 'package:task_manager_getx/utils/app_strings.dart';
import 'package:task_manager_getx/viewModels/user_view_model.dart';
import 'package:task_manager_getx/views/updateProfileScreen/update_profile_screen_form.dart';
import 'package:task_manager_getx/views/widgets/app_bar.dart';
import 'package:task_manager_getx/views/widgets/app_snackbar.dart';
import 'package:task_manager_getx/views/widgets/background_widget.dart';

class UpdateProfileScreen extends StatefulWidget {
  final SharedPreferences? preferences;

  const UpdateProfileScreen({super.key, this.preferences});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late final TextEditingController _emailTEController,
      _firstNameTEController,
      _lastNameTEController,
      _mobileNumberTEController,
      _passwordTEController;
  late final GlobalKey<FormState> _formKey;
  late final FocusNode _emailFocusNode,
      _passwordFocusNode,
      _firstNameFocusNode,
      _lastNameFocusNode,
      _mobileNumberFocusNode;

  @override
  void initState() {
    setInitials();
    super.initState();
  }

  void setInitials() {
    _emailTEController = TextEditingController();
    _firstNameTEController = TextEditingController();
    _lastNameTEController = TextEditingController();
    _mobileNumberTEController = TextEditingController();
    _passwordTEController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _mobileNumberFocusNode = FocusNode();
    getUserData();
  }

  void getUserData() {
    UserData userData = Get.find<UserViewModel>().userData;
    _emailTEController.text = userData.email.toString();
    _firstNameTEController.text = userData.firstName.toString();
    _lastNameTEController.text = userData.lastName.toString();
    _mobileNumberTEController.text = userData.mobile.toString();
    _passwordTEController.text = userData.password.toString();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: getApplicationAppBar(context: context, disableNavigation: true),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return BackgroundWidget(
            childWidget: SingleChildScrollView(
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GetBuilder<UserViewModel>(builder: (viewModel) {
                        if (viewModel.base64Image.isNotEmpty) {
                          return CircleAvatar(
                            radius: 90,
                            backgroundImage: MemoryImage(
                              base64Decode(
                                viewModel.base64Image,
                              ),
                            ),
                          );
                        }
                        return CircleAvatar(
                          radius: 90,
                          backgroundImage: (viewModel
                                  .userData.photo!.isNotEmpty)
                              ? MemoryImage(
                                  base64Decode(
                                    viewModel.userData.photo.toString(),
                                  ),
                                )
                              : const AssetImage(AppAssets.userDefaultImage),
                        );
                      }),
                    ),
                    const Gap(15),
                    Text(
                      AppStrings.updateProfileScreenTitle,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const Gap(15),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        Get.find<UserViewModel>().getImageFromGallery();
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: screenWidth * 0.25,
                              decoration: const BoxDecoration(
                                  color: AppColor.photoPickerColor,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(5),
                                      bottomLeft: Radius.circular(5))),
                              alignment: Alignment.center,
                              child: Text(
                                AppStrings.photoPickerText,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                            const Gap(20),
                            SizedBox(
                              width: screenWidth * 0.55,
                              child: GetBuilder<UserViewModel>(
                                builder: (viewModel) {
                                  if (viewModel.imageName.isEmpty) {
                                    return const Text(
                                      overflow: TextOverflow.ellipsis,
                                      AppStrings.chooseImageFileText,
                                      style: TextStyle(color: Colors.black),
                                    );
                                  }
                                  return Text(
                                      overflow: TextOverflow.ellipsis,
                                      viewModel.imageName,
                                      style:
                                          const TextStyle(color: Colors.black));
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(20),
                    UpdateProfileScreenForm(
                        emailTEController: _emailTEController,
                        firstNameTEController: _firstNameTEController,
                        lastNameTEController: _lastNameTEController,
                        mobileNumberTEController: _mobileNumberTEController,
                        passwordTEController: _passwordTEController,
                        formKey: _formKey,
                        emailFocusNode: _emailFocusNode,
                        passwordFocusNode: _passwordFocusNode,
                        firstNameFocusNode: _firstNameFocusNode,
                        lastNameFocusNode: _lastNameFocusNode,
                        mobileNumberFocusNode: _mobileNumberFocusNode,
                        onPressed: (viewModel) {
                          if (_formKey.currentState!.validate() &&
                              !viewModel.isLoading) {
                            updateProfile(viewModel);
                          }
                          FocusScope.of(context).unfocus();
                        })
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void updateProfile(UserViewModel viewModel) async {
    bool status = await viewModel.updateUserData(
        email: _emailTEController.text.trim(),
        firstName: _firstNameTEController.text.trim(),
        lastName: _lastNameTEController.text.trim(),
        mobile: _mobileNumberTEController.text.trim(),
        password: _passwordTEController.text);
    if (status && mounted) {
      AppSnackBar().showSnackBar(
          title: AppStrings.updateUserProfileSuccessTitle,
          content: AppStrings.updateUserProfileSuccessMessage,
          contentType: ContentType.success,
          color: AppColor.snackBarSuccessColor,
          context: context);
      Get.back();
      return;
    }
    if (mounted) {
      Failure failure = viewModel.response as Failure;
      AppSnackBar().showSnackBar(
        title: AppStrings.updateUserProfileFailureTitle,
        content: failure.message,
        contentType: ContentType.failure,
        color: AppColor.snackBarFailureColor,
        context: context,
      );
    }
  }

  @override
  void dispose() {
    _emailTEController.dispose();
    _firstNameTEController.dispose();
    _lastNameTEController.dispose();
    _mobileNumberTEController.dispose();
    _passwordTEController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _mobileNumberFocusNode.dispose();
    super.dispose();
  }
}
