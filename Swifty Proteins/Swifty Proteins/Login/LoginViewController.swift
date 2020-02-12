import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    private enum Constant {
        static let biometricsErrorTitle = "Warning"
        static let biometricsErrorMessage = "Your device does not support biometrics. Login with password only!"

        // https://developer.apple.com/documentation/localauthentication/laerror/code
        static let authFailTitle = "Authentication failed"
        static let appCancel = "The app canceled authentication."
        static let systemCancel = "The system canceled authentication."
        static let userCancel = "The user tapped the cancel button in the authentication dialog."
        static let touchIDNotAvailable = "Biometry is not available on the device."
        static let touchIDNotEnrolled = "The user has no enrolled Touch ID fingers."
        static let touchIDLockout = "Touch ID is locked because there were too many failed attempts."
        static let authenticationFailed = "The user failed to provide valid credentials."
        static let invalidContext = "The context was previously invalidated."
        static let notInteractive = "Displaying the required authentication user interface is forbidden."
        static let passcodeNotSet = "A passcode isn’t set on the device."
        static let unknownDefault = "Unknown error. Try again."
        static let userFallback = "The user tapped the fallback button in the authentication dialog, but no fallback is available for the authentication policy."

//        For furure use:
//        static let biometryLockout = "Biometry is locked because there were too many failed attempts."
//        static let biometryNotAvailable = "Biometry is not available on the device."
//        static let biometryNotEnrolled = "The user has no enrolled biometric identities."
//        static let watchNotAvailable = "An attempt to authenticate with Apple Watch failed."

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
            loginButton.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
//            loginButton.backgroundColor = UIColor.darkGray
            loginButton.layer.borderWidth = 1.0
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

            guard authenticationError == nil else {
                let error = authenticationError as! LAError
                let errorMessage: String

                switch error.code {
                case .appCancel:
                    errorMessage = Constant.appCancel
                case .authenticationFailed:
                    errorMessage = Constant.authenticationFailed
                case .userCancel:
                    errorMessage = Constant.userCancel
                case .userFallback:
                    errorMessage = Constant.userFallback
                case .systemCancel:
                    errorMessage = Constant.systemCancel
                case .passcodeNotSet:
                    errorMessage = Constant.passcodeNotSet
                case .touchIDNotAvailable:
                    errorMessage = Constant.touchIDNotAvailable
                case .touchIDNotEnrolled:
                    errorMessage = Constant.touchIDNotEnrolled
                case .touchIDLockout:
                    errorMessage = Constant.touchIDLockout
                case .invalidContext:
                    errorMessage = Constant.invalidContext
                case .notInteractive:
                    errorMessage = Constant.notInteractive
                @unknown default:
                    errorMessage = Constant.unknownDefault
                }
                
                DispatchQueue.main.async {
                    self.displayAlert(title: Constant.authFailTitle, message: errorMessage)
                }
                return
            }

            DispatchQueue.main.async {
                self.routeToProteinsList()
            }
        }
    }

    private func routeToProteinsList() {
        performSegue(withIdentifier: "routeToProteinsList", sender: self)
    }

    @IBAction private func touchIDButtonTapped(_ sender: Any) {
        kitchen.receive(.userUsedTouchID)
    }

    @IBAction private func loginButtonTapped(_ sender: Any) {
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
