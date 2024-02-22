import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trilo/constants/ui_constants.dart';
import 'package:trilo/locator.dart';
import 'package:trilo/services/auth_service.dart';

import '../../constants/regex_patterns.dart';
import '../../constants/route_names.dart';
import '../../services/navigation_service.dart';
import '../../widgets/input_field.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

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
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
    if (!mounted) return;
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      // 'version.securityPatch': build.version.securityPatch,
      // 'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      // 'version.previewSdkInt': build.version.previewSdkInt,
      // 'version.incremental': build.version.incremental,
      // 'version.codename': build.version.codename,
      // 'version.baseOS': build.version.baseOS,
      // 'board': build.board,
      // 'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      // 'display': build.display,
      // 'fingerprint': build.fingerprint,
      // 'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      // 'product': build.product,
      // 'supported32BitAbis': build.supported32BitAbis,
      // 'supported64BitAbis': build.supported64BitAbis,
      // 'supportedAbis': build.supportedAbis,
      // 'tags': build.tags,
      // 'type': build.type,
      // 'isPhysicalDevice': build.isPhysicalDevice,
      // 'systemFeatures': build.systemFeatures,
      // 'displaySizeInches':
      //     ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
      // 'displayWidthPixels': build.displayMetrics.widthPx,
      // 'displayWidthInches': build.displayMetrics.widthInches,
      // 'displayHeightPixels': build.displayMetrics.heightPx,
      // 'displayHeightInches': build.displayMetrics.heightInches,
      // 'displayXDpi': build.displayMetrics.xDpi,
      // 'displayYDpi': build.displayMetrics.yDpi,
      // 'serialNumber': build.serialNumber,
    };
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
      setState(() {
        isLoading = true;
      });
      await _authService.createAccount(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneNumberController.text,
        email: _emailController.text,
        password: _passwordController.text,
        deviceInfo: _deviceData,
      );
      setState(() {
        isLoading = false;
      });
      _navigationService.navigateToReplacement(storesListRoute);
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

    return Scaffold(
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            sliver(theme),
          ];
        },
        body: pageBody(theme),
      ),
    );
  }

  Widget sliver(ThemeData theme) {
    return SliverAppBar(
      automaticallyImplyLeading: true,
      expandedHeight: ScreenSize.width / 2,
      pinned: true,
      stretch: true,
      elevation: 0.0,
      stretchTriggerOffset: 100,
      title: const Text("Register user"),
      flexibleSpace: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: ScreenSize.width >= 600
              ? const Radius.circular(60)
              : const Radius.circular(25),
        ),
        child: FlexibleSpaceBar(
          background: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                "images/ericsson-mobility-report-novembe.png",
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              Container(
                color: Colors.black26,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Register user",
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
    );
  }

  Widget pageBody(ThemeData theme) {
    return Container(
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
          padding: const EdgeInsets.symmetric(vertical: 32),
          children: <Widget>[
            _createAccountForm(theme),
            Spacing.verticalSpace48,
            signUpButton(theme),
            Spacing.verticalSpace16,
            InkWell(
              onTap: () =>
                  _navigationService.navigateToReplacement(welcomeViewRoute),
              child: Text(
                "Already have an account? Sign in",
                style: theme.textTheme.titleMedium!.copyWith(
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
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
    return InputField(
      isLoading: isLoading,
      autofocus: true,
      focusNode: _firstNameFocus,
      onEditingComplete: () => _firstNameEditingComplete(),
      controller: _firstNameController,
      hintText: "First name",
      validator: (val) => val!.length < 3 ? "Invalid name" : null,
    );
  }

  Widget _lastNameInputField(
    ThemeData theme,
  ) {
    return InputField(
      isLoading: isLoading,
      focusNode: _lastNameFocus,
      onEditingComplete: () => _lastNameEditingComplete(),
      controller: _lastNameController,
      hintText: "Last name",
      validator: (val) => val!.length < 3 ? "Invalid name" : null,
    );
  }

  Widget _emailInputField(
    ThemeData theme,
  ) {
    return InputField(
      isLoading: isLoading,
      focusNode: _emailFocus,
      onEditingComplete: () => _emailEditingComplete(),
      controller: _emailController,
      hintText: "Email address",
      validator: (val) =>
          val!.isEmpty || !emailPattern.hasMatch(val) ? "Invalid email" : null,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _phoneInputField(
    ThemeData theme,
  ) {
    return InputField(
      isLoading: isLoading,
      focusNode: _phoneFocus,
      onEditingComplete: () => _phoneEditingComplete(),
      controller: _phoneNumberController,
      hintText: "Phone number",
      validator: (val) => !phoneNumberPattern.hasMatch(val!) || val.length < 10
          ? "Invalid phone number"
          : null,
      keyboardType: TextInputType.phone,
    );
  }

  Widget _passwordInputField(
    ThemeData theme,
  ) {
    return InputField(
      isLoading: isLoading,
      focusNode: _passwordFocus,
      onEditingComplete: () => _passwordEditingComplete(),
      obscureText: true,
      controller: _passwordController,
      hintText: "Password",
      validator: (val) => val!.length < 8 ? "Password is too short" : null,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
    );
  }

  Widget signUpButton(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 54,
          width: 192,
          child: ElevatedButton(
            onPressed: () async =>
                !isLoading && _createAccountFormKey.currentState!.validate()
                    ? await signUp()
                    : null,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : Text(
                    "Sign Up",
                    style: theme.textTheme.headlineSmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
