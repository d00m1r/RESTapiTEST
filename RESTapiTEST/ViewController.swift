//
//  ViewController.swift
//  RESTapiTEST
//
//  Created by Damasya on 2/8/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var isFirst = true
    private var token: String = ""
    private var filesData: DiskResponse?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirst{
            updateData()
        }
        isFirst = false
    }
    private func setupViews(){
        view.backgroundColor = .white
        title = "My photos"
        tableView.backgroundColor = .black
        
        tableView.register(FileTableViewCell.self, forCellReuseIdentifier: fileCellIdentifier)
        tableView.dataSource = self
        //        tableView.translatesAutoresizingMaskIntoConstraints = false
        //        view.addSubview(tableView)
        //        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        //        tableView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -10).isActive = true
        //        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        //        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
    }
    
//    @IBSegueAction func segueTo(_ coder: NSCoder) -> AuthViewController? {
//        return AuthViewController(coder: coder)
//    }
    func updateData(){
        guard !token.isEmpty else {
            let requestTokenViewController = AuthViewController()
            requestTokenViewController.delegate = self
            present(requestTokenViewController, animated: false, completion: nil)
            return
        }
        var components = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/resources/files")
        components?.queryItems = [URLQueryItem(name: "media_type", value: "image")]
        guard let url = components?.url else {return}
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request){
            [weak self] (data, response, error) in
            guard let sself = self, let data = data else {return}
            guard let newFiles = try? JSONDecoder().decode(DiskResponse.self, from: data) else {return}
            print("Received: \(newFiles.items?.count ?? 0) files")
            sself.filesData = newFiles
            
            DispatchQueue.main.async {
                [weak self] in self?.tableView.reloadData()
            }
        }
        task.resume()
    }
}

private let fileCellIdentifier = "FileTableViewCell"

extension ViewController: AuthViewControllerDelegate {
    func handleTokenChanged(token: String) {
        self.token = token
        print("hello there")
        print("New token \(token)")
        updateData()
    }
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesData?.items?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: fileCellIdentifier, for: indexPath)
        
        guard let items = filesData?.items, items.count > indexPath.row else { return cell }
        let currentFile = items[indexPath.row]
        if let fileCell = cell as? FileTableViewCell {
            fileCell.delegate = self
            fileCell.bindModel(currentFile)
        }
        return cell
    }
}

extension ViewController: FileTableViewCellDelegate{
    func loadImage(stringUrl: String, completion: @escaping ((UIImage?) -> Void)) {
        guard let url = URL(string: stringUrl) else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {return}
            DispatchQueue.main.async {
                completion(UIImage(data: data))
            }
        }
        task.resume()
    }
    
    
}

