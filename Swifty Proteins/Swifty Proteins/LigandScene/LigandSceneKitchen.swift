import Alamofire

enum LigandSceneViewEvent {
	case viewDidLoad(ligandId: String)
}

enum LigandSceneCommand {
	case showAlert(title: String, message: String)
	case createAtom(atom: (x: Float, y: Float, z: Float))
	case connectAtoms(atom1: (x: Float, y: Float, z: Float), atom2: (x: Float, y: Float, z: Float))
}


protocol LigandSceneKitchenDelegate: class {
	func peform(_ command: LigandSceneCommand)
}

class LigandSceneKitchen {
	private enum Constant {
	}

	private weak var delegate: LigandSceneKitchenDelegate?

	init (delegate: LigandSceneKitchenDelegate) {
		self.delegate = delegate
	}

	func receive(_ event: LigandSceneViewEvent) {
		switch event {
		case .viewDidLoad(let ligandId):
			handleViewDidLoad(lidandId: ligandId)
		}
	}

	// MARK: Private

	private func handleViewDidLoad(lidandId: String) {
		let urlString = "https://files.rcsb.org/ligands/view/\(lidandId)_ideal.pdb"
		let url = URL(string: urlString)!
		UIApplication.shared.isNetworkActivityIndicatorVisible = true

		Alamofire.request(url).validate().responseData {
			responce in
			guard let data = responce.data, let utf8Text = String(data: data, encoding: .utf8) else {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				DispatchQueue.main.async {
//					self.delegate.perform(.showAlert(title: Constant.internetErrorTitle, message: Constant.internetErrorMessage))
				}
				return
			}

			let lines = utf8Text.split(separator: "\n").map { $0.split(separator: " ") }
			var atoms = [(Float, Float, Float)]()
			for line in lines {
				switch line[0] {
				case "ATOM":
					guard let x = Float(line[6]), let y = Float(line[7]), let z = Float(line[8]) else {
						return
					}
					let atom = (x, y, z)
					atoms.append(atom)
					self.delegate?.peform(.createAtom(atom: atom))
				case "CONECT":
					guard let startIndex = Int(line[1]) else {
						return
					}
					for i in 2 ..< line.count {
						if let endIndex = Int(line[i]), startIndex < endIndex {
							self.delegate?.peform(.connectAtoms(atom1: atoms[startIndex - 1], atom2: atoms[endIndex - 1]))
						}
					}
				default:
					break
				}
			}
		}
	}
}

