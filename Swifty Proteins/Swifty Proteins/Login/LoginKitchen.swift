enum LoginViewEvent {
    case userEnteredPassword(login: String, password: String)
    case userUsedTouchID
}

enum LoginCommand {
    case routeToProteinsList
    case showAlert(title: String, message: String)
    case authenticateUser
}

protocol LoginKitchenDelegate: class {
    func perform(_ command: LoginCommand)
}

class LoginKitchen {
    private enum Constant {
        static let login = "BT116"
        static let password = "1301"
        static let invalidLoginTitle = "Login failed"
        static let invalidLoginMessage = "Incorrect password or/and login. Try again"
    }
    private weak var delegate: LoginKitchenDelegate?

    init(delegate: LoginKitchenDelegate) {
        self.delegate = delegate
    }

    func receive(_ event: LoginViewEvent) {
        switch event {
        case .userEnteredPassword(let login, let password):
            handleUserEnteredPassword(login: login, password: password)
        case .userUsedTouchID:
            handleUserUsedTouchID()
        }
    }

    // MARK: Private

    private func handleUserEnteredPassword(login: String, password: String) {
        if login == Constant.login && password == Constant.password {
			delegate?.perform(.routeToProteinsList)
        }
        else {
			delegate?.perform(.showAlert(title: Constant.invalidLoginTitle, message: Constant.invalidLoginMessage))
        }
    }

    private func handleUserUsedTouchID() {
		delegate?.perform(.authenticateUser)
    }
}
