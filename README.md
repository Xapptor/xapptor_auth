# **Xapptor Auth**
[![pub package](https://img.shields.io/pub/v/xapptor_auth?color=blue)](https://pub.dartlang.org/packages/xapptor_auth)
### Authentication Module to develop fast and easy Login, Register, Restore Password, and Edit Account Screens. Using Firebase Auth and Firestore.

## **Let's get started**

### **1 - Depend on it**
##### Add it to your package's pubspec.yaml file
```yml
dependencies:
    xapptor_auth: ^0.0.3
```

### **2 - Install it**
##### Install packages from the command line
```sh
flutter pub get
```

### **3 - Learn it like a charm**

### **Login Example**
```dart
UserInfoView(
    text_list: [
        "Email",
        "Password",
        "Remember me",
        "Log In",
        "Recover password",
        "Register",
    ],
    tc_and_pp_text: RichText(text: TextSpan()),
    gender_values: [],
    country_values: [],
    text_color: Colors.blue,
    first_button_color: Colors.white,
    second_button_color: Colors.white,
    third_button_color: Colors.white,
    logo_image_path: "your_image_path",
    has_language_picker: false,
    topbar_color: Colors.blue,
    custom_background: null,
    user_info_form_type: UserInfoFormType.login,
    outline_border: true,
    first_button_action: null,
    second_button_action: open_forgot_password,
    third_button_action: open_register,
    has_back_button: true,
    text_field_background_color: null,
);
```

### **Register Example**
```dart
UserInfoView(
    text_list: [
        "Email",
        "Confirm Email",
        "Password",
        "Confirm password",
        "First name",
        "Last name",
        "Birthday",
        "Register",
    ],
    tc_and_pp_text: RichText(
        text: TextSpan(
            children: [
                TextSpan(
                    text: 'I accept the ',
                    style: TextStyle(
                    color: color_text,
                    ),
                ),
                TextSpan(
                    text: 'privacy policies.',
                    style: TextStyle(
                    color: color_text,
                    fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()
                    ..onTap = () {
                        launchUrl("https://www.domain.com/#/privacy_policy");
                    },
                ),
            ],
        ),
    ),
    gender_values: gender_values_english = [
        'Masculine',
        'Femenine',
        'Non-binary',
        'Rather not say',
    ],
    country_values: [
        'United States',
        'Mexico',
        'Canada',
        'Brazil',
    ],
    text_color: Colors.blue,
    first_button_color: Colors.white,
    second_button_color: Colors.white,
    third_button_color: Colors.white,
    logo_image_path: "your_image_path",
    has_language_picker: false,
    topbar_color: Colors.blue,
    custom_background: null,
    user_info_form_type: UserInfoFormType.register,
    outline_border: true,
    first_button_action: null,
    second_button_action: null,
    third_button_action: null,
    has_back_button: true,
    text_field_background_color: null,
);
```

### **Restore Password Example**
```dart
UserInfoView(
    text_list: [
        "Enter your email",
        "Email",
        "Restore your password",
    ],
    tc_and_pp_text: RichText(text: TextSpan()),
    gender_values: [],
    country_values: [],
    text_color: Colors.blue,
    first_button_color: Colors.white,
    second_button_color: Colors.white,
    third_button_color: Colors.white,
    logo_image_path: "your_image_path",
    has_language_picker: false,
    topbar_color: Colors.blue,
    custom_background: null,
    user_info_form_type: UserInfoFormType.forgot_password,
    outline_border: true,
    first_button_action: null,
    second_button_action: null,
    third_button_action: null,
    has_back_button: true,
    text_field_background_color: null,
);
```

### **Edit Account Example**
```dart
UserInfoView(
    text_list: [
        "Email",
        "Confirm Email",
        "Password",
        "Confirm password",
        "First name",
        "Last name",
        "Birthday",
        "Update",
    ],
    tc_and_pp_text: RichText(text: TextSpan()),
    gender_values: gender_values_english = [
        'Masculine',
        'Femenine',
        'Non-binary',
        'Rather not say',
    ],
    country_values: [
        'United States',
        'Mexico',
        'Canada',
        'Brazil',
    ],
    text_color: Colors.blue,
    first_button_color: Colors.white,
    second_button_color: Colors.white,
    third_button_color: Colors.white,
    logo_image_path: "your_image_path",
    has_language_picker: false,
    topbar_color: Colors.blue,
    custom_background: null,
    user_info_form_type: UserInfoFormType.edit_account,
    outline_border: true,
    first_button_action: null,
    second_button_action: null,
    third_button_action: null,
    has_back_button: true,
    text_field_background_color: null,
);
```

### **4 - Check Abeinstitute Repo for more examples**
[Abeinstitute Repo](https://github.com/Xapptor/abeinstitute)

[Abeinstitute](https://www.abeinstitute.com)

### **5 - Live Examples**

### **Login**
[Abeinstitute Login](https://www.abeinstitute.com/login)

### **Register**
[Abeinstitute Register](https://www.abeinstitute.com/register)

### **Restore Password**
[Abeinstitute Restore Password](https://www.abeinstitute.com/forgot_password)
