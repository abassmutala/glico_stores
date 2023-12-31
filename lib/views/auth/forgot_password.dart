import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:glico_stores/constants/app_colors.dart';
import 'package:glico_stores/constants/regex_patterns.dart';
import 'package:glico_stores/constants/route_names.dart';
import 'package:glico_stores/constants/ui_constants.dart';
import 'package:glico_stores/locator.dart';
import 'package:glico_stores/services/auth_service.dart';
import 'package:glico_stores/widgets/input_field.dart';

import '../../services/navigation_service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _forgotPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  _emailEditingComplete() => FocusScope.of(context).nextFocus();
  _passwordEditingComplete() => FocusScope.of(context).nextFocus();

  late bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  final NavigationService _navigationService = locator<NavigationService>();
  final AuthService _auth = locator<AuthService>();

  Future forgotPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _auth.sendPasswordResetEmail(_emailController.text);
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "A password reset email has been sent to your inbox. Check your email inbox to reset your password."),
        ),
      );
      _navigationService.navigateToReplacement(signInViewRoute);
    } on PlatformException catch (e) {
      setState(() {
        isLoading = false;
      });
      throw PlatformException(code: e.code, message: e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Image.asset(
          "images/rectangle.png",
          fit: BoxFit.cover,
        ),
        const ModalBarrier(
          color: modalBg,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            shadowColor: Colors.transparent,
            automaticallyImplyLeading: false,
            toolbarHeight: kToolbarHeight * 4,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "images/rectangle.png",
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  const ModalBarrier(
                    color: Colors.black45,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 320,
                        child:
                            SvgPicture.asset("images/glico_general_logo.svg"),
                      ),
                      Text(
                        "Forgot Password",
                        style: theme.textTheme.headlineMedium!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: ScreenSize.width >= 600
                    ? const Radius.circular(60)
                    : const Radius.circular(25),
              ),
              color: Colors.white,
            ),
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: ScreenSize.width >= 600 ? 64 : 16,
              ),
              child: ListView(
                padding: const EdgeInsets.only(top: 32),
                children: <Widget>[
                  Spacing.verticalSpace16,
                  Text(
                    "Enter your email address below to receive a password reset email.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  Spacing.verticalSpace24,
                  _forgotPasswordForm(theme),
                  Spacing.verticalSpace24,
                  ElevatedButton(
                    // isLoading: isLoading!,
                    // margin: Insets.verticalPadding12,
                    child: Text(
                      "Request email",
                      style: theme.textTheme.titleMedium!
                          .copyWith(color: Colors.white),
                    ),
                    onPressed: () async =>
                        _forgotPasswordFormKey.currentState!.validate() &&
                                !isLoading
                            ? await forgotPassword()
                            : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Form _forgotPasswordForm(
    ThemeData theme,
  ) {
    return Form(
      key: _forgotPasswordFormKey,
      child: Column(
        children: <Widget>[
          _emailInputField(theme),
        ],
      ),
    );
  }

  Widget _emailInputField(
    ThemeData theme,
  ) {
    return InputField(
      isLoading: isLoading,
      autofocus: true,
      focusNode: _emailFocus,
      onEditingComplete: () => _emailEditingComplete(),
      controller: _emailController,
      hintText: "Email address",
      validator: (val) =>
          !emailPattern.hasMatch(val!) ? "Invalid email address" : null,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _passwordInputField(
    ThemeData theme,
  ) {
    return InputField(
      isLoading: isLoading,
      autofocus: true,
      focusNode: _passwordFocus,
      onEditingComplete: () => _passwordEditingComplete(),
      controller: _passwordController,
      hintText: "Password",
      validator: (val) => val!.length < 8 ? "Password is too short" : null,
      keyboardType: TextInputType.text,
      obscureText: true,
      textInputAction: TextInputAction.done,
    );
  }
}
