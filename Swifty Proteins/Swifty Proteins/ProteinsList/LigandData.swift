import Foundation

struct LigandData {
    let url: String
    let id: String
    let name: String
    let identifiers: String
    let formula: String
    let molecularWeight: String
    let type: String
    let isomericSMILES: String
    let inChI: String
    let inChIKey: String
    let image: String

    var dictionary: [String: String] {
        return ["Name": name,
                "Identifiers": identifiers,
                "Formula": formula,
                "Molecular Weight": molecularWeight,
                "Type": type,
                "Isomeric SMILES": isomericSMILES,
                "InChI": inChI,
                "InChIKey": inChIKey
        ]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
}
