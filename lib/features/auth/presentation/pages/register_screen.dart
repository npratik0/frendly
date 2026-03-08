import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:frendly/features/auth/presentation/state/auth_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../theme/app_styles.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/custom_text_field.dart';
import '../../../../widgets/password_field.dart';
import '../../../../widgets/divider_with_text.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pw = TextEditingController();
  final _confirm = TextEditingController();
  final _bio = TextEditingController();

  bool _hidePw = true;
  bool _hideConfirm = true;
  bool _agree = false;

  String? _gender;
  DateTime? _dob;

  File? _profileImage;

  final ImagePicker _imagePicker = ImagePicker();

  List<String> interests = [];
  final List<String> allInterests = [
    "Sports",
    "Music",
    "Gaming",
    "Movies",
    "Travel",
    "Tech",
    "Fitness",
    "Food",
    "Books",
    "Art",
  ];

  final List<Map<String, String>> countryCodes = [
    {"name": "Nepal", "code": "+977"},
    {"name": "India", "code": "+91"},
    {"name": "USA", "code": "+1"},
    {"name": "UK", "code": "+44"},
    {"name": "Australia", "code": "+61"},
    {"name": "Canada", "code": "+1"},
  ];

  String selectedCountry = "Nepal";
  String selectedCode = "+977";

  Future<void> _pickDOB() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime(2025),
    );

    if (date != null) {
      setState(() => _dob = date);
    }
  }

  Future<bool> _requestImagePermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "Please enable camera or gallery permission from settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final granted = await _requestImagePermission(ImageSource.camera);
    if (!granted) {
      _showPermissionDeniedDialog();
      return;
    }

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final granted = await _requestImagePermission(ImageSource.gallery);
    if (!granted) {
      _showPermissionDeniedDialog();
      return;
    }

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Open Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Open Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Listen to auth state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.registered) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration successful! Please login."),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }

      if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? "Something went wrong"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              const Text("Frendly", style: AppStyles.logoTitle),
              const SizedBox(height: 20),

              const Text("CREATE ACCOUNT", style: AppStyles.screenTitle),
              const SizedBox(height: 10),
              const Text("Join the community!", style: AppStyles.subtitle),

              const SizedBox(height: 32),

              /// ---------------- FORM ----------------
              Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// PROFILE PICTURE
                    Center(
                      child: GestureDetector(
                        onTap: _pickMedia,
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Colors.grey.shade700,
                                )
                              : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// FULL NAME
                    CustomTextField(
                      controller: _name,
                      hint: "Full Name",
                      validator: (v) => v!.isEmpty ? "Enter full name" : null,
                    ),
                    const SizedBox(height: 18),

                    /// USERNAME
                    CustomTextField(
                      controller: _user,
                      hint: "Username",
                      validator: (v) => v!.isEmpty ? "Enter username" : null,
                    ),
                    const SizedBox(height: 18),

                    /// EMAIL
                    CustomTextField(
                      controller: _email,
                      hint: "Email",
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Enter email";
                        if (!v.contains("@") || !v.contains("."))
                          return "Invalid email";
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    /// PHONE NUMBER
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCountry,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: countryCodes.map((c) {
                                return DropdownMenuItem(
                                  value: c["name"],
                                  child: Text(c["name"]!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedCountry = value!;
                                  selectedCode = countryCodes.firstWhere(
                                    (c) => c["name"] == value,
                                  )["code"]!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedCode,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                hintText: "Phone Number",
                                border: InputBorder.none,
                              ),
                              validator: (v) =>
                                  v!.isEmpty ? "Enter phone number" : null,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// DOB
                    GestureDetector(
                      onTap: _pickDOB,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          _dob == null
                              ? "Date of Birth"
                              : "${_dob!.day}/${_dob!.month}/${_dob!.year}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// GENDER
                    const Text(
                      "Gender",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text("male"),
                          value: "male",
                          groupValue: _gender,
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                        RadioListTile<String>(
                          title: const Text("female"),
                          value: "female",
                          groupValue: _gender,
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                        RadioListTile<String>(
                          title: const Text("other"),
                          value: "other",
                          groupValue: _gender,
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// BIO
                    CustomTextField(controller: _bio, hint: "Bio (optional)"),

                    const SizedBox(height: 18),

                    /// INTERESTS
                    const Text(
                      "Select Interests:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      children: allInterests.map((interest) {
                        final selected = interests.contains(interest);
                        return ChoiceChip(
                          label: Text(interest),
                          selected: selected,
                          onSelected: (v) {
                            setState(() {
                              v
                                  ? interests.add(interest)
                                  : interests.remove(interest);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    /// PASSWORD
                    PasswordField(
                      controller: _pw,
                      hint: "Password",
                      obscure: _hidePw,
                      onToggle: () => setState(() => _hidePw = !_hidePw),
                      validator: (v) =>
                          v!.length < 6 ? "Minimum 6 characters" : null,
                    ),

                    const SizedBox(height: 18),

                    /// CONFIRM PASSWORD
                    PasswordField(
                      controller: _confirm,
                      hint: "Confirm Password",
                      obscure: _hideConfirm,
                      onToggle: () =>
                          setState(() => _hideConfirm = !_hideConfirm),
                      validator: (v) =>
                          v != _pw.text ? "Passwords do not match" : null,
                    ),

                    const SizedBox(height: 18),

                    /// AGREEMENT
                    CheckboxListTile(
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v!),
                      title: const Text("I agree to the Terms & Conditions"),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              /// SIGN UP BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (!_form.currentState!.validate()) return;

                    if (!_agree || _dob == null || _gender == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please complete all required fields"),
                        ),
                      );
                      return;
                    }

                    ref
                        .read(authViewModelProvider.notifier)
                        .register(
                          username: _user.text.trim(),
                          email: _email.text.trim(),
                          password: _pw.text.trim(),
                          confirmPassword: _confirm.text.trim(),
                          fullName: _name.text.trim(),
                          phoneNumber: '$selectedCode ${_phone.text.trim()}',
                          dateOfBirth:
                              "${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}",
                          gender: _gender!,
                          profilePicture: _profileImage?.path ?? '',
                          bio: _bio.text.trim(),
                        );
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                child: const Text("Already have an account? Sign In"),
              ),

              const SizedBox(height: 20),

              const DividerWithText(text: "Or continue with"),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/images/google_logo.jpg',
                      height: 30,
                      width: 30,
                    ),
                    label: const Text(
                      "Login with Google",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
