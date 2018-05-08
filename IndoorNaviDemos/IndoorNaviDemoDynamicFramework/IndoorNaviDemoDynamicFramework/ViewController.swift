//
//  ViewController.swift
//  IndoorNaviDemoDynamicFramework
//
//  Created by Michał Pastwa on 10.04.2018.
//  Copyright © 2018 BlastLab. All rights reserved.
//

import UIKit
import IndoorNavi

class ViewController: UIViewController {
    
    var map: INMap!
    var marker: INMarker!
    
    let points1: [INCoordinates] = [INCoordinates(x: 480, y: 480), INCoordinates(x: 1220, y: 480), INCoordinates(x: 1220, y: 1220), INCoordinates(x: 480, y: 1220), INCoordinates(x: 750, y: 750)]
    let points2: [INCoordinates] = [INCoordinates(x: 2000, y: 2000), INCoordinates(x: 2500, y: 2000), INCoordinates(x: 3000, y: 2000), INCoordinates(x: 3000, y: 1500), INCoordinates(x: 2500, y: 1500)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frame = self.view.frame
        frame.origin.y = frame.origin.y + 20
        frame.size.height = frame.size.height - 100
        
        map = INMap(frame: frame, targetHost: "http://192.168.1.13:4200", apiKey: "TestAdmin")
        self.view.addSubview(map)
        map.load(2) {
            print("Completed.")
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "ALERT!", message: "Marker touched!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func drawInfoWindow(_ sender: Any) {
        let infoWindow = INInfoWindow(withMap: map)
        
        infoWindow.ready {
            infoWindow.setInnerHTML(string: "<h2>Lorem ipsum dolor sit amet</h2>")
            infoWindow.position = .top
            infoWindow.height = 100
            infoWindow.width = 300
            infoWindow.open(object: self.marker)
        }
    }
    
    @IBAction func drawPolyline1(_ sender: Any) {
        let polyline1 = INPolyline(withMap: map)
        
        polyline1.ready {
            polyline1.points(self.points1)
            polyline1.set(red: 1.0, green: 0.5, blue: 0.5)
            polyline1.draw()
            
            polyline1.getID { id in
                print("Polyline 1 ID:", id != nil ? id! : 0)
            }
            
            polyline1.getPoints { coordinates in
                print("Coordinates: \(String(describing: coordinates != nil ? coordinates : nil))")
            }
        }
    }
    
    @IBAction func drawPolyline2(_ sender: Any) {
        let polyline2 = INPolyline(withMap: map)
        
        polyline2.ready {
            polyline2.points(self.points2)
            polyline2.set(red: 0.5, green: 1.0, blue: 0.5)
            polyline2.draw()
            
            polyline2.getID { id in
                print("Polyline 2 ID: %d",id != nil ? id! : 0)
            }
        }
    }
    
    @IBAction func drawArea(_ sender: Any) {
        let area = INArea(withMap: map)
        
        area.ready {
            area.points(self.points1)
            area.setFillColor(red: 0.8, green: 0.4, blue: 0.2)
            area.setOpacity(0.5)
            area.draw()
        }
    }
    
    @IBAction func placeMarker(_ sender: Any) {
        marker = INMarker(withMap: map)
        
        marker.ready {
            self.marker.point(INCoordinates(x: 600, y: 600))
            self.marker.setIcon(withPath: "https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678111-map-marker-512.png")
            self.marker.setLabel(withText: "Tekst ABCD")
            self.marker.addEventListener {
                self.showAlert()
            }
            self.marker.draw()
        }
    }
}
