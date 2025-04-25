//
//  MapViewWithShadow.swift
//  Folium
//
//  Created by Jarrod Norwell on 23/4/2025.
//  Copyright © 2025 Jarrod Norwell. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class MapViewWithShadow : UIView {
    var mapView: MKMapView? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerCurve = .continuous
        layer.cornerRadius = 8
        layer.masksToBounds = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .init(width: 0, height: 8)
        layer.shadowOpacity = 1 / 8
        layer.shadowRadius = 8
        
        mapView = .init()
        guard let mapView else { return }
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.clipsToBounds = true
        mapView.isUserInteractionEnabled = false
        mapView.layer.cornerCurve = .continuous
        mapView.layer.cornerRadius = 8
        addSubview(mapView)
        
        mapView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func annotation(with coordinate: CLLocationCoordinate2D) {
        guard let mapView else { return }
        
        let annotation: MKPointAnnotation = .init()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    func region(with coordinate: CLLocationCoordinate2D) {
        guard let mapView else { return }
        mapView.region = .init(center: coordinate,
                               span: .init(latitudeDelta: 5, longitudeDelta: 5))
    }
}
