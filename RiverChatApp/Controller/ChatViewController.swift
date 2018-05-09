//
//  ChatViewController.swift
//  RiverChatApp
//
//  Created by penumutchu.prasad@gmail.com on 04/05/18.
//  Copyright © 2018 abnboys. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


class ChatViewController: JSQMessagesViewController {
    
    
    var messages = [JSQMessage]()
    var rootRef = Database.database().reference()
    lazy var msgRef = rootRef.child("messages")


    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let curntUser = Auth.auth().currentUser {
            
            self.senderId = curntUser.uid
            self.senderDisplayName = "PRASAD"
            observeMessages()
        }
        
    }

    
    
    @IBAction func onLogOut_TouchupInside(_ sender: UIBarButtonItem) {
        
        do {
            try  Auth.auth().signOut()
        }catch let error {
            print(error)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        //print(text)
//        self.messages.append(JSQMessage.init(senderId: senderId, displayName: senderDisplayName, text: text))
//        collectionView.reloadData()
      
        let newMsg = msgRef.childByAutoId()
        let msgData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "mediaType": "TEXT"]
        newMsg.setValue(msgData)
        
        self.finishSendingMessage()
        
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let sheet = UIAlertController.init(title: "Media Type", message: "Please Select From", preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (act) in
            
        }
        
        let photos = UIAlertAction.init(title: "Photos", style: .default) { (act) in
            
           self.presentPicker(OfType: kUTTypeImage)
        }
        
        let videos = UIAlertAction.init(title: "Videos", style: .default) { (act) in
            
            self.presentPicker(OfType: kUTTypeMovie)

        }
        
        sheet.addAction(photos)
        sheet.addAction(videos)
        sheet.addAction(cancel)
        present(sheet, animated: true, completion: nil)
    }
    
    func presentPicker(OfType type: CFString) {
        let imgPicker = UIImagePickerController.init()
        imgPicker.mediaTypes = [String(type)]
        imgPicker.delegate = self
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    func observeMessages() {
        
        msgRef.observe(.childAdded) { (snapShot) in
            
            if let dict = snapShot.value as? [String:String] {
                
                let sendrID = dict["senderId"]
                let sendrName = dict["senderName"]
                let mediaType = dict["mediaType"]
                
                if mediaType == "TEXT" {
                    
                    let txt = dict["text"]
                    self.messages.append(JSQMessage.init(senderId: sendrID, displayName: sendrName, text: txt))

                } else if mediaType == "PHOTO" {
                    
                    let imgURL = dict["fileURL"] as! String
                    
                    if let data = try? Data.init(contentsOf: URL.init(string: imgURL)!) as? Data {
                        
                        if let photo = UIImage.init(data: data!) {
                            let media = JSQPhotoMediaItem.init(image: photo)
                            self.messages.append(JSQMessage.init(senderId: sendrID, displayName: sendrName, media: media))
                            
                            if self.senderId == sendrID {
                                media?.appliesMediaViewMaskAsOutgoing = true
                            }else{
                                media?.appliesMediaViewMaskAsOutgoing = false

                            }
                        }
//                        else {
//                            let media = JSQPhotoMediaItem.init(image: UIImage.init(named: "GglBtn"))
//                            self.messages.append(JSQMessage.init(senderId: sendrID, displayName: sendrName, media: media))
//                        }
                        
                        
                    }
                    
                    
                    
//                    self.messages.append(JSQMessage.init(senderId: sendrID, displayName: sendrName, media: media))

                }else {
                    
                    let videoURL = URL.init(string: dict["fileURL"] as! String)
                    let video = JSQVideoMediaItem.init(fileURL: videoURL, isReadyToPlay: true)
                    
                    self.messages.append(JSQMessage.init(senderId: sendrID, displayName: sendrName, media: video))

                    if self.senderId == sendrID {
                        video?.appliesMediaViewMaskAsOutgoing = true
                    }else{
                        video?.appliesMediaViewMaskAsOutgoing = false
                        
                    }
                }
                
                self.collectionView.reloadData()
            }
        }
        
    }
    
    func sendMediaMessages(image: UIImage?, video: URL?) {
        
        let filePath = "\(Auth.auth().currentUser!)/\(Date.timeIntervalSinceReferenceDate)"
        
        if image != nil {
            
            let data = UIImageJPEGRepresentation(image!, 0.1)
            let metaData = StorageMetadata.init()
            metaData.contentType = "imgae/jpg"
            var storageRef = Storage.storage().reference().child(filePath).putData(data!, metadata: metaData) { (metaData, err) in
                
                if err != nil {
                    return
                }
                
                if let fileURL = metaData?.downloadURLs?.first?.absoluteString {
                    let newMsg = self.msgRef.childByAutoId()
                    let msgData = ["fileURL": fileURL, "senderId": self.senderId, "senderName": self.senderDisplayName, "mediaType": "PHOTO"]
                    newMsg.setValue(msgData)
                }
                
            }
        }else{
            
            guard let vid = video else {return}
            
            let data = try? Data.init(contentsOf: vid)
            let metaData = StorageMetadata.init()
            metaData.contentType = "video/mp4"
            var storageRef = Storage.storage().reference().child(filePath).putData(data!, metadata: metaData) { (metaData, err) in
                
                if err != nil {
                    return
                }
                
                if let fileURL = metaData?.downloadURLs?.first?.absoluteString {
                    let newMsg = self.msgRef.childByAutoId()
                    let msgData = ["fileURL": fileURL, "senderId": self.senderId, "senderName": self.senderDisplayName, "mediaType": "VIDEO"]
                    newMsg.setValue(msgData)
                }
                
            }
        }
        
    }
    
    // JSQCollectionView Delegates...
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
       
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubbleFactory = JSQMessagesBubbleImageFactory.init()
        let msg = messages[indexPath.item]
        if msg.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: .blue)

        }else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .orange)

        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImage.avatar(with: #imageLiteral(resourceName: "GglBtn"))
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        if let msg = messages[indexPath.item] as? JSQMessage, msg.isMediaMessage, let itemmm = msg.media as? JSQVideoMediaItem {
            
            let player = AVPlayer.init(url: itemmm.fileURL)
            
            let playerViewController = AVPlayerViewController.init()
            playerViewController.player = player
            
            self.present(playerViewController, animated: true, completion: nil)
            
        }
    }
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
//            let media = JSQPhotoMediaItem.init(image: img)
//            self.messages.append(JSQMessage.init(senderId: senderId, displayName: senderDisplayName, media: media))
            
            self.sendMediaMessages(image: img, video: nil)
            
        }else if let video = info[UIImagePickerControllerMediaURL] as? URL {
            
//            let media = JSQVideoMediaItem.init(fileURL: video, isReadyToPlay: true)
//            self.messages.append(JSQMessage.init(senderId: senderId, displayName: senderDisplayName, media: media))
            
            self.sendMediaMessages(image: nil, video: video)
            
        }
        collectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

