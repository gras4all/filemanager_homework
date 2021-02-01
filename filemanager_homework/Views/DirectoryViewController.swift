//
//  DirectoryViewController.swift
//  filemanager_homework
//
//  Created by Андрей Груненков on 01.02.2021.
//

import UIKit

class DirectoryViewController: UIViewController {
    
    @IBOutlet weak var filesTableView: UITableView!
    
    let fileManager = FileManagerService()
    var rootDirectory: URL?
    var filesList: [(name: String, isDirectory: Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if rootDirectory == nil {
            rootDirectory = fileManager.getURL(for: .Documents)
        }
        reloadFilesList()
        self.setupViews()
        self.setupNavigationBar()
    }
    
    func openTextFieldAlert(title: String, placeholder: String, saveHandler: @escaping (String) -> Void ) {
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = placeholder
        }
        let saveAction = UIAlertAction(title: "Create", style: .default, handler: { alert -> Void in
            if let textField = alertController.textFields?[0] {
                if textField.text!.count > 0 {
                    print("Text :: \(textField.text ?? "")")
                    saveHandler(textField.text ?? "")
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        alertController.preferredAction = saveAction
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func reloadFilesList() {
        filesList = fileManager.listFiles(in: rootDirectory)
        filesTableView.reloadData()
    }
    
    @objc func addFolderTapped() {
        openTextFieldAlert(title: "Create folder", placeholder: "Create folder", saveHandler: { [weak self] text in
            guard let _self = self,
                  let root = _self.rootDirectory else { return }
            _self.fileManager.createFolder(to: root, withName: text)
            _self.reloadFilesList()
            print(text)
            
        })
    }
    
    @objc func addFileTapped() {
        openTextFieldAlert(title: "Create file", placeholder: "Create file", saveHandler: { [weak self] text in
            guard let _self = self,
                  let root = _self.rootDirectory else { return }
            _self.fileManager.writeFile(containing: "Hello world!", directory: root, withName: text)
            _self.reloadFilesList()
        })
    }

    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let fileItem = filesList[indexPath.row]
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            guard let _self = self,
                  let url = _self.rootDirectory else { return }
            _self.fileManager.deleteFile(at: url, withName: fileItem.name)
            _self.reloadFilesList()
        }
        return action
    }

}

extension DirectoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FileCell.self)) as! FileCell
        let fileItem = filesList[indexPath.row]
        if fileItem.isDirectory {
            cell.fileIcon.image = UIImage(named: "icDirectory")
            cell.directoryArrow.isHidden = false
        } else {
            cell.fileIcon.image = UIImage(named: "icFile")
            cell.directoryArrow.isHidden = true
        }
        cell.fileLabel.text = fileItem.name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileItem = filesList[indexPath.row]
        if fileItem.isDirectory {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let nextFilderVC = storyboard.instantiateViewController(withIdentifier: String(describing: DirectoryViewController.self)) as? DirectoryViewController {
                let newURL = rootDirectory?.appendingPathComponent(fileItem.name)
                nextFilderVC.rootDirectory = newURL
                self.navigationController?.pushViewController(nextFilderVC, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 69
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let swipeConfig = UISwipeActionsConfiguration(actions: [self.contextualDeleteAction(forRowAtIndexPath: indexPath)])
        return swipeConfig
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
}

private extension DirectoryViewController {
    
    func setupViews() {
        filesTableView.delegate = self
        filesTableView.dataSource = self
    }
    
    func setupNavigationBar() {
        let directory = rootDirectory
        self.title = directory?.pathComponents.last
        
        let addFolderItemView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let addFolderImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let addFolderTap = UITapGestureRecognizer(target: self, action: #selector(addFolderTapped))
        addFolderImageView.image = UIImage(named: "addDirectory")
        addFolderImageView.tintColor = self.view.tintColor
        addFolderItemView.addSubview(addFolderImageView)
        addFolderItemView.addGestureRecognizer(addFolderTap)
        let addFolderButtonItem = UIBarButtonItem(customView: addFolderItemView)
        
        let addFileItemView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let addFileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let addFileTap = UITapGestureRecognizer(target: self, action: #selector(addFileTapped))
        addFileImageView.image = UIImage(named: "addFile")
        addFileImageView.tintColor = self.view.tintColor
        addFileItemView.addSubview(addFileImageView)
        addFileItemView.addGestureRecognizer(addFileTap)
        let addFileButtonItem = UIBarButtonItem(customView: addFileItemView)
        
        navigationItem.rightBarButtonItems = [addFileButtonItem, addFolderButtonItem]
    }
    
}


