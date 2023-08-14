// import 'package:flutter/material.dart';

// class SendEmail extends StatefulWidget {
//   const SendEmail({
//     super.key,
//     required this.email,
//     required this.firstName,
//     required this.lastName,
//   });

//   final String firstName;
//   final String lastName;
//   final String email;

//   @override
//   State<SendEmail> createState() => _SendEmailState();
// }

// class _SendEmailState extends State<SendEmail> {
//   final GlobalKey<FormState> _sendEmailFormKey = GlobalKey<FormState>();
//   final TextEditingController _subjectController = TextEditingController();
//   final TextEditingController _bodyController = TextEditingController();
//   final FocusNode _subjectFocus = FocusNode();
//   final FocusNode _bodyFocus = FocusNode();

//   _subjectEditingComplete() => FocusScope.of(context).nextFocus();
//   _bodyEditingComplete() => FocusScope.of(context).nextFocus();

//   late bool isLoading;

//   Future<void> sendEmail() async {
//     final Email sendEmail = Email(
//       body: _bodyController.text,
//       subject: _subjectController.text,
//       recipients: [widget.email],
//       // cc: ['example_cc@ex.com'],
//       // bcc: ['example_bcc@ex.com'],
//       // attachmentPaths: ['/path/to/email_attachment.zip'],
//       isHTML: false,
//     );

//     await FlutterEmailSender.send(sendEmail);
//   }

//   @override
//   void initState() {
//     isLoading = false;
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _subjectController.dispose();
//     _bodyController.dispose();
//     _subjectFocus.dispose();
//     _bodyFocus.dispose();

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ThemeData theme = Theme.of(context);

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(8.0),
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: Text("Send email to ${widget.firstName} ${widget.lastName}"),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               Form(
//                 key: _sendEmailFormKey,
//                 child: Column(
//                   children: [
//                     _subjectInputField(),
//                     Spacing.verticalSpace8,
//                     _bodyInputField(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         persistentFooterButtons: [
//           SizedBox(
//             width: ScreenSize.width,
//             child: ElevatedButton(
//               onPressed: () => sendEmail(),
//               child: Text(
//                 "Send email",
//                 style:
//                     theme.textTheme.titleLarge!.copyWith(color: Colors.white),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _subjectInputField() {
//     return Padding(
//       padding: Insets.standardPadding,
//       child: TextFormField(
//         enabled: isLoading == false,
//         autofocus: true,
//         focusNode: _subjectFocus,
//         onEditingComplete: () => _subjectEditingComplete(),
//         controller: _subjectController,
//         // icon: Icons.email_outlined,
//         // labelText: translate.email_address,
//         decoration: const InputDecoration(
//           hintText: "Subject/Title",
//           // border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
//           // filled: true,
//           // fillColor: Colors.grey[200],
//         ),
//         validator: (val) => val!.length < 3 ? "Subject is too short" : null,
//         keyboardType: TextInputType.text,
//         textInputAction: TextInputAction.next,
//       ),
//     );
//   }

//   Widget _bodyInputField() {
//     return Padding(
//       padding: Insets.standardPadding,
//       child: TextFormField(
//         enabled: isLoading == false,
//         focusNode: _bodyFocus,
//         onEditingComplete: () => _bodyEditingComplete(),
//         controller: _bodyController,
//         // icon: Icons.email_outlined,
//         // labelText: translate.email_address,
//         decoration: const InputDecoration(
//           hintText: "Body/Message",
//           // border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
//           // filled: true,
//           // fillColor: Colors.grey[200],
//         ),
//         validator: (val) => val!.length < 3 ? "Message is too short" : null,
//         keyboardType: TextInputType.multiline,
//         maxLines: 8,
//         textInputAction: TextInputAction.done,
//       ),
//     );
//   }
// }
