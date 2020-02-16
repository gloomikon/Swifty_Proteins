import UIKit
import SceneKit

class LigandSceneViewController: UIViewController {

	// MARK: Public properties

	var ligandId: String?

	// MARK: IBOutlets

    @IBOutlet weak var settingsView: UIView! {
        didSet {
            settingsView.layer.cornerRadius = 10
        }
    }

	// MARK: Private properties

	private var scnView: SCNView!
	private var scnScene: SCNScene!
	private var cameraNode: SCNNode!
	private lazy var kitchen = LigandSceneKitchen(delegate: self)
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    private var nodesToHide = [SCNNode]()
    private var labelNodes = [SCNNode]()
    private var shouldShowHydrogens = true
    private var shouldHaveDarkBackground = false
    private var atomSymbol: String?

	// MARK: Life cycle

	override func viewDidLoad() {
        super.viewDidLoad()

		kitchen.receive(.viewDidLoad(ligandId: ligandId!))

		scnView = (view as! SCNView)
		scnView.allowsCameraControl = true
		scnView.autoenablesDefaultLighting = true

		scnScene = SCNScene()

		scnView.scene = scnScene
		scnView.isPlaying = true

		cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)

		scnScene.rootNode.addChildNode(cameraNode)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }

    // MARK: IBAction

    @IBAction func shareButtonTapped(_ sender: Any) {
        let activityViewController = UIActivityViewController(activityItems: [scnView.snapshot()], applicationActivities: nil)

        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popoverController.sourceView = view
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }

        self.present(activityViewController, animated: true)
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SettingsViewController {
            controller.delegate = self
            controller.configure(shouldShowHydrogens: shouldShowHydrogens, shouldHaveDarkBackground: shouldHaveDarkBackground)
            slideInTransitioningDelegate.disableCompactHeight = false
            slideInTransitioningDelegate.direction = .right
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        }
        if let controller = segue.destination as? AtomViewController {
            slideInTransitioningDelegate.disableCompactHeight = true
            slideInTransitioningDelegate.direction = .bottom
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
            guard let atomSymbol = atomSymbol else {
                return
            }
            controller.configureWithAtom(atomSymbol)
        }
    }

    // MARK: SceneKit settings

	override var shouldAutorotate: Bool {
		return true
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		if UIDevice.current.userInterfaceIdiom == .phone {
			return .allButUpsideDown
		}
		else {
			return .all
		}
	}

	// MARK: Private functions

    // https://stackoverflow.com/questions/54409801/getting-location-of-tap-on-scnsphere-swift-scenekit-ios
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        if hitResults.count > 0 {
            let result: SCNHitTestResult = hitResults[0]

            guard let atomSymbol = result.node.name else {
                return
            }

            self.atomSymbol = atomSymbol

            performSegue(withIdentifier: "showAtomInfo", sender: nil)
        }
    }

	// https://www.youtube.com/watch?v=haZmF3ZYIYc&list=RDQM752rPUxMPc8&index=1
    private func createAtom(atom: Atom, hiddable: Bool) {
		let atomSphere = SCNSphere(radius: 0.2)
        atomSphere.materials.first?.diffuse.contents = atom.color
		let atomNode = SCNNode(geometry: atomSphere)
        atomNode.position = SCNVector3(x: atom.x, y: atom.y, z: atom.z)
        atomNode.name = atom.name
		scnScene.rootNode.addChildNode(atomNode)
        if hiddable {
            nodesToHide.append(atomNode)
        }
	}

    private func createConnection(atom1: Atom, atom2: Atom, hiddable: Bool) {
        let startPoint = SCNVector3(x: atom1.x, y: atom1.y, z: atom1.z)
        let middlePoint = SCNVector3(x: (atom1.x + atom2.x) / 2, y: (atom1.y + atom2.y) / 2, z: (atom1.z + atom2.z) / 2)
        let endPoint = SCNVector3(x: atom2.x, y: atom2.y, z: atom2.z)

        drawLines(startPoint: startPoint, endPoint: middlePoint, color: atom1.color, hiddable: hiddable)
        drawLines(startPoint: middlePoint, endPoint: endPoint, color: atom2.color, hiddable: hiddable)
    }

    //https://stackoverflow.com/a/41526915/8704249
    private func drawLines(startPoint: SCNVector3, endPoint: SCNVector3, color: UIColor, hiddable: Bool) {
		let height = CGFloat(GLKVector3Distance(SCNVector3ToGLKVector3(startPoint), SCNVector3ToGLKVector3(endPoint)))
		let startNode = SCNNode()
		let endNode = SCNNode()

		startNode.position = startPoint
		endNode.position = endPoint

		let zAxisNode = SCNNode()
		zAxisNode.eulerAngles.x = .pi / 2

		let cylinderGeometry = SCNCylinder(radius: 0.1, height: height)
		cylinderGeometry.firstMaterial?.diffuse.contents = color
		let cylinder = SCNNode(geometry: cylinderGeometry)

		cylinder.position.y = Float(-height / 2)
		zAxisNode.addChildNode(cylinder)

		let returnNode = SCNNode()

		if (startPoint.x > 0.0 && startPoint.y < 0.0 && startPoint.z < 0.0 && endPoint.x > 0.0 && endPoint.y < 0.0 && endPoint.z > 0.0)
		{
			endNode.addChildNode(zAxisNode)
			endNode.constraints = [ SCNLookAtConstraint(target: startNode) ]
			returnNode.addChildNode(endNode)
		}
		else if (startPoint.x < 0.0 && startPoint.y < 0.0 && startPoint.z < 0.0 && endPoint.x < 0.0 && endPoint.y < 0.0 && endPoint.z > 0.0)
		{
			endNode.addChildNode(zAxisNode)
			endNode.constraints = [ SCNLookAtConstraint(target: startNode) ]
			returnNode.addChildNode(endNode)

		}
		else if (startPoint.x < 0.0 && startPoint.y > 0.0 && startPoint.z < 0.0 && endPoint.x < 0.0 && endPoint.y > 0.0 && endPoint.z > 0.0)
		{
			endNode.addChildNode(zAxisNode)
			endNode.constraints = [ SCNLookAtConstraint(target: startNode) ]
			returnNode.addChildNode(endNode)

		}
		else if (startPoint.x > 0.0 && startPoint.y > 0.0 && startPoint.z < 0.0 && endPoint.x > 0.0 && endPoint.y > 0.0 && endPoint.z > 0.0)
		{
			endNode.addChildNode(zAxisNode)
			endNode.constraints = [ SCNLookAtConstraint(target: startNode) ]
			returnNode.addChildNode(endNode)

		}
		else
		{
			startNode.addChildNode(zAxisNode)
			startNode.constraints = [ SCNLookAtConstraint(target: endNode) ]
			returnNode.addChildNode(startNode)
		}

		scnScene.rootNode.addChildNode(returnNode)
        if hiddable {
            nodesToHide.append(returnNode)
        }
	}
}

// MARK: SettingsViewControllerDelegate

extension LigandSceneViewController: SettingsViewControllerDelegate {
    func showHydrogens() {
        shouldShowHydrogens = true
        nodesToHide.forEach {
            scnScene.rootNode.addChildNode($0)
        }
    }

    func hideHydrogens() {
        shouldShowHydrogens = false
        nodesToHide.forEach {
            $0.removeFromParentNode()
        }
    }

    func makeDarkBackground() {
        shouldHaveDarkBackground = true
        scnView.backgroundColor = UIColor.black
    }

    func makeLightBackground() {
        shouldHaveDarkBackground = false
        scnView.backgroundColor = UIColor.white
    }

}

// MARK: LigandSceneKitchenDelegate

extension LigandSceneViewController: LigandSceneKitchenDelegate {
	func peform(_ command: LigandSceneCommand) {
		switch command {
		case .showAlert(let title, let message):
			displayAlert(title: title, message: message)
		case .createAtom(let atom, let hiddable):
            createAtom(atom: atom, hiddable: hiddable)
		case .createConnection(let atom1, let atom2, let hiddable):
            createConnection(atom1: atom1, atom2: atom2, hiddable: hiddable)
		}
	}
}
