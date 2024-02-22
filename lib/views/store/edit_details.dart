import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/constants/app_colors.dart';
import '/constants/regex_patterns.dart';
import '/constants/route_names.dart';
import '/constants/ui_constants.dart';
import '/locator.dart';
import '/models/store.dart';
import '/models/store_location.dart';
import '/services/database_service.dart';
import '/services/location_service.dart';
import '/services/navigation_service.dart';
import '/views/map_view.dart';
import '/widgets/input_field.dart';
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

  final GlobalKey<FormState> _editStoreFormKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ownerController;
  late TextEditingController _addressController;
  late TextEditingController _commentController;
  late List<TextEditingController> _phoneInputControllers = [];
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _ownerFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode();
  final FocusNode _commentFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();

  _nameEditingComplete() => FocusScope.of(context).nextFocus();
  _ownerEditingComplete() => FocusScope.of(context).nextFocus();
  _addressEditingComplete() => FocusScope.of(context).nextFocus();
  _commentEditingComplete() => FocusScope.of(context).nextFocus();

  bool isLoading = true;
  late String dropdownValue;
  late GeoPoint? coordinates;
  late StoreLocation? currentLocation;
  late StoreLocation? currentAddress;
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
            "Could not get location of store",
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      throw PlatformException(code: e.code);
    }
  }

  Future updateStoreData(uid) async {
    final Map<String, dynamic> storeData = {
      "uid": uid,
      "name": _nameController.text,
      "owner": _ownerController.text,
      "address": _addressController.text,
      "coordinates": coordinates,
      "category": dropdownValue,
      "comment": _commentController.text,
      "phone": _phoneInputControllers.map((e) => e.text).toList(),
      // "photos": widget.args.photos,
    };

    try {
      db.updateStoreData(uid, storeData);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Data updated successfully"),
      ));
      navService.navigateToReplacement(storesListRoute);
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

  Future<Store> _fetchStoreData() async {
    final store = await db.getStore(widget.uid);
    setState(() => isLoading = false);
    return store;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _phoneInputControllers.isEmpty ? _addPhoneNumber() : null;
    _fetchStoreData()
        .then((store) => {
              _nameController = TextEditingController(text: store.name!),
              _ownerController = TextEditingController(text: store.owner!),
              _addressController = TextEditingController(text: store.address!),
              coordinates = store.coordinates,
              dropdownValue = store.category!,
              _commentController = TextEditingController(text: store.comment!),
              _phoneInputControllers = store.phone!
                  .map((e) => TextEditingController(text: e.toString()))
                  .toList(),
              downloadedPhotos = store.photos,
              selectedImages =
                  store.photos!.map((e) => File(e as String)).toList(),
              convertPathsToFiles(store.photos!),
            })
        .then((value) => debugPrint("$downloadedPhotos"));
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
                "images/ericsson-mobility-report-novembe.png",
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
                            Text(
                              "Edit store",
                              style: theme.textTheme.headlineSmall!.copyWith(
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
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
                          key: _editStoreFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _nameInputField(theme),
                              _ownerInputField(theme),
                              _addressInputField(theme),
                              _mapView(coordinates),
                              _categoryInputField(theme),
                              _phoneNumberWidgets(theme),
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
            onPressed: () async {
              return !isLoading && _editStoreFormKey.currentState!.validate()
                  ? await updateStoreData(widget.uid)
                  : null;
            },
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

  Widget _nameInputField(ThemeData theme) {
    return InputField(
      isLoading: isLoading,
      padding: Insets.verticalPadding16,
      autofocus: true,
      focusNode: _nameFocus,
      onEditingComplete: () => _nameEditingComplete(),
      controller: _nameController,
      labelText: "Store name",
      validator: (val) => val!.length < 2 ? "Store name is too short" : null,
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
                  child: const Text("Nature of store"),
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
          "Store' photos",
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
                      "No photos added for this store",
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
        ),
      ],
    );
  }
}
