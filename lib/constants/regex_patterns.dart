final emailPattern = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

final phoneNumberPattern = RegExp(r"^[+0-9]{10,}$");
//RegExp(r"^[+.0-9]+");

final RegExp commaSeparator = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

