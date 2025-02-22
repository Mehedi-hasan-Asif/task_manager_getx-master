import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:task_manager_getx/utils/app_strings.dart';
import 'package:task_manager_getx/views/authScreens/signUpScreen/sign_up_form.dart';
import 'package:task_manager_getx/views/widgets/app_snackbar.dart';
import 'package:task_manager_getx/views/widgets/background_widget.dart';
import 'package:task_manager_getx/views/widgets/sign_in_bottom_text.dart';

import '../../../utils/app_color.dart';
import '../../../viewModels/auth_view_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(body: OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return BackgroundWidget(
          childWidget: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.1,
                vertical: (orientation == Orientation.portrait)
                    ? screenHeight * 0.2
                    : screenHeight * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.signUpHeaderText,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const Gap(20),
                  SignUpForm(
                    emailTEController: _emailTEController,
                    passwordTEController: _passwordTEController,
                    formKey: _formKey,
                    emailFocusNode: _emailFocusNode,
                    passwordFocusNode: _passwordFocusNode,
                    screenWidth: screenWidth,
                    firstNameTEController: _firstNameTEController,
                    lastNameTEController: _lastNameTEController,
                    mobileNumberTEController: _mobileNumberTEController,
                    firstNameFocusNode: _firstNameFocusNode,
                    lastNameFocusNode: _lastNameFocusNode,
                    mobileNumberFocusNode: _mobileNumberFocusNode,
                    registerUser: registerUser,
                  ),
                  const Gap(30),
                  SignInBottomText(route: gotoSignIn)
                ],
              ),
            ),
          ),
        );
      },
    ));
  }

  Future<void> registerUser() async {
    bool status = await Get.find<AuthViewModel>().registerUser(
        email: _emailTEController.text.trim(),
        firstName: _firstNameTEController.text.trim(),
        lastName: _lastNameTEController.text.trim(),
        mobileNumber: _mobileNumberTEController.text.trim(),
        password: _passwordTEController.text.trim());
    if (mounted && status) {
      AppSnackBar().showSnackBar(
          title: AppStrings.registrationSuccessTitle,
          content: AppStrings.registrationSuccessMessage,
          contentType: ContentType.success,
          color: AppColor.snackBarSuccessColor,
          context: context);
      gotoSignIn();
    }
    if (mounted && !status) {
      AppSnackBar().showSnackBar(
          title: AppStrings.registrationFailureTitle,
          content: AppStrings.registrationFailureMessage,
          contentType: ContentType.failure,
          color: AppColor.snackBarFailureColor,
          context: context);
    }
  }

  void gotoSignIn() {
    Get.find<AuthViewModel>().setPasswordObscure = true;
    Get.back();
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
