//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Apple on 05.08.1444 (AH).
//

import Foundation
import FirebaseDatabase

final class DatabaseManager  {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAdress: String) -> String {
        var safeEmail = emailAdress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
 

}
// MARK: - Accaunt Mgmt
extension DatabaseManager {
    public func userExist(with email: String, completion: @escaping ((Bool) -> Void)) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child("\(safeEmail)").observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Insert new uservto database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child("\(user.safeEmail)").setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: {error, _ in
            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            self.database.child("users").observeSingleEvent(of: .value) { snapshot   in
                if var userCollection = snapshot.value as? [[String: String]] {
                    // append to user dictionary
                    let newElement =  [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.emailAdress
                    ]
                    userCollection.append(newElement)
                    self.database.child("users").setValue(userCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                    
                } else {
                    // create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.emailAdress
                        ]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            }
            
        })
    }
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
        
    }
    enum DatabaseError: Error {
        case failedToFetch
    }
 }

//MARK: - Sending message
extension DatabaseManager {
    
    /*
     "dsjkbbxc" {
        "messages": [
        {
          "id": String,
          "type": text, photo, viedo,
          "content": String,
          "date": Date(),
          "sender_email": String,
          "isRead": true/false
          }
        ]
     }
       conversation => [
            [
          "conversation_Id": "dsjkbbxc",
          "other_user_email":
          "lastest_message": => {
               "date": Date()
               "lastest_message": "message"
               "is_read": true/false
               }
            ]
            
        ]
     
     
     
     */
      /// Create new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
          
        let safeEmail = DatabaseManager.safeEmail(emailAdress: currentEmail)
        let reference = database.child(safeEmail)
        reference.observeSingleEvent(of: .value) { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dataFormattar.string(from: messageDate)
            
            var message =  ""
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "lastest_message": [
                "date": dateString,
                "message": message,
                "is_read": false
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array already exists fo current user
                // you should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                reference.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationId, name: name, firstMessage: firstMessage, completion: completion)
                }
            } else {
                //
               userNode["conversations"] = [
               newConversationData
               ]
                reference.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationId, name: name, firstMessage: firstMessage, completion: completion)
                completion(true)
                }
            }
        }
    }
    
    private func finishCreatingConversation(conversationID: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//        {
//            "id": String,
//            "type": text, photo, viedo,
//            "content": String,
//            "date": Date(),
//            "sender_email": String,
//            "isRead": true/false
//
//        }
        
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dataFormattar.string(from: messageDate)
  
        
        var message = ""
                
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let currentUserEmail = DatabaseManager.safeEmail(emailAdress: myEmail)
        let collectionMessage:  [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name,
        ]
        let value: [String: Any] = [
            "message": [collectionMessage]
        ]
        print("Adding converid: \(conversationID)")
        
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
                    
    
    /// Fetches and returns all conversations for the user with passed in email
    public func getAllconversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap({dictionary in
                guard let conversationId = dictionary["id"] as? String,
                        let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let lastestMessage = dictionary["lastest_message"] as? [String: Any],
                      let date = lastestMessage["date"] as? String,
                      let message = lastestMessage["message"] as? String,
                      let isRead = lastestMessage["is_read"] as? Bool
                      else {
                    return nil
                }
                let lastestMessageObject = LatestMessage(isRead: isRead, date: date, message: message)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, lastestMessage: lastestMessageObject)
            })
            completion(.success(conversations))
        }
    }
    
    /// Gets all message for given  conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap({ dictionary in
                guard let id = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let content = dictionary["content"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let type = dictionary["type"] as? String,
                      let senderEmail = dictionary["sender_email"] as?  String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dataFormattar.date(from: dateString) else {
                    return nil
                }
                let sender = Sender(photoUrl: "", senderId: senderEmail, displayName: name)
                return Message(sender: sender, messageId: id, sentDate: date, kind: .text(content))
            })
            completion(.success(messages))
        }
    }
    
    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
}

    struct ChatAppUser {
        var firstName: String
        var lastName: String
        var emailAdress: String
        var safeEmail : String {
            var safeEmail = emailAdress.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
            return safeEmail
        }
        
        var profilePictureFileName: String {
            return ("\(safeEmail)_profile_picture.png")
        }
        
    }

