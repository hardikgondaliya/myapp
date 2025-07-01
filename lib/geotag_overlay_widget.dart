import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'geotag_templates.dart'; // Assuming geotag_templates.dart is in the same directory
class GeotagOverlayWidget extends StatelessWidget {
  final Position position;
  final GeotagTemplate template;

  const GeotagOverlayWidget({
    super.key,
    required this.position,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder for static map API URL (replace with your chosen service and API key)
    // Example using a hypothetical service:
    // String mapImageUrl = 'https://api.example.com/staticmap?center=${position.latitude},${position.longitude}&zoom=${template.mapZoom}&size=${template.mapSize.width.toInt()}x${template.mapSize.height.toInt()}&key=YOUR_API_KEY';

    // Using a placeholder for now
 String mapImageUrl = ''; // Replace with actual URL construction

    return Container(
      color: template.backgroundColor,
      decoration: BoxDecoration( // Use BoxDecoration for border
        border: template.border,
      ),
      padding: template.padding,
      child: Column( // Use Column for overall layout
        children: [
          if (template.mapSize != null)
            FutureBuilder( // Use FutureBuilder to handle async map image fetching
              future: Future.value(mapImageUrl), // Replace with actual async function to get map URL
 builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Image.network(
                    snapshot.data as String,
                    width: template.mapSize!.width,
                    height: template.mapSize!.height,
                    fit: BoxFit.cover, // Adjust fit as needed
                  );
                } else {
                  // Placeholder or loading indicator if map data is not available
                  return Container(
                    width: template.mapSize?.width,
                    height: template.mapSize?.height,
                    color: Colors.grey[300], // Placeholder color
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          if (template.mapSize != null) SizedBox(height: 8), // Add spacing between map and text if map is present
          Row( // Row for text and icons
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (template.iconData != null) // Add icon if provided in template
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    template.iconData,
                    color: template.textColor,
                    size: (template.fontSize ?? 14.0) * 1.2, // Adjust icon size based on text size
                  ),
                ),
              Column(
                crossAxisAlignment: _getCrossAxisAlignment(template.alignment ?? TextAlign.start), // Apply alignment from template
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Existing Row for Lat/Lon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: _getCrossAxisAlignment(template.alignment ?? TextAlign.start), // Use null-aware operator here as well
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lat: ${position.latitude.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: template.fontSize,
                              color: template.textColor,
                            ),
                          ),
                          Text(
                            'Lon: ${position.longitude.toStringAsFixed(4)}',
                            style: TextStyle(
                              fontSize: template.fontSize,
                              color: template.textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(width: 16), // Add some spacing between columns
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: _getCrossAxisAlignment(template.alignment ?? TextAlign.start), // Use null-aware operator
                    children: [
                      Text(
                        'Altitude: ${position.altitude.toStringAsFixed(2)}m',
                        style: TextStyle(fontSize: template.fontSize, color: template.textColor),
                      ),
                      Text('Timestamp: ${position.timestamp.toLocal()}', style: TextStyle(fontSize: template.fontSize, color: template.textColor)),
                    ],
                  ),
                  // You can add more information here based on your template
                  // e.g., Text('Speed: ${position.speed?.toStringAsFixed(2) ?? 'N/A'} m/s'),
                ],
              ),
              // This is where the missing closing square bracket was.
            ], // Closing square bracket for the children of the main Row
          ), // Closing parenthesis for the main Row
        ], // Closing square bracket for the children of the main Column
      ), // Closing parenthesis for the main Column
    ); // Closing parenthesis for the Container and semicolon
  }

  // Helper function to convert TextAlign to CrossAxisAlignment
  CrossAxisAlignment _getCrossAxisAlignment(TextAlign alignment) { // Changed parameter to non-nullable TextAlign
    switch (alignment) {
      case TextAlign.left:
        return CrossAxisAlignment.start;
      case TextAlign.center:
        return CrossAxisAlignment.center;
      case TextAlign.right:
        return CrossAxisAlignment.end;
      default:
        return CrossAxisAlignment.start;
    }
  }
}

