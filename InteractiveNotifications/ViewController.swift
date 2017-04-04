//
//  ViewController.swift
//  InteractiveNotifications
//
//  Created by ESS Mac Pro on 4/4/17.
//  Copyright © 2017 NGA Group Inc. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var foodItems = [Food]()
    var moc:NSManagedObjectContext!
    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        moc = appDelegate?.persistentContainer.viewContext
        
        loadData()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
        
    }
    
    func loadData() {
        
        //1
        let foodRequest:NSFetchRequest<Food> = Food.fetchRequest()
        
        //2
        let sortDescriptor = NSSortDescriptor(key: "added", ascending: false)
        foodRequest.sortDescriptors = [sortDescriptor]
        
        //3
        do{
            try foodItems = moc.fetch(foodRequest)
        }catch{
            print("Could not load data")
        }
        
        //4
        self.tableView.reloadData()
        
    }
    
    @IBAction func addFoodToDataBase(_ sender: UIButton) {
        
        let foodItem = Food(context: moc)
        foodItem.added = NSDate()
        
        if sender.tag == 0 {
            foodItem.type = "Fruit"
        }else{
            foodItem.type = "Vegetable"
        }
        
        appDelegate?.saveContext()
        
        loadData()
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController : UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //1
        let foodItem = foodItems[indexPath.row]
        
        //2
        let foodType = foodItem.type
        cell.textLabel?.text = foodType
        
        //3
        let foodDate = foodItem.added as! Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d yyyy"
        
        cell.detailTextLabel?.text = dateFormatter.string(from: foodDate)
        
        //4
        if foodType == "Fruit" {
            cell.imageView?.image = UIImage(named: "Apple")
        }else{
            cell.imageView?.image = UIImage(named: "Salad")
        }
        
        return cell
        
    }
    
}
