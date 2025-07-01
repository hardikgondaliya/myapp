import 'package:flutter/material.dart';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;


// Define the GeotagTemplate class with properties for styling
class GeotagTemplate {
  final String name;
  final double? fontSize;
  final Color? textColor;
  final TextAlign? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BoxBorder? border;
  final IconData? iconData;
    // Map properties
  final String? mapType;
  final double? mapZoom;
  final Size? mapSize;


  GeotagTemplate({
    required this.name,
    this.fontSize,
    this.textColor,
    this.alignment,
    this.padding,
    this.backgroundColor,
    this.border,
    this.iconData,
     // Initialize map properties
    this.mapType,
    this.mapZoom,
    this.mapSize,
  });
}

// Define a list of predefined geotag templates
final List<GeotagTemplate> geotagTemplates = [
  GeotagTemplate(
    name: 'Basic',
    fontSize: 14.0,
    textColor: Colors.white,
    backgroundColor: Colors.black54,
    padding: EdgeInsets.all(8.0),
    alignment: TextAlign.center,
     iconData: Icons.location_on,
  ),
  GeotagTemplate(
    name: 'Stylish',
    fontSize: 16.0,
    textColor: Colors.yellow,
    backgroundColor: Colors.blueAccent.withAlpha((255 * 0.6).toInt()),
    border: Border.all(color: Colors.yellow, width: 2.0),
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
    alignment: TextAlign.left,
     iconData: Icons.info_outline,
  ),
   GeotagTemplate(
    name: 'Map Only',
    mapType: 'roadmap',
    mapZoom: 15.0,
    mapSize: Size(300, 200),
     backgroundColor: Colors.grey[200],
     padding: EdgeInsets.all(4.0),
  ),
   GeotagTemplate(
    name: 'Minimal',
    fontSize: 12.0,
    textColor: Colors.black87,
    padding: EdgeInsets.all(4.0),
    alignment: TextAlign.right,
  ),
    GeotagTemplate(
    name: 'Bold',
    fontSize: 18.0,
    textColor: Colors.redAccent,
    backgroundColor: Colors.white.withAlpha((255 * 0.7).toInt()),
    border: Border.all(color: Colors.redAccent, width: 1.0),
    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
    alignment: TextAlign.center,
  ),
   GeotagTemplate(
    name: 'Green & Clean',
    fontSize: 14.0,
    textColor: Colors.green[800],
    backgroundColor: Colors.green[100],
    padding: EdgeInsets.all(6.0),
    alignment: TextAlign.left,
     iconData: Icons.check_circle_outline,
  ),
    GeotagTemplate(
    name: 'Blue Sky',
    fontSize: 15.0,
    textColor: Colors.blue[900],
    backgroundColor: Colors.blue[100],
    border: Border.all(color: Colors.blue[900]!, width: 1.5),
    padding: EdgeInsets.all(8.0),
    alignment: TextAlign.center,
     iconData: Icons.cloud_outlined,
  ),
  GeotagTemplate(
    name: 'Orange Pop',
    fontSize: 16.0,
    textColor: Colors.deepOrangeAccent,
    backgroundColor: Colors.white.withAlpha((255 * 0.8).toInt()),
    border: Border.all(color: Colors.deepOrangeAccent, width: 2.0),
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
    alignment: TextAlign.right,
    iconData: Icons.star_border,
  ),
   GeotagTemplate(
    name: 'Purple Haze',
    fontSize: 14.0,
    textColor: Colors.deepPurple[800],
    backgroundColor: Colors.deepPurple[100],
    padding: EdgeInsets.all(10.0),
    alignment: TextAlign.center,
     iconData: Icons.brightness_5,
  ),
   GeotagTemplate(
    name: 'Brown Earth',
    fontSize: 13.0,
    textColor: Colors.brown[900],
    backgroundColor: Colors.brown[100],
    border: Border.all(color: Colors.brown[900]!, width: 1.0),
    padding: EdgeInsets.all(6.0),
    alignment: TextAlign.left,
    iconData: Icons.terrain,
  ),
];


// Placeholder function to apply the geotag template to an image
Future<File> applyGeotagTemplate(File imageFile, GeotagTemplate template, Position position) async {
  // TODO: Implement actual image manipulation based on the template
  // This is a placeholder implementation. You'll need to use an image
  // processing library (like the 'image' package) to draw text and
  // other elements onto the image based on the template's properties.

    // Read the image file
  img.Image? originalImage = img.decodeImage(await imageFile.readAsBytes());

  if (originalImage == null) {
    // Handle error: Unable to decode image
    return imageFile;
  }

  // Create a copy of the image to draw on
  img.Image outputImage = img.copyResize(originalImage, width: originalImage.width, height: originalImage.height);


   // Implement text drawing based on template
  if (template.fontSize != null && template.textColor != null) {
    String latLonText = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
    String altitudeText = 'Altitude: ${position.altitude.toStringAsFixed(2)}m';
    String timestampText = 'Timestamp: ${position.timestamp.toLocal()}';

    // Use a built-in font. For production, consider loading a TTF font.
    // The 'image' package doesn't have a 'Font' class. Use a specific font object like 'img.arial14'.
    final font = img.arial14;
    // Convert Flutter Color to image.ColorRgb32
    int r = (template.textColor!.red * 255).round();
    int g = (template.textColor!.green * 255).round();
    int b = (template.textColor!.blue * 255).round();
    img.Color textColor = img.ColorRgb8(r, g, b);

    // Simple drawing at a fixed position for now.
    // You'll need to calculate the position based on alignment and padding.
    int startX = (template.padding?.horizontal ?? 0) ~/ 2;
    int startY = (template.padding?.vertical ?? 0).round();

    img.drawString(
      outputImage,
      font: font,
      x: startX,
      y: startY,
      latLonText,
      color: textColor,
    );

    // Calculate line height using img.textHeight
 int lineHeight = font.lineHeight;

    img.drawString(outputImage, font: font, x: startX, y: (startY + lineHeight + 2).round(), altitudeText, color: textColor); // Add some spacing
    img.drawString(outputImage, font: font, x: startX, y: (startY + (lineHeight + 2) * 2).round(), timestampText, color: textColor); // Add more spacing
  }


  // TODO: Implement drawing of other elements (icons, map snippet)
  // based on the template's properties.
  // This will involve fetching the map image if mapType is not null and drawing it onto the outputImage.

  // Save the modified image to a new file
  // You might want to save it to a different directory or with a different name
  final String outputPath = '${imageFile.parent.path}/geotagged_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final File outputToFile = File(outputPath);
  await outputToFile.writeAsBytes(img.encodeJpg(outputImage));

  return outputToFile; // Return the path to the new geotagged image
}
