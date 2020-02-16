import UIKit

class AtomViewController: UIViewController {

    // MARK: IBOulets

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var discoveredByLabel: UILabel!
    @IBOutlet weak var atomicMassLabel: UILabel!
    @IBOutlet weak var electronConfigurationLabel: UILabel!

    // MARK: Private properties

    private lazy var kitchen = AtomKitchen(delegate: self)

    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        view.addGestureRecognizer(tapRecognizer)

        kitchen.receive(.viewDidLoad)
    }

    // MARK: Public functions

    func configureWithAtom(_ atomSymbol: String) {
        kitchen.receive(.saveAtom(atomSymol: atomSymbol))
    }

    // MARK: Private functions

    @objc private func handleTap(gestureRecognizer: UITapGestureRecognizer) {
      dismiss(animated: true)
    }

    private func configure(with info: AtomInfo) {
        nameLabel.text = info.name
        symbolLabel.text = info.symbol
        discoveredByLabel.text = info.discovered_by
        atomicMassLabel.text = info.atomic_mass
        electronConfigurationLabel.text = info.electron_configuration
    }

    // MARK: IBActions

    @IBAction private func moreInfoWasTapped(_ sender: Any) {
        kitchen.receive(.moreInfoWasTapped)
    }
}

// MARK: AtomKitchenDelegate

extension AtomViewController: AtomKitchenDelegate {
    func perform(_ command: AtomCommand) {
        switch command {
        case .configure(let info):
            configure(with: info)
        }
    }
}
