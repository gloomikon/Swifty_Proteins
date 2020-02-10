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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layer.frame = view.bounds
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension ProteinsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProteins.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.reusableCellIdentifier) as! ProteinsCell
        cell.proteinName = filteredProteins[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        kitchen.receive(.ligandCellTapped(ligandName: filteredProteins[indexPath.row]))
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
            // TODO
            break
        case .showAlert(let title, let message):
            displayAlert(title: title, message: message)
        }
    }


}
