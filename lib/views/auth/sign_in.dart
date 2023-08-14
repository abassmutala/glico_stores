import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glico_stores/constants/app_colors.dart';
import 'package:glico_stores/constants/regex_patterns.dart';
import 'package:glico_stores/constants/route_names.dart';
import 'package:glico_stores/constants/ui_constants.dart';
import 'package:glico_stores/locator.dart';
import 'package:glico_stores/services/auth_service.dart';

import '../../services/navigation_service.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();
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

  Future signIn() async {
    try {
      isLoading = true;
      await _auth.signInWithEmail(
          _emailController.text, _passwordController.text);
      isLoading = false;
      _navigationService.navigateToReplacement(businessesListRoute);
    } on PlatformException catch (e) {
      isLoading = false;
      throw PlatformException(code: e.code, message: e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
                  "Sign in",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
                Spacing.verticalSpace8,
                Text(
                  "Fill the fields below",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                Spacing.verticalSpace24,
                _signInForm(theme),
                Spacing.verticalSpace16,
                TextButton(
                  onPressed: () {
                    _navigationService.navigateTo(forgotPasswordRoute);
                  },
                  child: const Text("Forgot password?"),
                ),
                Spacing.verticalSpace24,
                ElevatedButton(
                  // isLoading: isLoading!,
                  // margin: Insets.verticalPadding12,
                  child: Text(
                    "Sign in",
                    style: theme.textTheme.titleMedium!
                        .copyWith(color: Colors.white),
                  ),
                  onPressed: () async =>
                      _signInFormKey.currentState!.validate() && !isLoading
                          ? await signIn()
                          : null,
                ),
                Spacing.verticalSpace24,
                InkWell(
                  onTap: () =>
                      _navigationService.navigateToReplacement(signUpViewRoute),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account?",
                      children: [
                        TextSpan(
                          text: " Create account",
                          style: TextStyle(color: theme.colorScheme.primary),
                        )
                      ],
                      style: theme.textTheme.titleMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Form _signInForm(
    ThemeData theme,
  ) {
    return Form(
      key: _signInFormKey,
      child: Column(
        children: <Widget>[
          _emailInputField(theme),
          _passwordInputField(theme),
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
