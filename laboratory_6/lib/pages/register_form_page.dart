import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laboratory_6/model/user.dart';
import 'package:laboratory_6/pages/main_page.dart';
import 'user_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RegisterFormPage extends StatefulWidget {
  final Function(User) onRegistered;

  const RegisterFormPage({super.key, required this.onRegistered});

  @override
  State<RegisterFormPage> createState() => _RegisterFormPageState();
}


class _RegisterFormPageState extends State<RegisterFormPage> {
  bool _hidePass = true;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _storyController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final List<String> _countries = ['Kazakhstan', 'Russia', 'Ukraine', 'Germany', 'France'];
  String _selectedCountry = 'Kazakhstan';

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();

  User newUser = User();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _storyController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    IconData? icon,
    IconData? suffix,
    VoidCallback? onSuffixTap,
    required FocusNode focusNode,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: focusNode.hasFocus ? Colors.orange : Colors.green[900]),
      icon: icon != null ? Icon(icon, color: Colors.green[900]) : null,
      suffixIcon: suffix != null
          ? GestureDetector(
              onTap: onSuffixTap,
              child: Icon(suffix, color: Colors.red),
            )
          : null,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        borderSide: BorderSide(color: Colors.green, width: 1.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        borderSide: BorderSide(color: Colors.orange, width: 2.0),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
  title: Text('register_form'.tr()),
  centerTitle: true,
  leading: PopupMenuButton<Locale>(
    onSelected: (Locale locale) {
      context.setLocale(locale);
       },
    icon: const Icon(Icons.language),
    itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
      const PopupMenuItem<Locale>(
        value: Locale('kk'),
        child: Text('Қазақша'),
      ),
      const PopupMenuItem<Locale>(
        value: Locale('en'),
        child: Text('English'),
      ),
    ],
  ),
),

    body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.9),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      focusNode: _nameFocus,
                      onFieldSubmitted: (_) => _fieldFocusChange(context, _nameFocus, _phoneFocus),
                      controller: _nameController,
                      decoration: _inputDecoration(
                        label: 'full_name'.tr(),
                        hint: 'name_hint'.tr(),
                        icon: Icons.person,
                        suffix: Icons.delete_outline,
                        onSuffixTap: () => _nameController.clear(),
                        focusNode: _nameFocus,
                      ),
                      validator: validateName,
                      onSaved: (value) => newUser.name = value!,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      focusNode: _phoneFocus,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      onFieldSubmitted: (_) => _fieldFocusChange(context, _phoneFocus, _passFocus),
                      decoration: _inputDecoration(
                        label: 'phone'.tr(),
                        hint: 'phone_hint'.tr(),
                        icon: Icons.call,
                        suffix: Icons.delete_outline,
                        onSuffixTap: () => _phoneController.clear(),
                        focusNode: _phoneFocus,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[()\d -]')),
                      ],
                      validator: (value) =>
                          validatePhoneNumber(value!) ? null : 'phone_invalid'.tr(),
                      onSaved: (value) => newUser.phone = value!,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration(
                        label: 'email'.tr(),
                        hint: 'email_hint'.tr(),
                        icon: Icons.mail,
                        focusNode: FocusNode(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) => newUser.email = value!,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField(
                      decoration: _inputDecoration(
                        label: 'country'.tr(),
                        icon: Icons.map,
                        focusNode: FocusNode(),
                      ),
                      items: _countries.map((country) {
                        return DropdownMenuItem(value: country, child: Text(country));
                      }).toList(),
                      value: _selectedCountry,
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value!;
                        });
                      },
                      onSaved: (value) => newUser.country = value!,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      focusNode: _passFocus,
                      controller: _passController,
                      obscureText: _hidePass,
                      maxLength: 8,
                      decoration: _inputDecoration(
                        label: 'password'.tr(),
                        hint: 'password'.tr(),
                        icon: Icons.security,
                        suffix: _hidePass ? Icons.visibility : Icons.visibility_off,
                        onSuffixTap: () {
                          setState(() {
                            _hidePass = !_hidePass;
                          });
                        },
                        focusNode: _passFocus,
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _confirmPassController,
                      obscureText: _hidePass,
                      maxLength: 8,
                      decoration: _inputDecoration(
                        label: 'confirm_password'.tr(),
                        hint: 'confirm_password'.tr(),
                        icon: Icons.border_color,
                        focusNode: FocusNode(),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      child: Text('submit'.tr()),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => context.setLocale(const Locale('kk')),
                          child: const Text('Қазақша'),
                        ),
                        ElevatedButton(
                          onPressed: () => context.setLocale(const Locale('en')),
                          child: const Text('English'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

 void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    newUser.password = _passController.text; // <--- ЭТО ОБЯЗАТЕЛЬНО

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('fullName', newUser.name);
    prefs.setString('email', newUser.email);
    prefs.setString('phone', newUser.phone);
    prefs.setString('country', newUser.country);
    prefs.setString('password', newUser.password);
    prefs.setBool('isAuthenticated', true);

    widget.onRegistered(newUser);

    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  } else {
    _showMessage(message: 'Form is not valid! Please review and correct');
  }
}




  void _showMessage({required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(message, style: const TextStyle(color: Colors.white)),
    ));
  }

  // ignore: unused_element
  void _showDialog({required String name}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration successful', style: TextStyle(color: Colors.green)),
        content: Text('$name is now a verified register form'),
        actions: [
          TextButton(
            child: const Text('Verified', style: TextStyle(color: Colors.green)),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserInfoPage(userInfo: newUser)),
              );
            },
          ),
        ],
      ),
    );
  }

  String? validateName(String? value) {
    final nameExp = RegExp(r'^[A-Za-z ]+$');
    if (value == null || value.isEmpty) return 'Name is required.';
    if (!nameExp.hasMatch(value)) return 'Please enter alphabetical characters.';
    return null;
  }

  bool validatePhoneNumber(String input) => RegExp(r'^\(\d\d\d\)\d\d\d\-\d\d\d\d$').hasMatch(input);

  String? _validatePassword(String? value) {
    if (_passController.text.length != 8) return '8 characters required';
    if (_confirmPassController.text != _passController.text) return 'Passwords do not match';
    return null;
  }
}
