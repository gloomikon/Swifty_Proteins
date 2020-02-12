import UIKit

class LigandDataViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet private weak var stackView: UIStackView!

    @IBOutlet private weak var ligandImage: UIImageView! {
        didSet {
            ligandImage.layer.cornerRadius = 30
        }
    }

    @IBOutlet private weak var contentView: UIView! {
        didSet {
            contentView.layer.cornerRadius = 20
        }
    }

    @IBOutlet private weak var infoTableView: UITableView! {
        didSet {
            infoTableView.dataSource = self
            infoTableView.delegate = self
        }
    }


    // MARK: Public properties

    var ligandData: LigandData?

    // MARK: Private properties

    private let layer = CAGradientLayer()
    private let ligandInfoProperties = ["Name", "Identifiers", "Formula", "Molecular Weight", "Type", "Isomeric SMILES", "InChI", "InChIKey"]
    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add gradient
        layer.frame = view.bounds
        layer.colors = [UIColor.coldAir.cgColor, UIColor.morningMilk.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(layer, at: 0)

        // Load image
        let url = URL(string: ligandData!.image)
        URLSession.shared.dataTask(with: url!) {
            (data, resp, err) in
            guard let data = data, err == nil else {
//                self.loadingIndicator.stopAnimating()
                return
            }
            DispatchQueue.main.async {
//                self.loadingIndicator.stopAnimating()
                self.ligandImage.image = UIImage(data: data)
            }
        }.resume()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = ligandData?.id
        infoTableView.estimatedRowHeight = 100
        infoTableView.rowHeight = UITableView.automaticDimension
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layer.frame = view.bounds
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown, .faceUp, .faceDown:
            stackView.axis = .vertical
        case .landscapeLeft, .landscapeRight:
            stackView.axis = .horizontal
        case .unknown:
            break
        @unknown default:
            break
        }
    }
}

// MARK:

extension LigandDataViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ligandInfoCell") as! LidandDataCell
        let property = ligandInfoProperties[indexPath.row]
        cell.property = (property, ligandData?.dictionary[property])
        return cell
    }
}
