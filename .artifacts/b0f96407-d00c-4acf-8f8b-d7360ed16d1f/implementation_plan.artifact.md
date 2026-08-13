# Implementation Plan - Modernize Android Integration

This plan aims to enhance the "Boomerang" Flutter app by integrating modern Android features, improving its native feel and performance on Android devices.

## Proposed Changes

### Android Project Configuration

#### [MODIFY] [build.gradle.kts](file:///C:/Users/Home-PC/Documents/Boomerang 1.0/boomerang/android/app/build.gradle.kts)
- Add `androidx.core:core-splashscreen` dependency.

#### [MODIFY] [AndroidManifest.xml](file:///C:/Users/Home-PC/Documents/Boomerang 1.0/boomerang/android/app/src/main/AndroidManifest.xml)
- Enable Predictive Back gesture support.
- Update launcher activity theme to the new Splash Screen theme.

#### [MODIFY] [styles.xml](file:///C:/Users/Home-PC/Documents/Boomerang 1.0/boomerang/android/app/src/main/res/values/styles.xml)
- Implement a modern Splash Screen theme using the `Theme.SplashScreen` API.
- Update `NormalTheme` to better support edge-to-edge.

#### [MODIFY] [MainActivity.kt](file:///C:/Users/Home-PC/Documents/Boomerang 1.0/boomerang/android/app/src/main/kotlin/com/example/boomerang/MainActivity.kt)
- Initialize the Android Splash Screen API.
- Enable Edge-to-Edge display in the window configuration.

### Flutter App Integration

#### [MODIFY] [main.dart](file:///C:/Users/Home-PC/Documents/Boomerang 1.0/boomerang/lib/main.dart)
- Configure `SystemChrome` to ensure transparent status and navigation bars for a true edge-to-edge experience.

## Verification Plan

### Manual Verification
- **Splash Screen**: Verify the new splash screen appears on app startup (Android 12+).
- **Edge-to-Edge**: Check that the app content flows behind the status bar and navigation bar.
- **Predictive Back**: Test the back gesture on Android 14+ devices to see the predictive animation.
- **Visual Check**: Ensure no UI elements are obscured by system bars (using `SafeArea` or appropriate padding).
