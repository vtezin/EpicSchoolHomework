//
//  QuestionViewController.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 14.06.2022.
//

import UIKit

final class QuestionViewController: UIViewController {
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var answerTextField: UITextField!
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var answerDescriptionTextView: UITextView!
    @IBOutlet private weak var checkAnswerButton: UIButton!
    
    var photoItem: PhotoItem
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(photoItem: PhotoItem) {
        self.photoItem = photoItem
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = photoItem.question
        answerDescriptionTextView.text = photoItem.answerDescription
        if photoItem.isAnsweredByCurrentUser {
            answerTextField.text = photoItem.answer
        }
        setVisible()
    }
}

// MARK: -  Functions
extension QuestionViewController {
    func setVisible() {
        answerDescriptionTextView.isHidden = !photoItem.isAnsweredByCurrentUser
        resultLabel.isHidden = !photoItem.isAnsweredByCurrentUser
        checkAnswerButton.isHidden = photoItem.isAnsweredByCurrentUser
    }
}

// MARK: -  @IBActions
extension QuestionViewController: UITextViewDelegate{
    @IBAction func checkAnswerTapped(_ sender: Any) {
        if photoItem.answerIsCorrect(answer: answerTextField.text ?? "") {
            photoItem.setAnsweredByCurrentUser()
            resultLabel.text = "Верный ответ 🙂"
        } else {
            resultLabel.text = "Чет не то 😕. Не сдаемся!"
        }
        setVisible()
    }
}
