import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:glico_stores/constants/api_path.dart';
import 'package:glico_stores/constants/app_colors.dart';
import 'package:glico_stores/constants/regex_patterns.dart';
import 'package:glico_stores/constants/route_names.dart';
import 'package:glico_stores/constants/ui_constants.dart';
import 'package:glico_stores/locator.dart';

import 'package:glico_stores/models/business.dart';
import 'package:glico_stores/models/business_location.dart';
import 'package:glico_stores/models/user.dart';
import 'package:glico_stores/services/auth_service.dart';
import 'package:glico_stores/services/database_service.dart';
import 'package:glico_stores/services/image_picker_service.dart';
import 'package:glico_stores/services/location_service.dart';
import 'package:glico_stores/services/navigation_service.dart';
import 'package:glico_stores/services/storage_service.dart';
import 'package:glico_stores/utils/enums.dart';
import 'package:glico_stores/utils/utilities.dart';
import 'package:glico_stores/views/map_view.dart';
import 'package:glico_stores/widgets/input_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class AddBusiness extends StatefulWidget {
  const AddBusiness({super.key});

  @override
  State<AddBusiness> createState() => _AddBusinessState();
}

class _AddBusinessState extends State<AddBusiness> {
  final GlobalKey<FormState> _addBusinessFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _assetCostController = TextEditingController();
  final TextEditingController _premiumController = TextEditingController();
  final List<TextEditingController> _phoneInputControllers = [];
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _ownerFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _commentFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _assetCostFocus = FocusNode();
  final List<FocusNode> _phoneFocuses = [];

  _nameEditingComplete() => FocusScope.of(context).nextFocus();
  _ownerEditingComplete() => FocusScope.of(context).nextFocus();
  _addressEditingComplete() => FocusScope.of(context).nextFocus();
  _commentEditingComplete() => FocusScope.of(context).nextFocus();
  _assetCostEditingComplete() => FocusScope.of(context).nextFocus();

  late bool isLoading;
  late BusinessLocation? currentLocation;
  late BusinessLocation? currentAddress;
  late GeoPoint? coordinates;
  late List<File>? selectedImages;
  String dropdownValue = '';
  InsuranceType insuranceTypeValue = InsuranceType.unselected;

  void _addPhoneNumber() {
    setState(() {
      _phoneInputControllers.add(TextEditingController());
      _phoneFocuses.add(FocusNode());
    });
  }

  void _removePhoneNumber(int index) {
    setState(() {
      _phoneInputControllers.removeAt(index);
      _phoneFocuses.removeAt(index);
    });
  }

  @override
  void initState() {
    isLoading = false;
    coordinates = null;
    selectedImages = [];
    _addPhoneNumber();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _addressController.dispose();
    _assetCostController.dispose();
    super.dispose();
  }

  // const uuid = Uuid();

  // final uid = uuid.v5(Uuid.NAMESPACE_URL, "accessbank.com");
  final DatabaseService db = locator<DatabaseService>();
  final NavigationService navService = locator<NavigationService>();
  final LocationService locationService = locator<LocationService>();
  final ImagePickerService imagePickerService = locator<ImagePickerService>();
  final StorageService storageService = locator<StorageService>();

  Future _takeCameraImages() async {
    final pickedFiles = await imagePickerService.pickImageFromCamera();
    XFile? pickedFileList = pickedFiles;
    setState(() {
      if (pickedFileList != null) {
        selectedImages!.add(
          File(pickedFileList.path),
        );
      }
    });
  }

  Future _pickGalleryImages() async {
    final pickedFiles = await imagePickerService.pickMultipleImages();
    List<XFile> pickedFileList = pickedFiles;
    setState(() {
      if (pickedFileList.isNotEmpty) {
        for (var i = 0; i < pickedFileList.length; i++) {
          selectedImages!.add(
            File(pickedFileList[i].path),
          );
        }
      }
    });
  }

  Future getCurrentLocation() async {
    try {
      setState(() {
        isLoading = true;
      });
      currentLocation = await locationService.getAddressFromCoordinates();
      _addressController.text =
          "${currentLocation?.city}, ${currentLocation?.region}";
      setState(() {
        coordinates =
            GeoPoint(currentLocation!.latitude!, currentLocation!.longitude!);
      });
      setState(() {
        isLoading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Could not get location of business",
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      throw PlatformException(code: e.code);
    }
  }

  Future<List<String>> uploadPhotos(List<File> photos, String uid) async {
    List<String> downloadUrls = [];

    for (var i = 0; i < photos.length; i++) {
      final photo = photos[i];
      // final compressedImage = await storageService.compressImage(photo);
      // print("Photo: $compressedImage");
      final downloadUrl =
          await storageService.uploadPhoto(photo, APIPath.businessPhotos(uid));
      downloadUrls.add(downloadUrl);
    }
    return downloadUrls;
  }

  Future<void> updatePhotoReferences(List<String> links, String uid) async {
    for (String link in links) {
      await db.updateBusinessData(uid, {
        "photos": FieldValue.arrayUnion([link])
      });
    }
  }

  Future<void> addBusiness() async {
    final User? currentUser =
        Provider.of<AuthBase>(context, listen: false).currentUser;

    List<String> phoneNumbersList =
        _phoneInputControllers.map((e) => e.text).toList();
    final estimatedAssetValue =
        double.tryParse(_assetCostController.text.replaceAll(",", ""));
    final premium =
        double.tryParse(_premiumController.text.replaceAll(",", ""));
    Business newBusiness = Business(
      uid: "uid",
      name: _nameController.text.trim(),
      owner: _ownerController.text.trim(),
      address: _addressController.text.trim(),
      coordinates: coordinates,
      comment: _commentController.text.trim(),
      category: dropdownValue,
      phone: phoneNumbersList,
      insuranceType: insuranceTypeValue.name,
      estimatedAssetValue: estimatedAssetValue,
      premium: premium,
      insured: false,
      photos: [],
      regDate: Timestamp.fromDate(
        DateTime.now(),
      ),
      uniqueCode: Utilities.generateBusinessCode(_addressController.text),
    );
    try {
      setState(() {
        isLoading = true;
      });
      final uid = await db.createBusinessProfile(newBusiness);
      await db.updateBusinessUid(uid);
      selectedImages != null
          ? await uploadPhotos(selectedImages!, uid).then(
              (value) => updatePhotoReferences(value, uid),
            )
          : null;
      await db.updateRegisteredBusinessesForUser(currentUser!.uid, uid);
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Business added successfully"),
        ),
      );

      navService.navigateToReplacement(businessesListRoute);
    } on PlatformException catch (e) {
      setState(() {
        isLoading = false;
      });
      throw PlatformException(
        code: e.code,
        message: e.message,
      );
    }
  }

  static const borderColor = Color(0xFFceced2);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // return Stack(
    //   children: [
    //     Stack(
    //       fit: StackFit.expand,
    //       children: [
    //         Image.asset(
    //           "images/rectangle.png",
    //           fit: BoxFit.cover,
    //           alignment: Alignment.topCenter,
    //         ),
    //         Container(
    //           color: Colors.black54,
    //         ),
    //         Column(
    //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             SizedBox(
    //               width: 320,
    //               child: SvgPicture.asset("images/glico_general_logo.svg"),
    //             ),
    //           ],
    //         )
    //       ],
    //     ),
    //     DraggableScrollableSheet(
    //         maxChildSize: 0.85,
    //         minChildSize: 0.2,
    //         builder: (context, scrollController) {
    //           return Container(
    //             padding: const EdgeInsets.symmetric(horizontal: 20),
    //             decoration: const BoxDecoration(
    //                 color: Colors.white,
    //                 borderRadius:
    //                     BorderRadius.vertical(top: Radius.circular(30))),
    //             child: SingleChildScrollView(
    //               controller: scrollController,
    //               child: const Column(
    //                 children: [],
    //               ),
    //             ),
    //           );
    //         })
    //   ],
    // );
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
            toolbarHeight: kToolbarHeight * 2.5,
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
                        "Add business",
                        style: theme.textTheme.headlineSmall!.copyWith(
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
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 32),
                children: [
                  Form(
                    key: _addBusinessFormKey,
                    child: Column(
                      children: [
                        _nameInputField(theme),
                        _ownerInputField(theme),
                        _addressInputField(theme),
                        _mapView(coordinates),
                        _categoryInputField(theme),
                        _phoneNumberWidgets(theme),
                        _insuraneTypePicker(theme),
                        _estimatedAssetCostInputField(theme),
                        _premium(theme),
                        _commentInputField(theme),
                        _photosInputField(theme)
                      ],
                    ),
                  ),
                  Spacing.verticalSpace16,
                  submitButton(theme),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatWithCommas(String value) {
    final format = NumberFormat("#,###.##");
    return format.format(double.parse(value));
  }

  void _updatePremium(String value) {
    if (value.isEmpty) {
      _premiumController.text = '';
    } else {
      double inputValue = double.tryParse(value.replaceAll(',', '')) ?? 0;
      double result = inputValue * 0.025;
      final formattedResult = _formatWithCommas(result.toStringAsFixed(2));
      _premiumController.text = formattedResult;
      // result.toStringAsFixed(2); // Format result to 2 decimal places
    }
  }

  Widget _nameInputField(ThemeData theme) {
    return InputField(
      isLoading: isLoading,
      hintText: "Business name",
      autofocus: true,
      focusNode: _nameFocus,
      onEditingComplete: () => _nameEditingComplete(),
      controller: _nameController,
      validator: (val) => val!.length < 2 ? "Business name is too short" : null,
    );
  }

  Widget _ownerInputField(ThemeData theme) {
    return InputField(
      isLoading: isLoading,
      hintText: "Owner's name",
      focusNode: _ownerFocus,
      onEditingComplete: () => _ownerEditingComplete(),
      controller: _ownerController,
      validator: (val) => val!.length < 3 ? "Name is too short" : null,
    );
  }

  Widget _addressInputField(ThemeData theme) {
    return InputField(
      isLoading: isLoading,
      hintText: "Tap to find address",
      focusNode: _addressFocus,
      onEditingComplete: () => _addressEditingComplete(),
      controller: _addressController,
      validator: (val) => val!.length < 3 ? "Invalid address" : null,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      readOnly: true,
      onTap: () => getCurrentLocation(),
    );
  }

  Widget _estimatedAssetCostInputField(ThemeData theme) {
    return InputField(
      isLoading: isLoading,
      hintText: "Estimated cost of assets (GH¢)",
      focusNode: _assetCostFocus,
      onEditingComplete: () => _assetCostEditingComplete(),
      controller: _assetCostController,
      onChanged: (val) {
        _updatePremium(val);
      },
      // onChanged: (val) {
      //   _premiumController.text =
      //     (double.parse(_assetCostController.text) * 0.025).toString();
      // },
      inputFormatters: [
        // FilteringTextInputFormatter.digitsOnly,
        ThousandsSeparatorInputFormatter(),
      ],
      // onChanged: (val) {
      //   if (val.isNotEmpty) {
      //     // _premiumController.text = "${(double.parse(val) * 0.025)}";
      //     String formattedValue =
      //         Utilities.formatNumber(_assetCostController.text);
      //     _assetCostController.value = _assetCostController.value.copyWith(
      //         text: formattedValue,
      //         selection:
      //             TextSelection.collapsed(offset: formattedValue.length));
      //   }
      // },
      validator: (val) => val!.length < 3 ? "Name is too short" : null,
      keyboardType: TextInputType.number,
    );
  }

  Widget _premium(ThemeData theme) {
    return InputField(
      isLoading: isLoading,
      hintText: "Premium",
      readOnly: true,
      controller: _premiumController,
    );
  }

  Widget _commentInputField(ThemeData theme) {
    return InputField(
      isLoading: isLoading,
      hintText: "Comment",
      focusNode: _commentFocus,
      onEditingComplete: () => _commentEditingComplete(),
      controller: _commentController,
      maxLines: 6,
      maxLength: 250,
      borderRadius: 25.0,
    );
  }

  Widget _photosInputField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Add photos of business",
          style: theme.textTheme.titleMedium!.copyWith(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        Spacing.verticalSpace8,
        Wrap(
          spacing: 12.0,
          children: [
            SizedBox(
              width: 95.5,
              height: 95.5,
              child: FloatingActionButton.large(
                heroTag: "business photos",
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                backgroundColor: kGlicoInputFill,
                elevation: 0.0,
                child: const Icon(
                  LucideIcons.plus,
                  color: Colors.black45,
                  size: 48,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => SimpleDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      title: Text(
                        "Choose photos",
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      // height: kToolbarHeight * 2,
                      children: [
                        ListTile(
                          // dense: true,
                          leading: const Icon(LucideIcons.camera),
                          title: Text("Take a photo",
                              style: theme.textTheme.bodyLarge),
                          onTap: () async {
                            navService.pop();
                            _takeCameraImages();
                          },
                        ),
                        ListTile(
                          // dense: true,
                          leading: const Icon(LucideIcons.image),
                          title: Text("Choose from gallery",
                              style: theme.textTheme.bodyLarge),
                          onTap: () {
                            navService.pop();
                            // pickImages();
                            _pickGalleryImages();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Wrap(
            //   spacing: 12.0,
            //   children: selectedImages != null
            //       ? selectedImages!
            //           .map(
            //             (e) => Stack(
            //               children: [
            //               InkWell(
            //                 onTap: () {},
            //                 child: Container(
            //                   padding: EdgeInsets.all(8.0),
            //                   child: Icon(LucideIcons.minusCircle, color: theme.colorScheme.error,),
            //                 ),
            //               ),
            //                 ClipRRect(
            //                   borderRadius: BorderRadius.circular(24.0),
            //                   child: SizedBox(
            //                     // margin: const EdgeInsets.only(right: 8.0),
            //                     width: 95.5,
            //                     height: 95.5,
            //                     child: Image.file(
            //                       File(e.path),
            //                       fit: BoxFit.cover,
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           )
            //           .toList()
            //       : [],
            // ),
            selectedImages != null
                ? Wrap(
                    spacing: 12.0,
                    children: List<Widget>.generate(
                      selectedImages!.length,
                      (index) {
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24.0),
                              child: SizedBox(
                                // margin: const EdgeInsets.only(right: 8.0),
                                width: 95.5,
                                height: 95.5,
                                child: Image.file(
                                  File(selectedImages![index].path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedImages!.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  LucideIcons.minusCircle,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : Container()
          ],
        )
      ],
    );
  }

  Widget _categoryInputField(ThemeData theme) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: db.getCategoriesStream(),
          builder: (context, snapshot) {
            final categories = snapshot.data;
            return DropdownButtonFormField<String>(
              items: categories
                  ?.map(
                    (e) => DropdownMenuItem(
                      value: e["value"] as String,
                      enabled: e["value"] != "",
                      child: Text(e["name"]),
                    ),
                  )
                  .toList(),
              value: dropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              focusNode: _categoryFocus,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16.0),
                filled: true,
                fillColor: kGlicoInputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(60.0),
                  borderSide: BorderSide.none,
                ),
                hintText: "Category",
                hintStyle: TextStyle(
                  color: dropdownValue == "" ? theme.hintColor : Colors.black,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              style: theme.textTheme.titleLarge,
            );
          }),
    );
  }

  Widget _insuraneTypePicker(ThemeData theme) {
    final List<Map<InsuranceType, String>> insuranceTypes = [
      {InsuranceType.unselected: "Insurance type"},
      {InsuranceType.business: "Business"},
      {InsuranceType.products: "Products"},
    ];

    List<DropdownMenuItem<InsuranceType>> buildDropdownMenuItems() {
      return insuranceTypes.map((insuranceTypeMap) {
        InsuranceType insuranceType = insuranceTypeMap.keys.first;
        String value = insuranceTypeMap.values.first;

        return DropdownMenuItem<InsuranceType>(
          value: insuranceType,
          enabled: value != "Insurance type",
          child: Text(
            value,
            style: TextStyle(
                color:
                    value == "Insurance type" ? theme.hintColor : Colors.black),
          ),
        );
      }).toList();
    }

    return Padding(
      padding: Insets.verticalPadding8,
      child: DropdownButtonFormField<InsuranceType>(
        items: buildDropdownMenuItems(),
        value: insuranceTypeValue,
        onChanged: (InsuranceType? newValue) {
          setState(() {
            insuranceTypeValue = newValue!;
          });
        },
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16.0),
            filled: true,
            fillColor: kGlicoInputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(60.0),
              borderSide: BorderSide.none,
            ),
            floatingLabelStyle:
                theme.textTheme.titleLarge!.copyWith(color: Colors.grey),
            hintText: "Insurance type",
            hintStyle: const TextStyle(color: Colors.grey),
            floatingLabelBehavior: FloatingLabelBehavior.auto),
        style: theme.textTheme.titleLarge, // validator: (val) =>
      ),
    );
  }

  Widget _mapView(GeoPoint? center) {
    if (center == null) {
      return Container();
    } else {
      return Padding(
        padding: Insets.verticalPadding8,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: Container(
            height: 240.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: borderColor),
            ),
            child: MapView(
              latitude: center.latitude,
              longitude: center.longitude,
            ),
          ),
        ),
      );
    }
  }

  Widget _phoneNumberWidgets(ThemeData theme) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _phoneInputControllers.length,
      itemBuilder: (context, index) => Row(
        children: [
          Flexible(
            child: InputField(
              isLoading: isLoading,
              hintText: "Phone number",
              focusNode: _phoneFocuses[index],
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
              controller: _phoneInputControllers[index],
              validator: (val) => !phoneNumberPattern.hasMatch(val!)
                  ? "Invalid phone number"
                  : null,
              keyboardType: TextInputType.phone,
            ),
          ),
          Spacing.horizontalSpace8,
          FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: kGlicoInputFill,
            heroTag: "remove phone number $index",
            elevation: 0.0,
            onPressed: () => _removePhoneNumber(index),
            child: const Icon(
              LucideIcons.minus,
              color: Colors.black54,
            ),
          ),
          Spacing.horizontalSpace8,
          FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: kGlicoInputFill,
            heroTag: "add phone number $index",
            elevation: 0.0,
            onPressed: () => _addPhoneNumber(),
            child: const Icon(
              LucideIcons.plus,
              color: Colors.black54,
            ),
          )
        ],
      ),
    );
  }

  Widget submitButton(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 54,
          width: 192,
          child: ElevatedButton(
            onPressed: () async => !isLoading &&
                    _addBusinessFormKey.currentState!.validate() &&
                    dropdownValue != "" &&
                    insuranceTypeValue != InsuranceType.unselected
                ? await addBusiness()
                : null,
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.secondary,
                    ),
                  )
                : Text(
                    "Submit",
                    style: theme.textTheme.titleLarge!
                        .copyWith(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final format = NumberFormat("#,###");
    final newText = format.format(int.parse(newValue.text.replaceAll(',', '')));

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
