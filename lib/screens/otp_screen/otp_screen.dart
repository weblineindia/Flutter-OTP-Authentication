import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

// ignore: must_be_immutable
class OtpScreen extends StatefulWidget {
  bool _isInit = true;
  var _contact = '';

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late String phoneNo;
  late String smsOTP;
  late String verificationId;
  String errorMessage = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _otpPinFieldKey = GlobalKey<OtpPinFieldState>();

  //this is method is used to initialize data
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data only once after screen load
    if (widget._isInit) {
      widget._contact = '${ModalRoute.of(context)?.settings.arguments as String}';
      generateOtp(widget._contact);
      widget._isInit = false;
    }
  }

  //dispose controllers
  @override
  void dispose() {
    super.dispose();
  }

  //build method for UI
  @override
  Widget build(BuildContext context) {
    //Getting screen height width
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Image.asset(
                  'assets/images/logo.png',
                  width: screenWidth * 0.7,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Image.asset(
                  'assets/images/registration.png',
                  height: screenHeight * 0.3,
                  fit: BoxFit.contain,
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                const Text(
                  'Verification',
                  style: TextStyle(fontSize: 28, color: Colors.black),
                ),
                SizedBox(
                  height: screenHeight * 0.02,
                ),
                Text(
                  'Enter A 6 digit number that was sent to ${widget._contact}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.04,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? screenWidth * 0.2 : 16),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      // ignore: prefer_const_literals_to_create_immutables
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: screenWidth * 0.025),
                        child: OtpPinField(
                          key: _otpPinFieldKey,
                          textInputAction: TextInputAction.done,
                          maxLength: 6,
                          fieldWidth: 40,
                          onSubmit: (text) {
                            smsOTP = text;
                          },
                          onChange: (text) {},
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                      GestureDetector(
                        onTap: () {
                          verifyOtp();
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 253, 188, 51),
                            borderRadius: BorderRadius.circular(36),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Verify',
                            style: TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Method for generate otp from firebase
  Future<void> generateOtp(String contact) async {
    final PhoneCodeSent smsOTPSent = (verId, forceResendingToken) {
      verificationId = verId;
    };
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: contact,
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        codeSent: smsOTPSent,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential phoneAuthCredential) {},
        verificationFailed: (error) {
          print(error);
        },
      );
    } catch (e) {
      handleError(e as PlatformException);
    }
  }

  //Method for verify otp entered by user
  Future<void> verifyOtp() async {
    if (smsOTP.isEmpty || smsOTP == '') {
      showAlertDialog(context, 'please enter 6 digit otp');
      return;
    }
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      final UserCredential user = await _auth.signInWithCredential(credential);
      final User? currentUser = _auth.currentUser;
      assert(user.user?.uid == currentUser?.uid);
      Navigator.pushReplacementNamed(context, '/homeScreen');
    } on PlatformException catch(e){
      handleError(e);
    }
    catch (e) {
      print('error $e');
    }
  }

  //Method for handle the errors
  void handleError(PlatformException error) {
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          errorMessage = 'Invalid Code';
        });
        showAlertDialog(context, 'Invalid Code');
        break;
      default:
        showAlertDialog(context, error.message ?? 'Error');
        break;
    }
  }

  //Basic alert dialogue for alert errors and confirmations
  void showAlertDialog(BuildContext context, String message) {
    // set up the AlertDialog
    final CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: const Text('Error'),
      content: Text('\n$message'),
      actions: <Widget>[
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
