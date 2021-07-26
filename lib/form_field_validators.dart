enum FormFieldValidatorsType {
  email,
  password,
  name,
  custom,
}

class FormFieldValidators {
  const FormFieldValidators({
    required this.value,
    required this.type,
    this.custom_message,
    this.custom_pattern,
  });

  final String value;
  final FormFieldValidatorsType type;
  final String? custom_message;
  final Pattern? custom_pattern;

  String? validate() {
    Pattern? pattern;
    String? message;

    switch (type) {
      case FormFieldValidatorsType.email:
        {
          pattern =
              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
          message = 'Email format is invalid';
        }
        break;

      case FormFieldValidatorsType.password:
        {}
        break;

      case FormFieldValidatorsType.name:
        {
          pattern = r"^[a-zA-Z]{2,25}$";
          message = "Enter a valid name";
        }
        break;

      case FormFieldValidatorsType.custom:
        {
          if (custom_message != null && custom_pattern != null) {
            message = custom_message;
            pattern = custom_pattern;
          } else {
            assert(
              custom_message != null && custom_pattern != null,
              "Custom validator require a custom message and a custom pattern",
            );
          }
        }
        break;
    }

    if (type == FormFieldValidatorsType.password) {
      if (value.length > 7) {
        bool has_number = false;
        bool has_letter = false;
        bool has_uppercase = false;
        bool has_lowercase = false;

        for (int i = 0; i < value.length; i++) {
          String subvalue = value.substring(i, i + 1);
          if (int.tryParse(subvalue) != null) {
            has_number = true;
          } else {
            has_letter = true;
            if (subvalue.toUpperCase() == subvalue) has_uppercase = true;
            if (subvalue.toLowerCase() == subvalue) has_lowercase = true;
          }
        }

        if (has_number) {
          if (has_letter) {
            if (has_uppercase) {
              if (has_lowercase) {
                return null;
              } else {
                return "Must contain lowercase";
              }
            } else {
              return "Must contain uppercase";
            }
          } else {
            return "Must contain a letter";
          }
        } else {
          return "Must contain a number";
        }
      } else {
        return "At least 8 characters";
      }
    } else {
      RegExp regex = new RegExp(pattern.toString());
      if (!regex.hasMatch(value)) {
        return message;
      } else {
        return null;
      }
    }
  }
}
