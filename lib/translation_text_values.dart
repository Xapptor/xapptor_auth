import 'package:xapptor_translation/model/text_list.dart';

TranslationTextListArray login_phone_values = TranslationTextListArray(
  [
    TranslationTextList(
      source_language: "en",
      text_list: [
        "Phone Number",
        "Verification Code",
        "Send Code",
        "Resend Code",
        "Validate Code",
      ],
    ),
    TranslationTextList(
      source_language: "es",
      text_list: [
        "Número de Teléfono",
        "Código de Verificación",
        "Enviar Código",
        "Reenviar Código",
        "Validar Código",
      ],
    ),
  ],
);

TranslationTextListArray login_values = TranslationTextListArray(
  [
    TranslationTextList(
      source_language: "en",
      text_list: [
        "Email",
        "Password",
        "Remember me",
        "Log In",
        "Restore password",
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
            'Write the verification code sent to your phone\nin the box below to confirm Your Account Deletion',
            "Password",
            'Verification Code',
            "Confirm Account Deletion",
            "Password is Invalid",
            'Verification Code is Invalid',
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
            'Escribe el código de verificación enviado a tu teléfono\nen el cuadro a continuación para confirmar la Eliminación de tu Cuenta',
            "Contraseña",
            'Código de Verificación',
            "Confirmar Eliminación de Cuenta",
            "Contraseña es Inválida",
            'Código de Verificación es Inválido'
          ],
    ),
  ],
);

TranslationTextListArray restore_password_values = TranslationTextListArray(
  [
    TranslationTextList(
      source_language: "en",
      text_list: [
        "Restore your Password",
        "Email",
        "Restore",
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

/// Social login text values
/// Index: 0 = Or, 1 = Sign in with Google, 2 = Sign in with Apple
TranslationTextListArray social_login_values = TranslationTextListArray(
  [
    TranslationTextList(
      source_language: "en",
      text_list: [
        "Or",
        "Sign in with Google",
        "Sign in with Apple",
      ],
    ),
    TranslationTextList(
      source_language: "es",
      text_list: [
        "O",
        "Iniciar sesión con Google",
        "Iniciar sesión con Apple",
      ],
    ),
  ],
);

/// Terms and Conditions / Privacy Policy text values
/// Index: 0 = I accept the, 1 = privacy policies.
TranslationTextListArray tc_and_pp_values = TranslationTextListArray(
  [
    TranslationTextList(
      source_language: "en",
      text_list: [
        "I accept the ",
        "privacy policies.",
      ],
    ),
    TranslationTextList(
      source_language: "es",
      text_list: [
        "Acepto las ",
        "políticas de privacidad.",
      ],
    ),
  ],
);
