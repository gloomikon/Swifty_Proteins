import Alamofire
import SwiftSoup

enum ProteinsListViewEvent {
    case viewDidLoad
    case ligandCellTapped(ligandId: String)
}

enum ProteinsListCommand {
    case routeToLigandDetailViewController(with: LigandData)
    case showAlert(title: String, message: String)
    case configure(with: [String])
}

protocol ProteinsListKitchenDelegate: class {
    func perform(_ command: ProteinsListCommand)
}

class ProteinsListKitchen {
    private enum Constant {
        static let fileNotFoundTitle = "File not found"
        static let fileNotFoundMessage = "File \"ligands.txt\" containing proteins list was not found."
        static let internetErrorTitle = "Error"
        static let internetErrorMessage = "An error ocurred while loading data. Check your internet connection and try again."
        static let ligandInfoURL = "http://www.rcsb.org/ligand/"
    }

	private weak var delegate: ProteinsListKitchenDelegate?

    init(delegate: ProteinsListKitchenDelegate) {
        self.delegate = delegate
    }

    func receive(_ event: ProteinsListViewEvent) {
        switch event {
        case .viewDidLoad:
            handleViewDidLoad()
        case .ligandCellTapped(let ligandId):
            loadLigandDetails(ligandId: ligandId)
        }
    }

    // MARK: Private

    private func handleViewDidLoad() {
        let path = Bundle.main.path(forResource: "ligands", ofType: "txt")
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: path!) else {
			delegate?.perform(.showAlert(title: Constant.fileNotFoundTitle, message: Constant.fileNotFoundMessage))
            return
        }
        do {
            let content = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            let proteins = (content.components(separatedBy: "\n") as [String]).filter({ !$0.isEmpty })
			delegate?.perform(.configure(with: proteins))
        }
        catch let error as NSError {
            print(error.debugDescription)
        }
    }

    private func loadLigandDetails(ligandId: String) {
        let urlString = Constant.ligandInfoURL + ligandId
        let url = URL(string: urlString)!
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(url).validate().responseData {
            responce in
            guard let data = responce.data, let utf8Text = String(data: data, encoding: .utf8) else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                DispatchQueue.main.async {
					self.delegate?.perform(.showAlert(title: Constant.internetErrorTitle, message: Constant.internetErrorMessage))
                }
                return
            }
            do {
                let doc = try SwiftSoup.parse(utf8Text)
                guard
                    let name = try doc.getElementById("chemicalName")?.select("td").first()?.text(),
                    let identifiers = try doc.getElementById("chemicalIdentifiers")?.select("td").first()?.text(),
                    let formula = try doc.getElementById("chemicalFormula")?.select("td").first()?.text(),
                    let molecularWeight = try doc.getElementById("chemicalMolecularWeight")?.select("td").first()?.text(),
                    let type = try doc.getElementById("chemicalType")?.select("td").first()?.text(),
                    let isomericSMILES = try doc.getElementById("chemicalIsomeric")?.select("td").first()?.text(),
                    let inChI = try doc.getElementById("chemicalInChI")?.select("td").first()?.text(),
                    let inChIKey = try doc.getElementById("chemicalInChIKey")?.select("td").first()?.text(),
                    let image = try doc.getElementById("ligandStaticImage")?.select("a").first()?.attr("href")
                else {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    DispatchQueue.main.async {
						self.delegate?.perform(.showAlert(title: Constant.internetErrorTitle, message: Constant.internetErrorMessage))
                    }
                    return
                }

                let ligand = LigandData(url: urlString,
                                        id: ligandId,
                                        name: name,
                                        identifiers: identifiers,
                                        formula: formula.replacingOccurrences(of: " ", with: ""),
                                        molecularWeight: molecularWeight,
                                        type: type,
                                        isomericSMILES: isomericSMILES,
                                        inChI: inChI,
                                        inChIKey: inChIKey,
                                        image: "https:" + image)
                DispatchQueue.main.async {
					self.delegate?.perform(.routeToLigandDetailViewController(with: ligand))
                }
            }
            catch {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
