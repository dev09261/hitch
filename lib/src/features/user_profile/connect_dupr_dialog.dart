import 'package:flutter/material.dart';
import 'package:hitch/src/models/dupr_model.dart';
import 'package:hitch/src/res/app_text_styles.dart';
import 'package:hitch/src/services/dupr_service.dart';
import 'package:hitch/src/utils/show_snackbars.dart';
import 'package:hitch/src/utils/utils.dart';

class ConnectDuprDialog extends StatefulWidget {
  const ConnectDuprDialog({super.key});

  @override
  State<ConnectDuprDialog> createState() => _ConnectDuprDialogState();
}

class _ConnectDuprDialogState extends State<ConnectDuprDialog> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_isLoading) return;
    if (_emailController.text != '') {
      setState(() {
        _isLoading = true;
      });
      DuprModel duprData = await DuprService().getDupr(email: _emailController.text);
      setState(() {
        _isLoading = false;
      });
      if (duprData.status == 'error') {
        ShowSnackbars.showErrorSnackBar(context, errorMsgTitle: "Connection Failed", errorMsgTxt: "Try again!");
        Navigator.pop(context);
        return;
      }

      Utils.showTopSnackBar(context, content: const Column(
        children: [
          Text('Successes!', style: AppTextStyles.pageHeadingStyle,),
        ],
      ));

      Navigator.pop(context, duprData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Rounded corners
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[500]!, // Lighter blue
              Colors.blue[900]!, // Darker blue
            ],
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16,),
              const Center(
                child: Text(
                  "Connect With",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              const Text(
                "DUPR",
                style: TextStyle(
                    color: Colors.white,
                    letterSpacing: -6.0, // Negative value reduces letter spacing
                    fontWeight: FontWeight.bold,
                    fontSize: 60
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Text(
                      "Submit your DUPR email to sync your rating with Hitch",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30)
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Enter Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 0
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child:
                      _isLoading ?
                      const CircularProgressIndicator(
                        color: Colors.white,
                      ):
                      const Text('Submit',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
                  )
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
