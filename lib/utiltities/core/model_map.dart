import 'package:elysia/utiltities/consts/model_metadata.dart';

class ModelUtils {
  /// Returns the display name for a given `name_of_model`.
  /// Returns null if no match is found.
  static String? getDisplayName(String nameOfModel) {
    final model = supportedModels.firstWhere(
      (m) => m['name_of_model'] == nameOfModel,
      orElse: () => {},
    );
    return model['display_name'];
  }
}
