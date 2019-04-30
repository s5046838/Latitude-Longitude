//
//  MasterViewController.swift
//  Assessment2.0
//
//  Created by Kayn Critchley on 15/4/19.
//  Copyright © 2019 Kayn Critchley. All rights reserved.
//
import CoreLocation
import UIKit
import Foundation

class MasterViewController: UITableViewController, UITextFieldDelegate, DetailViewControllerDelegate {
    
    var objects = [Location]()
    var newLocation = false
    var detailViewController: DetailViewController? = nil
    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = editButtonItem
        super.viewDidLoad()
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        decode()
    }

//        let aquarium = User(firstName: a, address: b)
//
//        let enclosures = [aquarium]
//        let encoder = JSONEncoder()
//        do {
//            let json = try encoder.encode(enclosures)
//            let fileURL = URL(fileURLWithPath: "/tmp/json")
//            try json.write(to: fileURL, options: .atomic)
//            let data = try Data(contentsOf: fileURL)
//            let decoder = JSONDecoder()
//            let places = try decoder.decode([User].self, from: data)
//            print("Got\(places.count) places:")
//            for place in places{
//                print(place.firstName)
//            }
//        } catch {
//            print("Error: \(error)")
//        }
    
    
    func encode() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let encode = objects
            let jsonData = try encoder.encode(encode)
            let fileURL = docs.appendingPathComponent("json")
            try jsonData.write(to: fileURL, options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    fileprivate func decode() {
        do {
            let fileURL = docs.appendingPathComponent("json")
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            self.objects = try decoder.decode([Location].self, from: data)
            print("Got \(objects.count) places:")

            self.tableView.reloadData()
        } catch {
            print("Error: \(error)")
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.delegate = self
            let indexPath: IndexPath
            if let i = sender as? IndexPath{
                indexPath = i
                let location = objects[indexPath.row]
                controller.detailItem = location
            } else if let cell = sender as? UITableViewCell,
                let i = tableView.indexPath(for: cell) {
                indexPath = i
            } else { return }
            let location = objects[indexPath.row]
            controller.detailItem = location
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
    
    func okayPressed(){
        //print("okay")
        tableView.reloadData()
        newLocation = false
    }
    
    func cancelPressed(){
        if newLocation {
            objects.removeLast()
        }
        newLocation = false
       
        navigationController?.popViewController(animated: true)
        tableView.reloadData()
        encode()
    }
    
    
    @IBAction func addObject(_ sender: Any) {
        let n = objects.count
        let location = Location(name: "", address: "", latitude: 0.0, longitude: 0.0)
        objects.append(location)
        //tableView.reloadData() refreshes the table screen
        let indexPath = IndexPath(row: n, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        performSegue(withIdentifier: "showDetail", sender: indexPath)
        newLocation = true
    }
    
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    //Inserts objects into rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let i = indexPath.row
        cell.textLabel?.text = "Name: \(objects[i].name)"
        cell.detailTextLabel?.text = "Address: \(objects[i].address)"
        //        print(objects[i].name, objects[i].address, objects[i].latitude, objects[i].longitude)
        encode()
        return cell
        
    }
    //deletes rows
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert { addObject(self) ; return }
        guard editingStyle == .delete else { return }
        objects.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        encode()
    }
    //Moves rows
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let object = objects.remove(at: sourceIndexPath.row)
        objects.insert(object, at: destinationIndexPath.row)
        encode()
    }
    
    
    
}

