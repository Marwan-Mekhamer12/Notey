//
//  ViewController.swift
//  Notey
//
//  Created by Marwan Mekhamer on 19/02/2025.
//

import UIKit
import CoreData
import ChameleonFramework

class ViewController: UIViewController {
   
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var NotDataYet: UILabel!
    
    var arrData = [Category]()
    var searchController: UISearchController!
    var filteredData: [String] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SearchController()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        loadingData()
        
    }
    
    // Search Controller
    func SearchController() {
        
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
    
    @IBAction func AddCells(_ sender: UIBarButtonItem) {
        var textfield = UITextField()
        let alert = UIAlertController(title: "Add more notes...", message: "what do you thinking about?", preferredStyle: .alert)
        alert.addTextField { text in
            text.placeholder = "Add your thinking..."
            textfield = text
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            let item = Category(context: self.context)
            item.title = textfield.text!
            item.done = false
            self.arrData.append(item)
            self.tableView.isHidden = false
            self.savingData()
        }))
        
        present(alert, animated: true)
    }
    
    @IBAction func Editbtn(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
    }
    
    // Mark :- CoreData function
    
    func savingData() {
        do {
            try context.save()
            tableView.reloadData()
        } catch {
            print("Error to save data: \(error)")
        }
        
    }
    
    func loadingData() {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do {
            arrData = try context.fetch(request)
            if arrData.isEmpty {
                self.tableView.isHidden = true
                self.NotDataYet.isHidden = false
            }else {
                self.tableView.isHidden = false
                self.NotDataYet.isHidden = true
            }

            tableView.reloadData()
        } catch {
            print("Error to load data: \(error)")
        }
        
    }
    
}

     // Mark: - TableView functions

extension ViewController : UITableViewDelegate & UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = arrData[indexPath.row].title
        
        cell.alpha = 0 // Start with hidden cell
           UIView.animate(withDuration: 0.5, delay: 0.1 * Double(indexPath.row), animations: {
               cell.alpha = 1 // Fade in
           })
        if let color = FlatWatermelon().darken(byPercentage: CGFloat(indexPath.row) /
            CGFloat(arrData.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(backgroundColor: color, returnFlat: true)
        }
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
            let data = self.arrData[indexPath.row]
            self.arrData.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.context.delete(data)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            self.savingData()
            
            // Check if table is empty after deletion
               if self.arrData.isEmpty {
                   self.tableView.isHidden = true
                   self.NotDataYet.isHidden = false
               }
            
            code(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectdata = arrData[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "data") as? DataVC {
            vc.selectCategory = selectdata
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ViewController : UISearchBarDelegate & UISearchResultsUpdating {

  
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
