//
//  ShapeAndVehiclesMapView.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 26/03/2024.
//

import SwiftUI
import MapLibre

struct ShapeAndVehiclesMapView: UIViewRepresentable {
//    @Environment(\.colorScheme) var colorScheme
    
    // TODO: These no longer need to be bindings
    let stops: [Stop]
    let vehicles: [Vehicle]
    let shape: CMShape?
    var isUserInteractionEnabled: Bool = true
    let lineColor: Color
    var hasDoneFirstAutoZoomIn: Bool = false
    
    func makeUIView(context: Context) -> MLNMapView {
        
        let styleURL = URL(string: "https://maps.carrismetropolitana.pt/styles/default/style.json")
//        let styleURL = URL(string: colorScheme == .light ? "https://maps.carrismetropolitana.pt/styles/default/style.json" : "https://api.maptiler.com/maps/e9d3c77d-4552-4ed6-83dd-1075b67bd977/style.json?key=NvTfdJJxC0xa6dknGF48")

        let mapView = MLNMapView(frame: .zero, styleURL: styleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.logoView.isHidden = true
//        mapView.attributionButtonPosition = .bottomLeft
        mapView.attributionButton.isHidden = true
        mapView.setCenter(
            CLLocationCoordinate2D(latitude: 38.7, longitude: -9.0),
            zoomLevel: 8.9,
            animated: false
        )
        
        mapView.isUserInteractionEnabled = isUserInteractionEnabled
        
        // Add a single tap gesture recognizer. This gesture requires the built-in MGLMapView tap gestures (such as those for zoom and annotation selection) to fail. Apparently... Test if true or not
//        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
//        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
//             tap.require(toFail: recognizer)
//         }
//        mapView.addGestureRecognizer(tap)
//

        // needed to respond to map events
        mapView.delegate = context.coordinator
        
        mapView.showsUserLocation = true

        return mapView
    }
    
//    func updateUIView(_ uiView: MLNMapView, context: Context) {}
    
    class Coordinator: NSObject, MLNMapViewDelegate {
        var control: ShapeAndVehiclesMapView
        let stops: [Stop]
        let vehicles: [Vehicle]
        let shape: CMShape?
        var isUserInteractionEnabled: Bool = true
        let lineColor: Color
        var hasDoneFirstAutoZoomIn: Bool = false
        
        init(_ control: ShapeAndVehiclesMapView) {
            self.control = control
            self.stops = control.stops
            self.vehicles = control.vehicles
            self.shape = control.shape
            self.isUserInteractionEnabled = control.isUserInteractionEnabled
            self.lineColor = control.lineColor
            self.hasDoneFirstAutoZoomIn = control.hasDoneFirstAutoZoomIn
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            print("was asked to handle tap")
            let mapView = sender.view as! MLNMapView
            let point = sender.location(in: mapView)
            let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: ["stops-layer"])

            if let feature = features.last { // if there are multiple overlapping select the last
                if let stopId = feature.attribute(forKey: "id") as? String {
//                    control.selectedStopId = stopId
                }
            }
        }
        
        func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            if let image = UIImage(named: "CMBusRegular") {
                style.setImage(image, forName: "cm-bus-regular")
            }
            print("Requested SAVMV creation with shapepoints: \(shape!.geojson.geometry.coordinates.count)--\(shape?.id)\nwith vehicles: \(vehicles.count)\nwith stops: \(stops.count), (style != nil) == \(style)")
            // Shape
            let shapeCoords = shape!.geojson.geometry.coordinates.map { coord -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
            }
            print("scs create ----> \(shapeCoords.count), \(shape?.id)")
            
            let shapeFeature = MLNPolylineFeature(coordinates: shapeCoords, count: UInt(shapeCoords.count))
            
            print("shfs create ----> \(shapeFeature.pointCount), \(shape?.id)")
            
            // Vehicles
            let vehicleFeatures = vehicles.map { vehicle -> MLNPointFeature in
                let feature = MLNPointFeature()
                feature.coordinate = CLLocationCoordinate2D(latitude: vehicle.lat, longitude: vehicle.lon)
                feature.attributes = ["id": vehicle.id, "bearing": vehicle.bearing]
                return feature
            }
            
            print("vfs create ----> \(vehicleFeatures.count)")
            
            // Stops
            let stopsFeatures = stops.map { stop -> MLNPointFeature in
                let feature = MLNPointFeature()
                feature.coordinate = CLLocationCoordinate2D(latitude: Double(stop.lat)!, longitude: Double(stop.lon)!)
                feature.attributes = ["id": stop.id, "name": stop.name]
                return feature
            }
            
            // Sources
            let shapeSource = MLNShapeSource(identifier: "shape-source", features: [shapeFeature], options: nil)
            let vehiclesSource = MLNShapeSource(identifier: "vehicles-source", features: vehicleFeatures, options: nil)
            let stopsSource = MLNShapeSource(identifier: "stops-source", features: stopsFeatures, options: nil)
            
            
            // Add sources
            style.addSource(shapeSource)
            style.addSource(vehiclesSource)
            style.addSource(stopsSource)
            
            
            // Shape (Line)
            let shapeLayer = MLNLineStyleLayer(identifier: "shape-layer", source: shapeSource)
            
            shapeLayer.lineJoin = NSExpression(forConstantValue: "round")
            shapeLayer.lineCap = NSExpression(forConstantValue: "round")
            shapeLayer.lineColor = NSExpression(forConstantValue: UIColor(lineColor))
            shapeLayer.lineWidth = NSExpression(
                forMLNInterpolating: .zoomLevelVariable,
                curveType: .linear,
                parameters: nil,
                stops: NSExpression(forConstantValue: [
                    10: NSExpression(forConstantValue: 4),
                    20: NSExpression(forConstantValue: 12)
                ])
            )
            
            // Vehicles (Symbol)
            let vehiclesLayer = MLNSymbolStyleLayer(identifier: "vehicles-layer", source: vehiclesSource)
            vehiclesLayer.iconImageName = NSExpression(forConstantValue: "cm-bus-regular")
            vehiclesLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
            vehiclesLayer.iconIgnoresPlacement = NSExpression(forConstantValue: true)
            vehiclesLayer.iconAnchor = NSExpression(forConstantValue: "center")
            vehiclesLayer.symbolPlacement = NSExpression(forConstantValue: "point")
            vehiclesLayer.iconRotationAlignment = NSExpression(forConstantValue: "map")
            vehiclesLayer.iconScale = NSExpression(
                forMLNInterpolating: .zoomLevelVariable,
                curveType: .linear,
                parameters: nil,
                stops: NSExpression(forConstantValue: [
                    10: NSExpression(forConstantValue: 0.05),
                    20: NSExpression(forConstantValue: 0.15)
                ])
            )
            vehiclesLayer.iconOffset = nil // nil defaults to CGVector(dx: 0, dy: 0)
            vehiclesLayer.iconRotation = NSExpression(forKeyPath: "bearing")
            
            
            // Stops (Circle)
            let stopsLayer = MLNCircleStyleLayer(identifier: "stops-layer", source: stopsSource)
            stopsLayer.circleColor = NSExpression(forConstantValue: UIColor(.white))
            stopsLayer.circleRadius = NSExpression(
                forMLNInterpolating: .zoomLevelVariable,
                curveType: .linear,
                parameters: nil,
                stops: NSExpression(forConstantValue: [
                    9: NSExpression(
                        forConditional: NSPredicate(format: "selected == TRUE"),
                        trueExpression: NSExpression(forConstantValue: 5),
                        falseExpression: NSExpression(forConstantValue: 1)
                    ),
                    26: NSExpression(
                        forConditional: NSPredicate(format: "selected == TRUE"),
                        trueExpression: NSExpression(forConstantValue: 25),
                        falseExpression: NSExpression(forConstantValue: 20)
                    )
                ])
            )
            stopsLayer.circleStrokeWidth = NSExpression(
                forMLNInterpolating: .zoomLevelVariable,
                curveType: .linear,
                parameters: nil,
                stops: NSExpression(forConstantValue: [
                    9: NSExpression(forConstantValue: 0.01),
                    26: NSExpression(
                        forConditional: NSPredicate(format: "selected == TRUE"),
                        trueExpression: NSExpression(forConstantValue: 8),
                        falseExpression: NSExpression(forConstantValue: 7)
                    )
                ])
            )
            stopsLayer.circleStrokeColor = NSExpression(forConstantValue: UIColor(lineColor))
            stopsLayer.circlePitchAlignment = NSExpression(forConstantValue: "map")
            
            style.addLayer(shapeLayer)
            style.insertLayer(stopsLayer, above: shapeLayer)
            if (vehicleFeatures.count > 0){
                style.insertLayer(vehiclesLayer, above: stopsLayer)
            }
            
            if (!hasDoneFirstAutoZoomIn) {
                let boundingBox = shapeCoords.reduce((minLat: Double.greatestFiniteMagnitude, minLon: Double.greatestFiniteMagnitude, maxLat: -Double.greatestFiniteMagnitude, maxLon: -Double.greatestFiniteMagnitude)) { bbox, coord in
                    return (
                        minLat: min(bbox.minLat, coord.latitude),
                        minLon: min(bbox.minLon, coord.longitude),
                        maxLat: max(bbox.maxLat, coord.latitude),
                        maxLon: max(bbox.maxLon, coord.longitude)
                    )
                }
                
                print("Init: Bounding box: \(boundingBox), \(shape?.id)")
                
                let boundingBoxCoords = [
                    CLLocationCoordinate2D(latitude: boundingBox.minLat, longitude: boundingBox.minLon),
                    CLLocationCoordinate2D(latitude: boundingBox.maxLat, longitude: boundingBox.maxLon)
                ]
                print("Init: Bounding box coordinates: \(boundingBoxCoords), \(shape?.id)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    // Weird things (altitude=0m) happen if you don't give it some breathing (async) space
                    // to set the camera, even though supposedly, it "didFinishLoading"
                    let camera = mapView.cameraThatFitsCoordinateBounds(
                        MLNCoordinateBounds(sw: boundingBoxCoords[0], ne: boundingBoxCoords[1]),
                        edgePadding: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 40.0, right: 10.0)
                    )
                    mapView.setCamera(camera, animated: true)
                })
                
            }
        }

//        func mapViewDidFinishLoadingMap(_ mapView: MLNMapView) {
//            if let style = mapView.style {
//                if let image = UIImage(named: "CMBusRegular") {
//                    style.setImage(image, forName: "cm-bus-regular")
//                }
//            }
//        }
    }
    
    func makeCoordinator() -> ShapeAndVehiclesMapView.Coordinator {
        Coordinator(self)
    }
    
    func updateUIView(_ uiView: MLNMapView, context: Context) {
        if uiView.style == nil {
            return()
        }
        if let shapeSource = uiView.style?.source(withIdentifier: "shape-source") as? MLNShapeSource {
            uiView.style?.removeSource(shapeSource)
            if let shapeLayer = uiView.style?.layer(withIdentifier: "shape-layer") {
                uiView.style?.removeLayer(shapeLayer)
            }
        }
        
        if let vehiclesSource = uiView.style?.source(withIdentifier: "vehicles-source") as? MLNShapeSource {
            uiView.style?.removeSource(vehiclesSource)
            if let vehiclesLayer = uiView.style?.layer(withIdentifier: "vehicles-layer") {
                uiView.style?.removeLayer(vehiclesLayer)
            }
        }
        
        if let stopsSource = uiView.style?.source(withIdentifier: "stops-source") as? MLNShapeSource {
            uiView.style?.removeSource(stopsSource)
            if let stopsLayer = uiView.style?.layer(withIdentifier: "stops-layer") {
                uiView.style?.removeLayer(stopsLayer)
            }
        }
        
        
        print("Requested SAVMV update with shapepoints: \(shape!.geojson.geometry.coordinates.count)--\(shape?.id)\nwith vehicles: \(vehicles.count)\nwith stops: \(stops.count), (style != nil) == \(uiView.style)")
        if let style = uiView.style {
            // Delete if already exists
            
            if let shapeSource = style.source(withIdentifier: "shape-source") as? MLNShapeSource {
                style.removeSource(shapeSource)
                if let shapeLayer = style.layer(withIdentifier: "shape-layer") {
                    style.removeLayer(shapeLayer)
                }
            }
            
            if let vehiclesSource = style.source(withIdentifier: "vehicles-source") as? MLNShapeSource {
                style.removeSource(vehiclesSource)
                if let vehiclesLayer = style.layer(withIdentifier: "vehicles-layer") {
                    style.removeLayer(vehiclesLayer)
                }
            }
            
            if let stopsSource = style.source(withIdentifier: "stops-source") as? MLNShapeSource {
                style.removeSource(stopsSource)
                if let stopsLayer = style.layer(withIdentifier: "stops-layer") {
                    style.removeLayer(stopsLayer)
                }
            }
            
            
            
            // Shape
            let shapeCoords = shape!.geojson.geometry.coordinates.map { coord -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: coord[1], longitude: coord[0])
            }
            
            let shapeFeature = MLNPolylineFeature(coordinates: shapeCoords, count: UInt(shapeCoords.count))
            
            print("shfs ----> \(shapeFeature.pointCount)")
            
            // Vehicles
            let vehicleFeatures = vehicles.map { vehicle -> MLNPointFeature in
                let feature = MLNPointFeature()
                feature.coordinate = CLLocationCoordinate2D(latitude: vehicle.lat, longitude: vehicle.lon)
                feature.attributes = ["id": vehicle.id, "bearing": vehicle.bearing]
                return feature
            }
            
            print("vfs ----> \(vehicleFeatures.count)")
            
            // Stops
            let stopsFeatures = stops.map { stop -> MLNPointFeature in
                let feature = MLNPointFeature()
                feature.coordinate = CLLocationCoordinate2D(latitude: Double(stop.lat)!, longitude: Double(stop.lon)!)
                feature.attributes = ["id": stop.id, "name": stop.name]
                return feature
            }
            
            // Sources
            let shapeSource = MLNShapeSource(identifier: "shape-source", features: [shapeFeature], options: nil)
            let vehiclesSource = MLNShapeSource(identifier: "vehicles-source", features: vehicleFeatures, options: nil)
            let stopsSource = MLNShapeSource(identifier: "stops-source", features: stopsFeatures, options: nil)
            
            
            // Add sources
            style.addSource(shapeSource)
            style.addSource(vehiclesSource)
            style.addSource(stopsSource)
            
            
            // Shape (Line)
            let shapeLayer = MLNLineStyleLayer(identifier: "shape-layer", source: shapeSource)
            
            shapeLayer.lineJoin = NSExpression(forConstantValue: "round")
            shapeLayer.lineCap = NSExpression(forConstantValue: "round")
            shapeLayer.lineColor = NSExpression(forConstantValue: UIColor(lineColor))
            shapeLayer.lineWidth = NSExpression(
                forMLNInterpolating: .zoomLevelVariable,
                curveType: .linear,
                parameters: nil,
                stops: NSExpression(forConstantValue: [
                    10: NSExpression(forConstantValue: 4),
                    20: NSExpression(forConstantValue: 12)
                ])
            )
            
            // Vehicles (Symbol)
            let vehiclesLayer = MLNSymbolStyleLayer(identifier: "vehicles-layer", source: vehiclesSource)
            vehiclesLayer.iconImageName = NSExpression(forConstantValue: "cm-bus-regular")
            vehiclesLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
            vehiclesLayer.iconIgnoresPlacement = NSExpression(forConstantValue: true)
            vehiclesLayer.iconAnchor = NSExpression(forConstantValue: "center")
            vehiclesLayer.symbolPlacement = NSExpression(forConstantValue: "point")
            vehiclesLayer.iconRotationAlignment = NSExpression(forConstantValue: "map")
            vehiclesLayer.iconScale = NSExpression(
                forMLNInterpolating: .zoomLevelVariable,
                curveType: .linear,
                parameters: nil,
                stops: NSExpression(forConstantValue: [
                    10: NSExpression(forConstantValue: 0.05),
                    20: NSExpression(forConstantValue: 0.15)
                ])
            )
            vehiclesLayer.iconOffset = nil // nil defaults to CGVector(dx: 0, dy: 0)
            vehiclesLayer.iconRotation = NSExpression(forKeyPath: "bearing")
            
            
            // Stops (Circle)
            let stopsLayer = MLNCircleStyleLayer(identifier: "stops-layer", source: stopsSource)
            stopsLayer.circleColor = NSExpression(forConstantValue: UIColor(.white))
            stopsLayer.circleRadius = NSExpression(
                forMLNInterpolating: .zoomLevelVariable,
                curveType: .linear,
                parameters: nil,
                stops: NSExpression(forConstantValue: [
                    9: NSExpression(
                        forConditional: NSPredicate(format: "selected == TRUE"),
                        trueExpression: NSExpression(forConstantValue: 5),
                        falseExpression: NSExpression(forConstantValue: 1)
                    ),
                    26: NSExpression(
                        forConditional: NSPredicate(format: "selected == TRUE"),
                        trueExpression: NSExpression(forConstantValue: 25),
                        falseExpression: NSExpression(forConstantValue: 20)
                    )
                ])
            )
            stopsLayer.circleStrokeWidth = NSExpression(
                forMLNInterpolating: .zoomLevelVariable,
                curveType: .linear,
                parameters: nil,
                stops: NSExpression(forConstantValue: [
                    9: NSExpression(forConstantValue: 0.01),
                    26: NSExpression(
                        forConditional: NSPredicate(format: "selected == TRUE"),
                        trueExpression: NSExpression(forConstantValue: 8),
                        falseExpression: NSExpression(forConstantValue: 7)
                    )
                ])
            )
            stopsLayer.circleStrokeColor = NSExpression(forConstantValue: UIColor(lineColor))
            stopsLayer.circlePitchAlignment = NSExpression(forConstantValue: "map")
            
            style.addLayer(shapeLayer)
            style.insertLayer(stopsLayer, above: shapeLayer)
            style.insertLayer(vehiclesLayer, above: stopsLayer)
            
            if (!hasDoneFirstAutoZoomIn) {
                let boundingBox = shapeCoords.reduce((minLat: Double.greatestFiniteMagnitude, minLon: Double.greatestFiniteMagnitude, maxLat: -Double.greatestFiniteMagnitude, maxLon: -Double.greatestFiniteMagnitude)) { bbox, coord in
                    return (
                        minLat: min(bbox.minLat, coord.latitude),
                        minLon: min(bbox.minLon, coord.longitude),
                        maxLat: max(bbox.maxLat, coord.latitude),
                        maxLon: max(bbox.maxLon, coord.longitude)
                    )
                }
                print("Bounding box: \(boundingBox), \(shape?.id)")
                let boundingBoxCoords = [
                    CLLocationCoordinate2D(latitude: boundingBox.minLat, longitude: boundingBox.minLon),
                    CLLocationCoordinate2D(latitude: boundingBox.maxLat, longitude: boundingBox.maxLon)
                ]
                
                print("Bounding box coordinates: \(boundingBoxCoords), \(shape?.id)")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    let camera = uiView.cameraThatFitsCoordinateBounds(
                        MLNCoordinateBounds(sw: boundingBoxCoords[0], ne: boundingBoxCoords[1]),
                        edgePadding: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 40.0, right: 10.0)
                    )
                    uiView.setCamera(camera, animated: true)
                })
            }
        }
    }
}
