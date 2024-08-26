//
//  MapLibreMapView.swift
//  Carris Metropolitana
//
//  Created by João Pereira on 17/03/2024.
//

import SwiftUI
import MapLibre

enum MapVisualStyle: CaseIterable {
    case standard, satellite
}

func getMapVisualStyleString(for mapVisualStyle: MapVisualStyle) -> String {
    switch mapVisualStyle {
    case .standard:
        "Mapa"
    case .satellite:
        "Satélite"
    }
}

struct MapLibreMapView: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var locationManager: LocationManager
    
    var stops: [Stop]
    @Binding var selectedStopId: String?
    
    let onStopSelect: (_ stopId: String) -> Void
    
    var flyToCoords: CLLocationCoordinate2D?
    @Binding var shouldFlyToUserCoords: Bool
    
    var mapVisualStyle: MapVisualStyle = .standard
    
    func makeUIView(context: Context) -> MLNMapView {
        print("MapLibreMapView makeUIView called")
        //        let styleURL = URL(string: "https://maps.carrismetropolitana.pt/styles/default/style.json")
        //        let styleURL = URL(string: colorScheme == .light ? "https://maps.carrismetropolitana.pt/styles/default/style.json" : "https://api.maptiler.com/maps/e9d3c77d-4552-4ed6-83dd-1075b67bd977/style.json?key=NvTfdJJxC0xa6dknGF48")
        
        //        let mapView = MLNMapView(frame: .zero, styleURL: styleURL)
        let mapView = MLNMapView(frame: .zero)
        updateStyle(mapView)
//        updateTiles(mapView)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.logoView.isHidden = true
        mapView.attributionButtonPosition = .bottomLeft
        
        if let location = locationManager.location {
            mapView.setCenter(
                location.coordinate,
                zoomLevel: 12,
                animated: false
            )
        } else {
            mapView.setCenter(
                CLLocationCoordinate2D(latitude: 38.7, longitude: -9.0),
                zoomLevel: 8.9,
                animated: false)
        }
        
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
    
    private func updateStyle(_ mapView: MLNMapView) {
        mapView.styleURL = URL(string: "https://maps.carrismetropolitana.pt/styles/default/style.json")
    }
    
    private func updateTiles(on mapView: MLNMapView, to visualStyle: MapVisualStyle) {
        guard let style = mapView.style else {
            print("[StopsMapView.updateTiles] — Tried to update tiles but style is not loaded.")
            return
        }
        
        switch visualStyle {
        case .standard:
            if let satelliteTilesSource = mapView.style?.source(withIdentifier: "satellite-source") {
                mapView.style?.removeSource(satelliteTilesSource)
            }
            
            if let satelliteTilesLayer = mapView.style?.layer(withIdentifier: "satellite-layer") {
                mapView.style?.removeLayer(satelliteTilesLayer)
            }
        case .satellite:
            print("updating to satellite")
            let rasterTilesSource = MLNRasterTileSource(
                identifier: "satellite-source",
                tileURLTemplates: ["https://server.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}"],
                options: [
                    .minimumZoomLevel: 5,
                    .maximumZoomLevel: 18,
                    .tileSize: 256,
                    .attributionInfos: [
                        MLNAttributionInfo(
                            title: NSAttributedString("Esri, Maxar, Earthstar Geographics, and the GIS User Community"),
                            url: URL(string: "https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer")
                        )
                    ]
                ]
            )
            mapView.style?.addSource(rasterTilesSource)
            
            let rasterTilesLayer = MLNRasterStyleLayer(identifier: "satellite-layer", source: rasterTilesSource)
            mapView.style?.insertLayer(rasterTilesLayer, below: (mapView.style?.layer(withIdentifier: "stops-layer"))!)
        }
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
        var mapVisualStyle: MapVisualStyle // is this really how this is supposed to be done??
        var flyToCoords: CLLocationCoordinate2D?
        
        init(_ control: MapLibreMapView) {
            self.control = control
            self.mapVisualStyle = control.mapVisualStyle
            self.flyToCoords = control.flyToCoords
        }
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            print("was asked to handle tap")
            let mapView = sender.view as! MLNMapView
            let point = sender.location(in: mapView)
            let features = mapView.visibleFeatures(at: point, styleLayerIdentifiers: ["stops-layer"])
            
            if let feature = features.last { // if there are multiple overlapping select the last
                if let stopId = feature.attribute(forKey: "id") as? String {
//                    control.selectedStopId = ""
//                    DispatchQueue.main.async {
//                        self.control.selectedStopId = stopId
//                    }
                    control.onStopSelect(stopId)
                }
            }
        }
        
        func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            print("finished loading mapstyle")
            control.addStops(to: mapView)
            print("calling updateb tiles baceuse syle loaded")
            print("FROM CONTROLLED MV: \(mapVisualStyle)")
            control.updateTiles(on: mapView, to: mapVisualStyle)
            print("added stops, \(style.source(withIdentifier: "stops-layer")), \(style.layer(withIdentifier: "stops"))")
            
            print("from delegate map, flytoCoords is \(control.flyToCoords)")
            
        }
        
        func mapViewDidFinishLoadingMap(_ mapView: MLNMapView) {
            print("mapviewdidfinishloadingmap")
        }
    }
    
    func flyToCoordinate(on mapView: MLNMapView, to coordinate: CLLocationCoordinate2D) {
        let camera = MLNMapCamera(
            lookingAtCenter: coordinate,
            altitude: 5500,
            pitch: 0,
            heading: 0)
        
        mapView.setCamera(
            camera,
            withDuration: 3,
            animationTimingFunction: CAMediaTimingFunction(name: .easeInEaseOut))
    }
    
    func flyToUserCoords(on mapView: MLNMapView) {
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
    
    func makeCoordinator() -> MapLibreMapView.Coordinator {
        Coordinator(self)
    }
    
    func updateUIView(_ uiView: MLNMapView, context: Context) {
        print("MapLibreMapView updateUIView called")
        print("updateUIView called with \(stops.count) stops")
        
        guard let style = uiView.style else {
            print("Style not loaded yet")
            return
        }
        
        updateStyle(uiView)
        print("update ui view, st is \(mapVisualStyle)")
        print("style is \(uiView.style)")
//        updateTiles(uiView)
        context.coordinator.mapVisualStyle = mapVisualStyle

        if style.source(withIdentifier: "stops") == nil {
            addStops(to: uiView)
        } else {
            updateStops(on: uiView)
        }
        
        print("flytocoords out nilguard is \(flyToCoords)")
        if let flyToCoords = flyToCoords {
            flyToCoordinate(on: uiView, to: flyToCoords)
        }
        
        if shouldFlyToUserCoords {
            print("should fly to user coords is \(shouldFlyToUserCoords)")
            flyToUserCoords(on: uiView)
            DispatchQueue.main.async {
                shouldFlyToUserCoords = false
            }
        }
    }
}
