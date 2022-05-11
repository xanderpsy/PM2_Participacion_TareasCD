//
//  ViewController.swift
//  TareasCD
//
//  Created by Alexander Tapia on 10/05/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tablaTareas: UITableView!
    var listaTarea = [Tarea]()
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaTareas.delegate = self
        tablaTareas.dataSource = self
        leer()
    }

    
    @IBAction func btnagregarTarea(_ sender: UIBarButtonItem) {
        
        var titulo = UITextField()
        let alerta = UIAlertController(title: "agregar", message: "Tarea", preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "aceptar", style: .default) { _ in
            //Crear una nueva tarea
            let nuevatarea = Tarea(context:self.contexto)
            nuevatarea.titulo = titulo.text
            nuevatarea.realizada = false
            //agregar esa nueva tarea de lista tarea para llenar la tabla
            self.listaTarea.append(nuevatarea)
            self.guardar()
        }
        
        alerta.addTextField { textFieldAlerta in
            textFieldAlerta.placeholder = "Escribe algo aqui"
            titulo = textFieldAlerta
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }
    
    func guardar(){
        do{
            try contexto.save()
        }catch{
            print("error al guardar en core data\(error.localizedDescription)")
        }
        self.tablaTareas.reloadData()
    }
    
    func leer(){
        let solicitud : NSFetchRequest<Tarea> = Tarea.fetchRequest()
        
        do{
            listaTarea = try contexto.fetch(solicitud)
        }catch{
            print("error\(error.localizedDescription)")
        }
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaTarea.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tablaTareas.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        
        let tarea = listaTarea[indexPath.row]
        celda.textLabel?.text = tarea.titulo
        celda.textLabel?.textColor = tarea.realizada ? .black : .blue
        celda.detailTextLabel?.text = tarea.realizada ? "completada?" : "Por completar"
        celda.accessoryType = tarea.realizada ? .checkmark : .none
        
        return celda
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tablaTareas.cellForRow(at: indexPath)?.accessoryType == .checkmark{
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .none
        }else{
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        listaTarea[indexPath.row].realizada = !listaTarea[indexPath.row].realizada
        guardar()
        tablaTareas.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accionEliminar = UIContextualAction(style: .normal, title: "borrar") { _, _, _ in
            self.contexto.delete(self.listaTarea[indexPath.row])
            self.listaTarea.remove(at: indexPath.row)
            self.guardar()
        }
        accionEliminar.image = UIImage(systemName: "trash")
        accionEliminar.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [accionEliminar])
    }
    
}

