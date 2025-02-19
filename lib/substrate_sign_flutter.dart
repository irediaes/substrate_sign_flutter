import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

///////////////////////////////////////////////////////////////////////////////
// Typedef's
///////////////////////////////////////////////////////////////////////////////

typedef FreeStringFunc = void Function(Pointer<Utf8>);
typedef FreeStringFuncNative = Void Function(Pointer<Utf8>);

typedef RustRandomPhrase = Pointer<Utf8> Function(int);
typedef RustRandomPhraseNative = Pointer<Utf8> Function(Uint32);

typedef RustSign = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef RustSignNative = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);

typedef RustSubstrateAddress = Pointer<Utf8> Function(Pointer<Utf8>, int);
typedef RustSubstrateAddressNative = Pointer<Utf8> Function(
    Pointer<Utf8>, Uint32);

typedef RustEncrypt = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef RustEncryptNative = Pointer<Utf8> Function(
    Pointer<Utf8>, Pointer<Utf8>);

typedef RustDecrypt = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
typedef RustDecryptNative = Pointer<Utf8> Function(
    Pointer<Utf8>, Pointer<Utf8>);

typedef RustDecryptWithRef = int Function(Pointer<Utf8>, Pointer<Utf8>);
typedef RustDecryptWithRefNative = Int64 Function(Pointer<Utf8>, Pointer<Utf8>);

typedef RustDestroyDataRef = void Function(int);
typedef RustDestroyDataRefNative = Void Function(Int64);

typedef RustSignWithRef = Pointer<Utf8> Function(
    int, Pointer<Utf8>, Pointer<Utf8>);
typedef RustSignWithRefNative = Pointer<Utf8> Function(
    Int64, Pointer<Utf8>, Pointer<Utf8>);

typedef RustSubstrateAddressWithRef = Pointer<Utf8> Function(
    int, Pointer<Utf8>, int);
typedef RustSubstrateAddressWithRefNative = Pointer<Utf8> Function(
    Int64, Pointer<Utf8>, Uint32);

///////////////////////////////////////////////////////////////////////////////
// Load the library
///////////////////////////////////////////////////////////////////////////////

final DynamicLibrary nativeSubstrateSignLib = Platform.isAndroid
    ? DynamicLibrary.open("libsubstrateSign.so")
    : DynamicLibrary.process();

///////////////////////////////////////////////////////////////////////////////
// Locate the symbols we want to use
///////////////////////////////////////////////////////////////////////////////

final FreeStringFunc freeCString = nativeSubstrateSignLib
    .lookup<NativeFunction<FreeStringFuncNative>>("rust_cstr_free")
    .asFunction();

final RustRandomPhrase rustRandomPhrase = nativeSubstrateSignLib
    .lookup<NativeFunction<RustRandomPhraseNative>>("random_phrase")
    .asFunction();

final RustSign rustSign = nativeSubstrateSignLib
    .lookup<NativeFunction<RustSignNative>>("substrate_sign")
    .asFunction();

final RustSubstrateAddress rustSubstrateAddress = nativeSubstrateSignLib
    .lookup<NativeFunction<RustSubstrateAddressNative>>("substrate_address")
    .asFunction();

final RustEncrypt rustEncrypt = nativeSubstrateSignLib
    .lookup<NativeFunction<RustEncryptNative>>("encrypt_data")
    .asFunction();

final RustDecrypt rustDecrypt = nativeSubstrateSignLib
    .lookup<NativeFunction<RustDecryptNative>>("decrypt_data")
    .asFunction();

final RustDecryptWithRef rustDecryptWithRef = nativeSubstrateSignLib
    .lookup<NativeFunction<RustDecryptWithRefNative>>("decrypt_data_with_ref")
    .asFunction();

final RustDestroyDataRef rustDestroyDataRef = nativeSubstrateSignLib
    .lookup<NativeFunction<RustDestroyDataRefNative>>("destroy_data_ref")
    .asFunction();

final RustSignWithRef rustSignWithRef = nativeSubstrateSignLib
    .lookup<NativeFunction<RustSignWithRefNative>>("substrate_sign_with_ref")
    .asFunction();

final RustSubstrateAddressWithRef rustSubstrateAddressWithRef =
    nativeSubstrateSignLib
        .lookup<NativeFunction<RustSubstrateAddressWithRefNative>>(
            "substrate_address_with_ref")
        .asFunction();

///////////////////////////////////////////////////////////////////////////////
// HANDLERS
///////////////////////////////////////////////////////////////////////////////

String randomPhrase(int digits) {
  if (nativeSubstrateSignLib == null)
    return "ERROR: The library is not initialized 🙁";

  print(
      "nativeSubstrateSignLib:  ${nativeSubstrateSignLib.toString()}"); // Instance info
  final phrasePointer = rustRandomPhrase(digits);
  return phrasePointer.toDartString();
}

String substrateSign(String suri, String message) {
  final utf8Suri = suri.toNativeUtf8();
  final utf8Message = message.toNativeUtf8();
  final utf8SignedMessage = rustSign(utf8Suri, utf8Message);
  final signedMessage = utf8SignedMessage.toDartString();
  freeCString(utf8SignedMessage);
  return signedMessage;
}

String substrateAddress(String seed, int prefix) {
  final utf8Seed = seed.toNativeUtf8();
  final utf8Address = rustSubstrateAddress(utf8Seed, prefix);
  final address = utf8Address.toDartString();
  freeCString(utf8Address);
  return address;
}

String encryptData(String data, String password) {
  final utf8Data = data.toNativeUtf8();
  final utf8Password = password.toNativeUtf8();
  final utf8Encrypted = rustEncrypt(utf8Data, utf8Password);
  final encrypted = utf8Encrypted.toDartString();
  freeCString(utf8Encrypted);
  return encrypted;
}

String decryptData(String data, String password) {
  final utf8Data = data.toNativeUtf8();
  final utf8Password = password.toNativeUtf8();
  final utf8Decrypted = rustDecrypt(utf8Data, utf8Password);
  final decrypted = utf8Decrypted.toDartString();
  freeCString(utf8Decrypted);
  return decrypted;
}

int decryptDataWithRef(String data, String password) {
  final utf8Data = data.toNativeUtf8();
  final utf8Password = password.toNativeUtf8();
  final ref = rustDecryptWithRef(utf8Data, utf8Password);
  return ref;
}

void destroyDataRef(int ref) {
  rustDestroyDataRef(ref);
}

String substrateSignWithRef(int seedRef, String suriSuffix, String message) {
  if (seedRef == 0) return "seed ref not valid";
  final utf8SuriSuffix = suriSuffix.toNativeUtf8();
  final utf8Message = message.toNativeUtf8();
  final utf8SignedMessage =
      rustSignWithRef(seedRef, utf8SuriSuffix, utf8Message);
  final signedMessage = utf8SignedMessage.toDartString();
  freeCString(utf8SignedMessage);
  return signedMessage;
}

String substrateAddressWithRef(int seedRef, String suriSuffix, int prefix) {
  if (seedRef == 0) return "seed ref not valid";
  final utf8SuriSuffix = suriSuffix.toNativeUtf8();
  final utf8Address =
      rustSubstrateAddressWithRef(seedRef, utf8SuriSuffix, prefix);
  final address = utf8Address.toDartString();
  freeCString(utf8Address);
  return address;
}
