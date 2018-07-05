//
//  ListViewController.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/3/18.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ListViewController.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    var viewModel = ListViewModel(with:UserLocationService.shared, and: DataProvider(with: SessionManager())) {
        didSet {
            updateUI()
        }
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.viewModel.refreshViewModel()
    }

    
    func updateUI() {
        viewModel.cells.bindAndFire { [weak self] in
            print($0)
            self?.tableView.reloadData()
        }
        viewModel.refreshing.bindAndFire {[weak self] in
            if $0 == true {
                self?.refreshControl.beginRefreshing()
            } else {
                self?.refreshControl.endRefreshing()
            }
        }
        viewModel.errorMessage.bindAndFire { [weak self] in
            if !$0.isEmpty {
            let alert = UIAlertController(title: "Error", message: $0, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
            }
        }
        self.viewModel.refreshViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.addSubview(self.refreshControl)
        updateUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presentDetailsForCelWithIndex(withIndex: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.presentDetailsForCelWithIndex(withIndex: indexPath.row)
    }
    
    func presentDetailsForCelWithIndex(withIndex index: Int) {
        guard let annotation = self.viewModel.provideAnnotationForCellBy(index: index) else {
            return
        }
        
        let vm = DetailViewModel(with: self.viewModel.locationService, self.viewModel.dataProvider, true, annotation)
        let controller = DetailViewController.detailViewController(withViewModel: vm)
        self.present(controller, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
        
        self.viewModel.cells.value[indexPath.row].name.bindAndFire { string in
            cell.nameLabel.text = string
        }
        
        self.viewModel.cells.value[indexPath.row].lat.bindAndFire { string in
            cell.latLabel.text = string
        }
        self.viewModel.cells.value[indexPath.row].lon.bindAndFire {  string in
            cell.lonLabel.text = string
        }
        self.viewModel.cells.value[indexPath.row].distance.bindAndFire { string in
            cell.distanceLabel.text = string
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cells.value.count
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
