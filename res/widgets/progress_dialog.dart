import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final String? title;

  const ProgressDialog({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black38,
      child: Dialog(
        backgroundColor: Colors.black38,
        child: Container(
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //SizedBox(width: 6.0,),

                CupertinoActivityIndicator(
                  radius: 25,
                  color: Theme.of(context).primaryColor,
                ),
                // CircularProgressIndicator(
                //   valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                // ),
                const SizedBox(
                  width: 26.0,
                ),
                Text(
                  title ?? "Ждем...",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
