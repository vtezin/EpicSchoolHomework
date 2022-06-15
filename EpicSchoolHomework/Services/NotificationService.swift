//
//  NotificationService.swift
//  EpicSchoolHomework
//
//  Created by Vladimir Tezin on 01.06.2022.
//

import UserNotifications
import CoreLocation
import UIKit

final class NotificationService {
    static var shared = NotificationService()
    
    let notificationCenter = UNUserNotificationCenter.current()
    var autorizationStatus: UNAuthorizationStatus?
    
    init() {
        reloadAutorizationStatus()
    }
}

// MARK: -  Autorization
extension NotificationService {
    private func reloadAutorizationStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.autorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    private func requestAutorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { isGranted, _ in
            DispatchQueue.main.async {
                self.autorizationStatus = isGranted ? .authorized : .denied
            }
        }
    }
}

// MARK: -  Notifications
extension NotificationService {
    func addNotificationForPhotoItem(_ photoItem: PhotoItem) {
        if autorizationStatus == .notDetermined {
            requestAutorization()
        }
        
        let center = CLLocationCoordinate2D(latitude: photoItem.latitude, longitude: photoItem.longitude)
        let region = CLCircularRegion(center: center, radius: 50.0, identifier: photoItem.id)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        let trigger = UNLocationNotificationTrigger(region: region, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = "Рядом снято лайкнутое фото"
        content.subtitle = "'\(photoItem.wrappedDescription)' от \(photoItem.author)"
        //content.userInfo = ["id": photoItem.id]
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "notificationSound.wav"))
        let identifier = ProcessInfo.processInfo.globallyUniqueString
        if let image = photoItem.image, let compressionImage = image.compressedImage {
            if let attachment = UNNotificationAttachment.create(identifier: identifier, image: compressionImage, options: nil) {
                content.attachments = [attachment]
            }
            
        }
        
        let request = UNNotificationRequest(identifier: photoItem.id,
                                            content: content,
                                            trigger: trigger)
        
        
        notificationCenter.add(request)
    }
    
    func deleteNotificationForPhotoItem(_ photoItem: PhotoItem) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [photoItem.id])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [photoItem.id])
    }
    
    func printAllNotifications() {
        notificationCenter.getPendingNotificationRequests() { requests in
            DispatchQueue.main.async {
                for request in requests{
                    print(request.content.subtitle)
                    if let trigger = request.trigger as? UNLocationNotificationTrigger {
                        print(trigger.region)
                    }
                }
            }
        }
    }
}

extension UNNotificationAttachment {
    static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".jpg"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            let imageData = UIImage.jpegData(image)
            try imageData(1)?.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
}

