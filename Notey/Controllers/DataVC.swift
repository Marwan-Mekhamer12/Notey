//
//  DataVC.swift
//  Notey
//
//  Created by Marwan Mekhamer on 20/02/2025.
//

import UIKit
import CoreData
import ChameleonFramework

class DataVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var notDataYet: UILabel!
    
    var arrData = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var searchController: UISearchController!
    var filteredData: [String] = []
    var selectCategory : Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SearchController()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        AddBarButtonItem()
        loadingData()
        
        if let item = selectCategory {
               // Use 'item' to populate your UI with the correct data
            self.title = item.title
           }
    }
    
    func SearchController() {
        // Search Controller
        searchController = UISearchController(searchResultsController: nil)
        searchController.isActive = true
        searchController.searchResultsUpdater = self // Set the delegate to update the search results
        searchController.obscuresBackgroundDuringPresentation = false // Allow background interaction during search
        searchController.searchBar.placeholder = "Search items" // Set placeholder text
        searchController.searchBar.backgroundColor = .white
        navigationItem.searchController = searchController
        definesPresentationContext = true // Prevents the search bar from being displayed when pushing another view controller
        searchController.searchBar.delegate = self
        searchController.searchBar.becomeFirstResponder()
    }
    
    func AddBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(AddMore))
    }
    
    @objc func AddMore() {
        var textfield = UITextField()
        let alert = UIAlertController(title: "Add more notes...", message: "what do you thinking about?", preferredStyle: .alert)
        alert.addTextField { text in
            text.placeholder = "Add your thinking..."
            textfield = text
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            let item = Item(context: self.context)
            item.title = textfield.text!
            item.done = false
            item.category = self.selectCategory
            self.arrData.append(item)
            self.tableView.isHidden = false
            self.saveData()
        }))
        
        present(alert, animated: true)
    }
    
    // Core Data functions
    
    func saveData() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Erro to save data: \(error)")
        }
        
    }
    
    func loadingData() {
        
        guard let category = selectCategory else {return}
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "category == %@", category)
        request.predicate = predicate
        
        // let predicate = NSPredicate(format: "category == %@", category.title ?? "")
        //request.predicate = predicate
        do {
            arrData = try context.fetch(request)
            if arrData.isEmpty {
                self.tableView.isHidden = true
                self.notDataYet.isHidden = false
            }else {
                self.tableView.isHidden = false
                self.notDataYet.isHidden = true
            }
            tableView.reloadData()
        } catch {
            print("Error to loading data: \(error)")
        }
    }
}

extension DataVC : UITableViewDelegate & UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = arrData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "data", for: indexPath)
        cell.textLabel?.text = arrData[indexPath.row].title
        cell.alpha = 0 // Start with hidden cell
           UIView.animate(withDuration: 0.5, delay: 0.1 * Double(indexPath.row), animations: {
               cell.alpha = 1 // Fade in
           })
        if let color = FlatSand().darken(byPercentage: CGFloat(indexPath.row) /
            CGFloat(arrData.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(backgroundColor: color, returnFlat: true)
        }
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        arrData.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "") { _, _, code in
            self.arrData.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
            self.tableView.endUpdates()
            self.saveData()
            code(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = arrData[indexPath.row]
        item.done = !item.done
        saveData()
    }
}


extension DataVC : UISearchBarDelegate & UISearchResultsUpdating {

  
   func updateSearchResults(for searchController: UISearchController) {
       
       let searchText = searchController.searchBar.text ?? ""
       
       if searchText.isEmpty {
           loadingData()
       } else {
           arrData = arrData.filter { item in
               return item.title?.lowercased().contains(searchText.lowercased()) ?? false
           }
       }
       
       // Reload the table view to reflect the filtered results
       tableView.reloadData()
   }
   
   
   func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         tableView.reloadData() // Reload table with all items
     }
   
   
   
}
