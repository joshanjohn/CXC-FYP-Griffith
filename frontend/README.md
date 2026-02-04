# Chest X-Ray Analysis Flutter App

A modern, multi-platform Flutter application for chest X-ray analysis that works seamlessly across iOS, Android, macOS, Windows, and web platforms.

## ✨ Features

- 📱 **Multi-Platform Support**: Runs on iOS, Android, macOS, Windows, and Web
- 📸 **Image Capture**: Take photos using device camera (mobile platforms)
- 📤 **Image Upload**: Select images from gallery or file system
- 🎨 **Responsive Design**: Adaptive UI that looks great on any screen size
- 🌓 **Dark Mode**: Automatic theme switching based on system preferences
- ⚡ **Modern UI**: Premium design with gradients, animations, and smooth transitions
- 🔍 **Analysis Ready**: Placeholder for backend API integration

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- For iOS development: Xcode
- For Android development: Android Studio
- For Web: Chrome browser

### Installation

1. **Clone the repository** (if applicable) or navigate to the project directory:
   ```bash
   cd /Users/joshan/Documents/final-year-project/frontend
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   
   For Web:
   ```bash
   flutter run -d chrome
   ```
   
   For iOS Simulator:
   ```bash
   flutter run -d ios
   ```
   
   For Android Emulator:
   ```bash
   flutter run -d android
   ```
   
   For macOS:
   ```bash
   flutter run -d macos
   ```
   
   For Windows:
   ```bash
   flutter run -d windows
   ```

## 📱 Platform-Specific Setup

### iOS

Camera and photo library permissions are already configured in `ios/Runner/Info.plist`:
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSPhotoLibraryAddUsageDescription`

### Android

Camera and storage permissions are configured in `android/app/src/main/AndroidManifest.xml`:
- `CAMERA`
- `READ_EXTERNAL_STORAGE`
- `WRITE_EXTERNAL_STORAGE`

### Web

No additional setup required. The app uses file picker for image selection.

### Desktop (macOS/Windows)

File picker is used for image selection. No additional permissions needed.

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── screens/
│   ├── home_screen.dart              # Landing page with upload/camera options
│   └── image_preview_screen.dart     # Image display and analysis screen
├── services/
│   └── image_service.dart            # Platform-aware image handling
├── utils/
│   └── responsive_helper.dart        # Responsive layout utilities
└── widgets/
    ├── adaptive_button.dart          # Custom button component
    └── image_display_widget.dart     # Responsive image display
```

## 🎨 Design Features

- **Material Design 3**: Modern design system with dynamic theming
- **Google Fonts**: Inter font family for premium typography
- **Responsive Layouts**: Adapts to mobile, tablet, and desktop screens
- **Smooth Animations**: Fade-in, slide, and scale transitions
- **Gradient Accents**: Beautiful color gradients throughout the UI
- **Hover Effects**: Interactive feedback on desktop platforms

## 🔌 Backend Integration

The app includes placeholder functions for backend API integration. To connect your X-ray analysis backend:

1. Open `lib/screens/image_preview_screen.dart`
2. Find the `_analyzeImage()` method
3. Replace the mock implementation with your API call:

```dart
Future<void> _analyzeImage() async {
  setState(() => _isAnalyzing = true);

  try {
    // Your API integration here
    final response = await http.post(
      Uri.parse('YOUR_API_ENDPOINT'),
      body: {
        'image': widget.imageSource.path,
      },
    );
    
    // Parse response and update UI
    setState(() {
      _analysisResults = jsonDecode(response.body);
      _isAnalyzing = false;
    });
  } catch (e) {
    // Handle errors
    setState(() => _isAnalyzing = false);
  }
}
```

## 📦 Dependencies

- `flutter_screenutil`: Responsive design
- `google_fonts`: Typography
- `image_picker`: Image selection and camera capture
- `camera`: Camera functionality
- `file_picker`: Cross-platform file selection
- `path_provider`: File system access
- `permission_handler`: Runtime permissions

## 🧪 Testing

Run tests with:
```bash
flutter test
```

Check for issues:
```bash
flutter analyze
```

## 📱 Responsive Breakpoints

- **Mobile**: < 600px width
- **Tablet**: 600px - 1200px width
- **Desktop**: > 1200px width

## 🎯 Usage

1. **Launch the app** on your preferred platform
2. **Choose an option**:
   - **Upload X-Ray**: Select an image from your device
   - **Capture X-Ray**: Take a photo (mobile only)
3. **View the image** in the preview screen
4. **Analyze** the X-ray (requires backend integration)
5. **Review results** displayed on screen

## 🔧 Troubleshooting

### Flutter Permission Issues

If you encounter permission errors when running Flutter commands:
```bash
# Try running with sudo (not recommended for production)
sudo flutter pub get

# Or fix Flutter permissions
sudo chown -R $(whoami) /Users/joshan/development/flutter
```

### Camera Not Working

- Ensure permissions are granted in device settings
- Check that camera permissions are properly configured in platform files
- Verify camera hardware is available on the device

### Image Not Displaying

- Check file path is correct
- Verify image format is supported (JPG, PNG, JPEG)
- Ensure proper permissions for file access

## 📄 License

This project is part of a final year project for chest X-ray analysis.

## 🤝 Contributing

This is a final year project. For questions or contributions, please contact the project maintainer.

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review Flutter documentation: https://flutter.dev/docs
3. Check platform-specific guides for iOS/Android/Web/Desktop

---

Built with ❤️ using Flutter
