//
//  NewConvertationViewController.swift
//  Messenger
//
//  Created by Apple on 02.08.1444 (AH).
//

import UIKit
import JGProgressHUD

class NewConvertationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users = [[String: String]]()
    
    public var completion: (([String: String]) -> (Void))?
    
    private var results = [[String: String]]()
    
    private var hasFetch: Bool = false
    
    private let searchBar: UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.placeholder = "Search for User"
        return searchBar
    }()
    
    private let tableView: UITableView = {
       let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultLabel: UILabel = {
       let label = UILabel()
        label.text = "No Results"
        label.isHidden = true
        label.tintColor = .gray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        title = "Create a new chat"
        setUPTable()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.width/4, y: (view.height - 200)/2, width: view.width/2, height: 200)
    }
    
    private func setUPTable() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        view.addSubview(noResultLabel)
      }
    
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
    
    
 }


// MARK: - Table View stuffs
extension NewConvertationViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // start conversation
        let targerUserData = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(targerUserData)
            
        }
        
    }
    
}

// MARK: - Searchbar Delegate
extension NewConvertationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view)
        self.searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        // check if array has firebase results
        if hasFetch {
            // if it does filter
           filterUsers(with: query)
        } else {
            DatabaseManager.shared.getAllUsers {[weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetch = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get result from Databse \(error)")
                }
            }
            // if it not fetch then filter
        }
    }
   func filterUsers(with term: String) {
       // update the UI: either show results or no results
       guard hasFetch else {
           return
       }
       let results: [[String: String]] = self.users.filter {
           guard let name = $0["name"]?.lowercased() else {
               return false
           }
           return name.hasPrefix(term.lowercased())
       }
       self.results = results
       updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            noResultLabel.isHidden = false
            tableView.isHidden = true
            self.spinner.dismiss()
        } else {
            noResultLabel.isHidden = true
            tableView.isHidden = false
            self.spinner.dismiss()
            tableView.reloadData()
        }
    }
}
