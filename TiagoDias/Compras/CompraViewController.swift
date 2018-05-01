//
//  ProdutoViewController.swift
//  TiagoDias
//
//  Created by Tiago Novaes Dias on 29/04/18.
//  Copyright © 2018 Tiago Novaes Dias. All rights reserved.
//

import UIKit
import CoreData

class CompraViewController: UIViewController {

    
    
    @IBOutlet weak var tfNome: UITextField!
    @IBOutlet weak var tfEstado: UITextField!
    @IBOutlet weak var tfValor: UITextField!
    @IBOutlet weak var swCartao: UISwitch!
    @IBOutlet weak var ivPoster: UIImageView!
    @IBOutlet weak var btAddUpdate: UIButton!
    
 
    //MARK: - Propertiers
    var compra: Compra!
    var smallImage: UIImage!
    var estadoPickerView: UIPickerView!
    
    
    var estadoDataSource: [Estado] = []
    // MARK:  Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadEstados()
        createEstadosPicker()
    }

    // MARK:  Methods
    
    func createEstadosPicker() {
        estadoPickerView = UIPickerView() //Instanciando o UIPickerView
        estadoPickerView.backgroundColor = .white
        estadoPickerView.delegate = self  //Definindo seu delegate
        estadoPickerView.dataSource = self  //Definindo seu dataSource
        
        //        //Criando uma toobar que servirá de apoio ao pickerView. Através dela, o usuário poderá
        //        //confirmar sua seleção ou cancelar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        //
        //        //O botão abaixo servirá para o usuário cancelar a escolha de gênero, chamando o método cancel
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //
        //        //O botão done confirmará a escolha do usuário, chamando o método done.
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        //Definindo a toolbar como view de apoio do textField (view que fica acima do teclado)
        tfEstado.inputAccessoryView = toolbar
        
        //Aqui definimos que o pickerView será usado como entrada do extField
        tfEstado.inputView = estadoPickerView
    }
    
    
    
    //O método cancel irá esconder o teclado e não irá atribuir a seleção ao textField
    @objc func cancel() {
        
        //O método resignFirstResponder() faz com que o campo deixe de ter o foco, fazendo assim
        //com que o teclado (pickerView) desapareça da tela
        estadoPickerResign()
    }
    
    //O método done irá atribuir ao textField a escolhe feita no pickerView
    @objc func done() {
        
        //Abaixo, recuperamos a linha selecionada na coluna (component) 0 (temos apenas um component
        //em nosso pickerView)
        tfEstado.text = estadoDataSource[estadoPickerView.selectedRow(inComponent: 0)].nome

        //Agora, gravamos esta escolha no UserDefaults
        UserDefaults.standard.set(tfEstado.text!, forKey: "estado")
        estadoPickerResign()
    }
    
    func estadoPickerResign() {
        tfEstado.resignFirstResponder()
    }
    
    func loadCompra() {
        if compra != nil {
            tfNome.text = compra.nome
            //            tfEstado.text = compra.estado
            tfValor.text = "(compra.valor)"
            swCartao.isOn = compra.cartao
            btAddUpdate.setTitle("Atualizar", for: .normal)
            if let image = compra.poster as? UIImage {
                ivPoster.image = image
            }
        }
    }
    
    func loadEstados() {
        let fetchRequest: NSFetchRequest<Estado> = Estado.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "nome", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            estadoDataSource = try context.fetch(fetchRequest)
            //estadosTableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {
        //Criando o objeto UIImagePickerController
        let imagePicker = UIImagePickerController()
        
        //Definimos seu sourceType através do parâmetro passado
        imagePicker.sourceType = sourceType
        
        //Definimos a MovieRegisterViewController como sendo a delegate do imagePicker
        imagePicker.delegate = self
        
        //Apresentamos a imagePicker ao usuário
        present(imagePicker, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: - IBActions
    @IBAction func addPoster(_ sender: UIButton) {
        //Criando o alerta que será apresentado ao usuário
        let alert = UIAlertController(title: "Selecionar imagem", message: "De onde você quer escolher a imagem?", preferredStyle: .actionSheet)
        
        //Verificamos se o device possui câmera. Se sim, adicionamos a devida UIAlertAction
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default, handler: { (action: UIAlertAction) in
                self.selectPicture(sourceType: .camera)
            })
            alert.addAction(cameraAction)
        }

        //As UIAlertActions de Biblioteca de fotos e Álbum de fotos também são criadas e adicionadas
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)

        let photosAction = UIAlertAction(title: "Álbum de fotos", style: .default) { (action: UIAlertAction) in
            self.selectPicture(sourceType: .savedPhotosAlbum)
        }
        alert.addAction(photosAction)

        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)

        
    }
    
    @IBAction func addUpdateCompras(_ sender: UIButton) {
        if compra == nil {
            compra = Compra(context: context)
        }
        
        if let nome = tfNome.text, let valor = tfValor.text, let estado = tfEstado.text  {
            compra.nome  = nome
            //compra.valor = Decimal(valor)!
            //compra.estado = estado
            compra.poster = ivPoster.image
            compra.cartao = swCartao.isOn
        } else {
            //exibir alerta indicando que todos os campos sao obrigatorios
        }
     }
}

// MARK: - UIImagePickerControllerDelegate
extension CompraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //O método abaixo nos trará a imagem selecionada pelo usuário em seu tamanho original
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        
        //Iremos usar o código abaixo para criar uma versão reduzida da imagem escolhida pelo usuário
        let smallSize = CGSize(width: 300, height: 280)
        UIGraphicsBeginImageContext(smallSize)
        image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
        
        //Atribuímos a versão reduzida da imagem à variável smallImage
        smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivPoster.image = smallImage //Atribuindo a imagem à ivPoster
        
        //Aqui efetuamos o dismiss na UIImagePickerController, para retornar à tela anterior
        dismiss(animated: true, completion: nil)
    }
}


extension CompraViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return estadoDataSource[row].nome
    }
}

extension CompraViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return estadoDataSource.count
    }
}
