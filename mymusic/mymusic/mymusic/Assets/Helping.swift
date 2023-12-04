import UIKit
import Network

struct Helping {
    static func checkInternetConnection(from navigationController: UINavigationController?) {
        let monitor = NWPathMonitor()

        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // Internet connection is available, proceed with your logic
            } else {
                // No internet connection, push NetworkViewController
                DispatchQueue.main.async {
                    self.navigateToNetworkViewController(from: navigationController)
                }
            }
        }

        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }

    static func navigateToNetworkViewController(from navigationController: UINavigationController?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let networkViewController = storyboard.instantiateViewController(withIdentifier: "NetworkViewController") as? NetworkViewController {
            navigationController?.setViewControllers([networkViewController], animated: true)
        }
    }
    
    static func showError(text: String, label: UILabel, textFields: [UITextField]){
        label.isHidden = false
        label.text = text
        for textField in textFields {
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = UIColor.systemPink.cgColor
        }
    }
    
    static func checkTextFields(errorLabel: UILabel, textFields: [UITextField], confirmationField: UITextField? = nil, passwordTextField: UITextField? = nil) -> String? {
        for textField in textFields {
            if textField.text!.count <= 2 {
                return "Refill the highlighted text fields."
            }
        }
        guard confirmationField != nil else { return nil }
        
        if confirmationField?.text != passwordTextField?.text {
            return "Your password does not match two times, please try again later"
        }
        return nil
    }
}
