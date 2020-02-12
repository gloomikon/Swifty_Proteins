import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    private enum Constant {
        static let biometricsErrorTitle = "Warning"
        static let biometricsErrorMessage = "Your device does not support biometrics. Login with password only!"
        static let authFailTitle = "Authentication failed"
        static let authFailMessage = "Try again!"
        static let authLabelTouchIDText = "Authenticate via TouchID"
        static let authLabelFaceIDText = "Authenticate via FaceID"
    }

    // MARK: IBOutlets

    @IBOutlet private weak var loginTextInput: UITextField! {
        didSet {
            loginTextInput.placeholder = "Enter login"
            loginTextInput.autocorrectionType = .no
        }
    }

    @IBOutlet private weak var passwordTextInput: UITextField! {
        didSet {
            passwordTextInput.placeholder = "Enter password"
            passwordTextInput.autocorrectionType = .no
            passwordTextInput.keyboardType = .numberPad
            passwordTextInput.isSecureTextEntry = true
        }
    }
    @IBOutlet private weak var authButton: UIButton!
    
    @IBOutlet private weak var authTextLabel: UILabel!

    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = 10
        }
    }

    // MARK: Private properties

    private lazy var kitchen = LoginKitchen(delegate: self)
    private let context = LAContext()
    private let layer = CAGradientLayer()

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add gradient
        layer.frame = view.bounds
        layer.colors = [UIColor.clearSea.cgColor, UIColor.summerMorning.cgColor]
        view.layer.insertSublayer(layer, at: 0)

        // Add (hide) biometrics image and text
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            switch context.biometryType {
            case .faceID:
                authButton.setImage(UIImage(named: "faceID"), for: .normal)
                authTextLabel.text = Constant.authLabelFaceIDText
            case .touchID:
                authButton.setImage(UIImage(named: "touchID"), for: .normal)
                authTextLabel.text = Constant.authLabelTouchIDText
            case .none:
                break
            @unknown default:
                break
            }
        }
        else {
            displayAlert(title: Constant.biometricsErrorTitle, message: Constant.biometricsErrorMessage)
            authTextLabel.isHidden = true
            authButton.isHidden = true
        }

        // Hide keyboard on tap outside
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layer.frame = view.bounds
    }

    // MARK: Private functions

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func authenticateUser() {
        let reason = "Identify yourself!"

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
            [unowned self] success, authenticationError in

            DispatchQueue.main.async {
                if success {
                    self.routeToProteinsList()
                }
                else {
                    self.displayAlert(title: Constant.authFailTitle, message: Constant.authFailMessage)
                }
            }
        }
    }

    private func routeToProteinsList() {
        performSegue(withIdentifier: "routeToProteinsList", sender: self)
    }

    // MARK: IBActions

    @IBAction private func touchIDButtonTapped(_ sender: Any) {
        kitchen.receive(.userUsedTouchID)
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        guard
            let login = loginTextInput.text,
            let password = passwordTextInput.text,
            !login.isEmpty,
            !password.isEmpty else {
                displayAlert(title: "Error", message: "Field(s) can not be empty!")
                return
        }
        kitchen.receive(.userEnteredPassword(login: login, password: password))
    }
}

// MARK: LoginKitchenDelegate

extension LoginViewController: LoginKitchenDelegate {
    func perform(_ command: LoginCommand) {
        switch command {
        case .routeToProteinsList:
            routeToProteinsList()
        case .showAlert(let title, let message):
            displayAlert(title: title, message: message)
        case .authenticateUser:
            authenticateUser()
        }
    }
}
