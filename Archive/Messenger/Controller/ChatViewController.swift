//
//  ChatViewController.swift
//  Messenger
//
//  Created by Apple on 05.08.1444 (AH).
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    public var sender: MessageKit.SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKit.MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}
struct Sender: SenderType {
    public var photoUrl: String
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public static let dataFormattar: DateFormatter = {
       let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    
    public let otherUserEmail:  String
    private  let conversationId :  String?
     
    public var isNewConversation: Bool = false

    public var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
        
       return Sender(photoUrl: "",
               senderId: safeEmail,
               displayName: "Me")
    }
    
    init(with email: String, id: String?) {
        self.otherUserEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
        if let conversationId = conversationId {
            listenForMessage(id: conversationId)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
           view.backgroundColor = .systemMint
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
                
     }
    private func listenForMessage(id: String) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
                guard  !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                }
            case .failure(let error):
                print("failed to get messsages: \(error)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
  
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
               let selfSender = self.selfSender,
               let messageId = createMessageId() else {
            return
        }
        print("sending \(text)")
        // send message
        if isNewConversation == true {
            // create convo in database
           let otherEmail = DatabaseManager.safeEmail(emailAdress: otherUserEmail)
           let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
           DatabaseManager.shared.createNewConversation(with: otherEmail, name: self.title ?? "User", firstMessage: message) { success in
               if success {
                print("message sent")
               } else {
                     print("failed to send")
                 }
             }
        } else {
            // append to existing conversation data
        }
        
    }
    
    private func createMessageId() -> String? {
        // data , otherUserEmail, SenderEMail, randomInt
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        
        
        let otherEmail = DatabaseManager.safeEmail(emailAdress: otherUserEmail)
        let currentUserEmail = DatabaseManager.safeEmail(emailAdress: myEmail)
        let dateString = Self.dataFormattar.string(from: Date())
        let newIdentifier = "\(otherEmail)_\(currentUserEmail)_\(dateString)"
        print("created message id: \(newIdentifier)")
        return newIdentifier
    }
}


// MARK: - Extensions
extension ChatViewController: MessagesLayoutDelegate, MessagesDataSource, MessagesDisplayDelegate  {
    func currentSender() -> MessageKit.SenderType {
        if let sender = selfSender  {
            return sender
        }
        fatalError("Self sender is nil, email should be cashed")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
}
