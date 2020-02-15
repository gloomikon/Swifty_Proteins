import UIKit

class LigandDataViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet private weak var stackView: UIStackView!

    @IBOutlet private weak var ligandImage: UIImageView! {
        didSet {
            ligandImage.layer.cornerRadius = 30
            ligandImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showLigandImage)))
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

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView! {
        didSet {
            loadingIndicator.hidesWhenStopped = true
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

        navigationItem.backBarButtonItem = UIBarButtonItem(title: ligandData!.id, style: .plain, target: nil, action: nil)

        // Add gradient
        layer.frame = view.bounds
        layer.colors = [UIColor.coldAir.cgColor, UIColor.morningMilk.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(layer, at: 0)

        // Load image
        let url = URL(string: ligandData!.image)
        self.loadingIndicator.startAnimating()
        URLSession.shared.dataTask(with: url!) {
            (data, resp, err) in
            guard let data = data, err == nil else {
                self.loadingIndicator.stopAnimating()
                return
            }
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
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

    // MARK: Private functions

    @objc private func showLigandImage() {
        performSegue(withIdentifier: "roueToLigandImageViewController", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is LigandImageViewController {
            let vc = segue.destination as! LigandImageViewController
            vc.image = ligandImage.image
        }

        if (segue.destination is LigandSceneViewController) {
            let vc = segue.destination as! LigandSceneViewController
			vc.ligandId = ligandData!.id
        }
    }

    @IBAction private func shareButtonTapped(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [ligandImage.image!, ligandData!.url], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = view
        
        present(activityVC, animated: true)
    }

    @IBAction func showSceneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "routeToLigandScene", sender: nil)
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
