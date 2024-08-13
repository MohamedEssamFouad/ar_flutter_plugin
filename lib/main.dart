import 'package:ar_flutter_plugin_flutterflow/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_flutterflow/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_flutterflow/datatypes/config_planedetection.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

void main() {
  runApp(ARDistanceApp());
}

class ARDistanceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Distance Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ARDistanceCalculator(),
    );
  }
}

class ARDistanceCalculator extends StatefulWidget {
  @override
  _ARDistanceCalculatorState createState() => _ARDistanceCalculatorState();
}

class _ARDistanceCalculatorState extends State<ARDistanceCalculator> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;
  ARLocationManager? arLocationManager;

  ARAnchor? markerAnchor;
  double? distanceInCentimeters;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AR Distance Calculator'),
      ),
      body: Stack(
        children: [
          ARView(
            onARViewCreated: onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () => _placeMarker(),
              child: Text('Place Marker'),
            ),
          ),
          if (distanceInCentimeters != null)
            Positioned(
              top: 20,
              left: 20,
              child: Text(
                'Distance: ${distanceInCentimeters!.toStringAsFixed(2)} cm',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void onARViewCreated(
      ARSessionManager sessionManager,
      ARObjectManager objectManager,
      ARAnchorManager anchorManager,
      ARLocationManager locationManager,
      ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;
    arLocationManager = locationManager;

    arSessionManager?.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: true,
    );

    arObjectManager?.onInitialize();
  }

  Future<void> _placeMarker() async {
    final anchor = ARPlaneAnchor(transformation: vector.Matrix4.identity());
    final didAddAnchor = await arAnchorManager?.addAnchor(anchor);
    if (didAddAnchor == true) {
      setState(() {
        markerAnchor = anchor;
      });
      _calculateDistance();
    }
  }

  Future<void> _calculateDistance() async {
    if (markerAnchor != null) {
      final distanceMeters =
      await arSessionManager?.getDistanceFromAnchor(markerAnchor!);
      if (distanceMeters != null) {
        setState(() {
          distanceInCentimeters = distanceMeters * 100;
        });
      }
    }
  }

  @override
  void dispose() {
    arSessionManager?.dispose();
    super.dispose();
  }
}
