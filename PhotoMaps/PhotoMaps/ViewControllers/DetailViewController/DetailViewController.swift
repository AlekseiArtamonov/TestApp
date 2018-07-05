//
//  DetailViewController.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/3/18.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var titleView: UINavigationItem!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    var mapViewHeiht: CGFloat
    var keyboardFrame: CGRect
    var viewModel: DetailViewModel?
    let bottomDefaultConstraintValue: CGFloat = 16.0
    var kbShown = false
    
    class func detailViewController(withViewModel vm: DetailViewModel) -> DetailViewController{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        controller.viewModel = vm
        return controller
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        viewModel = nil
        mapViewHeiht = 200
        keyboardFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
        super.init(coder: aDecoder)
    }
    
    func updateUI() {
        if let vm = self.viewModel {
            if vm.isCreatingNew {
                self.titleTextField.isUserInteractionEnabled = vm.isCreatingNew
                self.titleTextField.backgroundColor = UIColor.white
            } else {
                self.titleTextField.isUserInteractionEnabled = vm.isCreatingNew
            }
            
            vm.viewTitle.bindAndFire { [weak self] in
                self?.titleView.title = $0
            }
            
            vm.annotation.bindAndFire {[weak self] in
                guard let strongSelf = self else {
                    return
                }
                let radius = 2500.0
                let coordinateRegion = MKCoordinateRegionMakeWithDistance($0.coordinate,
                                                                          radius, radius)
                strongSelf.mapView.setRegion(coordinateRegion, animated: true)
                strongSelf.mapView.removeAnnotations(strongSelf.mapView.annotations)
                strongSelf.mapView.addAnnotation($0)
            }
            
            vm.locationName.bindAndFire {[weak self] in
                self?.titleTextField.text = $0
            }
            
            vm.note.bindAndFire {[weak self] in
                self?.noteTextView.text = $0
            }
            
            vm.distance.bindAndFire { [weak self] in
                self?.distanceLabel.text = $0
            }
            
            vm.errorMessage.bindAndFire { [weak self] in
                if !$0.isEmpty {
                    let alert = UIAlertController(title: "Error", message: $0, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
            
            vm.refreshViewModel()
        }
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if let vm = self.viewModel, vm.saveLocation() {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.updateUI()  //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.scrollView.scrollToView(view: textField, animated: true)
    }

    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === self.titleTextField {
            let textToChange: NSString = (textField.text ?? "") as NSString
            let txtAfterUpdate = textToChange.replacingCharacters(in: range, with: string)
            self.viewModel?.updateLocationNameWith(txtAfterUpdate as String)
            return false
        }
        return true
    }
    
    internal func textViewDidBeginEditing(_ textView: UITextView) {
        self.scrollView.scrollToView(view: textView, animated: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView === self.noteTextView {
            let textToChange: NSString = (textView.text ?? "") as NSString
            let txtAfterUpdate = textToChange.replacingCharacters(in: range, with: text)
            self.viewModel?.updateNoteWith(txtAfterUpdate as String)
            return false
        }
        return true
    }
//    internal func textViewDidEndEditing(_ textView: UITextView) {
//        textView.resignFirstResponder()
//    }

    
// Keyboard Methods
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func inputViewIntersectionWithKeyboard(_ inputViewFrame: CGRect, _ accessoryHeight: CGFloat, _ kbFrame: CGRect) -> CGFloat {
        var yDiff: CGFloat = 0.0
        let textInputBottom: CGFloat = inputViewFrame.origin.y + inputViewFrame.size.height
        let yIntersection: CGFloat = kbFrame.origin.y - accessoryHeight - textInputBottom
        if yIntersection < 0 {
            yDiff = (-1) * yIntersection
        } else if yIntersection > 0 {
            yDiff = self.bottomConstraint.constant - yIntersection
        }
        return yDiff
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.kbShown = true
        if let kbFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardFrame = kbFrame
            bottomConstraint.constant += kbFrame.size.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.kbShown = false
        UIView.animate(withDuration: 1, animations: { () -> Void in
            self.bottomConstraint.constant = self.bottomDefaultConstraintValue
        })
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
