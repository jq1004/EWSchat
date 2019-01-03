//
//  WeatherController.swift
//  EarlyWarningSystem
//
//  Created by Junqing li on 12/23/18.
//  Copyright © 2018 Junqing li. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation
import GoogleMaps
import GooglePlaces

class WeatherController : UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    let cellId = "cellId"
    let gradientLayer = CAGradientLayer()
    
    let weatherApiKey = "02164969bf428cc17cf55cf3626914ac"
    var activityIndicator: NVActivityIndicatorView!
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var data = [WeatherData]()
    var locationManager: CLLocationManager!
    
    var location: CLLocation!{
        didSet{
            getDarkWeatherInfo(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        }
    }
    
    let backgroundImage: UIImageView = {
        let b = UIImageView(frame: UIScreen.main.bounds)
        b.image = UIImage(named: "login.png")
        b.contentMode = UIView.ContentMode.scaleAspectFill
        return b
    }()
    
    let dayWeatherTableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor.clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.allowsSelection = false
        return tv
    }()
    
    let cityLabel: UILabel = {
        let c = UILabel()
        c.font=UIFont.boldSystemFont(ofSize: 28)
        c.textColor = UIColor.blue
//        c.backgroundColor = UIColor.white
        c.textAlignment = .center
        c.translatesAutoresizingMaskIntoConstraints=false
        return c
    }()
    
    let dayLabel: UILabel = {
        let w = UILabel()
        w.font=UIFont.boldSystemFont(ofSize: 15)
        w.textColor = UIColor.blue
        w.textAlignment = .center
        w.translatesAutoresizingMaskIntoConstraints=false
        return w
    }()
    
    let weatherImage: UIImageView = {
        let w = UIImageView()
        w.translatesAutoresizingMaskIntoConstraints = false
        return w
    }()
    
    let weatherCondition: UILabel = {
        let w = UILabel()
        w.font=UIFont.boldSystemFont(ofSize: 15)
        w.textColor = UIColor.blue
        w.textAlignment = .center
        w.translatesAutoresizingMaskIntoConstraints=false
        return w
    }()
    
    let temperatureLabel: UILabel = {
        let w = UILabel()
        w.font=UIFont.boldSystemFont(ofSize: 30)
        w.textColor = UIColor.blue
        w.textAlignment = .center
        w.translatesAutoresizingMaskIntoConstraints=false
        return w
    }()
   
    @objc func logoutUser(){
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        dismiss(animated: true, completion: nil)
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    fileprivate func setUpbackgroundImageView(){
        view.insertSubview(backgroundImage, at: 0)
        
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func setupViews(){
        
        view.backgroundColor = .gray
        
        let logoutBarButtonItem = UIBarButtonItem(title: "", style: .done, target: self, action: #selector(logoutUser))
        let logoutIcon: UIImage = UIImage(named: "logout.png")!
        logoutBarButtonItem.setBackgroundImage(logoutIcon, for: .normal, barMetrics: .default)
        navigationItem.leftBarButtonItem  = logoutBarButtonItem
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Home"
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
       
      
        view.addSubview(cityLabel)
         cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        cityLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
       
        cityLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        cityLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        view.addSubview(dayLabel)
        dayLabel.leftAnchor.constraint(equalTo: cityLabel.leftAnchor, constant: 0).isActive = true
        dayLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 8).isActive = true
        dayLabel.rightAnchor.constraint(equalTo: cityLabel.rightAnchor, constant: 0).isActive = true
        dayLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.addSubview(weatherImage)
        weatherImage.topAnchor.constraint(equalTo:dayLabel.bottomAnchor, constant: 10).isActive = true
        weatherImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        weatherImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
        weatherImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        view.addSubview(weatherCondition)
        weatherCondition.leftAnchor.constraint(equalTo: cityLabel.leftAnchor, constant: 0).isActive = true
        weatherCondition.topAnchor.constraint(equalTo: weatherImage.bottomAnchor, constant: 8).isActive = true
        weatherCondition.rightAnchor.constraint(equalTo: cityLabel.rightAnchor, constant: 0).isActive = true
        weatherCondition.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        view.addSubview(temperatureLabel)
        temperatureLabel.leftAnchor.constraint(equalTo: cityLabel.leftAnchor, constant: 0).isActive = true
        temperatureLabel.topAnchor.constraint(equalTo: weatherCondition.bottomAnchor, constant: 15).isActive = true
        temperatureLabel.rightAnchor.constraint(equalTo: cityLabel.rightAnchor, constant: 0).isActive = true
        temperatureLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(dayWeatherTableView)
        dayWeatherTableView.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 20).isActive = true
        dayWeatherTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        dayWeatherTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        dayWeatherTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        checkCoreLocationPermission()
        
        dayWeatherTableView.dataSource = self
        dayWeatherTableView.delegate = self
        dayWeatherTableView.register(DayWeatherCell.self, forCellReuseIdentifier: cellId)
        
        setUpbackgroundImageView()
        setupViews()
        
        activityIndicator.startAnimating()
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    func checkCoreLocationPermission(){
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .restricted {
            print("unauthorized to use location service")
        }
    }
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        print(location.coordinate)
        locationManager.stopUpdatingLocation()
    }
    
    //https://api.darksky.net/forecast/02164969bf428cc17cf55cf3626914ac/-26.2041028,28.0473051
    func getDarkWeatherInfo(lat: Double, lon: Double){
        data.removeAll()
        Alamofire.request("https://api.darksky.net/forecast/\(weatherApiKey)/\(lat),\(lon)").responseJSON { (response) in
            
            self.activityIndicator.stopAnimating()
            
            if let responseStr = response.result.value {
                var jsonResponse = JSON(responseStr)
                var jsonWeather = jsonResponse["currently"]
                let iconName = jsonWeather["icon"].stringValue
               
                print("*******Printing weather data")
//                print(iconName)
                self.weatherImage.image = UIImage(named: iconName)
                self.weatherCondition.text = jsonWeather["summary"].stringValue
                self.temperatureLabel.text = "\(Int(round(jsonWeather["temperature"].doubleValue)))"
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.dayLabel.text = dateFormatter.string(from: date)
                
                // configure week weather data
                var daily = jsonResponse["daily"]
                for item in daily["data"]{
                    print("1")
                    let dayWeather = WeatherData()
                    dayWeather.icon = item.1["icon"].stringValue
                    dayWeather.lowTemp = "\(Int(round(item.1["temperatureMin"].doubleValue)))"
                    dayWeather.highTemp = "\(Int(round(item.1["temperatureMax"].doubleValue)))"
                    
                    let seconds = item.1["time"].doubleValue
                    let timestampDate = NSDate(timeIntervalSince1970: seconds)
                    let dataStr = dateFormatter.string(from: timestampDate as Date)
                    print(dataStr)
                    dayWeather.day = dataStr
                    self.data.append(dayWeather)
                 }
                DispatchQueue.main.async {
                    self.dayWeatherTableView.reloadData()
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DayWeatherCell
        cell.dayLabel.text = data[indexPath.row].day
        cell.lowTempLabel.text = data[indexPath.row].lowTemp
        cell.highTempLabel.text = data[indexPath.row].highTemp
        cell.profileImageView.image = UIImage(named:data[indexPath.row].icon! )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
}

class DayWeatherCell: UITableViewCell {
    
    var dayLabel: UILabel = {
        let d = UILabel()
        let attributedText = NSMutableAttributedString(string: "Sunday", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        d.attributedText = attributedText
        
        return d
    }()
    
    let profileImageView: UIImageView = {
        let p = UIImageView()
        p.contentMode = .scaleAspectFit
        p.image = UIImage(named: "sunny")
        return p
    }()
    
    let lowTempLabel: UILabel = {
        let l = UILabel()
        let attributedText = NSMutableAttributedString(string: "-8", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        l.attributedText = attributedText
        
        return l
    }()
    
    let highTempLabel: UILabel = {
        let h = UILabel()
        let attributedText = NSMutableAttributedString(string: "0", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        h.attributedText = attributedText
        
        return h
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCellView(){
        backgroundColor = UIColor.clear
        addSubview(dayLabel)
        addSubview(profileImageView)
        addSubview(lowTempLabel)
        addSubview(highTempLabel)
        
        addConstraintsWithFormat(format: "H:|-8-[v0]-60-[v1(40)]-137-[v2]-20-[v3]-8-|", views: dayLabel,profileImageView, lowTempLabel, highTempLabel)

        addConstraintsWithFormat(format: "V:|-10-[v0]", views: dayLabel)
        addConstraintsWithFormat(format: "V:|-5-[v0(30)]-5-|", views: profileImageView)
        addConstraintsWithFormat(format: "V:|-10-[v0]", views: lowTempLabel)
        addConstraintsWithFormat(format: "V:|-10-[v0]", views: highTempLabel)
    }
}


extension WeatherController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        activityIndicator.startAnimating()
        
        self.cityLabel.text = place.name
        getDarkWeatherInfo(lat: place.coordinate.latitude, lon: place.coordinate.longitude)
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        print("lat:\(place.coordinate.latitude)")
        print("lon:\(place.coordinate.longitude)")
        
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        print("Error: ", error.localizedDescription)
    }
    
    func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
