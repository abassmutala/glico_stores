import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:glico_stores/views/business/add_business.dart';
import 'package:glico_stores/views/map_view.dart';
import 'package:glico_stores/widgets/input_field.dart';
import 'package:intl/intl.dart';
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
  late List? downloadedPhotos;

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
    _fetchBusinessData()
        .then((business) => {
              _nameController = TextEditingController(text: business.name!),
              _ownerController = TextEditingController(text: business.owner!),
              _addressController =
                  TextEditingController(text: business.address!),
              coordinates = business.coordinates,
              dropdownValue = business.category!,
              insuranceTypeValue = Utilities.convertStringToInsuranceTypeEnum(
                  business.insuranceType!),
              _commentController =
                  TextEditingController(text: business.comment!),
              _assetValueController = TextEditingController(
                  text: business.estimatedAssetValue!.toString()),
              _premiumValueController =
                  TextEditingController(text: business.premium!.toString()),
              _phoneInputControllers = business.phone!
                  .map((e) => TextEditingController(text: e.toString()))
                  .toList(),
              downloadedPhotos = business.photos,
              selectedImages =
                  business.photos!.map((e) => File(e as String)).toList(),
              convertPathsToFiles(business.photos!),
            })
        .then((value) => print(downloadedPhotos));
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
        : Stack(
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
                              child: SvgPicture.asset(
                                  "images/glico_general_logo.svg"),
                            ),
                            Text(
                              "Edit business",
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
                        updateButton(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  Widget updateButton(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 54,
          width: 192,
          child: ElevatedButton(
            // margin: Insets.verticalPadding12,
            onPressed: () async {
              return !isLoading && _editBusinessFormKey.currentState!.validate()
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
        ),
      ],
    );
  }

  void _updatePremium(String value) {
    if (value.isEmpty) {
      _premiumValueController.text = '';
    } else {
      double inputValue = double.tryParse(value.replaceAll(',', '')) ?? 0;
      double result = inputValue * 0.3;

      // Format the result with thousand separator and 2 decimal places
      final formattedResult = NumberFormat("#,###.##")
          .format(double.parse(result.toStringAsFixed(2)));
      _premiumValueController.text = formattedResult;
    }
  }

  Widget _nameInputField(ThemeData theme) {
    return InputField(
      isLoading: isLoading,
      padding: Insets.verticalPadding16,
      autofocus: true,
      focusNode: _nameFocus,
      onEditingComplete: () => _nameEditingComplete(),
      controller: _nameController,
      labelText: "Business name",
      validator: (val) => val!.length < 2 ? "Business name is too short" : null,
    );
  }

  Widget _ownerInputField(ThemeData theme) {
    return InputField(
      isLoading: isLoading,
      padding: Insets.verticalPadding16,
      focusNode: _ownerFocus,
      onEditingComplete: () => _ownerEditingComplete(),
      controller: _ownerController,
      labelText: "Owner's name",
      validator: (val) => val!.length < 3 ? "Name is too short" : null,
    );
  }

  Widget _addressInputField(ThemeData theme) {
    return InputField(
      isLoading: isLoading,
      padding: Insets.verticalPadding16,
      focusNode: _addressFocus,
      onEditingComplete: () => _addressEditingComplete(),
      controller: _addressController,
      labelText: "Address",
      validator: (val) => val!.length < 3 ? "Invalid address" : null,
      readOnly: true,
      onTap: () => getCurrentLocation(),
    );
  }

  Widget _mapView(GeoPoint? center) {
    if (center == null) {
      return Container();
    } else {
      return Padding(
        padding: Insets.verticalPadding16,
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

  Widget _categoryInputField(ThemeData theme) {
    return Padding(
      padding: Insets.verticalPadding16,
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
                label: Container(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: const Text("Nature of business"),
                ),
                hintStyle: const TextStyle(color: Colors.grey),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              style: theme.textTheme.titleLarge, // validator: (val) =>
              //     !phoneNumberPattern.hasMatch(val!) ? "Invalid phone number" : null,
            );
          }),
    );
  }

  Widget _commentInputField(ThemeData theme) {
    return InputField(
      isLoading: isLoading,
      padding: Insets.verticalPadding16,
      focusNode: _commentFocus,
      onEditingComplete: () => _commentEditingComplete(),
      controller: _commentController,
      labelText: "Comment",
      maxLines: 6,
      maxLength: 250,
      borderRadius: 25.0,
    );
  }

  Widget _phoneNumberWidgets(ThemeData theme) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _phoneInputControllers.length,
      itemBuilder: (context, index) => Row(
        children: [
          Flexible(
            child: InputField(
              padding: Insets.verticalPadding16,
              onEditingComplete: () => FocusScope.of(context).nextFocus(),
              controller: _phoneInputControllers[index],
              labelText: "Phone number ${index + 1}",
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

  Widget _photosInputField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Business' photos",
          style: theme.textTheme.titleMedium!.copyWith(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        Spacing.verticalSpace8,
        Wrap(
          spacing: 12.0,
          children: downloadedPhotos!.isNotEmpty
              ? downloadedPhotos!
                  .map(
                    (e) => ClipRRect(
                      borderRadius: BorderRadius.circular(24.0),
                      child: SizedBox(
                        // margin: const EdgeInsets.only(right: 8.0),
                        width: 100,
                        height: 100,
                        child: CachedNetworkImage(
                          imageUrl: e,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                  .toList()
              : [
                  SizedBox(
                    width: ScreenSize.width,
                    child: const Text(
                      "No photos added for this business",
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
        ),
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
      padding: Insets.verticalPadding16,
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
            label: Container(
              padding: const EdgeInsets.only(bottom: 36.0),
              child: const Text(
                "Insurance type",
              ),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto),
        style: theme.textTheme.titleLarge, // validator: (val) =>
        //     !phoneNumberPattern.hasMatch(val!) ? "Invalid phone number" : null,
      ),
    );
  }

  Widget _estimatedAssetValueInputField(ThemeData theme) {
    return InputField(
      isLoading: isLoading,
      padding: Insets.verticalPadding16,
      focusNode: _assetValueFocus,
      onEditingComplete: () => _assetValueEditingComplete(),
      controller: _assetValueController,
      onChanged: (val) {
        _updatePremium(val);
      },
      inputFormatters: [ThousandsSeparatorInputFormatter()],
      labelText: "Sum insured (GH¢)",
      validator: (val) => val!.length < 3 ? "Name is too short" : null,
      keyboardType: TextInputType.number,
    );
  }

  Widget _premium(ThemeData theme) {
    return InputField(
      isLoading: isLoading,
      padding: Insets.verticalPadding16,
      readOnly: true,
      controller: _premiumValueController,
      labelText: "Premium",
    );
  }
}
