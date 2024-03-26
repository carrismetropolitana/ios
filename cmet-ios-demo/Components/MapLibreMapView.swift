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
    
//    func updateUIView(_ uiView: MLNMapView, context: Context) {}
    
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

//            for feature in features {
//                if let stopId = feature.attribute(forKey: "id") as? String {
//                    print(stopId)
//                    // Find the stop with the tapped id
//                    print(control.stops.count)
//                    if let stop = control.stops.first(where: { $0.id == stopId }) {
//                        // Update the selected stop
//                        print(stop.id)
//                        print(stop.name)
//                        control.selectedStopId = stop
//                        break
//                    }
//                }
//            }
//            for feature in features {
            if let feature = features.last { // if there are multiple overlapping select the last
                if let stopId = feature.attribute(forKey: "id") as? String {
                    control.selectedStopId = stopId
                }
            }
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
//        var didChangeStyle = false
//
//
//        if uiView.styleURL.absoluteString.contains("carrismetropolitana") && colorScheme == .dark {
//            uiView.styleURL = URL(string: "https://api.maptiler.com/maps/e9d3c77d-4552-4ed6-83dd-1075b67bd977/style.json?key=NvTfdJJxC0xa6dknGF48")
//            didChangeStyle = true
//        }
//
//        if uiView.styleURL.absoluteString.contains("maptiler") && colorScheme == .light {
//            uiView.styleURL = URL(string: "https://maps.carrismetropolitana.pt/styles/default/style.json")
//            didChangeStyle = true
//        }
        
//        uiView.styleURL = URL(string: colorScheme == .light ? "https://maps.carrismetropolitana.pt/styles/default/style.json" : "https://api.maptiler.com/maps/e9d3c77d-4552-4ed6-83dd-1075b67bd977/style.json?key=NvTfdJJxC0xa6dknGF48")
        
        if selectedStopId == nil {
            // Convert Stop objects to MGLPointFeature objects
            let features = stops.map { stop -> MLNPointFeature in
                let feature = MLNPointFeature()
                feature.coordinate = CLLocationCoordinate2D(latitude: Double(stop.lat)!, longitude: Double(stop.lon)!)
                feature.attributes = ["id": stop.id, "name": stop.name]
                return feature
            }
            
            // Create a MGLShapeSource with the features
            let source = MLNShapeSource(identifier: "stops", features: features, options: nil)
            
            // Add the source to the map view
            uiView.style?.addSource(source)
            
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
            
            // Add the layer to the map view
            uiView.style?.addLayer(layer)
            
//            print(uiView.style?.sources.first(where: {$0.identifier == "stops"}))
//            print(uiView.style?.layers)
            
//            if stops.count > 0 {
//                if let userLocation = uiView.userLocation {
//                    print("setUL")
//                    let camera = MLNMapCamera(
//                        lookingAtCenter: userLocation.coordinate,
//                        altitude: 4500,
//                        pitch: 0,
//                        heading: 0)
//                    
//                    uiView.setCamera(
//                        camera,
//                        withDuration: 2,
//                        animationTimingFunction: CAMediaTimingFunction(name: .easeInEaseOut))
//                }
//            }
        }
    }
}
