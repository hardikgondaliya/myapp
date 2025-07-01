import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:myapp/geotag_templates.dart'; // Adjust the import path based on your project structure
import 'package:myapp/geotag_overlay_widget.dart'; // Import the geotag overlay widget
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
// Import for ByteData and Uint8List
import 'package:flutter/services.dart'; // Import for PlatformException
import 'package:myapp/gallery_screen.dart'; // Import the gallery screen

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

 @override
  _CameraScreenState createState() => _CameraScreenState();
}


class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  final GlobalKey _geotagOverlayKey = GlobalKey();
  List<CameraDescription>? cameras;
  Position? _currentPosition; // To store the current location for the overlay

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras != null && cameras!.isNotEmpty) {
        _controller = CameraController(
          cameras![0],
          ResolutionPreset.medium,
        );
        _controller!.initialize().then((_) {
          if (!mounted) {
            return;
          }
          setState(() {});
        });
      }
    });
    _availableTemplates = geotagTemplates;

    // Set a default selected template
    _selectedTemplate = _availableTemplates.first;
    _updateLiveLocation(); // Start updating live location for the overlay
  }

  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final locationStatus = await Permission.locationWhenInUse.request();

    if (cameraStatus.isDenied || locationStatus.isDenied) {
      // Handle cases where permissions are denied
      // You might want to show a dialog explaining why permissions are needed
      print('Permissions denied');
    }
  }

  List<GeotagTemplate> _availableTemplates = [];
  GeotagTemplate? _selectedTemplate;

  // Function to continuously update the live location for the overlay
  void _updateLiveLocation() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // Use LocationAccuracy.high
      distanceFilter: 100, // Update every 100 meters
    );
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        if (position != null) {
          setState(() {
            _currentPosition = position;
          });
        }
      },
      onError: (e) {
        print('Error updating live location: $e');
      },
    );
  }

  Future<void> _capturePhotoWithGeotag() async {
    // Ensure a template is selected before proceeding
    if (_selectedTemplate == null) return;
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    // Capture the photo
    final XFile photo = await _controller!.takePicture();

    // Get the current location
    try {
      // Use the most recent position obtained from the stream for accuracy
      Position position = _currentPosition ?? await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('Photo captured.');
      print('Location: ${position.latitude}, ${position.longitude}'); // Keep this for now for verification

      // Save the photo to a file
      final directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await photo.saveTo(filePath);
      print('Photo saved to: $filePath');

      // Apply the selected geotag template
      // 1. Render the GeotagOverlayWidget to an image
      if (_geotagOverlayKey.currentContext != null) {
        RenderRepaintBoundary boundary = _geotagOverlayKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
        ui.Image geotagImage = await boundary.toImage(pixelRatio: 3.0); // Adjust pixelRatio as needed
        ByteData? byteData = await geotagImage.toByteData(format: ui.ImageByteFormat.png);
        Uint8List geotagPngBytes = byteData!.buffer.asUint8List();

        // 2. Load the captured photo
        final originalImage = img.decodeImage(File(filePath).readAsBytesSync());
        if (originalImage == null) {
          print('Error decoding original image.');
          return;
        }

        // 3. Load the geotag overlay image
        final geotagOverlayImage = img.decodeImage(geotagPngBytes);
        if (geotagOverlayImage == null) {
          print('Error decoding geotag overlay image.');
          return;
        }

        // 4. Calculate position and composite the images (overlay geotag on photo)
        // We need to scale the position from the screen coordinates to the image coordinates
        // TODO: Calculate overlay position based on template alignment/padding and image dimensions
        final double scaleX = originalImage.width / MediaQuery.of(context).size.width;
        final double scaleY = originalImage.height / MediaQuery.of(context).size.height;
        // This is a placeholder for positioning the overlay on the original image
        final int overlayX = (50.0 * scaleX).round(); // Assuming top: 50.0 in the UI
        final int overlayY = (50.0 * scaleY).round(); // Assuming left: 50.0 in the UI

      // 5. Save the combined image
 img.compositeImage(originalImage, geotagOverlayImage, dstX: overlayX, dstY: overlayY);
      File('$filePath.geotagged.jpg').writeAsBytesSync(img.encodeJpg(originalImage));
      }
    } on PlatformException catch (e) { // Catch specific PlatformException
      print('Error getting location: $e');
      // Handle location errors
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text('Camera')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Capture Photo with Geotag'),
        actions: [
          IconButton(
            icon: Icon(Icons.photo_library),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GalleryScreen()),
              );
            },
          ),
        ],
      ),
 body: Stack(
        children: [
        Positioned.fill( // Fill the entire screen with the camera preview
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),
        ),
        if (_currentPosition != null && _selectedTemplate != null) // Only show overlay if location and template are available
 Positioned( // Position the geotag overlay
          // TODO: Position the overlay based on the selected template's desired location
          top: 50.0, // Example positioning
          left: 50.0, // Example positioning
          child: RepaintBoundary(
            key: _geotagOverlayKey,
            child: GeotagOverlayWidget(
              position: _currentPosition!, // Use the actual live position
              template: _selectedTemplate!,
            ),
          ),
        ),
        Positioned( // Position the controls (dropdown and capture button)
          bottom: 16.0,
          left: 0,
          right: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropdownButton<GeotagTemplate>(
                value: _selectedTemplate,
                onChanged: (GeotagTemplate? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedTemplate = newValue;
                    });
                  }
                },
                items: _availableTemplates.map<DropdownMenuItem<GeotagTemplate>>((GeotagTemplate template) {
                  return DropdownMenuItem<GeotagTemplate>(value: template, child: Text(template.name));
                }).toList(),
              ),
              SizedBox(height: 16), // Add some spacing
              FloatingActionButton(
                onPressed: _capturePhotoWithGeotag,
                child: Icon(Icons.camera_alt),
              ),
            ],
          ),
        ),
      ],
      ),
    );
  }
  @override
  void dispose() {
 _controller?.dispose();
 super.dispose();
  }
}

