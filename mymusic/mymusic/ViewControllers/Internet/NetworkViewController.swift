import UIKit
import Network

class NetworkViewController: UIViewController {
    @IBOutlet weak var networkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func networkButtonDidTapped(_ sender: UIButton) {
        checkInternetConnection()
    }
    
    func checkInternetConnection() {
            let monitor = NWPathMonitor()

            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    // Internet connection is available, navigate to LogInViewController
                    DispatchQueue.main.async {
                        self.navigateToLogInViewController()
                    }
                } else {
                    // No internet connection, show alert controller
                    DispatchQueue.main.async {
                        self.showNoInternetAlert()
                    }
                }
            }

            let queue = DispatchQueue(label: "Monitor")
            monitor.start(queue: queue)
        }
    
    func navigateToLogInViewController() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let logInViewController = storyboard.instantiateViewController(withIdentifier: "LogInViewController") as? LogInViewController {
                navigationController?.setViewControllers([logInViewController], animated: true)
            }
        }

        func showNoInternetAlert() {
            let alertController = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again.", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "OK", style: .default)

            alertController.addAction(okAction)

            present(alertController, animated: true, completion: nil)
        }
}
