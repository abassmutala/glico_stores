import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glico_stores/constants/app_colors.dart';
import 'package:glico_stores/constants/regex_patterns.dart';
import 'package:glico_stores/constants/route_names.dart';
import 'package:glico_stores/constants/ui_constants.dart';
import 'package:glico_stores/locator.dart';
import 'package:glico_stores/services/auth_service.dart';

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
      isLoading = true;
      await _auth.sendPasswordResetEmail(_emailController.text);
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "A password reset email has been sent to your inbox. Check your email inbox to reset your password."),
        ),
      );
      _navigationService.navigateToReplacement(signInViewRoute);
    } on PlatformException catch (e) {
      isLoading = false;
      throw PlatformException(code: e.code, message: e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot password"),
      ),
      body: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 450,
          ),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              children: <Widget>[
                Spacing.verticalSpace24,
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
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        enabled: isLoading == false,
        autofocus: true,
        focusNode: _emailFocus,
        onEditingComplete: () => _emailEditingComplete(),
        controller: _emailController,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
            filled: true,
            fillColor: kGlicoInputFill,
            border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: borderColor),
            ),
            // label: const Text("Name of business"),
            floatingLabelStyle:
                theme.textTheme.titleLarge!.copyWith(color: Colors.grey),
            hintText: "Email address",
            hintStyle: const TextStyle(color: Colors.grey),
            floatingLabelBehavior: FloatingLabelBehavior.auto),
        style: theme.textTheme.titleLarge,
        validator: (val) =>
            !emailPattern.hasMatch(val!) ? "Invalid email address" : null,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _passwordInputField(
    ThemeData theme,
  ) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        enabled: isLoading == false,
        autofocus: true,
        focusNode: _passwordFocus,
        onEditingComplete: () => _passwordEditingComplete(),
        controller: _passwordController,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
            filled: true,
            fillColor: kGlicoInputFill,
            border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: borderColor),
            ),
            // label: const Text("Name of business"),
            floatingLabelStyle:
                theme.textTheme.titleLarge!.copyWith(color: Colors.grey),
            hintText: "Password",
            hintStyle: const TextStyle(color: Colors.grey),
            floatingLabelBehavior: FloatingLabelBehavior.auto),
        style: theme.textTheme.titleLarge,
        validator: (val) => val!.length < 8 ? "Password is too short" : null,
        keyboardType: TextInputType.text,
        obscureText: true,
        textInputAction: TextInputAction.done,
      ),
    );
  }
}
