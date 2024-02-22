class User {
  final String uid;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? profilePicture;
  final String? color;
  final String? dateJoined;
  final List? addedStores;
  final Map? deviceInfo;
  final int? uniqueCode; 

  User({
    required this.uid,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.profilePicture,
    this.color,
    this.dateJoined,
    this.addedStores,
    this.deviceInfo,
    this.uniqueCode,
  });

  factory User.fromMap(Map<String, dynamic> mapData) {
    final String uid = mapData['uid'];
    final String? firstName = mapData['firstName'];
    final String? lastName = mapData['lastName'];
    final String email = mapData['email'];
    final String phone = mapData['phone'];
    final String? profilePicture = mapData['profilePicture'];
    final String color = mapData['color'];
    final String dateJoined = mapData['dateJoined'];
    final List? addedStores = mapData['addedStores'];
    final Map? deviceInfo = mapData['deviceInfo'];
    final int? uniqueCode = mapData['uniqueCode'];

    return User(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      profilePicture: profilePicture,
      color: color,
      dateJoined: dateJoined,
      addedStores: addedStores,
      deviceInfo: deviceInfo,
      uniqueCode: uniqueCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "phone": phone,
      "profilePicture": profilePicture,
      "color": color,
      "dateJoined": dateJoined,
      "addedStores": addedStores,
      "deviceInfo": deviceInfo,
      "uniqueCode": uniqueCode,
    };
  }
}
