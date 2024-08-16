


import UIKit
import CoreData

class ViewController: UIViewController {
    
    var alertController = UIAlertController()
    
    @IBOutlet weak var tableView: UITableView!
    
    //CoreDatadan çekiyoruz.
    var data = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
   @IBAction func didRemoveBarButtonItemTapped(_ sender:UIBarButtonItem) {
           presentAlert(title: "Uyarı",
                        massage: "Listeyi Silmek İstedinize Emin Misiniz?",
                        defualtButtonTitle: "Evet",
                        cancelButtonTitle: "Hayır") { _ in
               
               let appDelegate = UIApplication.shared.delegate as? AppDelegate
               
               let managedObjectContext = appDelegate?.persistentContainer.viewContext
               
               for item in self.data {
                   managedObjectContext?.delete(item)
               }
               try? managedObjectContext?.save()
               self.fetch()
               
               //self.data.removeAll()
               //self.tableView.reloadData()
           }
       }
       
       @IBAction func didAddBarButtonItem (_ sender: UIBarButtonItem) {
           //Func - AddAlert
           presentAddAlert()
       }
       func presentAddAlert() {
           /*
            let alertController = UIAlertController(title: "Yeni Ekleme",
            message: nil,
            preferredStyle: .alert)
            
            let defaultButton = UIAlertAction(title: "Ekle",
            style: .default){ _ in
            
            let textController = alertController.textFields?.first?.text
            
            if textController != ""{
            self.data.append((textController)!)
            self.tableView.reloadData()
            }else {
            //Func - WarningAlert
            self.presentWarningAlert()
            }
            }
            let alertButton = UIAlertAction(title: "Vazgeç", style: .cancel)
            
            alertController.addTextField()
            alertController.addAction(defaultButton)
            alertController.addAction(alertButton)
            present(alertController, animated: true)
            */
           presentAlert(title:"Yeni Eleman Ekle ",
                        massage: nil,
                        defualtButtonTitle: "Ekle",
                        cancelButtonTitle: "Vazgeç",
                        isTextFieldAvailable: true,
                        defualtButtonHandler: { _ in
               let textController = self.alertController.textFields?.first?.text
               
               if textController != ""{
                   //self.data.append((textController)!)
                   
                   let appDelegate = UIApplication.shared.delegate as? AppDelegate
                   
                   let managedObjectContext = appDelegate?.persistentContainer.viewContext
                   
                   let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedObjectContext!)
                   let listItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                   
                   listItem.setValue(textController, forKey: "title")
                   
                   try? managedObjectContext?.save()
                   
                   self.fetch()
                   //self.tableView.reloadData() ----> Eski
               }else {
                   //Func - WarningAlert
                   self.presentWarningAlert()
               }
           } )
           
       }
    func presentWarningAlert() {
           let popHap = UIAlertController(title: "Hata!",
                                          message: "List'ye Boş Bir eleman Eklenemez.",
                                          preferredStyle: .alert)
           
           let alertButton = UIAlertAction(title: "Çıkış", style: .cancel)
           popHap.addAction(alertButton)
           present(popHap, animated: true)
       }
       // MARK: Func - Present Alert
       func presentAlert (title: String?,
                          massage:String?,
                          preferredStyle: UIAlertController.Style = .alert,
                          defualtButtonTitle: String? = nil,
                          cancelButtonTitle: String?,
                          isTextFieldAvailable: Bool = false,
                          defualtButtonHandler: ((UIAlertAction) -> Void)? = nil) {
           
           alertController = UIAlertController(title: title,
                                               message: massage,
                                               preferredStyle: preferredStyle)
           
           if defualtButtonTitle != nil {
               let defualtButton = UIAlertAction(title: defualtButtonTitle, style: .default, handler: defualtButtonHandler)
               
               alertController.addAction(defualtButton)
           }
           
           
           let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
           
           if isTextFieldAvailable {
               alertController.addTextField()
           }
           
           alertController.addAction(cancelButton)
           
           
           present(alertController, animated: true)
           
       }
       
       func fetch() {
           let appDelegate = UIApplication.shared.delegate as? AppDelegate
           let managedObjectContext = appDelegate?.persistentContainer.viewContext
           
           let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
           
           data = try! managedObjectContext!.fetch(fetchRequest)
           
           tableView.reloadData()
       }
       
       
       /*
        //MARK: Cancel Alert NOT USED
        func cancelDel() -> UIAlertAction {
        return UIAlertAction(title: "Vazgeç", style: .cancel)
        
        }
        */
       /*
        func alertController() -> UIAlertController {
        return UIAlertController(title: "Yeni Ekleme", message: nil, preferredStyle: .)
        }
        */
   }

   // MARK: Extension
   // Herhangi bir class türetmeden ona yeni özellikler eklememizi sağlıyor.
   extension ViewController: UITableViewDelegate, UITableViewDataSource {
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return data.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "defualtCell", for: indexPath)
           let listItem = data[indexPath.row]
           cell.textLabel?.text = listItem.value(forKey: "title") as? String
           return cell
       }
       
       func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           let deleteAction = UIContextualAction(style: .normal, title: "Sil") { _, _, _ in
           
               
               let appDelegate = UIApplication.shared.delegate as? AppDelegate
               let managedObjectContext = appDelegate?.persistentContainer.viewContext
               
               managedObjectContext?.delete(self.data[indexPath.row])
               
               try? managedObjectContext?.save()
               
               self.fetch()
               
           }
           
           deleteAction.backgroundColor = .systemRed
           let editAction = UIContextualAction(style: .normal, title: "Düzenle") { _, _, _ in
              
               self.presentAlert(title:"Elemanı Düzenle ",
                                 massage: nil,
                                 defualtButtonTitle: "Düzenle",
                                 cancelButtonTitle: "Vazgeç",
                                 isTextFieldAvailable: true,
                                 defualtButtonHandler: { _ in
                   let textController = self.alertController.textFields?.first?.text
                   
                   if textController != ""{
                      
                       
                       let appDelegate = UIApplication.shared.delegate as? AppDelegate
                       let managedObjectContext = appDelegate?.persistentContainer.viewContext
                       
                       self.data[indexPath.row].setValue(textController, forKey: "title")
                       
                       if managedObjectContext!.hasChanges {
                           try? managedObjectContext?.save()
                       }
                       
                       
                       
                       self.tableView.reloadData()
                   }else {
                       
                       self.presentWarningAlert()
                   }
               } )
           }
          
           let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
           return config
       }
   }
