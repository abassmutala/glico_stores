import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glico_stores/constants/regex_patterns.dart';
import 'package:glico_stores/constants/route_names.dart';
import 'package:glico_stores/constants/ui_constants.dart';
import 'package:glico_stores/locator.dart';
import 'package:glico_stores/services/auth_service.dart';

import '../../services/navigation_service.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _createAccountFormKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  _firstNameEditingComplete() => FocusScope.of(context).nextFocus();
  _lastNameEditingComplete() => FocusScope.of(context).nextFocus();
  _emailEditingComplete() => FocusScope.of(context).nextFocus();
  _phoneEditingComplete() =>
      FocusScope.of(context).requestFocus(_passwordFocus);
  _passwordEditingComplete() => FocusScope.of(context).nextFocus();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _firstNameFocus.dispose();
    _emailController.dispose();
    _emailFocus.dispose();
    _phoneNumberController.dispose();
    _phoneFocus.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  final AuthBase _authService = locator<AuthService>();
  final NavigationService _navigationService = locator<NavigationService>();

  Future signUp() async {
    try {
      isLoading = true;
      await _authService.createAccount(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phone: _phoneNumberController.text,
          email: _emailController.text,
          password: _passwordController.text);
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
                  "Create account",
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
                _createAccountForm(theme),
                Spacing.verticalSpace16,
                ElevatedButton(
                  // isLoading: isLoading!,
                  // margin: Insets.verticalPadding12,
                  child: Text(
                    "Create account",
                    style: theme.textTheme.titleMedium!
                        .copyWith(color: Colors.white),
                  ),
                  onPressed: () async => !isLoading &&
                          _createAccountFormKey.currentState!.validate()
                      ? await signUp()
                      : null,
                ),
                Spacing.verticalSpace24,
                InkWell(
                  onTap: () => _navigationService
                      .navigateToReplacement(businessesListRoute),
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account?",
                      children: [
                        TextSpan(
                          text: " Sign in",
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

  Form _createAccountForm(
    ThemeData theme,
  ) {
    return Form(
      key: _createAccountFormKey,
      child: Column(
        children: <Widget>[
          _nameInputField(theme),
          _lastNameInputField(theme),
          _emailInputField(theme),
          _phoneInputField(theme),
          _passwordInputField(theme),
        ],
      ),
    );
  }

  Widget _nameInputField(
    ThemeData theme,
  ) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        enabled: isLoading == false,
        autofocus: true,
        focusNode: _firstNameFocus,
        onEditingComplete: () => _firstNameEditingComplete(),
        controller: _firstNameController,
        // icon: Icons.email_outlined,
        decoration: const InputDecoration(
          labelText: "First name",
        ),
        validator: (val) => val!.length < 3 ? "Invalid name" : null,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _lastNameInputField(
    ThemeData theme,
  ) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        enabled: isLoading == false,
        autofocus: true,
        focusNode: _lastNameFocus,
        onEditingComplete: () => _lastNameEditingComplete(),
        controller: _lastNameController,
        // icon: Icons.email_outlined,
        decoration: const InputDecoration(
          labelText: "Last name",
        ),
        validator: (val) => val!.length < 3 ? "Invalid name" : null,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
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
        focusNode: _emailFocus,
        onEditingComplete: () => _emailEditingComplete(),
        controller: _emailController,
        // icon: Icons.email_outlined,
        decoration: const InputDecoration(
          labelText: "Email address",
        ),
        validator: (val) => val!.isEmpty || !emailPattern.hasMatch(val)
            ? "Invalid email"
            : null,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _phoneInputField(
    ThemeData theme,
  ) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        focusNode: _phoneFocus,
        onEditingComplete: () => _phoneEditingComplete(),
        controller: _phoneNumberController,
        decoration: const InputDecoration(
          labelText: "Phone number",
        ),
        validator: (val) =>
            !phoneNumberPattern.hasMatch(val!) || val.length < 10
                ? "Invalid phone number"
                : null,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        enabled: isLoading == false,
      ),
    );
  }

  Widget _passwordInputField(
    ThemeData theme,
  ) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        focusNode: _passwordFocus,
        onEditingComplete: () => _passwordEditingComplete(),
        obscureText: true,
        controller: _passwordController,
        decoration: const InputDecoration(
          labelText: "Password",
        ),
        validator: (val) => val!.length < 8 ? "Password is too short" : null,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        enabled: !isLoading,
      ),
    );
  }
}
