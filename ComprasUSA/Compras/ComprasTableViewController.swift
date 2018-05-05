//
//  ComprasTableViewController.swift
//  TiagoDias
//
//  Created by Tiago Novaes Dias on 29/04/18.
//  Copyright © 2018 Tiago Novaes Dias. All rights reserved.
//

import UIKit
import CoreData

class ComprasTableViewController: UITableViewController {

    
    var dataSource: [Compra] = []
    var lbListaComprasVazia = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 22))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 106
        tableView.rowHeight = UITableViewAutomaticDimension
        lbListaComprasVazia.text = "Sua lista está vazia!"
        lbListaComprasVazia.textAlignment = .center
        //loadCompras()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCompras()
        //tableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! == "editarCompraSegue" {
            let viewController = segue.destination as! CompraViewController
            viewController.compra = dataSource[tableView.indexPathForSelectedRow!.row]
        }
    }
    
    func loadCompras() {

        let fetchRequest: NSFetchRequest<Compra> = Compra.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "nome", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            dataSource = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "compraCell", for: indexPath) as! ComprasTableViewCell
        let compra = dataSource[indexPath.row]
        cell.prepare(with: compra)
        return cell
    }
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = dataSource.count
        
        tableView.backgroundView = count == 0 ? lbListaComprasVazia : nil
        
        return count
    }
}

extension ComprasTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

