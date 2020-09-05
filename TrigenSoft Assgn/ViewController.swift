//
//  ViewController.swift
//  TrigenSoft Assgn
//
//  Created by Shubham Vinod Kamdi on 04/09/20.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SnapKit
import DropDown
import CoreLocation
import SwiftyJSON
import Alamofire
import UserNotifications

class ViewController: UIViewController{
    
    var startLocLabel: UILabel!
    var endLocLabel: UILabel!
    
    var isFirst: Bool = true
    var sourceLabel: UILabel!
    var destinationTextField: UITextField!
    var destinationView: CardView!
    var sourceView: CardView!
    var startBtn: UIButton!
    var label: UILabel!
    var shouldStop: Bool = false
    var geocoder: GMSGeocoder!
    var destLoc: [CLLocation] = []
    var sourceCordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var destinationCordinate: CLLocationCoordinate2D!
    var locationManager: CLLocationManager!
    var dropDown: DropDown!
    var likelyPlaces: [SearchResult] = []
    var placesClient: GMSPlacesClient!
    var places: [String] = []
    var distanceRemainingLabel: UILabel!
    
    var distance: Double = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLocLabel = UILabel()
        endLocLabel = UILabel()
        destinationView = CardView()
        sourceView = CardView()
        label = UILabel()
        startBtn = UIButton()
        sourceLabel = UILabel()
        destinationTextField = UITextField()
        distanceRemainingLabel = UILabel()
        geocoder = GMSGeocoder()
       
        dropDown = DropDown()
        dropDown.anchorView = self.destinationTextField
        addDoneButtonOnKeyboard(textField: destinationTextField)
        
        self.destinationView.addSubview(destinationTextField)
        self.sourceView.addSubview(sourceLabel)
        self.view.addSubview(destinationView)
        self.view.addSubview(sourceView)
        self.view.addSubview(startBtn)
        self.view.addSubview(label)
        self.view.addSubview(distanceRemainingLabel)
        self.view.addSubview(startLocLabel)
        self.view.addSubview(endLocLabel)
        
        self.startBtn.isHidden = true
        
        
        startLocLabel.snp.makeConstraints({
            $0.width.equalTo(UIScreen.main.bounds.width * 0.3)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalTo(sourceView.snp.leading).offset(-5)
            $0.centerY.equalTo(sourceView)
        })
        
        endLocLabel.snp.makeConstraints({
            $0.width.equalTo(UIScreen.main.bounds.width * 0.3)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalTo(destinationView.snp.leading).offset(-5)
            $0.centerY.equalTo(destinationView)
        })
        
        label.snp.makeConstraints({
             
            $0.top.equalToSuperview().offset(55)
            $0.leading.equalToSuperview().offset(10)
            $0.bottom.equalTo(sourceView.snp.top).offset(-10)
            
        })
        
        sourceLabel.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().offset(5)
            $0.top.bottom.equalToSuperview().offset(5)
        })
        
        destinationTextField.snp.makeConstraints({
            $0.leading.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().offset(-5)
            $0.top.bottom.equalToSuperview().offset(5)
        })
        
        sourceView.snp.makeConstraints({
            $0.top.equalTo(label.snp.bottom).offset(10)
            //$0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.equalTo(45)
        })
        
        destinationView.snp.makeConstraints({
            //$0.leading.trailing.equalTo(sourceView)
            $0.trailing.equalTo(sourceView)
            $0.height.equalTo(sourceView.snp.height)
            $0.top.equalTo(sourceView.snp.bottom).offset(15)
        })
        
        
        
        startBtn.snp.makeConstraints({
           
            $0.trailing.equalTo(destinationView)
            $0.leading.equalTo(endLocLabel)
            $0.height.equalTo(45)
            $0.top.equalTo(destinationView.snp.bottom).offset(20)
        })
        
        distanceRemainingLabel.snp.makeConstraints({
            $0.leading.trailing.equalToSuperview().offset(10)
            $0.height.equalTo(45)
            $0.top.equalTo(startBtn.snp.bottom).offset(20)
        })
        
        distanceRemainingLabel.textAlignment = .left
        
        self.startBtn.addTarget(self, action: #selector(startBtnAct), for: .touchUpInside)
        distanceRemainingLabel.isHidden = true
        startBtn.backgroundColor = .blue
        startBtn.setTitle("START", for: .normal)
        startBtn.clipsToBounds = true
        startBtn.layer.cornerRadius = 8
        startBtn.layer.borderWidth = 0.7
        startBtn.layer.borderColor = UIColor.lightGray.cgColor
        
        sourceView.backgroundColor = .white
        destinationView.backgroundColor = .white
        startLocLabel.text = "Current Loc:"
        endLocLabel.text = "Destination Loc:"
        label.text = "Coding Assignment"
        label.font = UIFont.boldSystemFont(ofSize: 25)
        startLocLabel.font = UIFont.boldSystemFont(ofSize: 15)
        startLocLabel.adjustsFontSizeToFitWidth = true
        endLocLabel.font = UIFont.boldSystemFont(ofSize: 15)
        endLocLabel.adjustsFontSizeToFitWidth = true
        // Ask for Authorisation from the User.
        locationManager = CLLocationManager()
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        destinationTextField.delegate = self
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.startBtn.transform = CGAffineTransform(scaleX: 0, y: 1)
            self.startBtn.isHidden = false
            self.destinationTextField.text = item
            self.getCordinate(placeID: self.likelyPlaces[index].placeID)
            if !self.sourceLabel.text!.isEmpty && !self.destinationTextField.text!.isEmpty{
                           
                UIView.animate(withDuration: 0.2, animations: {
                    self.startBtn.transform = .identity
                })
                           
                       }
        }

        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)! + 40)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
              (granted, error) in
              if granted {
                  print("yes")
              } else {
                  print("No")
              }
          }
    }
    
    

    func reverse(currentLocation: CLLocation){
        geocoder.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude), completionHandler: {
                       response, error in
                       if error == nil{
                           if let resultAdd = response?.firstResult(){
                              
                               let lines = resultAdd.lines! as [String]
                               
                               print("ADDRESS => \(lines.joined(separator: "\n"))")
                            self.sourceLabel.text = "\(lines.joined(separator: "\n"))"
                           }else{
                               print("ERROR_PLEASE_TRY_AGAIN_LATER")
                           }
                           
                       }
                   })
    }
    
    func getCordinate(placeID: String!){
       placesClient.lookUpPlaceID(placeID, callback: {
            (result, error) -> Void in
            if error == nil{
                
                print(result?.coordinate.latitude ?? "ERROR IN FETCHING LATITUDE")
                print(result?.coordinate.longitude ?? "ERROR IN FETCHING LONGITUDE")
                self.destinationCordinate = CLLocationCoordinate2DMake((result?.coordinate.latitude)!, (result?.coordinate.longitude)!)
                
            }else{
                return
            }
        })
    }
    
    func addDoneButtonOnKeyboard(textField: UITextField) {
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            doneToolbar.barStyle       = UIBarStyle.default
            let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem  = UIBarButtonItem(title: "SEARCH NOW", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneButtonAction))
            
            var items = [UIBarButtonItem]()
            items.append(flexSpace)
            items.append(done)
            
            doneToolbar.items = items
            doneToolbar.sizeToFit()
            
            textField.inputAccessoryView = doneToolbar
        }
        
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
      
    
    func getPlaces(){
        if Reachability.isInternetAvailable(){
            placesClient = GMSPlacesClient()
            placesClient.autocompleteQuery(self.destinationTextField.text!, bounds: nil, filter: nil, callback: {
                (Result, error) -> Void in
                if Result != nil{
                    for result in Result!{
                        print(result)
                        
                        if let result = result as? GMSAutocompletePrediction{
                            self.likelyPlaces.append(SearchResult(placeText: result.attributedFullText.string, placeID: result.placeID))
                            
                            self.places.append(result.attributedFullText.string)
                        }
                        self.dropDown.show()
                        

                        
                        self.dropDown.dataSource = self.places
                    
                    }
                    
                   
                    
                }else{
                    print(error)
                }
            })
        }else{
            let alertController = UIAlertController(title: "Error",
                                                    message: "Please check your Internet Connection and try again",
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
                _ in
                self.dismiss(animated: true, completion: {
                    print("DISMISSING_VIEWCONTROLLER")
                })
            })
            alertController.addAction(cancelAction)
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }
       
    }
    
    @objc func startBtnAct(){
        if self.startBtn.titleLabel?.text == "STOP"{
            
            distanceRemainingLabel.text = ""
            distanceRemainingLabel.isHidden = true
            self.isFirst = true
            self.startBtn.isHidden = true
            self.destinationCordinate = nil
            self.destinationTextField.text = ""
            self.shouldStartUpdating = false
            self.shouldStop = true
            self.locationManager.stopUpdatingLocation()
            self.locationManager.stopMonitoringSignificantLocationChanges()
            self.sendNotificationOnce = true
            
            UIView.animate(withDuration: 0.2, animations: {
                self.startBtn.transform = CGAffineTransform(scaleX: 0.1, y: 1)
            }, completion: {
                _ in
                self.startBtn.isHidden = true
                self.startBtn.setTitle("START", for: .normal)
                self.shouldStop = false
            })
           
            
        }else{
            
            print("Destination => \(destinationCordinate)")
            print("Source => \(sourceCordinate)")
            
            
            DispatchQueue.global(qos: .background).async {
                self.getDistance()
                
            }
           
            
        }
        }
    var sendNotificationOnce: Bool = true
    
     func sendNotification() {
        
        DispatchQueue.global(qos: .background).async {
            
            //get the notification center
            let center =  UNUserNotificationCenter.current()

            //create the content for the notification
            let content = UNMutableNotificationContent()
            content.title = "Code Assignment"
            content.subtitle = "Trigensoft Pvt Ltd"
            content.body = "Less than a KM is remaing, click on STOP to save battery"
            content.sound = UNNotificationSound.default

            //notification trigger can be based on time, calendar or location
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval:1.0, repeats: false)

            //create request to display
            let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)

            //add request to notification center
            center.add(request) { (error) in
                if error != nil {
                    print("error \(String(describing: error))")
                }
            }
            
        }
        
    }
        
    
    var shouldStartUpdating: Bool = false

}

extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if shouldStartUpdating{
            
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            self.sourceCordinate = locValue
            DispatchQueue.global(qos: .background).async {
                if self.destinationCordinate != nil{
                    self.getDistance()
                }
                
                
            }
            
        }else{
            
            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
            reverse(currentLocation: locations.first!)
            self.locationManager.stopUpdatingLocation()
            self.sourceCordinate = locValue
            print("locations = \(locValue.latitude) \(locValue.longitude)")
            shouldStartUpdating = true
        }
        
       
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status{
            
        case .authorizedAlways:
           
            break
            
        case .authorizedWhenInUse:
            
            break
            
        case .notDetermined:
            
            //redirectToSettings()
            break
            
        case .denied:
            
            redirectToSettings()
            break
            
        case .restricted:
            
            redirectToSettings()
            break
            
        default:
            print("ERROR_TRY_AGAIN_LATER")
            
        }
        
    }
    
    func redirectToSettings(){
            if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .notDetermined{
                
                let alertController = UIAlertController(title: "Location Access Denied or Restricted",
                                                        message: "Please enable location and Restart the app again",
                                                        preferredStyle: .alert)
                
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
                    if let appSettings = NSURL(string: UIApplication.openSettingsURLString) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(appSettings as URL, options: [:], completionHandler: { _ in
                            })
                            self.dismiss(animated: true, completion: nil)
                            
                        } else {
                            UIApplication.shared.openURL(appSettings as URL)
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                    }
                }
                alertController.addAction(settingsAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    _ in
                    self.dismiss(animated: true, completion: {
                        print("DISMISSING_VIEWCONTROLLER")
                    })
                })
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
}

extension ViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !textField.text!.isEmpty && self.sourceCordinate != nil{
            
            if self.destinationCordinate != nil{
                self.startBtn.isUserInteractionEnabled = true
                distanceRemainingLabel.text = ""
                distanceRemainingLabel.isHidden = true
                self.isFirst = true
                self.startBtn.isHidden = true
               // self.destinationCordinate = nil
                self.destinationTextField.text = ""
                self.shouldStartUpdating = false
                self.shouldStop = true
                self.startBtn.transform = CGAffineTransform(scaleX: 0.1, y: 1)
                self.sendNotificationOnce = true
                self.shouldStop = false
                getPlaces()
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.startBtn.transform = .identity
                })
                
            }else{
                UIView.animate(withDuration: 0.2, animations: {
                           self.startBtn.transform = CGAffineTransform(scaleX: 0.1, y: 1)
                       }, completion: {
                           _ in
                           self.startBtn.isHidden = true
                           self.startBtn.transform = .identity
                        self.getPlaces()
                       })
            }
            
            
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.places = []
        self.likelyPlaces = []
        self.dropDown.hide()
    }
   
}


@IBDesignable
class CardView: UIView {
    
    @IBInspectable var CornerRadiusCard: CGFloat = 5
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.lightGray
    @IBInspectable var shadowOpacity: Float = 0.9
    
    override func layoutSubviews() {
        layer.cornerRadius = CornerRadiusCard
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: CornerRadiusCard)
        layer.masksToBounds = false
        //        layer.borderColor = UIColor(red:0.84, green:0.84, blue:0.84, alpha:1.0).cgColor
        //        layer.borderWidth = 1
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
    func RoundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

struct SearchResult{
    
    var placeText: String!
    var placeID: String!
    
    init(placeText: String!, placeID: String!){
        self.placeText = placeText
        self.placeID = placeID
    }

}

extension ViewController{
   func getDistance(){
    
    
    if Reachability.isInternetAvailable(){
        DispatchQueue.main.async {
            self.startBtn.isUserInteractionEnabled = false
        }
        
              let origin  = "\(self.sourceCordinate.latitude),\(self.sourceCordinate.longitude)"
              let destination = "\(self.destinationCordinate.latitude),\(self.destinationCordinate.longitude)"
              let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&alternatives=false&key=AIzaSyCSGtoCmeuAwpsFiM8j79qEdVMCtGHZaDA"
              
             
              Alamofire.request(url).responseJSON(completionHandler: {
                           Response in
                           if Response.result.isSuccess {
                               do{
                                   let json =  JSON(Response.data!)
                                   
                                 // print(json)
                                let routes = json["routes"].arrayValue
                                let route1 = routes[0]
                                let leg = route1["legs"]
                                self.distance = leg[0]["distance"]["value"].doubleValue / 1000
                                print("DISTANCE Remaining=> \(self.distance) KM ")
                                
                                if self.isFirst{
                                    
                                    self.locationManager.startMonitoringSignificantLocationChanges()
                                    self.locationManager.startUpdatingLocation()
                                    self.isFirst = false
                                }
                                
                                self.distanceRemainingLabel.isHidden = false
                                self.distanceRemainingLabel.text = "Distance Remaining: \(self.distance) KM"
                               
                                if self.distance <= 1{
                                    
                                    DispatchQueue.main.async {
                                        self.startBtn.isHidden = false
                                        self.startBtn.isUserInteractionEnabled = true
                                        self.startBtn.setTitle("STOP", for: .normal)
                                        
                                    }
                                    if self.sendNotificationOnce{
                                        self.sendNotification()
                                        self.sendNotificationOnce = false
                                    }
                                   
                                   
                                   
                                }else{
                                    
                                    DispatchQueue.main.async {
                                        self.startBtn.setTitle("START", for: .normal)
                                        self.startBtn.isHidden = true
                                        self.startBtn.isUserInteractionEnabled = false
                                    }
                                    
                                    
                                    //DISPLAY NOTIFICATION
                                }
                                if self.shouldStop{
                                    //BREAK RECURSSION
                                    self.locationManager.stopUpdatingLocation()
                                }else{
                                    
                                }
                                
                               }catch{
                                   print("ERROR")
                               }
                             }
                       })
    }else{
        let alertController = UIAlertController(title: "Error",
                                                message: "Please check your Internet Connection and try again",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: {
            _ in
            self.dismiss(animated: true, completion: {
                print("DISMISSING_VIEWCONTROLLER")
            })
        })
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
      }
    
}


