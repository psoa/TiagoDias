//
//  AjustesTableViewController.swift
//  TiagoDias
//
//  Created by Tiago Novaes Dias on 29/04/18.
//  Copyright © 2018 Tiago Novaes Dias. All rights reserved.
//

import UIKit
import CoreData

enum EstadoEditMode {
    case add
    case update
}

class AjustesViewController: UIViewController {

    
    @IBOutlet weak var ajustesTableView: UITableView!
    @IBOutlet weak var tfCotacao: UITextField!
    @IBOutlet weak var tfIOF: UITextField!
    
    
    
    // MARK: - Properties
    
    var dataSource: [Estado] = []
    
    
    func loadEstados() {
        let fetchRequest: NSFetchRequest<Estado> = Estado.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "nome", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
            ajustesTableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadDefaultSettings() {
        tfCotacao.text = String(UserDefaults.standard.double(forKey: "cotacao"))
        tfIOF.text = String(UserDefaults.standard.double(forKey: "IOF"))
    }
    
    func saveDefaultSettings() {
        
        if let cotacao = tfCotacao.text?.doubleValue, cotacao > 0 {
            UserDefaults.standard.set(cotacao, forKey: "cotacao")
        }
        
        if let iof = tfIOF.text?.doubleValue, iof >  0 {
            UserDefaults.standard.set(iof, forKey: "IOF")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "refresh"), object: nil, queue: nil, using: {(notification) in
            self.loadDefaultSettings()
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadEstados()
        loadDefaultSettings()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveDefaultSettings()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return(true)
    }
    
    @objc func done() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func showAlert(type: EstadoEditMode, estado: Estado?) {
        let title = (type == .add) ? "Adicionar" : "Editar"
        let alert = UIAlertController(title: "\(title) Estado", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Nome do estado"
            if let nome = estado?.nome {
                textField.text = nome
            }
        }
        alert.addTextField { (textField: UITextField) in
            textField.placeholder = "Imposto"
            if let imposto = estado?.imposto {
                textField.text = String(imposto)
            }
        }
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action: UIAlertAction) in
            
            if let imposto = alert.textFields?.last?.text?.doubleValue,
                let nome = alert.textFields?.first?.text,
                !nome.isEmpty
            {
                let estado = estado ?? Estado(context: self.context)
                estado.nome = nome
                estado.imposto = imposto
                do {
                    try self.context.save()
                    self.loadEstados()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func add(_ sender: UIButton) {
        showAlert(type: .add, estado: nil)
    }
    
}


extension AjustesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Excluir") { (action: UITableViewRowAction, indexPath: IndexPath) in
            let estado = self.dataSource[indexPath.row]
            self.context.delete(estado)
            do {
                try self.context.save()
                self.dataSource.remove(at: indexPath.row)
                self.ajustesTableView.deleteRows(at: [indexPath], with: .fade)

            } catch {
                print(error.localizedDescription)
            }
        }

        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let estado = self.dataSource[indexPath.row]
        
        showAlert(type: .update, estado: estado)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension AjustesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "estadoCell", for: indexPath) as! AjustesTableViewCell
        let estado = dataSource[indexPath.row]
        cell.lbEstado.text = estado.nome
        cell.lbImposto.text = String(estado.imposto)
        return cell
    }
}

extension AjustesViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        ajustesTableView.reloadData()
    }
}
