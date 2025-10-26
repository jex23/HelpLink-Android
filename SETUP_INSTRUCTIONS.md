# HelpLink Post Creation Setup Instructions

## Overview
This document provides instructions for setting up the post creation feature with location services, photo/video uploads, and **OpenStreetMap** integration (No API keys required!).

## Features Implemented

### 1. Post Creation
- **Post Type**: Select between 'donation' or 'request'
- **Title**: Required field for post title
- **Description**: Optional detailed description
- **Address**: Optional location address
- **Photos**: Multiple photo uploads
- **Videos**: Multiple video uploads
- **GPS Coordinates**: Automatic location capture

### 2. Location Services
- **Current Location**: Automatically fetch GPS coordinates
- **Map Picker**: Select location on interactive OpenStreetMap
- **Address Geocoding**: Convert coordinates to address and vice versa
- **Location Permissions**: Handles Android and iOS permissions
- **No API Keys Required**: Uses free OpenStreetMap tiles

### 3. Media Uploads
- **Multiple Photos**: Upload multiple images at once
- **Multiple Videos**: Upload multiple videos at once
- **Preview**: See photos and videos before posting
- **Remove**: Ability to remove selected media

## Setup Requirements

### No API Keys Needed!

This implementation uses **OpenStreetMap** which is completely free and requires **NO API keys**. The map will work immediately after installation without any additional configuration.

### Internet Connection Required
- Map tiles are loaded from OpenStreetMap servers
- Geocoding requires internet connection
- Media uploads require connection to your backend API

## Permissions

### Android Permissions (Already Configured)
The following permissions are configured in `android/app/src/main/AndroidManifest.xml`:
- `ACCESS_FINE_LOCATION` - For precise GPS location
- `ACCESS_COARSE_LOCATION` - For approximate location
- `READ_MEDIA_IMAGES` - For reading images on Android 13+
- `READ_MEDIA_VIDEO` - For reading videos on Android 13+
- `CAMERA` - For camera access
- `READ_EXTERNAL_STORAGE` - For reading media files
- `WRITE_EXTERNAL_STORAGE` - For writing media files (API < 33)

### iOS Permissions (Already Configured)
The following permissions are configured in `ios/Runner/Info.plist`:
- `NSLocationWhenInUseUsageDescription` - Location access
- `NSLocationAlwaysUsageDescription` - Background location
- `NSPhotoLibraryUsageDescription` - Photo library access
- `NSCameraUsageDescription` - Camera access
- `NSMicrophoneUsageDescription` - Microphone for videos

## API Integration

The post creation sends data to the backend API at:
- **Endpoint**: `POST /api/posts`
- **Auth**: Bearer token required
- **Content-Type**: `multipart/form-data`

### Form Data Fields:
- `post_type` (required): "donation" or "request"
- `title` (required): Post title
- `description` (optional): Post description
- `address` (optional): Location address
- `latitude` (optional): GPS latitude coordinate
- `longitude` (optional): GPS longitude coordinate
- `photos[]` (files, optional): Multiple image files
- `videos[]` (files, optional): Multiple video files

## Files Created/Modified

### New Files:
1. `lib/utils/location_helper.dart` - Location services helper
2. `lib/widgets/location_picker_dialog.dart` - OpenStreetMap picker widget
3. `SETUP_INSTRUCTIONS.md` - This file

### Modified Files:
1. `lib/pages/post_page.dart` - Enhanced with location and video features
2. `pubspec.yaml` - Added new dependencies
3. `android/app/src/main/AndroidManifest.xml` - Added permissions
4. `ios/Runner/Info.plist` - Added iOS permissions

### Dependencies Added:
- `geolocator: ^10.1.0` - GPS location services (no API key needed)
- `geocoding: ^2.1.1` - Address geocoding (no API key needed)
- `flutter_map: ^6.1.0` - OpenStreetMap integration (no API key needed)
- `latlong2: ^0.9.0` - Latitude/longitude handling
- `file_picker: ^6.1.1` - Video file picker

## Why OpenStreetMap?

### Advantages:
✅ **Free Forever** - No costs, no quotas, no billing
✅ **No API Keys** - Zero configuration needed
✅ **Privacy-Friendly** - No tracking by big tech companies
✅ **Open Source** - Community-driven project
✅ **Reliable** - Used by millions of apps worldwide
✅ **No Setup** - Works immediately after installation

### Map Features:
- Interactive map with zoom and pan
- Tap to select location
- Location marker
- Satellite-free street map view
- Worldwide coverage

## Usage Guide

### Creating a Post:

1. **Select Post Type**: Choose between Donation or Request
2. **Enter Title**: Required field for your post
3. **Add Description**: Optional detailed description
4. **Add Location** (Optional):
   - Click "Use Current Location" to get GPS coordinates
   - Click "Pick on Map" to select location on OpenStreetMap
   - Manually enter address in the text field
5. **Add Photos** (Optional):
   - Click "Add Photo" button
   - Select multiple photos from gallery
   - Remove photos by clicking the X icon
6. **Add Videos** (Optional):
   - Click "Add Video" button
   - Select multiple videos from device
   - Remove videos by clicking the X icon
7. **Submit Post**: Click "Post" button in the app bar

### Location Features:

#### Current Location:
- Requests location permission
- Fetches GPS coordinates
- Automatically converts to address
- Shows confirmation with coordinates

#### Map Picker (OpenStreetMap):
- Opens OpenStreetMap dialog
- Tap on map to select location
- Shows marker at selected position
- Displays coordinates
- Converts coordinates to address
- Confirms selection

### Error Handling:
- Permission denied notifications
- Location service disabled alerts
- Network error messages
- File picker errors

## Testing

### Test Location Services:
1. Enable location services on device
2. Grant location permissions when prompted
3. Test "Use Current Location" button
4. Verify coordinates and address display

### Test Map Picker:
1. Click "Pick on Map" button
2. Verify OpenStreetMap loads correctly
3. Test tap to select location
4. Verify coordinates are saved
5. Check address generation

### Test Media Uploads:
1. Add multiple photos
2. Add multiple videos
3. Verify previews display
4. Test removing media
5. Submit post with media

### Test Post Creation:
1. Fill all required fields
2. Add optional location
3. Add photos/videos
4. Submit post
5. Verify success message
6. Check fields are cleared

## Troubleshooting

### Map not loading:
- Verify internet connection
- Check firewall settings
- Try refreshing the app
- Clear app cache

### Location not working:
- Verify permissions are granted
- Check location services are enabled
- Test on real device (not simulator)
- Check AndroidManifest.xml permissions

### Videos not uploading:
- Check file size limits
- Verify video format is supported
- Check backend API limits
- Test with smaller video files

### Build errors:
- Run `flutter clean`
- Run `flutter pub get`
- Rebuild the project
- Check for plugin compatibility

## Map Tile Usage Policy

This app uses OpenStreetMap tiles with the following considerations:

### Fair Use:
- OpenStreetMap tiles are free but have usage limits
- For production apps with high traffic, consider:
  - Self-hosting tiles
  - Using a tile provider (Mapbox, Maptiler, etc.)
  - Caching tiles locally

### Attribution:
OpenStreetMap requires attribution. This is automatically handled in the app, but ensure you comply with the [OpenStreetMap License](https://www.openstreetmap.org/copyright).

## Alternative Map Providers (Optional)

If you want different map styles or need commercial support, you can easily switch tile providers:

```dart
// In location_picker_dialog.dart, change the urlTemplate:

// Satellite view (requires API key from MapBox)
urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/{z}/{x}/{y}?access_token=YOUR_TOKEN',

// Dark theme
urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',

// Light theme
urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
```

## Important Notes

1. **No API Keys**: The current setup requires zero API keys and zero configuration. It works immediately.

2. **iOS Simulator**: Location services may not work properly on iOS simulator. Test on real devices.

3. **Video Size**: Large videos may take time to upload. Consider adding file size limits and progress indicators.

4. **Network**: Ensure the device has internet connection for map tiles and geocoding.

5. **Permissions**: Users must grant location permissions for GPS features to work.

6. **OpenStreetMap**: The map uses community-maintained data. Some remote areas may have less detail than commercial maps.

## Performance Tips

### Map Performance:
- Map tiles are cached automatically by flutter_map
- Initial load may take a moment on slow connections
- Zoom and pan are hardware-accelerated

### Location Performance:
- GPS accuracy depends on device and environment
- Indoor locations may be less accurate
- First location fix may take a few seconds

## Next Steps

Consider implementing:
- [ ] File size validation
- [ ] Upload progress indicators
- [ ] Image/video compression
- [ ] Location caching
- [ ] Offline map support (using mbtiles)
- [ ] Custom map markers
- [ ] Search location by address
- [ ] Multiple map themes
- [ ] Nearby posts on map view

## Support

For issues with:
- **OpenStreetMap**: https://www.openstreetmap.org/help
- **flutter_map**: https://github.com/fleaflet/flutter_map
- **Geolocator**: https://pub.dev/packages/geolocator

## License

OpenStreetMap data is licensed under the [Open Data Commons Open Database License (ODbL)](https://opendatacommons.org/licenses/odbl/).
