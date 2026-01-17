// import 'package:flutter/material.dart';
// import 'package:frendly/features/auth/presentation/view_model/auth_view_model.dart';
// import '../../../../theme/app_styles.dart';
// import '../../../../theme/app_colors.dart';
// import '../../../../widgets/custom_text_field.dart';
// import '../../../../widgets/password_field.dart';
// import '../../../../widgets/divider_with_text.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _form = GlobalKey<FormState>();

//   final _name = TextEditingController();
//   final _user = TextEditingController();
//   final _email = TextEditingController();
//   final _phone = TextEditingController();
//   final _pw = TextEditingController();
//   final _confirm = TextEditingController();
//   final _bio = TextEditingController();

//   bool _hidePw = true;
//   bool _hideConfirm = true;
//   bool _agree = false;

//   String? _gender;
//   DateTime? _dob;

//   List<String> interests = [];
//   final List<String> allInterests = [
//     "Sports",
//     "Music",
//     "Gaming",
//     "Movies",
//     "Travel",
//     "Tech",
//     "Fitness",
//     "Food",
//     "Books",
//     "Art",
//   ];

//   Future<void> _pickDOB() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: DateTime(2005),
//       firstDate: DateTime(1950),
//       lastDate: DateTime(2025),
//     );

//     if (date != null) setState(() => _dob = date);
//   }

//   final List<Map<String, String>> countryCodes = [
//     {"name": "Nepal", "code": "+977"},
//     {"name": "India", "code": "+91"},
//     {"name": "USA", "code": "+1"},
//     {"name": "UK", "code": "+44"},
//     {"name": "Australia", "code": "+61"},
//     {"name": "Canada", "code": "+1"},
//   ];

//   String selectedCountry = "Nepal";
//   String selectedCode = "+977";

//   @override
//   Widget build(BuildContext context) {
//     // authstate
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 10),

//               const Text("Frendly", style: AppStyles.logoTitle),
//               const SizedBox(height: 20),

//               const Text("CREATE ACCOUNT", style: AppStyles.screenTitle),
//               const SizedBox(height: 10),
//               const Text("Join the community!", style: AppStyles.subtitle),

//               const SizedBox(height: 32),

//               /// ---------------- FORM ----------------
//               Form(
//                 key: _form,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// PROFILE PICTURE
//                     Center(
//                       child: CircleAvatar(
//                         radius: 45,
//                         backgroundColor: Colors.grey.shade300,
//                         child: Icon(
//                           Icons.camera_alt,
//                           size: 40,
//                           color: Colors.grey.shade700,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     /// FULL NAME
//                     CustomTextField(
//                       controller: _name,
//                       hint: "Full Name",
//                       validator: (v) => v!.isEmpty ? "Enter full name" : null,
//                     ),
//                     const SizedBox(height: 18),

//                     /// USERNAME
//                     CustomTextField(
//                       controller: _user,
//                       hint: "Username",
//                       validator: (v) => v!.isEmpty ? "Enter username" : null,
//                     ),
//                     const SizedBox(height: 18),

//                     /// EMAIL
//                     CustomTextField(
//                       controller: _email,
//                       hint: "Email",
//                       validator: (v) {
//                         if (v == null || v.isEmpty) return "Enter email";
//                         if (!v.contains("@") || !v.contains("."))
//                           return "Invalid email";
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 18),

//                     // Phone
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade400),
//                       ),
//                       child: Row(
//                         children: [
//                           /// COUNTRY DROPDOWN
//                           DropdownButtonHideUnderline(
//                             child: DropdownButton<String>(
//                               value: selectedCountry,
//                               icon: const Icon(Icons.arrow_drop_down),
//                               items: countryCodes.map((c) {
//                                 return DropdownMenuItem(
//                                   value: c["name"],
//                                   child: Row(children: [Text(c["name"]!)]),
//                                 );
//                               }).toList(),
//                               onChanged: (value) {
//                                 setState(() {
//                                   selectedCountry = value!;
//                                   selectedCode = countryCodes.firstWhere(
//                                     (c) => c["name"] == value,
//                                   )["code"]!;
//                                 });
//                               },
//                             ),
//                           ),

//                           const SizedBox(width: 8),

//                           /// COUNTRY CODE TEXT
//                           Text(
//                             selectedCode,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),

//                           const SizedBox(width: 12),

//                           /// PHONE NUMBER INPUT
//                           Expanded(
//                             child: TextFormField(
//                               controller: _phone,
//                               keyboardType: TextInputType.phone,
//                               decoration: const InputDecoration(
//                                 hintText: "Phone Number",
//                                 border: InputBorder.none,
//                               ),
//                               validator: (v) =>
//                                   v!.isEmpty ? "Enter phone number" : null,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 18),

//                     /// DATE OF BIRTH
//                     GestureDetector(
//                       onTap: _pickDOB,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 14,
//                           vertical: 16,
//                         ),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.shade400),
//                         ),
//                         child: Text(
//                           _dob == null
//                               ? "Date of Birth"
//                               : "${_dob!.day}/${_dob!.month}/${_dob!.year}",
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 18),

//                     // GENDER RADIO BUTTONS
//                     const Text(
//                       "Gender",
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),

//                     Column(
//                       children: [
//                         RadioListTile<String>(
//                           title: const Text("Male"),
//                           value: "Male",
//                           groupValue: _gender,
//                           onChanged: (value) {
//                             setState(() => _gender = value);
//                           },
//                         ),
//                         RadioListTile<String>(
//                           title: const Text("Female"),
//                           value: "Female",
//                           groupValue: _gender,
//                           onChanged: (value) {
//                             setState(() => _gender = value);
//                           },
//                         ),
//                         RadioListTile<String>(
//                           title: const Text("Other"),
//                           value: "Other",
//                           groupValue: _gender,
//                           onChanged: (value) {
//                             setState(() => _gender = value);
//                           },
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 18),

//                     const SizedBox(height: 18),

//                     /// BIO (OPTIONAL)
//                     CustomTextField(
//                       controller: _bio,
//                       hint: "Bio (optional)",
//                       // maxLines: 3,
//                     ),
//                     const SizedBox(height: 18),

//                     /// INTERESTS
//                     const Text(
//                       "Select Interests:",
//                       style: TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                     const SizedBox(height: 10),

//                     Wrap(
//                       spacing: 10,
//                       children: allInterests.map((interest) {
//                         final selected = interests.contains(interest);
//                         return ChoiceChip(
//                           label: Text(interest),
//                           selected: selected,
//                           onSelected: (v) {
//                             setState(() {
//                               if (v)
//                                 interests.add(interest);
//                               else
//                                 interests.remove(interest);
//                             });
//                           },
//                         );
//                       }).toList(),
//                     ),

//                     const SizedBox(height: 20),

//                     /// PASSWORD
//                     PasswordField(
//                       controller: _pw,
//                       hint: "Password",
//                       obscure: _hidePw,
//                       onToggle: () => setState(() => _hidePw = !_hidePw),
//                       validator: (v) =>
//                           v!.length < 6 ? "Minimum 6 characters" : null,
//                     ),
//                     const SizedBox(height: 18),

//                     /// CONFIRM PASSWORD
//                     PasswordField(
//                       controller: _confirm,
//                       hint: "Confirm Password",
//                       obscure: _hideConfirm,
//                       onToggle: () =>
//                           setState(() => _hideConfirm = !_hideConfirm),
//                       validator: (v) =>
//                           v != _pw.text ? "Passwords do not match" : null,
//                     ),

//                     const SizedBox(height: 18),

//                     /// AGREEMENT
//                     CheckboxListTile(
//                       value: _agree,
//                       onChanged: (v) => setState(() => _agree = v!),
//                       title: const Text("I agree to the Terms & Conditions"),
//                       controlAffinity: ListTileControlAffinity.leading,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 22),

//               /// SIGN UP BUTTON
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     if (_form.currentState!.validate() && _agree) {
//                       // Navigator.pushReplacementNamed(context, '/home');
//                       ref
//                           .read(authViewModelProvider.notifier)
//                           .register(
//                             username: _user.text,
//                             email: _email.text,
//                             password: _pw.text,
//                             fullName: _name.text,
//                             phoneNumber: '$selectedCode ${_phone.text}',
//                             dob: _dob!,
//                             gender: _gender!,
//                             profilePicture: null,
//                             bio: _bio.text,
//                           );
//                     }
//                   },
//                   child: const Text(
//                     "Sign Up",
//                     style: TextStyle(fontSize: 18, color: Colors.white),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               TextButton(
//                 onPressed: () =>
//                     Navigator.pushReplacementNamed(context, '/login'),
//                 child: const Text("Already have an account? Sign In"),
//               ),

//               const SizedBox(height: 20),

//               const DividerWithText(text: "Or continue with"),

//               const SizedBox(height: 18),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: () {},
//                     icon: Image.asset(
//                       'assets/images/google_logo.jpg',
//                       height: 30,
//                       width: 30,
//                     ),
//                     label: const Text(
//                       "Login with Google",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.black,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         side: const BorderSide(
//                           color: Colors.grey,
//                         ), // subtle border
//                       ),
//                       elevation: 5,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:frendly/features/auth/presentation/state/auth_state.dart';
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
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.grey.shade700,
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
                          // phoneNumber: int.parse(_phone.text.trim()),
                          dateOfBirth:
                              "${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}",
                          gender: _gender!,
                          profilePicture: null,
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
