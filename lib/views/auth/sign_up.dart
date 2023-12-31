import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
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
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        deviceData = switch (defaultTargetPlatform) {
          TargetPlatform.android =>
            _readAndroidBuildData(await deviceInfoPlugin.androidInfo),
          TargetPlatform.iOS =>
            _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
          TargetPlatform.linux =>
            _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
          TargetPlatform.windows =>
            _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
          TargetPlatform.macOS =>
            _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
          TargetPlatform.fuchsia => <String, dynamic>{
              'Error:': 'Fuchsia platform isn\'t supported'
            },
        };
      }
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

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': describeEnum(data.browserName),
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'patchVersion': data.patchVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
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
      _navigationService.navigateToReplacement(businessesListRoute);
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
                padding: const EdgeInsets.symmetric(vertical: 32),
                children: <Widget>[
                  _createAccountForm(theme),
                  Spacing.verticalSpace48,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 54,
                        width: 192,
                        child: ElevatedButton(
                          onPressed: () async => !isLoading &&
                                  _createAccountFormKey.currentState!.validate()
                              ? await signUp()
                              : null,
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Text(
                                  "Sign Up",
                                  style:
                                      theme.textTheme.headlineSmall!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  Spacing.verticalSpace16,
                  InkWell(
                    onTap: () => _navigationService
                        .navigateToReplacement(signInViewRoute),
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
          ),
        ),
      ],
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
}
