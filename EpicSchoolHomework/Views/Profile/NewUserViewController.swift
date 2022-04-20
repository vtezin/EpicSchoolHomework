//
//  NewUserViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 17.04.2022.
//

import UIKit
import Firebase

final class NewUserViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resultTextField: UILabel!
    @IBOutlet weak var createNewUser: UISwitch!
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
                !email.isEmpty && !password.isEmpty else {
            updateResultText("Не введен email или пароль", withError: true)
            return
        }
        
        if createNewUser.isOn {
            registerNewUser(email: email, password: password)
        } else {
            login(email: email, password: password)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

// MARK: -  Functions
extension NewUserViewController {
    
    private func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
          
            if let error = error {
                strongSelf.updateResultText(error.localizedDescription, withError: true)
                return
            }
            strongSelf.updateResultText("Вход выполнен")
            
        }
    }
    
    private func registerNewUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.updateResultText(error.localizedDescription, withError: true)
                return
            }
            self.updateResultText("Пользователь зарегистрирован")
        }
    }
    
    private func updateResultText(_ text: String, withError: Bool = false) {
        resultTextField.text = text
        self.resultTextField.textColor = withError ? .red : .green
    }
    
}
