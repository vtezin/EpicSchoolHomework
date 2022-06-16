//
//  NewUserViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 17.04.2022.
//

import UIKit
import Firebase
import RealmSwift

final class UserProfileViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resultTextField: UILabel!
    @IBOutlet weak var createNewUser: UISwitch!
    @IBOutlet weak var userDetailsStackView: UIStackView!
    @IBOutlet weak var logInOutButton: UIButton!
    @IBOutlet weak var currentUserEmailLabel: UILabel!
    @IBOutlet weak var currentUserInfoStackView: UIStackView!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userLoggedIn = false {
        didSet{
            loginStateDidChanged()
        }
    }
    @IBAction func clearCashButtonTapped(_ sender: Any) {
        PhotoItemRealm.deleteAllItems()
        appState.photoItems.removeAll()
        let alertController = simpleAlert(title: "Очистка кэша", message: "Готово")
        present(alertController, animated: true)
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        if userLoggedIn {
            logoutUser()
            return
        }
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                self.currentUserEmailLabel.text = user.email
                self.userLoggedIn = true
            } else {
                self.userLoggedIn = false
            }
        }
        NotificationService.shared.printAllNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Профиль"
    }
    
}

// MARK: -  Functions
extension UserProfileViewController {    
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
    
    private func logoutUser() {
        do { try Auth.auth().signOut() }
        catch { print("already logged out") }
    }
    
    private func updateResultText(_ text: String, withError: Bool = false) {
        resultTextField.text = text
        self.resultTextField.textColor = withError ? .red : .green
    }
    
    private func loginStateDidChanged() {
        logInOutButton.setTitle(userLoggedIn ? "Выйти" : "Войти", for: .normal)
        userDetailsStackView.isHidden = userLoggedIn
        currentUserInfoStackView.isHidden = !userLoggedIn
    }
}
