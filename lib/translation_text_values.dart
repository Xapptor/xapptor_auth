import 'package:xapptor_translation/model/text_list.dart';

TranslationTextListArray login_values = TranslationTextListArray(
  [
    TranslationTextList(
      source_language: "en",
      text_list: [
        "Email",
        "Password",
        "Remember me",
        "Log In",
        "Recover password",
        "Register",
      ],
    ),
    TranslationTextList(
      source_language: "es",
      text_list: [
        "Email",
        "Contraseña",
        "Recuérdame",
        "Ingresar",
        "Recuperar contraseña",
        "Registrar",
      ],
    ),
  ],
);

TranslationTextListArray register_values = TranslationTextListArray(
  [
    TranslationTextList(
      source_language: "en",
      text_list: [
        "Email",
        "Confirm Email",
        "Password",
        "Confirm Password",
        "First Name",
        "Last Name",
        "Birthday",
        "Register",
      ],
    ),
    TranslationTextList(
      source_language: "es",
      text_list: [
        "Email",
        "Confirmar Email",
        "Contraseña",
        "Confirmar Contraseña",
        "Nombres",
        "Apellidos",
        "Fecha de Nacimiento",
        "Registrar",
      ],
    ),
  ],
);

TranslationTextListArray account_values = TranslationTextListArray(
  [
    TranslationTextList(
      source_language: "en",
      text_list: register_values.list[0].text_list
              .sublist(0, register_values.list[0].text_list.length - 1) +
          [
            "Update",
            "Delete My Account",
            "Write your password in the box below\nto confirm Your Account Deletion",
            "Password",
            "Confirm Account Deletion",
            "Password is Invalid",
          ],
    ),
    TranslationTextList(
      source_language: "es",
      text_list: register_values.list[1].text_list
              .sublist(0, register_values.list[1].text_list.length - 1) +
          [
            "Actualizar",
            "Eliminar Mi Cuenta",
            "Escribe tu contraseña en el cuadro a continuación\npara confirmar la Eliminación de tu Cuenta",
            "Contraseña",
            "Confirmar Eliminación de Cuenta",
            "Contraseña es Inválida",
          ],
    ),
  ],
);

TranslationTextListArray forgot_password_values = TranslationTextListArray(
  [
    TranslationTextList(
      source_language: "en",
      text_list: [
        "Enter your Email",
        "Email",
        "Restore your Password",
      ],
    ),
    TranslationTextList(
      source_language: "es",
      text_list: [
        "Ingresa tu Email",
        "Email",
        "Restablecer Contraseña",
      ],
    ),
  ],
);

TranslationTextListArray gender_values = TranslationTextListArray(
  [
    TranslationTextList(
      source_language: "en",
      text_list: [
        'Masculine',
        'Femenine',
        'Non-binary',
        'Rather not say',
      ],
    ),
    TranslationTextList(
      source_language: "es",
      text_list: [
        'Masculino',
        'Femenino',
        'No binario',
        'Prefiero no decir',
      ],
    ),
  ],
);
