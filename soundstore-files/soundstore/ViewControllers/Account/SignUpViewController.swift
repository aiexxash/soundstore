import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import Firebase
import Network

class SignUpViewController: UIViewController {
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Helping.checkInternetConnection(from: self.navigationController)
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    @IBAction func signButtonClicked(_ sender: UIButton) {
        Helping.checkInternetConnection(from: self.navigationController)
        
        let error = Helping.checkTextFields(errorLabel: errorLabel, textFields: [emailTextField], confirmationField: passwordConfirmTextField, passwordTextField: passwordTextField)
        guard error == nil else {
            Helping.showError(text: error!, label: errorLabel, textFields: [emailTextField, passwordTextField, passwordConfirmTextField])
            return
        }
                
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            if err != nil {
                Helping.showError(text: "Error creating user", label: self.errorLabel, textFields: [])
            } else {
                self.defaults.set(self.emailTextField.text!, forKey: "email")
                let db = Firestore.firestore()
                
                db.collection("users").addDocument(data: ["email": email, "uid": result!.user.uid ]) { (error) in
                    if error != nil {
                        Helping.showError(text: "Error saving user data", label: self.errorLabel, textFields: [])
                    }
                }
                let ac = UIAlertController(title: "Success", message: "Your account was successfuly created and now you are free to use it.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default){_ in
                    let destVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EmailViewController")
                    self.navigationController?.setViewControllers([destVC], animated: true)
                })
                self.present(ac, animated: true)
            }
        }
    }
    @IBAction func googleButtonDidClicked(_ sender: UIButton) {
        Helping.checkInternetConnection(from: self.navigationController)
        
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
    
    func navigateToSignUpViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let signUpViewController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            navigationController?.pushViewController(signUpViewController, animated: true)
        }
    }
}
