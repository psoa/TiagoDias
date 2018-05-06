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
    var ajusteImagem: Bool = false
    
    // MARK:  Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        createEstadosPicker()
        createValorPad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadEstados()
        loadCompra()

    }

    // MARK:  Methods

    func loadEstados() {
        let fetchRequest: NSFetchRequest<Estado> = Estado.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "nome", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            estadoDataSource = try context.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createEstadosPicker() {
        estadoPickerView = UIPickerView() //Instanciando o UIPickerView
        estadoPickerView.backgroundColor = .white
        estadoPickerView.delegate = self  //Definindo seu delegate
        estadoPickerView.dataSource = self  //Definindo seu dataSource
        
        //Criando uma toobar que servirá de apoio ao pickerView. Através dela, o usuário poderá
        //confirmar sua seleção ou cancelar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        //
        //
        //O botão abaixo servirá para o usuário cancelar a escolha de gênero, chamando o método cancel
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //
        //
        //O botão done confirmará a escolha do usuário, chamando o método done.
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        //Definindo a toolbar como view de apoio do textField (view que fica acima do teclado)
        tfEstado.inputAccessoryView = toolbar
        
        //Aqui definimos que o pickerView será usado como entrada do extField
        tfEstado.inputView = estadoPickerView
    }
    
    func createValorPad() {
        let decimalPadToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        let btFlexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneClicked))
        decimalPadToolbar.items = [btFlexSpace, btDone]
        tfValor.delegate = self
        tfValor.inputAccessoryView = decimalPadToolbar
    }
    
    //O método cancel irá esconder o teclado e não irá atribuir a seleção ao textField
    @objc func cancel() {
        estadoPickerResign()
    }
    
    //O método done irá atribuir ao textField a escolhe feita no pickerView
    @objc func done() {
        let pickerIndex = estadoPickerView.selectedRow(inComponent: 0)
        
        if  pickerIndex > -1 && !estadoDataSource.isEmpty {
            tfEstado.text = estadoDataSource[pickerIndex].nome
        }
        estadoPickerResign()
    }
    
    func estadoPickerResign() {
        tfEstado.resignFirstResponder()
    }
    
    func loadCompra() {
        if compra != nil {
            tfNome.text = compra.nome
            tfValor.text = String(compra.valor)
            
            if let estado = compra.estado, let index = estadoDataSource.index(of: estado) {
                tfEstado.text = compra.estado?.nome
                estadoPickerView.selectRow(index, inComponent: 0, animated: false)
            }
            swCartao.setOn(compra.cartao, animated: false)
            
            if ajusteImagem == true {
                ajusteImagem = false
            } else {
                if let image = compra.poster as? UIImage {
                    ivPoster.image = image
                } else {
                    ivPoster.image = UIImage(named: "red-shopping-bag-md")
                }
            }
            
            btAddUpdate.setTitle("ATUALIZAR", for: .normal)
        }
    }
    
    func selectPicture(sourceType: UIImagePickerControllerSourceType) {

        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction func addPoster(_ sender: UIButton) {
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
    func campoObrigatorioAlert(missing info: String) {
        //Criando o alerta que será apresentado ao usuário
        let alert = UIAlertController(title: "Campo obrigatório"
            , message: "Preencha a informação faltante ou inválida"
            , preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: info, style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func validateNome() -> Bool {
        if let nome = tfNome.text, !nome.isEmpty {
            return true
        }
        return false
    }

    func validateValor() -> Bool {
        if let valor = tfValor.text?.doubleValue, valor > 0 {
            return true
        }
        return false
    }
    
    func validateEstado () -> Bool {
        if  let strEstado = tfEstado.text, !strEstado.isEmpty {
            return true
        }
        return false
    }
    
    @IBAction func addUpdateCompras(_ sender: UIButton) {

        if !validateNome() {
            campoObrigatorioAlert(missing: "Nome do produto")
            return
        }
        
        if !validateValor() {
            campoObrigatorioAlert(missing: "Valor do produto")
            return
        }
        
        if !validateEstado () {
            campoObrigatorioAlert(missing: "Estado")
            return
        }
        
        if compra == nil {
            compra = Compra(context: context)
        }
        compra.valor = tfValor.text!.doubleValue!
        compra.nome = tfNome.text
        compra.estado = estadoDataSource[estadoPickerView.selectedRow(inComponent: 0)]
        compra.poster = ivPoster.image //Já possui um valor padrão
        compra.cartao = swCartao.isOn //Já possui um valor padrão
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
        navigationController?.popViewController(animated: true)
     }
    
}

// MARK: - UIImagePickerControllerDelegate
extension CompraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            //Iremos usar o código abaixo para criar uma versão reduzida da imagem escolhida pelo usuário
            let smallSize = CGSize(width: 300, height: 280)
            UIGraphicsBeginImageContext(smallSize)
            image.draw(in: CGRect(x: 0, y: 0, width: smallSize.width, height: smallSize.height))
            
            //Atribuímos a versão reduzida da imagem à variável smallImage
            smallImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            ivPoster.image = smallImage //Atribuindo a imagem à ivPoster
            ajusteImagem = true
        }
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

extension CompraViewController: UITextFieldDelegate {
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
}
