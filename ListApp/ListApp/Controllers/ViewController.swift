//
//  ViewController.swift
//  ListApp
//
//  Created by Ömer Faruk Başaran on 16.11.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController  {
    var alertController = UIAlertController()
    var data = [NSManagedObject]()
    
    @IBOutlet weak var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        fetch()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didBarButtonItemTapped(_ sender:UIBarButtonItem){
        presentAddAlert()
    }
    @IBAction func didRemoveBarButtonItemTapped(_ sender:UIBarButtonItem){
        if self.data.isEmpty {
            presentAlert(title: "Uyarı!", message: "Silinecek hiçbir şey yok", cancelButtonTitle: "Tamam")
        }
        presentAlert(title: "Uyarı!",
                     message: "Her şeyi silmek istediğine emin misin?",
                     defaultButtonTitle: "Evet",
                     cancelButtonTitle: "Vazgeç",
                     defaultButtonHandler: { _ in
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let menagedObjectContext = appDelegate?.persistentContainer.viewContext
            
            for items in self.data {
                menagedObjectContext?.delete(items)
                
            }
                

                // Save Changes
            try? menagedObjectContext!.save()
                     self.fetch()
            //self.data.removeAll()
            self.tableView.reloadData()
        })
    }
    func presentAddAlert (){
        
        presentAlert(title: "Yeni Eleman Ekle", message: nil, defaultButtonTitle: "Ekle" ,cancelButtonTitle: "Vazgeç",defaultButtonHandler: { [self] _ in
            let text = self.alertController.textFields?.first?.text
            if text != "" {
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let menagedObjectContext = appDelegate?.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: menagedObjectContext!)
                let listItem = NSManagedObject(entity: entity!, insertInto: menagedObjectContext)
                listItem.setValue(text, forKey: "title")
                try? menagedObjectContext?.save()
                self.fetch()
                
            } else {
                self.presentWarningAlert()
            }
        },isTextFieldAvailable: true)
        
    }
    func presentWarningAlert(){
        presentAlert(title: "Uyarı!",
                     message: "Liste elemanı boş olamaz",
                     cancelButtonTitle: "Tamam")
    }
    func presentAlert(title: String?,
                      message: String?,
                      preferredStyle:UIAlertController.Style = .alert,
                      defaultButtonTitle: String?=nil,
                      cancelButtonTitle: String?,
                      defaultButtonHandler: ((UIAlertAction)-> Void)? = nil,
                      isTextFieldAvailable: Bool=false){
        
        alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle, style: .default,handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        
        if isTextFieldAvailable {
            alertController.addTextField()
        }
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
        
        alertController.addAction(cancelButton)
        present(alertController, animated: true)
    }
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let menagedObjectContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        data = try! menagedObjectContext!.fetch(fetchRequest)
        tableView.reloadData()
    }
}
    extension ViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return data.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
            let listItem = data[indexPath.row]
            cell.textLabel?.text = listItem.value(forKey: "title") as? String
            return cell
        }
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .normal, title: "Sil") { _, _, _ in
                
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let menagedObjectContext = appDelegate?.persistentContainer.viewContext
                
                menagedObjectContext?.delete(self.data[indexPath.row])
                
                try? menagedObjectContext?.save()
                self.fetch()
            
            }
            deleteAction.backgroundColor = .systemRed
            
            let customizeAction = UIContextualAction(style: .normal, title: "Düzenle") { _, _, _ in
                self.presentAlert(title: "Elemanı düzenle", message: nil, defaultButtonTitle: "Düzenle" ,cancelButtonTitle: "Vazgeç",defaultButtonHandler: { _ in
                    let text = self.alertController.textFields?.first?.text
                    if text != "" {
                        
                        let appDelegate = UIApplication.shared.delegate as? AppDelegate
                        let menagedObjectContext = appDelegate?.persistentContainer.viewContext
                        
                        self.data[indexPath.row].setValue(text, forKey: "title")
                        if menagedObjectContext!.hasChanges {
                            try? menagedObjectContext?.save()

                        }
                        tableView.reloadData()
                        
                      //  self.data[indexPath.row] = text!
                    } else {
                        self.presentWarningAlert()
                    }
                },isTextFieldAvailable: true)
            }
            //customizeAction.backgroundColor = .systemOrange
            let config = UISwipeActionsConfiguration(actions: [deleteAction,customizeAction])
            return config
        }
    }

