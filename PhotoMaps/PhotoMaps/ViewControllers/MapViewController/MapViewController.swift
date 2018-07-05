//
//  MapViewController.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/2/18.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: RoundButton!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mapCursor: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var savingLocation = false
    var newAnnotation: MKPointAnnotation?
    
    var viewModel = MapViewModel(with:UserLocationService.shared, and: DataProvider(with: SessionManager())) {
        didSet {
            updateUI()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI();
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setMapCenter(withLocation location: CLLocation, andRadius radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  radius, radius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func updateUI() {
        viewModel.pins.bindAndFire { [weak self] in
            self?.mapView.addAnnotations($0)
        }
        viewModel.currentLocation.bindAndFire { [weak self] in
            guard let stongSelf = self else {
                return
            }
            if !stongSelf.savingLocation {
                let radius: CLLocationDistance? = self?.viewModel.regionRadius.value
                let location: CLLocation? = $0
                self?.setMapCenter(withLocation: location!, andRadius: radius!)
            }
        }
        viewModel.regionRadius.bindAndFire { [weak self] in
            guard let stongSelf = self else {
                return
            }
            if !stongSelf.savingLocation {
                let radius: CLLocationDistance? = $0
                let location: CLLocation? = stongSelf.viewModel.currentLocation.value
                stongSelf.setMapCenter(withLocation: location!, andRadius: radius!)
            }
        }
        viewModel.refreshing.bindAndFire { [weak self] in
            if $0 {
                self?.animateRefreshButton()
            }
        }
        
        viewModel.errorMessage.bindAndFire { [weak self] in
            if !$0.isEmpty {
                let alert = UIAlertController(title: "Error", message: $0, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
        self.viewModel.refreshViewModel()
    }
    
    func animateRefreshButton() {
        
        self.refreshButton.transform = CGAffineTransform.init(rotationAngle: 0.0)
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: { [weak self] () -> Void in
            self?.refreshButton.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
        }) { [weak self] (finished) -> Void in
            self?.refreshButton.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: { [weak self] () -> Void in
                self?.refreshButton.transform = CGAffineTransform.init(rotationAngle: 2 * CGFloat(Double.pi))
            }) { [weak self] (finished) -> Void in
                guard let stongSelf = self else {
                    return
                }
                if finished && stongSelf.viewModel.refreshing.value {
                    stongSelf.animateRefreshButton()
                }
            }
        }
    }
    
    func setAddingStateWithAnimation(_ isAdding: Bool) {
        var firstPart: Array<UIView>
        var secondPart: Array<UIView>
        if isAdding {
            firstPart = [self.addLocationButton, self.refreshButton]
            secondPart = [self.cancelButton, self.saveButton, self.mapCursor]
        } else {
            firstPart = [self.cancelButton, self.saveButton, self.mapCursor]
            secondPart = [self.addLocationButton, self.refreshButton]
        }
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveLinear, animations: { () -> Void in
            for button in firstPart {
                button.alpha = 0.0
            }
            
        }) { (finished) -> Void in
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveLinear, animations: { () -> Void in
                for button in secondPart {
                    button.alpha =  1.0
                }
            })
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        self.viewModel.refreshViewModel()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.setAddingStateWithAnimation(false)
        isEditing = false
        if let annotation = self.newAnnotation {
            let vm = DetailViewModel(with: self.viewModel.locationService, self.viewModel.dataProvider, false, annotation)
            let controller = DetailViewController.detailViewController(withViewModel: vm)
            
            self.present(controller, animated: true, completion: nil)
        }
        self.setAddingStateWithAnimation(false)
        isEditing = false
        self.mapView.removeAnnotation(self.newAnnotation!)
        self.newAnnotation = nil
        
    }
    @IBAction func addLocationButtonPressed(_ sender: Any) {
        var radius: CLLocationDistance? = self.viewModel.regionRadius.value
        let location: CLLocation? = self.viewModel.locationService.currentLocation()
        if radius! >= 5000.0 {
            radius = 2500
        }
        self.setMapCenter(withLocation: location!, andRadius: radius!)
        if self.newAnnotation == nil {
            self.setAddingStateWithAnimation(true)
            let annotation = MKPointAnnotation()
            annotation.title = "New"
            annotation.coordinate = mapView.centerCoordinate
            self.newAnnotation = annotation
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
        
    }
    
    private func cancelAdding() {
        if let annotation = self.newAnnotation {
            self.mapView.removeAnnotation(annotation)
        }
        self.newAnnotation = nil
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cancelAdding()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.newAnnotation?.coordinate = mapView.centerCoordinate
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation {
            var isEditing = true
            if view.annotation === self.newAnnotation {
                self.setAddingStateWithAnimation(false)
                self.mapView.removeAnnotation(self.newAnnotation!)
                self.newAnnotation = nil
                isEditing = false
            }
            
            let vm = DetailViewModel(with: self.viewModel.locationService, self.viewModel.dataProvider, isEditing, annotation)
            let controller = DetailViewController.detailViewController(withViewModel: vm)
            self.present(controller, animated: true, completion: nil)
            view.setSelected(false, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.annotation === self.newAnnotation {
            cancelAdding()
            self.setAddingStateWithAnimation(false)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let identifier = "Pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        var btn: UIButton
        if annotation === newAnnotation {
            btn = UIButton(type: .contactAdd)
            annotationView?.isDraggable = true
        } else {
            btn = UIButton(type: .detailDisclosure)
        }
        annotationView?.rightCalloutAccessoryView = btn
        annotationView?.isDraggable = annotation === newAnnotation
        annotationView?.annotation = annotation
        
        
        return annotationView
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
