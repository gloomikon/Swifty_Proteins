import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    private enum Constant {
        static let authFailTitle = "Authentication failed"
        static let authFailMessage = "Try again!"
        static let touchIDUnavailableTitle = "Touch ID is not available"
        static let touchIDUnavailableMessage = "Your device is not configured for Touch ID."
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

    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = 10
        }
    }

    private lazy var kitchen = LoginKitchen(delegate: self)

    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide keyboard on tap outside
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    // MARK: Private functions

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            displayAlert(title: Constant.touchIDUnavailableTitle, message: Constant.touchIDUnavailableMessage)
            return
        }

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
