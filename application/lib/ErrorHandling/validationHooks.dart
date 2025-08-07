import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FieldValidation {
  final String? error;
  final bool touched;
  final bool changed;
  final void Function(bool hasFocus) onFocusChange;
  final void Function() validateNow;

  const FieldValidation({
    required this.error,
    required this.touched,
    required this.changed,
    required this.onFocusChange,
    required this.validateNow,
  });
}

FieldValidation useFieldValidation({
  required TextEditingController controller,
  required String? Function(String) validator,
}) {
  final error = useState<String?>(null);
  final touched = useState(false);
  final changed = useState(false);
  final last = useRef(controller.text);

  useEffect(() {
    void listener() {
      if (controller.text != last.value) {
        changed.value = true;
        last.value = controller.text;
      }
      if (touched.value) error.value = validator(controller.text);
    }

    controller.addListener(listener);
    return () => controller.removeListener(listener);
  }, [controller, touched.value]);

  void onFocusChange(bool hasFocus) {
    if (!hasFocus && changed.value) {
      touched.value = true;
      error.value = validator(controller.text);
    }
  }

  void validateNow() {
    touched.value = true;
    error.value = validator(controller.text);
  }

  return FieldValidation(
    error: error.value,
    touched: touched.value,
    changed: changed.value,
    onFocusChange: onFocusChange,
    validateNow: validateNow,
  );
}

bool hasAnyError(List<FieldValidation> f) => f.any((e) => e.error != null);

void validateAll(List<FieldValidation> f) => f.forEach((e) => e.validateNow());

Future<void> scrollToFirstError(
  List<MapEntry<GlobalKey, FieldValidation>> keyed,
) async {
  for (final e in keyed) {
    if (e.value.error != null && e.key.currentContext != null) {
      await Scrollable.ensureVisible(
        e.key.currentContext!,
        duration: const Duration(milliseconds: 300),
        alignment: 0.1,
        curve: Curves.easeInOut,
      );
      break;
    }
  }
}
