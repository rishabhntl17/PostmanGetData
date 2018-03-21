//
//  ViewController.swift
//  PostmanGetData
//
//  Created by Appinventiv on 3/13/18.
//  Copyright © 2018 Appinventiv. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var names = [String]()
    var addresses = [String]()
    var ratings = [NSNumber]()
    var imageReference = [String]()
    var images = [UIImage]()
  
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var searchTextFieldOutlet: UITextField!
    @IBOutlet weak var searchLoader: UIActivityIndicatorView!
    @IBOutlet weak var searchButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        detailsTableView.delegate = self
        detailsTableView.dataSource = self
        self.detailsTableView.layer.borderWidth = 2.0
        self.detailsTableView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.searchLoader.isHidden = true
        
        UIView.animate(withDuration: 3) {
            self.searchTextFieldOutlet.center.x += UIScreen.main.bounds.width
            self.detailsTableView.center.y -= UIScreen.main.bounds.height
            self.detailsTableView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.searchTextFieldOutlet.center.x -= UIScreen.main.bounds.width
        self.detailsTableView.center.y += UIScreen.main.bounds.height
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func searchButtonAction(_ sender: UIButton) {
        sender.isHidden = true
        names = []
        addresses = []
        ratings = []
        images = []
        toSearch()
        //imageFromURL()
        searchLoader.isHidden = false
        searchLoader.startAnimating()
        searchLoader.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.reloadDataAfterDelay()
        detailsTableView.reloadDataAfterDelay()
        sender.show()
        searchLoader.hide()
    }
    
    func reloadDataAfterDelay(delayTime: TimeInterval = 3) -> Void {
        self.perform(#selector(self.imageFromURL), with: nil, afterDelay: delayTime)
    }
    
    func toSearch()
    {

        let headers = [
            "Cache-Control": "no-cache",
            "Postman-Token": "6975e883-8a6c-4000-af2e-6dbc3b0fca83"
        ]
        
        let searchString = searchTextFieldOutlet.text!
        let newSearchString = searchString.replacingOccurrences(of: " ", with: "+")
        let URLrequest = NSMutableURLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?query="+newSearchString+"&key=AIzaSyAqMrIjsevRHLx-qSZ5KQA8ka2rAcZlUVM")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        URLrequest.httpMethod = "POST"
        URLrequest.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: URLrequest as URLRequest, completionHandler: { (data, response, error) -> Void in
//            if (error != nil) {
//                    print(error)
//            } else {
//                _ = response as? HTTPURLResponse
//                    print(httpResponse)
//            }
            guard let allData = data
                else
            {
                return
            }
            do
            {
                if let dic = try! JSONSerialization.jsonObject(with: allData, options: .mutableContainers) as? [String : Any],
                    let results = dic["results"] as? [[String:Any]] {
                    for result in results
                    {
                        if let name = result["name"] as? String
                        {
                           // print(name)
                            self.names.append(name)
                        }
                        if let address = result["formatted_address"] as? String
                        {
                            //print(address)
                            self.addresses.append(address)
                        }
                        if let rating = result["rating"] as? NSNumber
                        {
                            //print(rating)
                            self.ratings.append(rating)
                        }
                        if let photos = result["photos"] as? [[String:Any]]
                        {
                            for photo in photos
                            {
                                if let image = photo["photo_reference"] as? String
                                {
                                    self.imageReference.append(image)
                                    print(image ,"\n\n")
                                }
                            }
                        }
                    }
                }
            }
        })
        
        dataTask.resume()
    }
    
    @objc func imageFromURL() {
        
        let headers = [
            "Cache-Control": "no-cache",
            "Postman-Token": "6f37158a-57a7-498b-a4db-3299f61ade64"
        ]
        for imageRef in imageReference
        {
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference="+imageRef+"&key=AIzaSyAqMrIjsevRHLx-qSZ5KQA8ka2rAcZlUVM")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
            }
            
            guard let imageData = data else {return}
            let image = UIImage(data : imageData)
            self.images.append(image!)
            
            
        })
        
        dataTask.resume()
//        for urlString in urlStrings
//        {
//            URLSession.shared.dataTask(with: NSURL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference="+urlString+"&key=AIzaSyAqMrIjsevRHLx-qSZ5KQA8ka2rAcZlUVM")! as URL, completionHandler: { (data, response, error) -> Void in
//                if error != nil {
//                    print(error ?? "No Error")
//                    return
//                }
//                DispatchQueue.main.async(execute: { () -> Void in
//                    let image = UIImage(data: data!)
//                    self.images.append(image!)
//                    print("Image found")
//                })
//
//            }).resume()
//        }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = detailsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailsTVCell
        cell.nameLabel.text = names[indexPath.row]
        cell.addressLabel.text = addresses[indexPath.row]
        if !images.isEmpty
        {
            cell.locationImageView.isHidden = false
            cell.locationImageView.image = images[indexPath.row]
        }
        else if images.isEmpty
        {
            cell.locationImageView.isHidden = true
        }
        if !ratings.isEmpty
        {
            cell.ratingsLabel.isHidden = false
            cell.ratingsLabel.text = "\(ratings[indexPath.row])"
            cell.ratingsImageView.isHidden = false
        }
        else if ratings.isEmpty
        {
            cell.ratingsLabel.isHidden = true
            cell.ratingsImageView.isHidden = true
        }
        return cell
    }
}

extension UITableView
{
    func reloadDataAfterDelay(delayTime: TimeInterval = 6) -> Void {
        self.perform(#selector(self.reloadDataFromTable), with: nil, afterDelay: delayTime)
    }
    @objc func reloadDataFromTable()
    {
        self.reloadData()
        let cells = self.visibleCells
        let tableViewHeight = self.bounds.height
        for cell in cells
        {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        var delayCounter = 0
        for cell in cells
        {
            UIView.animate(withDuration: 3, delay: Double(delayCounter) * 0.1, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
}

extension UIButton
{
    func show(delayTime: TimeInterval = 6) -> Void {
        self.perform(#selector(self.showButton), with: nil, afterDelay: delayTime)
    }
    @objc func showButton()
    {
        self.isHidden = false
    }
    
}

extension UIView
{
    func hide(delayTime: TimeInterval = 6) -> Void {
        self.perform(#selector(self.hideLoader), with: nil, afterDelay: delayTime)
    }
    @objc func hideLoader()
    {
        self.isHidden = true
    }
}

