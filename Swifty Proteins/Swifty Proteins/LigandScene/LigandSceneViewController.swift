import UIKit
import SceneKit

class LigandSceneViewController: UIViewController {

	// MARK: Public properties

	var ligandId: String?

	// MARK: IBOutlets


	// MARK: Private properties

	private var scnView: SCNView!
	private var scnScene: SCNScene!
	private var cameraNode: SCNNode!
	private lazy var kitchen = LigandSceneKitchen(delegate: self)

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
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 30)

		scnScene.rootNode.addChildNode(cameraNode)
    }

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

	// https://www.youtube.com/watch?v=haZmF3ZYIYc&list=RDQM752rPUxMPc8&index=1
	private func createAtom(x: Float, y: Float, z: Float) {
		let atom = SCNSphere(radius: 0.2)
		atom.materials.first?.diffuse.contents = UIColor.red
		let atomNode = SCNNode(geometry: atom)
		atomNode.position = SCNVector3(x: x, y: y, z: z)
		scnScene.rootNode.addChildNode(atomNode)
	}

	private func connectAtoms(atom1: (x: Float, y: Float, z: Float), atom2: (x: Float, y: Float, z: Float)) {
		let startPoint = SCNVector3(x: atom1.x, y: atom1.y, z: atom1.z)
		let endPoint = SCNVector3(x: atom2.x, y: atom2.y, z: atom2.z)

		let height = CGFloat(GLKVector3Distance(SCNVector3ToGLKVector3(startPoint), SCNVector3ToGLKVector3(endPoint)))
		let startNode = SCNNode()
		let endNode = SCNNode()

		startNode.position = startPoint
		endNode.position = endPoint

		let zAxisNode = SCNNode()
		zAxisNode.eulerAngles.x = .pi / 2

		let cylinderGeometry = SCNCylinder(radius: 0.05, height: height)
		cylinderGeometry.firstMaterial?.diffuse.contents = UIColor.darkGray
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
	}
}

extension LigandSceneViewController: SCNSceneRendererDelegate {
	func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
		glLineWidth(100000)
    }
}

// MARK: LigandSceneKitchenDelegate

extension LigandSceneViewController: LigandSceneKitchenDelegate {
	func peform(_ command: LigandSceneCommand) {
		switch command {
		case .showAlert(let title, let message):
			displayAlert(title: title, message: message)
		case .createAtom(let atom):
			createAtom(x: atom.x, y: atom.y, z: atom.z)
		case .connectAtoms(let atom1, let atom2):
			connectAtoms(atom1: atom1, atom2: atom2)
		}
	}
}
