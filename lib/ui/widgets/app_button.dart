import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final Future<void> Function()? onPressed; // 🔧 support async
  final bool loading;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: loading
            ? null
            : () async {
                if (onPressed != null) {
                  await onPressed!();
                }
              },
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(text),
      ),
    );
  }
}
