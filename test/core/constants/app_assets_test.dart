import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jatra_nova/core/constants/app_assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'every AppAssets constant is registered in pubspec and loads cleanly',
    () async {
      const assets = <String>[
        AppAssets.splashBackground,
        AppAssets.onboardingBackground,
        AppAssets.languageSelectionBackground,
        AppAssets.resetPasswordBackground,
        AppAssets.generalBackground,
        AppAssets.onboardingIllustration1,
        AppAssets.onboardingIllustration2,
        AppAssets.onboardingIllustration3,
        AppAssets.emailIllustration,
        AppAssets.busIllustration,
        AppAssets.busLogo,
        AppAssets.busIcon,
        AppAssets.googleLogo,
      ];

      for (final path in assets) {
        final data = await rootBundle.load(path);
        expect(data.lengthInBytes, greaterThan(0), reason: 'Failed: $path');
      }
    },
  );
}
