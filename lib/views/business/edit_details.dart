import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glico_stores/constants/app_colors.dart';
import 'package:glico_stores/constants/regex_patterns.dart';
import 'package:glico_stores/constants/route_names.dart';
import 'package:glico_stores/constants/ui_constants.dart';
import 'package:glico_stores/locator.dart';
import 'package:glico_stores/models/business.dart';
import 'package:glico_stores/models/business_location.dart';
import 'package:glico_stores/services/database_service.dart';
import 'package:glico_stores/services/location_service.dart';
import 'package:glico_stores/services/navigation_service.dart';
import 'package:glico_stores/utils/enums.dart';
import 'package:glico_stores/utils/utilities.dart';
import 'package:glico_stores/views/map_view.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditDetails extends StatefulWidget {
  final String uid;

  const EditDetails({super.key, required this.uid});

  @override
  State<EditDetails> createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final GlobalKey<FormState> _editBusinessFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ownerController;
  late TextEditingController _addressController;
  late TextEditingController _commentController;
  late TextEditingController _assetValueController;
  late TextEditingController _premiumValueController;
  late List<TextEditingController> _phoneInputControllers = [];
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _ownerFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _commentFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _assetValueFocus = FocusNode();

  _nameEditingComplete() => FocusScope.of(context).nextFocus();
  _ownerEditingComplete() => FocusScope.of(context).nextFocus();
  _addressEditingComplete() => FocusScope.of(context).nextFocus();
  _commentEditingComplete() => FocusScope.of(context).nextFocus();
  _assetValueEditingComplete() => FocusScope.of(context).nextFocus();

  bool isLoading = true;
  late String dropdownValue;
  late InsuranceType insuranceTypeValue;
  late GeoPoint? coordinates;
  late BusinessLocation? currentLocation;
  late BusinessLocation? currentAddress;
  late List<File>? selectedImages;
  List<File> filesList = [];

  final DatabaseService db = locator<DatabaseService>();
  final NavigationService navService = locator<NavigationService>();
  final LocationService locationService = locator<LocationService>();

  void _addPhoneNumber() {
    setState(() {
      _phoneInputControllers.add(TextEditingController());
    });
  }

  void _removePhoneNumber(int index) {
    setState(() {
      _phoneInputControllers.removeAt(index);
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

  Future updateBusinessData(uid) async {
    final Map<String, dynamic> businessData = {
      "uid": uid,
      "name": _nameController.text,
      "owner": _ownerController.text,
      "address": _addressController.text,
      "coordinates": coordinates,
      "category": dropdownValue,
      "comment": _commentController.text,
      "phone": _phoneInputControllers.map((e) => e.text).toList(),
      // "photos": widget.args.photos,
      "insuranceType": insuranceTypeValue.name,
      "estimatedAssetValue": double.parse(_assetValueController.text),
      "premium": double.parse(_premiumValueController.text),
    };

    try {
      db.updateBusinessData(uid, businessData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Data updated successfully"),
      ));
      navService.navigateToReplacement(businessesListRoute);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Error, could not update data"),
        ),
      );
    }
  }

  Future<void> convertPathsToFiles(List photos) async {
    for (String path in photos) {
      File file = File(path);
      if (await file.exists()) {
        setState(() {
          filesList.add(file);
        });
      } else {
        debugPrint('File does not exist at path: $path');
      }
    }
  }

  Future<Business> _fetchBusinessData() async {
    final business = await db.getBusiness(widget.uid);
    setState(() => isLoading = false);
    return business;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _phoneInputControllers.isEmpty ? _addPhoneNumber() : null;
    _fetchBusinessData().then((business) => {
          _nameController = TextEditingController(text: business.name!),
          _ownerController = TextEditingController(text: business.owner!),
          _addressController = TextEditingController(text: business.address!),
          coordinates = business.coordinates,
          dropdownValue = business.category!,
          insuranceTypeValue = Utilities.convertStringToInsuranceTypeEnum(
              business.insuranceType!),
          _commentController = TextEditingController(text: business.comment!),
          _assetValueController = TextEditingController(
              text: business.estimatedAssetValue!.toString()),
          _premiumValueController =
              TextEditingController(text: business.premium!.toString()),
          _phoneInputControllers = business.phone!
              .map((e) => TextEditingController(text: e.toString()))
              .toList(),
          selectedImages =
              business.photos!.map((e) => File(e as String)).toList(),
          convertPathsToFiles(business.photos!),
        });
    // isLoading = false;
    // print("photos: ${widget.args.photos}");
    // print("photos1: $selectedImages");
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _ownerController.dispose();
    _addressController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  static const borderColor = Color(0xFFceced2);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/map_bg.png"),
                fit: BoxFit.cover,
              ),
              color: Color(0xFFe5e9f2),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text("Edit business"),
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
                          key: _editBusinessFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _nameInputField(theme),
                              _ownerInputField(theme),
                              _addressInputField(theme),
                              _mapView(coordinates),
                              _categoryInputField(theme),
                              _phoneNumberWidgets(theme),
                              _insuraneTypePicker(theme),
                              _estimatedAssetValueInputField(theme),
                              _premium(theme),
                              _commentInputField(theme),
                              _photosInputField(theme),
                            ],
                          ),
                        ),
                        Spacing.verticalSpace16,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              // margin: Insets.verticalPadding12,
                              onPressed: () async {
                                return !isLoading &&
                                        _editBusinessFormKey.currentState!
                                            .validate()
                                    ? await updateBusinessData(widget.uid)
                                    : null;
                              },
                              // margin: Insets.verticalPadding12,
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      color: theme.colorScheme.secondary,
                                    )
                                  : Text(
                                      "Update",
                                      style: theme.textTheme.titleLarge!
                                          .copyWith(color: Colors.white),
                                    ),
                            ),
                          ],
                        ),
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
        focusNode: _nameFocus,
        onEditingComplete: () => _nameEditingComplete(),
        controller: _nameController,
        decoration: InputDecoration(
            label: const Text("Business name"),
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
            label: const Text("Owner's name"),
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
            label: const Text("Address"),
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
              //     !phoneNumberPattern.hasMatch(val!) ? "Invalid phone number" : null,
            );
          }),
    );
  }

  Widget _commentInputField(ThemeData theme) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        enabled: isLoading == false,
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

  Widget _phoneNumberWidgets(ThemeData theme) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _phoneInputControllers.length,
      itemBuilder: (context, index) => Row(
        children: [
          Flexible(
            child: Padding(
              padding: Insets.verticalPadding8,
              child: TextFormField(
                enabled: isLoading == false,
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
                            //TODO: _takeCameraImages();
                          },
                        ),
                        ListTile(
                          // dense: true,
                          leading: const Icon(LucideIcons.image),
                          title: const Text("Choose from gallery"),
                          onTap: () {
                            navService.pop();
                            //TODO: _pickGalleryImages();
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
                        (e) => ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: SizedBox(
                            // margin: const EdgeInsets.only(right: 8.0),
                            width: 95.5,
                            height: 95.5,
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: e.path,
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
        //     !phoneNumberPattern.hasMatch(val!) ? "Invalid phone number" : null,
      ),
    );
  }

  Widget _estimatedAssetValueInputField(ThemeData theme) {
    return Padding(
      padding: Insets.verticalPadding8,
      child: TextFormField(
        enabled: isLoading == false,
        focusNode: _assetValueFocus,
        onEditingComplete: () => _assetValueEditingComplete(),
        controller: _assetValueController,
        onChanged: (val) => _premiumValueController.text =
            _assetValueController.text != ""
                ? (double.parse(_assetValueController.text) * 0.025).toString()
                : "",
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
            hintText: "Estimated cost of assets (GH¢)",
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
        controller: _premiumValueController,
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
}
