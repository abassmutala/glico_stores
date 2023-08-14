import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:image_picker/image_picker.dart';
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
  _assetCostEditingComplete() => {FocusScope.of(context).nextFocus()};

  late bool isLoading;
  late BusinessLocation? currentLocation;
  late BusinessLocation? currentAddress;
  late GeoPoint? coordinates;
  late List<File>? selectedImages;
  String dropdownValue = 'other';
  InsuranceType insuranceTypeValue = InsuranceType.business;

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
      isLoading = true;
      currentLocation = await locationService.getAddressFromCoordinates();
      _addressController.text =
          "${currentLocation?.city}, ${currentLocation?.region}";
      setState(() {
        coordinates =
            GeoPoint(currentLocation!.latitude!, currentLocation!.longitude!);
      });

      isLoading = false;
    } on PlatformException catch (e) {
      isLoading = false;
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
      estimatedAssetValue: double.parse(_assetCostController.text),
      premium: double.parse(_premiumController.text),
      insured: false,
      photos: [],
      regDate: Timestamp.fromDate(
        DateTime.now(),
      ),
      uniqueCode: Utilities.generateBusinessCode(_addressController.text),
    );
    try {
      isLoading = true;
      debugPrint("Loading state: $isLoading");
      final uid = await db.createBusinessProfile(newBusiness);
      await db.updateBusinessUid(uid);
      selectedImages != null
          ? await uploadPhotos(selectedImages!, uid).then(
              (value) => updatePhotoReferences(value, uid),
            )
          : null;
      await db.updateRegisteredBusinessesForUser(currentUser!.uid, uid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Business added successfully"),
        ),
      );

      isLoading = false;
      navService.navigateToReplacement(businessesListRoute);
    } on PlatformException catch (e) {
      isLoading = false;
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
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/map_bg.png"),
          fit: BoxFit.cover,
        ),
        color: Color(0xFFe5e9f2),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Add business"),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                "images/map_bg.png",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 48.0),
                children: [
                  Spacing.verticalSpace8,
                  SizedBox(
                    height: 120,
                    child: Image.asset("images/glicogeneral_logo.png"),
                  ),
                  Spacing.verticalSpace12,
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
      ),
    );
  }

  Widget _nameInputField(ThemeData theme) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        enabled: isLoading == false,
        autofocus: true,
        focusNode: _nameFocus,
        onEditingComplete: () => _nameEditingComplete(),
        controller: _nameController,
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
            hintText: "Business name",
            hintStyle: const TextStyle(color: Colors.grey),
            floatingLabelBehavior: FloatingLabelBehavior.auto),
        style: theme.textTheme.titleLarge,
        validator: (val) =>
            val!.length < 2 ? "Business name is too short" : null,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _ownerInputField(ThemeData theme) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        enabled: isLoading == false,
        focusNode: _ownerFocus,
        onEditingComplete: () => _ownerEditingComplete(),
        controller: _ownerController,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
            filled: true,
            fillColor: kGlicoInputFill,
            border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: borderColor),
            ),
            // label: const Text("Name of owner"),
            floatingLabelStyle:
                theme.textTheme.titleLarge!.copyWith(color: Colors.grey),
            hintText: "Owner's name",
            hintStyle: const TextStyle(color: Colors.grey),
            floatingLabelBehavior: FloatingLabelBehavior.auto),
        style: theme.textTheme.titleLarge,
        validator: (val) => val!.length < 3 ? "Name is too short" : null,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _addressInputField(ThemeData theme) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        enabled: isLoading == false,
        focusNode: _addressFocus,
        onEditingComplete: () => _addressEditingComplete(),
        controller: _addressController,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
            filled: true,
            fillColor: kGlicoInputFill,
            border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: borderColor),
            ),
            floatingLabelStyle:
                theme.textTheme.titleLarge!.copyWith(color: Colors.grey),
            hintText: "Tap to find address",
            hintStyle: const TextStyle(color: Colors.grey),
            floatingLabelBehavior: FloatingLabelBehavior.auto),
        style: theme.textTheme.titleLarge,
        validator: (val) => val!.length < 3 ? "Invalid address" : null,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        readOnly: true,
        onTap: () => getCurrentLocation(),
      ),
    );
  }

  Widget _estimatedAssetCostInputField(ThemeData theme) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        enabled: isLoading == false,
        focusNode: _assetCostFocus,
        onEditingComplete: () => _assetCostEditingComplete(),
        controller: _assetCostController,
        onChanged: (val) => _premiumController.text =
            (double.parse(_assetCostController.text) * 0.025).toString(),
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
            filled: true,
            fillColor: kGlicoInputFill,
            border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: borderColor),
            ),
            // label: const Text("Name of owner"),
            floatingLabelStyle:
                theme.textTheme.titleLarge!.copyWith(color: Colors.grey),
            labelText: "Estimated cost of assets (GH¢)",
            hintStyle: const TextStyle(color: Colors.grey),
            floatingLabelBehavior: FloatingLabelBehavior.auto),
        style: theme.textTheme.titleLarge,
        validator: (val) => val!.length < 3 ? "Name is too short" : null,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _premium(ThemeData theme) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        enabled: isLoading == false,
        // focusNode: _assetCostFocus,
        readOnly: true,
        // onEditingComplete: () => _assetCostEditingComplete(),
        controller: _premiumController,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
            filled: true,
            fillColor: kGlicoInputFill,
            border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: borderColor),
            ),
            // label: const Text("Name of owner"),
            floatingLabelStyle:
                theme.textTheme.titleLarge!.copyWith(color: Colors.grey),
            labelText: "Premium",
            hintStyle: const TextStyle(color: Colors.grey),
            floatingLabelBehavior: FloatingLabelBehavior.auto),
        style: theme.textTheme.titleLarge,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _commentInputField(ThemeData theme) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        enabled: isLoading == false,
        autofocus: true,
        focusNode: _commentFocus,
        onEditingComplete: () => _commentEditingComplete(),
        controller: _commentController,
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
            filled: true,
            fillColor: kGlicoInputFill,
            border: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: borderColor),
            ),
            floatingLabelStyle:
                theme.textTheme.titleLarge!.copyWith(color: Colors.grey),
            hintText: "Comment",
            hintStyle: const TextStyle(color: Colors.grey),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            counterStyle: const TextStyle(color: Colors.white)),
        style: theme.textTheme.titleLarge,
        // validator: (val) =>
        //     val!.length < 2 ? "Business name is too short" : null,
        keyboardType: TextInputType.text,
        maxLines: 8,
        maxLength: 250,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _photosInputField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Add photos of business",
          style: theme.textTheme.titleLarge!.copyWith(color: Colors.white),
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
                  borderRadius: BorderRadius.circular(12.0),
                ),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.3),
                elevation: 0.0,
                child: Icon(
                  LucideIcons.plus,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const Text("Choose photos"),
                      // height: kToolbarHeight * 2,
                      children: [
                        ListTile(
                          // dense: true,
                          leading: const Icon(LucideIcons.camera),
                          title: const Text("Take a photo"),
                          onTap: () async {
                            navService.pop();
                            _takeCameraImages();
                          },
                        ),
                        ListTile(
                          // dense: true,
                          leading: const Icon(LucideIcons.image),
                          title: const Text("Choose from gallery"),
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
            Wrap(
              spacing: 12.0,
              children: selectedImages != null
                  ? selectedImages!
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: SizedBox(
                              // margin: const EdgeInsets.only(right: 8.0),
                              width: 95.5,
                              height: 95.5,
                              child: Image.file(
                                File(e.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList()
                  : [],
            ),
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
                      child: Text(e["name"]),
                    ),
                  )
                  .toList(),
              value: dropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                  debugPrint(dropdownValue);
                });
              },
              focusNode: _categoryFocus,
              decoration: InputDecoration(
                label: const Text("Category"),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
                filled: true,
                fillColor: kGlicoInputFill,
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: borderColor),
                ),
                // label: const Text("Category"),
                floatingLabelStyle:
                    theme.textTheme.titleLarge!.copyWith(color: Colors.grey),
                hintText: "Category",
                hintStyle: const TextStyle(color: Colors.grey),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              style: theme.textTheme.titleLarge, // validator: (val) =>
            );
          }),
    );
  }

  Widget _insuraneTypePicker(ThemeData theme) {
    final List<Map<InsuranceType, String>> insuranceTypes = [
      {InsuranceType.business: "Business"},
      {InsuranceType.products: "Products"}
    ];

    List<DropdownMenuItem<InsuranceType>> buildDropdownMenuItems() {
      return insuranceTypes.map((insuranceTypeMap) {
        InsuranceType insuranceType = insuranceTypeMap.keys.first;
        String value = insuranceTypeMap.values.first;

        return DropdownMenuItem<InsuranceType>(
          value: insuranceType,
          child: Text(value),
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
        focusNode: _categoryFocus,
        decoration: InputDecoration(
          label: const Text("Category"),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8.0),
          filled: true,
          fillColor: kGlicoInputFill,
          border: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: borderColor),
          ),
          // label: const Text("Category"),
          floatingLabelStyle:
              theme.textTheme.titleLarge!.copyWith(color: Colors.grey),
          hintText: "Insurance type",
          hintStyle: const TextStyle(color: Colors.grey),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
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
          borderRadius: BorderRadius.circular(12.0),
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _phoneInputControllers.length,
      itemBuilder: ((context, index) => Row(
            children: [
              Flexible(
                child: Padding(
                  padding: Insets.verticalPadding8,
                  child: TextFormField(
                    enabled: isLoading == false,
                    focusNode: _phoneFocuses[index],
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    controller: _phoneInputControllers[index],
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8.0),
                        filled: true,
                        fillColor: kGlicoInputFill,
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        floatingLabelStyle: theme.textTheme.titleLarge!
                            .copyWith(color: Colors.grey),
                        hintText: "Phone number",
                        hintStyle: const TextStyle(color: Colors.grey),
                        floatingLabelBehavior: FloatingLabelBehavior.auto),
                    style: theme.textTheme.titleLarge,
                    validator: (val) => !phoneNumberPattern.hasMatch(val!)
                        ? "Invalid phone number"
                        : null,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              Spacing.horizontalSpace8,
              FloatingActionButton(
                heroTag: "remove phone number $index",
                elevation: 0.0,
                onPressed: () => _removePhoneNumber(index),
                child: Icon(
                  LucideIcons.minus,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Spacing.horizontalSpace8,
              FloatingActionButton(
                heroTag: "add phone number $index",
                elevation: 0.0,
                onPressed: () => _addPhoneNumber(),
                child: Icon(
                  LucideIcons.plus,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            ],
          )),
    );
  }

  Widget submitButton(ThemeData theme) {
    return Container(
      width: ScreenSize.width,
      constraints: const BoxConstraints(maxWidth: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 20))),
            // margin: Insets.verticalPadding12,
            onPressed: () async =>
                !isLoading && _addBusinessFormKey.currentState!.validate()
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
        ],
      ),
    );
  }
}
