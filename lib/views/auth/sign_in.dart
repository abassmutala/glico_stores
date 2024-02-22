import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trilo/locator.dart';

import '../../constants/route_names.dart';
import '../../constants/ui_constants.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/navigation_service.dart';
import '../../widgets/input_field.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _uniqueCodeFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _uniqueCodeController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  _emailEditingComplete() => FocusScope.of(context).nextFocus();
  _passwordEditingComplete() => FocusScope.of(context).nextFocus();

  late bool isLoading;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
    isLoading = false;
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
    _emailController.dispose();
    _emailFocus.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  final NavigationService _navigationService = locator<NavigationService>();
  final AuthService _auth = locator<AuthService>();

  Future signIn(ThemeData theme) async {
    try {
      setState(() {
        isLoading = true;
      });
      debugPrint("Loading");
      final user = await _auth.signInWithEmail(
          _emailController.text, _passwordController.text);
      setState(() {
        isLoading = false;
      });
      await showUniqueCodeInput(theme, user);
    } on PlatformException catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Sign in failed"),
          content: Text("${e.message}"),
        ),
      );
    }
  }

  // Future validateCodes(User user) async {
  //   try {
  //     setState(() {
  //       isLoading = true;
  //     });
  //     final valid = await DatabaseService().checkIfCredentialsMatch(
  //         user, _uniqueCodeController.text, _deviceData["id"]);
  //     setState(() {
  //       isLoading = false;
  //     });
  //     if (valid) {
  //       _navigationService.navigateToReplacement(storesListRoute);
  //     }
  //     // await showErrorDialog();
  //   } on PlatformException {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     await showErrorDialog();
  //   }
  // }

  Future<dynamic> showErrorDialog() {
    return showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text("Error signing in"),
        content: Text(
            "We could not verify your credentials. Perhaps, the unique code you entered is incorrect, or you are signing in from a device different from the one you created your account with. If problem persist, contact the support team."),
      ),
    );
  }

  Future<dynamic> showUniqueCodeInput(ThemeData theme, User user) {
    return showDialog(
      context: context,
      builder: ((context) => SimpleDialog(
            title: const Text("Enter unique code"),
            children: [
              Form(
                key: _uniqueCodeFormKey,
                child: Column(
                  children: [
                    InputField(
                      autofocus: true,
                      hintText: "Unique code",
                      isLoading: isLoading,
                      controller: _uniqueCodeController,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(
                      height: 54,
                      width: 192,
                      child: ElevatedButton(
                        child: Text(
                          "Continue",
                          style: theme.textTheme.titleMedium!
                              .copyWith(color: Colors.white),
                        ),
                        // onPressed: () async =>
                        //     _uniqueCodeFormKey.currentState!.validate() &&
                        //             !isLoading
                        //         ? await validateCodes(user)
                        //         : null,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Image.asset(
          "images/ericsson-mobility-report-novembe.png",
          fit: BoxFit.cover,
        ),
        const ModalBarrier(
          color: Colors.black54,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            shadowColor: Colors.transparent,
            automaticallyImplyLeading: false,
            toolbarHeight: kToolbarHeight * 5,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "images/ericsson-mobility-report-novembe.png",
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
                      // SizedBox(
                      //   width: 320,
                      //   child:
                      //       SvgPicture.asset("images/glico_general_logo.svg"),
                      // ),
                      Text(
                        "Sign In",
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
                  // _signInForm(theme),
                  // Spacing.verticalSpace8,
                  // TextButton(
                  //   onPressed: () {
                  //     _navigationService.navigateTo(forgotPasswordRoute);
                  //   },
                  //   child: const Text(
                  //     "Forgot password?",
                  //     style: TextStyle(
                  //         decoration: TextDecoration.underline,
                  //         color: subtitleColor),
                  //   ),
                  // ),
                  Spacing.verticalSpace24,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 54,
                        width: 192,
                        child: ElevatedButton(
                          child: Text(
                            "Sign in",
                            style: theme.textTheme.titleMedium!
                                .copyWith(color: Colors.white),
                          ),
                          // onPressed: () async =>
                          //     _signInFormKey.currentState!.validate() &&
                          //             !isLoading
                          //         ? await signIn(theme)
                          //         : null,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  Spacing.verticalSpace24,
                  InkWell(
                    onTap: () => _navigationService
                        .navigateToReplacement(signUpViewRoute),
                    child: Text(
                      "Don't have an account? Create account",
                      style: theme.textTheme.titleMedium!
                          .copyWith(decoration: TextDecoration.underline),
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
}
