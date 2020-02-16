import Alamofire

enum LigandSceneViewEvent {
	case viewDidLoad(ligandId: String)
}

enum LigandSceneCommand {
	case showAlert(title: String, message: String)
    case createAtom(atom: Atom, hiddable: Bool)
	case createConnection(atom1: Atom, atom2: Atom, hiddable: Bool)
}

struct Atom {
    let x: Float
    let y: Float
    let z: Float
    let label: String
    let color: UIColor
    let name: String
}

protocol LigandSceneKitchenDelegate: class {
	func peform(_ command: LigandSceneCommand)
}

class LigandSceneKitchen {
	private weak var delegate: LigandSceneKitchenDelegate?

	init(delegate: LigandSceneKitchenDelegate) {
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
				return
			}

			let lines = utf8Text.split(separator: "\n").map { $0.split(separator: " ") }
			var atoms = [Atom]()
			for line in lines {
				switch line[0] {
				case "ATOM":
					guard let x = Float(line[6]), let y = Float(line[7]), let z = Float(line[8]) else {
						return
					}
                    let label = String(line[2])
                    let name = String(line[11])
                    let color: UIColor
                    switch name {
                    case "H":
                        color = UIColor.Atom.H
                    case "He":
                        color = UIColor.Atom.He
                    case "Li":
                        color = UIColor.Atom.Li
                    case "Be":
                        color = UIColor.Atom.Be
                    case "B":
                        color = UIColor.Atom.B
                    case "C":
                        color = UIColor.Atom.C
                    case "N":
                        color = UIColor.Atom.N
                    case "O":
                        color = UIColor.Atom.O
                    case "F":
                        color = UIColor.Atom.F
                    case "Ne":
                        color = UIColor.Atom.Ne
                    case "Na":
                        color = UIColor.Atom.Na
                    case "Mg":
                        color = UIColor.Atom.Mg
                    case "Al":
                        color = UIColor.Atom.Al
                    case "Si":
                        color = UIColor.Atom.Si
                    case "P":
                        color = UIColor.Atom.P
                    case "S":
                        color = UIColor.Atom.S
                    case "Cl":
                        color = UIColor.Atom.Cl
                    case "Ar":
                        color = UIColor.Atom.Ar
                    case "K":
                        color = UIColor.Atom.K
                    case "Ca":
                        color = UIColor.Atom.Ca
                    case "Sc":
                        color = UIColor.Atom.Sc
                    case "Ti":
                        color = UIColor.Atom.Ti
                    case "V":
                        color = UIColor.Atom.V
                    case "Cr":
                        color = UIColor.Atom.Cr
                    case "Mn":
                        color = UIColor.Atom.Mn
                    case "Fe":
                        color = UIColor.Atom.Fe
                    case "Co":
                        color = UIColor.Atom.Co
                    case "Ni":
                        color = UIColor.Atom.Ni
                    case "Cu":
                        color = UIColor.Atom.Cu
                    case "Zn":
                        color = UIColor.Atom.Zn
                    case "Ga":
                        color = UIColor.Atom.Ga
                    case "Ge":
                        color = UIColor.Atom.Ge
                    case "As":
                        color = UIColor.Atom.As
                    case "Se":
                        color = UIColor.Atom.Se
                    case "Br":
                        color = UIColor.Atom.Br
                    case "Kr":
                        color = UIColor.Atom.Kr
                    case "Rb":
                        color = UIColor.Atom.Rb
                    case "Sr":
                        color = UIColor.Atom.Sr
                    case "Y":
                        color = UIColor.Atom.Y
                    case "Zr":
                        color = UIColor.Atom.Zr
                    case "Nb":
                        color = UIColor.Atom.Nb
                    case "Mo":
                        color = UIColor.Atom.Mo
                    case "Tc":
                        color = UIColor.Atom.Tc
                    case "Ru":
                        color = UIColor.Atom.Ru
                    case "Rh":
                        color = UIColor.Atom.Rh
                    case "Pd":
                        color = UIColor.Atom.Pd
                    case "Ag":
                        color = UIColor.Atom.Ag
                    case "Cd":
                        color = UIColor.Atom.Cd
                    case "In":
                        color = UIColor.Atom.In
                    case "Sn":
                        color = UIColor.Atom.Sn
                    case "Sb":
                        color = UIColor.Atom.Sb
                    case "Te":
                        color = UIColor.Atom.Te
                    case "I":
                        color = UIColor.Atom.I
                    case "Xe":
                        color = UIColor.Atom.Xe
                    case "Cs":
                        color = UIColor.Atom.Cs
                    case "Ba":
                        color = UIColor.Atom.Ba
                    case "La":
                        color = UIColor.Atom.La
                    case "Ce":
                        color = UIColor.Atom.Ce
                    case "Pr":
                        color = UIColor.Atom.Pr
                    case "Nd":
                        color = UIColor.Atom.Nd
                    case "Pm":
                        color = UIColor.Atom.Pm
                    case "Sm":
                        color = UIColor.Atom.Sm
                    case "Eu":
                        color = UIColor.Atom.Eu
                    case "Gd":
                        color = UIColor.Atom.Gd
                    case "Tb":
                        color = UIColor.Atom.Tb
                    case "Dy":
                        color = UIColor.Atom.Dy
                    case "Ho":
                        color = UIColor.Atom.Ho
                    case "Er":
                        color = UIColor.Atom.Er
                    case "Tm":
                        color = UIColor.Atom.Tm
                    case "Yb":
                        color = UIColor.Atom.Yb
                    case "Lu":
                        color = UIColor.Atom.Lu
                    case "Hf":
                        color = UIColor.Atom.Hf
                    case "Ta":
                        color = UIColor.Atom.Ta
                    case "W":
                        color = UIColor.Atom.W
                    case "Re":
                        color = UIColor.Atom.Re
                    case "Os":
                        color = UIColor.Atom.Os
                    case "Ir":
                        color = UIColor.Atom.Ir
                    case "Pt":
                        color = UIColor.Atom.Pt
                    case "Au":
                        color = UIColor.Atom.Au
                    case "Hg":
                        color = UIColor.Atom.Hg
                    case "Tl":
                        color = UIColor.Atom.Tl
                    case "Pb":
                        color = UIColor.Atom.Pb
                    case "Bi":
                        color = UIColor.Atom.Bi
                    case "Po":
                        color = UIColor.Atom.Po
                    case "At":
                        color = UIColor.Atom.At
                    case "Rn":
                        color = UIColor.Atom.Rn
                    case "Fr":
                        color = UIColor.Atom.Fr
                    case "Ra":
                        color = UIColor.Atom.Ra
                    case "Ac":
                        color = UIColor.Atom.Ac
                    case "Th":
                        color = UIColor.Atom.Th
                    case "Pa":
                        color = UIColor.Atom.Pa
                    case "U":
                        color = UIColor.Atom.U
                    case "Np":
                        color = UIColor.Atom.Np
                    case "Pu":
                        color = UIColor.Atom.Pu
                    case "Am":
                        color = UIColor.Atom.Am
                    case "Cm":
                        color = UIColor.Atom.Cm
                    case "Bk":
                        color = UIColor.Atom.Bk
                    case "Cf":
                        color = UIColor.Atom.Cf
                    case "Es":
                        color = UIColor.Atom.Es
                    case "Fm":
                        color = UIColor.Atom.Fm
                    case "Md":
                        color = UIColor.Atom.Md
                    case "No":
                        color = UIColor.Atom.No
                    case "Lr":
                        color = UIColor.Atom.Lr
                    case "Rf":
                        color = UIColor.Atom.Rf
                    case "Db":
                        color = UIColor.Atom.Db
                    case "Sg":
                        color = UIColor.Atom.Sg
                    case "Bh":
                        color = UIColor.Atom.Bh
                    case "Hs":
                        color = UIColor.Atom.Hs
                    case "Mt":
                        color = UIColor.Atom.Mt
                    default:
                        color = UIColor.white
                    }
                    let atom = Atom(x: x, y: y, z: z, label: label, color: color, name: name)
					atoms.append(atom)
                    self.delegate?.peform(.createAtom(atom: atom, hiddable: atom.name == "H"))
				case "CONECT":
					guard let startIndex = Int(line[1]) else {
						return
					}
					for i in 2 ..< line.count {
						if let endIndex = Int(line[i]), startIndex < endIndex {
                            let atom1 =  atoms[startIndex - 1]
                            let atom2 = atoms[endIndex - 1]
                            self.delegate?.peform(.createConnection(atom1: atom1, atom2: atom2, hiddable: atom1.name == "H" || atom2.name == "H"))
						}
					}
				default:
					break
				}
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
			}
		}
	}
}

