import 'package:app/src/models/user.dart' as user_model;
import 'package:app/src/sign_in_ui/email_password_sign_in_strings.dart';
import 'package:app/src/sign_in_ui/string_validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum EmailPasswordSignInFormType { signIn, register, forgotPassword }

class EmailAndPasswordValidators {
  final TextInputFormatter emailInputFormatter =
      ValidatorInputFormatter(editingValidator: EmailEditingRegexValidator());
  final StringValidator emailSubmitValidator = EmailSubmitRegexValidator();
  final StringValidator passwordRegisterSubmitValidator =
      MinLengthStringValidator(8);
  final StringValidator passwordSignInSubmitValidator =
      NonEmptyStringValidator();
}

class EmailPasswordSignInModel with EmailAndPasswordValidators, ChangeNotifier {
  EmailPasswordSignInModel({
    required this.firebaseAuth,
    this.email = '',
    this.password = '',
    this.name = '',
    this.formType = EmailPasswordSignInFormType.signIn,
    this.isLoading = false,
    this.submitted = false,
  });
  final FirebaseAuth firebaseAuth;

  String email;
  String name;
  String password;
  EmailPasswordSignInFormType formType;
  bool isLoading;
  bool submitted;

  Future<bool> submit() async {
    try {
      updateWith(submitted: true);
      if (!canSubmit) {
        return false;
      }
      updateWith(isLoading: true);
      switch (formType) {
        case EmailPasswordSignInFormType.signIn:
          await firebaseAuth.signInWithCredential(
              EmailAuthProvider.credential(email: email, password: password));
          break;
        case EmailPasswordSignInFormType.register:
          await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password);
          var userInstance = firebaseAuth.currentUser;
          var userObject = user_model.User(
              id: userInstance?.uid ?? '',
              avatar: '',
              email: userInstance?.email ?? '',
              name: name,
              seller: false,
              approver: false);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userInstance?.uid)
              .set(userObject.toMap());

          await FirebaseFirestore.instance
              .collection('stats')
              .doc('stats1')
              .update({'total_users': FieldValue.increment(1)});

          break;
        case EmailPasswordSignInFormType.forgotPassword:
          await firebaseAuth.sendPasswordResetEmail(email: email);
          updateWith(isLoading: false);
          break;
      }
      return true;
    } catch (e) {
      updateWith(isLoading: false);
      rethrow;
    }
  }

  void updateEmail(String email) => updateWith(email: email);

  void updatePassword(String password) => updateWith(password: password);

  void updateFormType(EmailPasswordSignInFormType formType) {
    updateWith(
      email: '',
      password: '',
      name: '',
      formType: formType,
      isLoading: false,
      submitted: false,
    );
  }

  void updateWith({
    String? email,
    String? name,
    String? password,
    EmailPasswordSignInFormType? formType,
    bool? isLoading,
    bool? submitted,
  }) {
    this.email = email ?? this.email;
    this.name = name ?? this.name;
    this.password = password ?? this.password;
    this.formType = formType ?? this.formType;
    this.isLoading = isLoading ?? this.isLoading;
    this.submitted = submitted ?? this.submitted;
    notifyListeners();
  }

  String get passwordLabelText {
    if (formType == EmailPasswordSignInFormType.register) {
      return EmailPasswordSignInStrings.password8CharactersLabel;
    }
    return EmailPasswordSignInStrings.passwordLabel;
  }

  // Getters
  String get primaryButtonText {
    return <EmailPasswordSignInFormType, String>{
      EmailPasswordSignInFormType.register:
          EmailPasswordSignInStrings.createAnAccount,
      EmailPasswordSignInFormType.signIn: EmailPasswordSignInStrings.signIn,
      EmailPasswordSignInFormType.forgotPassword:
          EmailPasswordSignInStrings.sendResetLink,
    }[formType]!;
  }

  String get secondaryButtonText {
    return <EmailPasswordSignInFormType, String>{
      EmailPasswordSignInFormType.register:
          EmailPasswordSignInStrings.haveAnAccount,
      EmailPasswordSignInFormType.signIn:
          EmailPasswordSignInStrings.needAnAccount,
      EmailPasswordSignInFormType.forgotPassword:
          EmailPasswordSignInStrings.backToSignIn,
    }[formType]!;
  }

  EmailPasswordSignInFormType get secondaryActionFormType {
    return <EmailPasswordSignInFormType, EmailPasswordSignInFormType>{
      EmailPasswordSignInFormType.register: EmailPasswordSignInFormType.signIn,
      EmailPasswordSignInFormType.signIn: EmailPasswordSignInFormType.register,
      EmailPasswordSignInFormType.forgotPassword:
          EmailPasswordSignInFormType.signIn,
    }[formType]!;
  }

  String get errorAlertTitle {
    return <EmailPasswordSignInFormType, String>{
      EmailPasswordSignInFormType.register:
          EmailPasswordSignInStrings.registrationFailed,
      EmailPasswordSignInFormType.signIn:
          EmailPasswordSignInStrings.signInFailed,
      EmailPasswordSignInFormType.forgotPassword:
          EmailPasswordSignInStrings.passwordResetFailed,
    }[formType]!;
  }

  String get title {
    return <EmailPasswordSignInFormType, String>{
      EmailPasswordSignInFormType.register: EmailPasswordSignInStrings.register,
      EmailPasswordSignInFormType.signIn: EmailPasswordSignInStrings.signIn,
      EmailPasswordSignInFormType.forgotPassword:
          EmailPasswordSignInStrings.forgotPassword,
    }[formType]!;
  }

  bool get canSubmitEmail {
    return emailSubmitValidator.isValid(email);
  }

  bool get canSubmitPassword {
    if (formType == EmailPasswordSignInFormType.register) {
      return passwordRegisterSubmitValidator.isValid(password);
    }
    return passwordSignInSubmitValidator.isValid(password);
  }

  bool get canSubmit {
    final bool canSubmitFields =
        formType == EmailPasswordSignInFormType.forgotPassword
            ? canSubmitEmail
            : canSubmitEmail && canSubmitPassword;
    return canSubmitFields && !isLoading;
  }

  String? get emailErrorText {
    final bool showErrorText = submitted && !canSubmitEmail;
    final String errorText = email.isEmpty
        ? EmailPasswordSignInStrings.invalidEmailEmpty
        : EmailPasswordSignInStrings.invalidEmailErrorText;
    return showErrorText ? errorText : null;
  }

  String? get passwordErrorText {
    final bool showErrorText = submitted && !canSubmitPassword;
    final String errorText = password.isEmpty
        ? EmailPasswordSignInStrings.invalidPasswordEmpty
        : EmailPasswordSignInStrings.invalidPasswordTooShort;
    return showErrorText ? errorText : null;
  }

  @override
  String toString() {
    return 'email: $email, password: $password, formType: $formType, isLoading: $isLoading, submitted: $submitted';
  }
}
