import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import Firebase
import Network

class LogInViewController: UIViewController {
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var logButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    let defaults = UserDefaults.standard
    static var logInError: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Helping.checkInternetConnection(from: self.navigationController)
        guard defaults.string(forKey: "email") == nil else {
            let destVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
            self.navigationController?.setViewControllers([destVC], animated: true)
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Helping.checkInternetConnection(from: self.navigationController)
    }
    
    @IBAction func googleButtonDidTapped(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                return
            }

            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                let destVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
                self.defaults.set(self.emailTextField.text!, forKey: "email")
                self.navigationController?.setViewControllers([destVC], animated: true)
            }
        }
    }
    
    @IBAction func logButtonClicked(_ sender: UIButton) {
        let error = Helping.checkTextFields(errorLabel: errorLabel, textFields: [emailTextField, passwordTextField])
         
        guard error == nil else {
            Helping.showError(text: error!, label: errorLabel, textFields: [emailTextField,passwordTextField])
            return
        }
         
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
        if error != nil {
            Helping.showError(text: error!.localizedDescription, label: self.errorLabel, textFields: [self.emailTextField, self.passwordTextField])
        }
        else {
            let destVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
            self.defaults.set(self.emailTextField.text!, forKey: "email")
            self.navigationController?.setViewControllers([destVC], animated: true)
            }
        }
    }
    @IBAction func signButtonClicked(_ sender: UIButton) {
        Helping.checkInternetConnection(from: self.navigationController)
        let signUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController")
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    func navigateToSignUpViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            navigationController?.pushViewController(signUpViewController, animated: true)
        }
    }
}

