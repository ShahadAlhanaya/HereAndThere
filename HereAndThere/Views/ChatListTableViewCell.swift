//
//  ChatListTableViewCell.swift
//  HereAndThere
//
//  Created by Shahad Nasser on 04/01/2022.
//

import UIKit

class ChatListTableViewCell: UITableViewCell {

    var user: User?
    var chat: Chat?

    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var recentLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    
    func configure(){
        userNameLabel.text = user!.name
        
        var sender = ""
        if chat?.recentMessage?.senderID == user?.id{
            sender = user?.name ?? ""
        }else{
            sender = "Me"
        }
        recentLabel.text = "\(sender): \(chat!.recentMessage?.text ?? "")"
    
        var date = ""
        if let timestamp: Int = chat?.recentMessage?.timestamp {
            let calendar = Calendar.current
            if calendar.isDateInYesterday(Date(timeIntervalSince1970: TimeInterval(timestamp))){
                date = "Yesterday"
            }else if calendar.isDateInToday(Date(timeIntervalSince1970: TimeInterval(timestamp))){
                date = convertDate(timestamp: timestamp, format: "h:mm a")
            }else{
                date = convertDate(timestamp: timestamp, format: "MMM d")
            }
        }
        timeLabel.text = date
       
        userImageView.image = UIImage(named: "empty_profile")
        let image = user!.image
        if image.trimmingCharacters(in: .whitespaces) != "" {
            userImageView.sd_setImage(with: URL(string: image))
        }
    }
    
    func convertDate(timestamp: Int, format: String)-> String{
          let date = Date(timeIntervalSince1970: Double(timestamp))
          let dateFormatter = DateFormatter()
          dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
          dateFormatter.locale = NSLocale.current
          dateFormatter.dateFormat = format
          return dateFormatter.string(from: date)
      }
    
}
