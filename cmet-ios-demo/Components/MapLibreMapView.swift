//
//  MapLibreMapView.swift
//  cmet-ios-demo
//
//  Created by João Pereira on 17/03/2024.
//

import SwiftUI
import MapLibre

struct MapLibreMapView: UIViewRepresentable {
//    @Environment(\.colorScheme) var colorScheme
    var stops: [Stop]
    @Binding var selectedStopId: String?
    @Binding var flyToCoords: CLLocationCoordinate2D?
    
    func makeUIView(context: Context) -> MLNMapView {
        let styleURL = URL(string: "https://maps.carrismetropolitana.pt/styles/default/style.json")
//        let styleURL = URL(string: colorScheme == .light ? "https://maps.carrismetropolitana.pt/styles/default/style.json" : "https://api.maptiler.com/maps/e9d3c77d-4552-4ed6-83dd-1075b67bd977/style.json?key=NvTfdJJxC0xa6dknGF48")

        let mapView = MLNMapView(frame: .zero, styleURL: styleURL)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.logoView.isHidden = true
        mapView.attributionButtonPosition = .bottomLeft
        mapView.setCenter(
            CLLocationCoordinate2D(latitude: 38.7, longitude: -9.0),
            zoomLevel: 8.9,
            animated: false)
        
        // Add a single tap gesture recognizer. This gesture requires the built-in MGLMapView tap gestures (such as those for zoom and annotation selection) to fail. Apparently... Test if true or not
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
             tap.require(toFail: recognizer)
         }
        mapView.addGestureRecognizer(tap)
        

        // needed to respond to map events
        mapView.delegate = context.coordinator
        
        mapView.showsUserLocation = true

        return mapView
    }
    
    private func addStops(to mapView: MLNMapView) {
        print("Adding stops layer with \(stops.count) stops")
        // Convert Stop objects to MGLPointFeature objects
        let features = stops.map { stop -> MLNPointFeature in
            let feature = MLNPointFeature()
            feature.coordinate = CLLocationCoordinate2D(latitude: Double(stop.lat)!, longitude: Double(stop.lon)!)
            feature.attributes = ["id": stop.id, "name": stop.name]
            return feature
        }
        
        // Create a MGLShapeSource with the features
        let source = MLNShapeSource(identifier: "stops", features: features, options: nil)
        
        // Create a MGLCircleStyleLayer using the source
        let layer = MLNCircleStyleLayer(identifier: "stops-layer", source: source)
        
        
        // Set the layer properties
        //        layer.circleColor = NSExpression(format: "mgl_step:from:stops:($zoomLevel, '#ffdd01', 9, '#ffffff')")
        layer.circleColor = NSExpression(forConstantValue: UIColor(.cmYellow))
        layer.circleRadius = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                          [9: NSExpression(forConditional: NSPredicate(format: "selected == TRUE"), trueExpression: NSExpression(forConstantValue: 5), falseExpression: NSExpression(forConstantValue: 1)),
                                           26: NSExpression(forConditional: NSPredicate(format: "selected == TRUE"), trueExpression: NSExpression(forConstantValue: 25), falseExpression: NSExpression(forConstantValue: 20))])
        layer.circleStrokeWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                               [9: NSExpression(forConstantValue: 0.01),
                                                26: NSExpression(forConditional: NSPredicate(format: "selected == TRUE"), trueExpression: NSExpression(forConstantValue: 8), falseExpression: NSExpression(forConstantValue: 7))])
        layer.circleStrokeColor = NSExpression(forConstantValue: UIColor(.black))
        layer.circlePitchAlignment = NSExpression(forConstantValue: "map")
        
        
        // Add the source to the map view
        mapView.style?.addSource(source)
        
        // Add the layer to the map view
        mapView.style?.addLayer(layer)
    }
    
    private func updateStops(on mapView: MLNMapView) {
        print("Updating stops layer with \(stops.count) stops")
        guard let source = mapView.style?.source(withIdentifier: "stops") as? MLNShapeSource else {
            print("Stops source not found")
            return
        }

        let features = stops.map { stop -> MLNPointFeature in
            let feature = MLNPointFeature()
            feature.coordinate = CLLocationCoordinate2D(latitude: Double(stop.lat)!, longitude: Double(stop.lon)!)
            feature.attributes = ["id": stop.id, "name": stop.name]
            return feature
        }

        source.shape = MLNShapeCollectionFeature(shapes: features)
    }
    
    class Coordinator: NSObject, MLNMapViewDelegate {
        var control: MapLibreMapView

        init(_ control: MapLibreMapView) {
            self.control = control
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            print("was asked to handle tap")
            let mapView = sender.view as! MLNMapView
            let point = sender.location(in: mapView)
            let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: ["stops-layer"])
            
            if let feature = features.last { // if there are multiple overlapping select the last
                if let stopId = feature.attribute(forKey: "id") as? String {
                    control.selectedStopId = stopId
                }
            }
        }
        
        func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            print("finished loading mapstyle")
            control.addStops(to: mapView)
            print("added stops, \(style.source(withIdentifier: "stops-layer")), \(style.layer(withIdentifier: "stops"))")
        }

        func mapViewDidFinishLoadingMap(_ mapView: MLNMapView) {
            if let userLocation = mapView.userLocation {
                let camera = MLNMapCamera(
                    lookingAtCenter: userLocation.coordinate,
                    altitude: 5500,
                    pitch: 0,
                    heading: 0)
                
                mapView.setCamera(
                    camera,
                    withDuration: 3,
                    animationTimingFunction: CAMediaTimingFunction(name: .easeInEaseOut))
            }
        }
    }
    
    func makeCoordinator() -> MapLibreMapView.Coordinator {
        Coordinator(self)
    }
    
    func updateUIView(_ uiView: MLNMapView, context: Context) {
        print("updateUIView called with \(stops.count) stops")
        guard let style = uiView.style else {
            print("Style not loaded yet")
            return
        }

        if style.source(withIdentifier: "stops") == nil {
            addStops(to: uiView)
        } else {
            updateStops(on: uiView)
        }
        
        if let flyToCoords = flyToCoords {
            let camera = MLNMapCamera(
                lookingAtCenter: flyToCoords,
                altitude: 5500,
                pitch: 0,
                heading: 0
            )
            
            uiView.setCamera(
                camera,
                withDuration: 1.5,
                animationTimingFunction: CAMediaTimingFunction(name: .easeInEaseOut)
            )
        }
    }
}
