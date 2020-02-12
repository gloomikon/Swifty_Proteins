import UIKit
import Alamofire
import SwiftSoup

class ProteinsListViewController: UIViewController {
    private enum Constant {
        static let reusableCellIdentifier = "ProteinsCell"
        static let searchProteinsPlaceholder = "Search for proteins"
    }

    // MARK: IBOutlet

    @IBOutlet private weak var proteinsTableView: UITableView! {
        didSet {
            proteinsTableView.delegate = self
            proteinsTableView.dataSource = self
            proteinsTableView.keyboardDismissMode = .onDrag
        }
    }
    
    @IBOutlet private weak var searchInput: UISearchBar! {
        didSet {
            searchInput.placeholder = Constant.searchProteinsPlaceholder
            searchInput.delegate = self
            searchInput.searchTextField.textColor = .white
        }
    }

    // MARK: Private properties

    private var proteins = [String]()
    private var filteredProteins = [String]()
    private let layer = CAGradientLayer()
    private var ligandData: LigandData?
    private lazy var kitchen = ProteinsListKitchen(delegate: self)

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add gradient
        layer.frame = view.bounds
        layer.colors = [UIColor.sakuraTree.cgColor, UIColor.clearSky.cgColor]
        view.layer.insertSublayer(layer, at: 0)

        kitchen.receive(.viewDidLoad)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layer.frame = view.bounds
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is LigandDataViewController {
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "List of proteins", style: .plain, target: nil, action: nil)
            let vc = segue.destination as? LigandDataViewController
            vc?.ligandData = ligandData
        }
    }

    // MARK: Private functions

    private func handleRouteToLigandData(with data: LigandData) {
        ligandData = data
        performSegue(withIdentifier: "routeToLigandDataViewController", sender: nil)
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension ProteinsListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredProteins.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reusableCellIdentifier) as! ProteinsCell
        cell.proteinName = filteredProteins[indexPath.section]
        cell.layer.cornerRadius = 20
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        kitchen.receive(.ligandCellTapped(ligandId: filteredProteins[indexPath.section]))
    }
}

// MARK: UISearchBarDelegate

extension ProteinsListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let search = searchBar.text else {
            return
        }
        filteredProteins = search.isEmpty ? proteins : proteins.filter({$0.contains(search)})
        proteinsTableView.reloadData()
    }
}

// MARK: ProteinsListKitchenDelegate

extension ProteinsListViewController: ProteinsListKitchenDelegate {
    func perform(_ command: ProteinsListCommand) {
        switch command {
        case .configure(let proteins):
            self.proteins = proteins
            self.filteredProteins = proteins
            proteinsTableView.reloadData()
        case .routeToLigandDetailViewController(let ligand):
            handleRouteToLigandData(with: ligand)
        case .showAlert(let title, let message):
            displayAlert(title: title, message: message)
        }
    }
}
