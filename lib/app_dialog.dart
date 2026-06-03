import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppDialogAction {
  const AppDialogAction({
    required this.text,
    this.onPressed,
    this.isPrimary = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
}

class AppDialog {
  static Future<void> showMessage({
    required String title,
    required String message,
    String buttonText = '知道了',
  }) async {
    await show(
      title: title,
      message: message,
      actions: [
        AppDialogAction(
          text: buttonText,
          isPrimary: true,
        ),
      ],
    );
  }

  static Future<void> show({
    required String title,
    required String message,
    required List<AppDialogAction> actions,
    bool barrierDismissible = false,
  }) async {
    final context = appNavigatorKey.currentContext;
    if (context == null) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return _AppDialogView(
          title: title,
          message: message,
          actions: actions,
        );
      },
    );
  }
}

class _AppDialogView extends StatelessWidget {
  const _AppDialogView({
    required this.title,
    required this.message,
    required this.actions,
  });

  final String title;
  final String message;
  final List<AppDialogAction> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        width: 322,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: actions
                  .map(
                    (action) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: action == actions.first ? 0 : 6,
                          right: action == actions.last ? 0 : 6,
                        ),
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              action.onPressed?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: action.isPrimary
                                  ? const Color(0xFF4F46E5)
                                  : const Color(0xFFF4F4F5),
                              foregroundColor: action.isPrimary
                                  ? Colors.white
                                  : Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              action.text,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
