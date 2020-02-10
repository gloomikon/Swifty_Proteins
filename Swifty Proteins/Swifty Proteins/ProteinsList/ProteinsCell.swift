import UIKit

class ProteinsCell: UITableViewCell {
    @IBOutlet private weak var proteinNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    var proteinName: String? {
        get {
            return proteinNameLabel.text
        }
        set {
            proteinNameLabel.text = newValue
        }
    }
}
