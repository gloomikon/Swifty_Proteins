import Foundation
import SwiftyJSON

enum AtomViewEvent {
    case viewDidLoad
    case saveAtom(atomSymol: String)
    case moreInfoWasTapped
}

enum AtomCommand {
    case configure(info: AtomInfo)
}

struct AtomInfo {
    let name: String
    let symbol: String
    let discovered_by: String
    let atomic_mass: String
    let electron_configuration: String
}

protocol AtomKitchenDelegate: class {
    func perform(_ command: AtomCommand)
}

class AtomKitchen {
    private weak var delegate: AtomKitchenDelegate?
    private var atomSymbol: String?
    private var source: String?

    init(delegate: AtomKitchenDelegate) {
        self.delegate = delegate
    }

    func receive(_ event: AtomViewEvent) {
        switch event {
        case .viewDidLoad:
            handleViewDidLoad()
        case .saveAtom(let atomSymbol):
            self.atomSymbol = atomSymbol
        case .moreInfoWasTapped:
            displayWikipedia()
        }
    }

    // MARK: Private

    private func handleViewDidLoad() {
        guard let path = Bundle.main.path(forResource: "PeriodicTableJSON", ofType: "json") else {
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let json = try JSON(data: data)
            guard let elements = json["elements"].array else {
                return
            }
            for element in elements {
                if element["symbol"].stringValue == atomSymbol {
                    let name = element["name"].stringValue
                    let symbol = element["symbol"].stringValue
                    let discovered_by = element["discovered_by"].stringValue
                    let atomic_mass = element["atomic_mass"].stringValue
                    let electron_configuration = element["electron_configuration"].stringValue
                    source = element["source"].stringValue
                    let atomInfo = AtomInfo(name: name, symbol: symbol, discovered_by: discovered_by, atomic_mass: atomic_mass, electron_configuration: electron_configuration)
                    delegate?.perform(.configure(info: atomInfo))
                    break
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    private func displayWikipedia() {
        guard let urlString = source, let url = URL(string: urlString) else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
