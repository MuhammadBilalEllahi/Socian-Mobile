import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class MyTextField extends StatelessWidget {
  const MyTextField(
      {super.key,
      required TextEditingController textEditingController,
      required this.label,
      required this.obscureTextBool,
      required this.focus,
      required this.validator,
      this.readOnly = false,
      this.inputFormatters,
      this.inputBorder,
      this.height,
      this.width,
      this.padZero,
      this.keybordType,
      this.validatorForm,
      this.suffixIcon,
      this.customKey})
      : _textEditingController = textEditingController;

  final TextEditingController _textEditingController;
  final FormFieldValidator<String>? validatorForm;
  final String label;
  final bool focus;
  final bool obscureTextBool;
  final FormFieldValidator? validator;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final InputBorder? inputBorder;
  final double? height;
  final double? width;
  final double? padZero;
  final TextInputType? keybordType;
  final IconButton? suffixIcon;
  final Key? customKey;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: height ?? 90,
      width: width ?? 400,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            padZero ?? 0, padZero ?? 0, padZero ?? 0, padZero ?? 0),
        child: TextFormField(
          key: customKey,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          controller: _textEditingController,
          autofocus: focus,
          validator: validatorForm ?? validator,
          readOnly: readOnly,
          keyboardType: keybordType,
          obscureText: obscureTextBool,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            fillColor: isDarkMode ? Colors.grey[900] : Colors.white,
            suffixIcon: suffixIcon,
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10),
            border: inputBorder ?? const UnderlineInputBorder(),
            label: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDarkMode ? Colors.white54 : Colors.black54,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class MyPhoneTextField extends StatefulWidget {
//   const MyPhoneTextField({
//     super.key,
//     required TextEditingController textEditingController,
//     required this.label,
//     required this.focus,
//     required this.validator,
//     this.readOnly = false,
//     this.inputFormatters,
//     this.inputBorder,
//   }) : _textEditingController = textEditingController;

//   final TextEditingController _textEditingController;
//   final String label;
//   final bool focus;
//   final FormFieldValidator<String>? validator;
//   final bool readOnly;
//   final List<TextInputFormatter>? inputFormatters;
//   final InputBorder? inputBorder;

//   @override
//   State<MyPhoneTextField> createState() => _MyPhoneTextFieldState();
// }

// class _MyPhoneTextFieldState extends State<MyPhoneTextField> {
//   String phoneCode = '+93';

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 100,
//       width: 400,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(25, 5, 25, 10),
//         child: InternationalPhoneNumberInput(
//           textFieldController: widget._textEditingController,
//           onInputValidated: (bool value) {
//             if (value) {
//               var number = PhoneNumber().phoneNumber;
//               debugPrint("$number");
//               // The input is considered valid, update the textEditingController
//               widget._textEditingController.text =
//                   "$phoneCode${widget._textEditingController.text}";
//               debugPrint(widget._textEditingController.text);
//               debugPrint(value);
//             }
//           },
//           onInputChanged: (PhoneNumber number) {
//             phoneCode = number.dialCode!;
//             debugPrint(phoneCode);
//             // Access the entered phone number
//             String phoneNumber = number.phoneNumber ?? "";
//             debugPrint("$phoneNumber and ${widget._textEditingController.text}");

//             // Handle phone number changes if needed
//           },
//           selectorConfig: const SelectorConfig(
//             selectorType: PhoneInputSelectorType.DIALOG,
//             useBottomSheetSafeArea: true,
//           ),
//           keyboardType: TextInputType.phone,
//           ignoreBlank: false,
//           autoValidateMode: AutovalidateMode.disabled,
//           selectorTextStyle:
//               TextStyle(color: Theme.of(context).primaryColorLight),
//           textStyle: TextStyle(color: Theme.of(context).primaryColorLight),
//           inputDecoration: InputDecoration(
//             fillColor: Colors.green,
//             errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10),
//             border: widget.inputBorder ?? const UnderlineInputBorder(),
//             labelText: widget.label,
//             labelStyle: TextStyle(
//                 fontSize: 16, color: Theme.of(context).primaryColorLight),
//           ),
//         ),
//       ),
//     );
//   }
// }
