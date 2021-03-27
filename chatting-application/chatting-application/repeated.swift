//
//  repeated.swift
//  chatting-application
//
//  Created by Omar Amer on 05/03/2021.
//

import SwiftUI
import Firebase

struct inputField: View {
    
    @State var name: String
    @Binding var saving: String
    @State var secure: Bool
    
    var body: some View {
        
        if secure {
            SecureField(name, text: $saving)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .font(.system(size: 16))
            
        } else if !secure {
            TextField(name, text: $saving)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .font(.system(size: 16))
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct chatsList : View {

    var id:String
    var name: String
    var profileImage: String
    var new: Bool
    var lastMessage: String
    var time: String
    var typing: Bool
    var unreadMessages: Int
    
    @ObservedObject var viewModel = ChatroomsViewModel()

    var body: some View {
        NavigationLink(destination: Chat(id: id, name: name, image: profileImage)) {
            HStack( spacing: 20) {

                Image(uiImage: imageDecoder(image: profileImage))
                    .resizable()
                    .frame(width: 55, height: 55, alignment: .center)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text(name)
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.primary)

                    if typing {
                        Text("Typing...")
                            .font(.system(size: 16, weight: .light, design: .default))
                            .foregroundColor(.accentColor)
                    } else {
                        Text(lastMessage)
                            .font(.system(size: 16, weight: .light, design: .default))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }

                Spacer()

                VStack(spacing: 10) {
                    
                    if new {
                        Text(time)
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(.accentColor)
                        
                        Text("New")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 22, alignment: .center)
                            .background(Color.accentColor)
                            .clipShape(Rectangle())
                            .cornerRadius(16)
                    } else if unreadMessages != 0 {
                        Text(time)
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(.accentColor)
                        
                        if unreadMessages >= 1000 {
                            Text("\(unreadMessages / 1000)k+")
                                .font(.system(size: 14, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 7)
                                .background(Color.accentColor)
                                .cornerRadius(90 ,corners: [.allCorners])
                        } else {
                            Text("\(unreadMessages)")
                                .font(.system(size: 14, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .padding(.vertical, 2)
                                .padding(.horizontal, 7)
                                .background(Color.accentColor)
                                .cornerRadius(90 ,corners: [.allCorners])
                        }
                    } else {
                        Text(time)
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(.gray)
                    }
                }
            }

        }
        .contextMenu {

            Button {
                viewModel.removeChat(id: id)
            } label: {

                HStack {

                    Text("Delete")

                    Image(systemName: "trash")

                }
            }
            .frame(width: 100, height: 100, alignment: .center)
        }
    }
    
    func imageDecoder(image:String) -> UIImage {

        if image != "" {
            let decodedData: Data = Data(base64Encoded: image, options: .ignoreUnknownCharacters)!

            let decodedImage = UIImage(data: decodedData)

            return decodedImage!
        } else {
            return UIImage(systemName: "person.crop.circle")!
        }

    }
}

struct SearchList: View {

    var uid:String
    var image: String
    var name: String
    var status: String

    @ObservedObject var viewModel = ChatroomsViewModel()
    
    var body: some View {


        VStack {
            Button {
                
            } label: {
                HStack(spacing: 15) {
                    Image(uiImage: imageDecoder(image: image))
                        .resizable()
                        .frame(width: 55, height: 55, alignment: .center)
                        .clipShape(Circle())
                        .padding(.leading, 10)
                        .colorScheme(.light)

                    Text(name)
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.primary)

                    Spacer()
                    
                    if status == "me" {
                        Text("You")
                            .foregroundColor(.gray)
                    } else if status == "add" {
                        Button {
                            
                            viewModel.AddChat(uid: uid, type: "private") { (done) in
                                if !done {
                                    print("error in adding chat")
                                }
                            }
                            
                        } label: {
                            Text("Add")
                        }
                    } else if status == "added" {
                        Text("Added")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    func imageDecoder(image:String) -> UIImage {
        
        if image != "" {
            let decodedData: Data = Data(base64Encoded: image, options: .ignoreUnknownCharacters)!

            let decodedImage = UIImage(data: decodedData)

            return decodedImage!
        } else{
            return UIImage(systemName: "person.crop.circle")!
        }

    }
}

struct Message: View {

    var chatID: String
    var id: String
    var message: String
    var time: String
    var mine: Bool
    var corners: UIRectCorner
    var seen: Bool
    var isAI: Bool
    var isLast: Bool
    
    @ObservedObject var viewModel = ChatroomsViewModel()
    

    var body: some View {

        HStack {
            
            if isAI {
                
                if id.components(separatedBy: ".")[0] == "AI" {
                    
                    Spacer(minLength: 25)

                    HStack {
                        Text(time)
                            .font(.system(size: 16, weight: .medium, design: .default))
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 14)
                    .foregroundColor(.accentColor)
                    .cornerRadius(20, corners: corners)
                    
                    Spacer(minLength: 25)
                    
                } else if id.components(separatedBy: ".")[0] == "UNREADAI" {
                    
                    if !mine {
                        HStack {
                            Text(message)
                                .font(.system(size: 14, weight: .medium, design: .default))
                            
                            VStack {
                                Divider()
                                    .frame(width: .infinity, height: 1, alignment: .center)
                                    .background(Color.accentColor)
                            }
                        }
                        .padding(.horizontal, 15)
                        .padding(.vertical, 14)
                        .foregroundColor(.accentColor)
                        .cornerRadius(20, corners: corners)
                        
                        Spacer()
                    }
                
                } else if id == "Error" {
                    Spacer(minLength: 25)
                    HStack {

                        Text("unable to load message")
                            .font(.system(size: 16, weight: .medium, design: .default))
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .foregroundColor(.primary)
                    .cornerRadius(20, corners: corners)
                    
                    Spacer(minLength: 25)
                }
            } else {
                if mine {
                    
                    Spacer(minLength: 50)
                    
                    VStack {
                        
                        HStack {
                            Spacer()
                            HStack {

                                Text(message)
                                    .font(.system(size: 16, weight: .medium, design: .default))

                                Text(time)
                                    .font(.system(size: 11, weight: .light, design: .default))
                                    .padding(.vertical, 2)

                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 12)
                            .background(Color("myMessage"))
                            .foregroundColor(.primary)
                            .cornerRadius(20, corners: corners)
                            .contextMenu {
                                Button("delete") {
                                    viewModel.deleteMessage(id: chatID, messageID: id)
                                }
                            }
                        }
                        
                        if isLast && seen {
                            HStack {

                                Spacer()

                                Text("seen")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 20)
                                    .padding(.top, -4)
                            }
                        }
                    }
                } else {

                    HStack {

                        Text(message)
                            .font(.system(size: 16, weight: .medium, design: .default))

                        Text(time)
                            .font(.system(size: 11, weight: .light, design: .default))
                            .padding(.vertical, 2)

                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(Color("theirMessage"))
                    .foregroundColor(.primary)
                    .cornerRadius(20, corners: corners)

                    Spacer(minLength: 50)
                }
            }

        }
        .padding(.horizontal, 8)
        .padding(.vertical, -3)
    }
}

func ChatDateAndTime(timestamp: Any) -> String {
    
    var final = ""
    
    let time = Timestamp.dateValue(timestamp as! Timestamp).self
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "dd/MM/yyyy"
    timeFormatter.dateFormat = "hh:mm a"
    
    if dateFormatter.calendar.isDateInToday(time()) {
        final = timeFormatter.string(from: time())
        
    } else if dateFormatter.calendar.isDateInYesterday(time()) {
        final = "yesterday"
    } else {
        final = dateFormatter.string(from: time())
    }
    
    return final
}

func MessageTime(timestamp: Any) -> String {
    var final = ""
    
    let time = Timestamp.dateValue(timestamp as! Timestamp).self
    
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "hh:mm a"
    
    final = timeFormatter.string(from: time())
    
    return final
}

func ChatMessagesDateAndTime(timestamp: Any) -> String {
    var final = ""
    
    let time = Timestamp.dateValue(timestamp as! Timestamp).self
    let timeFormatter = DateFormatter()
    let dateFormatter = DateFormatter()
    timeFormatter.dateFormat = "hh:mm a"
    dateFormatter.dateFormat = "dd/MM/yyyy"
    
    if dateFormatter.calendar.isDateInToday(time()) {
        final = "today, \(timeFormatter.string(from: time()))"
    } else if dateFormatter.calendar.isDateInYesterday(time()) {
        final = "yesterday, \(timeFormatter.string(from: time()))"
    } else {
        final = "\(dateFormatter.string(from: time())), \(timeFormatter.string(from: time()))"
    }
    
    return final
}

func DateChecker(timestamp:Any) -> String {
    var result = ""
    
    let time = Timestamp.dateValue(timestamp as! Timestamp).self
    let dateFormatter = DateFormatter()
    
    if dateFormatter.calendar.isDateInToday(time()) {
        result = "today"
    } else if dateFormatter.calendar.isDateInYesterday(time()) {
        result = "yesterday"
    } else {
        result = "date"
    }
    
    return result
}

func imageDecoder(image:String) -> UIImage {
    
    if image != "" {
        let decodedData: Data = Data(base64Encoded: image, options: .ignoreUnknownCharacters)!

        let decodedImage = UIImage(data: decodedData)

        return decodedImage!
    } else{
        return UIImage(systemName: "person.crop.circle")!
    }

}

func MessageClassification(chatID:String, message: Messages, messages: [Messages]) -> Message {

    let mineFirstCorners: UIRectCorner = [.topRight, .topLeft, .bottomLeft]
    let mineMiddleCorners: UIRectCorner = [.topLeft, .bottomLeft]
    let mineLastCorners: UIRectCorner = [.topLeft, .bottomLeft, .bottomRight]

    let notMineFirstCorners: UIRectCorner = [.topRight, .topLeft, .bottomRight]
    let notMineMiddleCorners: UIRectCorner = [.topRight, .bottomRight]
    let notMineLastCorners: UIRectCorner = [.topRight, .bottomRight, .bottomLeft]

    let aloneCorners: UIRectCorner = [.allCorners]

    var isAIBefore: Bool = false
    var isAIAfter: Bool = false

    var isUnReadAIBefore: Bool = false
    var isUnReadAIAfter: Bool = false

    var isMyUnReadAIBefore: Bool = false
    var isMyUnReadAIAfter: Bool = false
    var isMineAfterMyUnReadAI: Bool = false
    var isMineBeforeMyUnReadAI: Bool = false

    var isAlone: Bool = false
    var isFirst: Bool = false
    var isMiddle: Bool = false
    var isLast: Bool = false
    var isMinebefore: Bool = false
    var isMineAfter: Bool = false

    if message.isAI {

        // checks if the message is an AI and returns the AI message to be shown.
        
        return Message(chatID: chatID, id: message.id, message: message.message, time: message.time, mine: message.mine, corners: [], seen: message.seen, isAI: message.isAI, isLast: false)

    } else {
        // message is not an AI

        if messages.count >= 2 {
            // checks if total messages is more than two. the least amount of messages is always two as there is the date and it is concidered as a message.

            if messages[messages.firstIndex(of: message)! - 1].isAI {

                // checks if the message before is an AI and identifies it.

                if messages[messages.firstIndex(of: message)! - 1].id.components(separatedBy: ".")[0] == "AI" {
                    isAIBefore = true
                } else {
                    if messages[messages.firstIndex(of: message)! - 1].mine {

                        // checks if the unread messages AI is mine. if it is then it will be hidden and I must arrange the messages to appear as there is nothing in between. if it is mine then they will act as there is a separator in between.
                        
                        isMyUnReadAIBefore = true

                        if messages[messages.firstIndex(of: message)! - 2].isAI {
                            isMineBeforeMyUnReadAI = false
                        } else if messages[messages.firstIndex(of: message)! - 2].mine {
                            isMineBeforeMyUnReadAI = true
                        } else {
                            isMineBeforeMyUnReadAI = false
                        }

                    } else {
                        isUnReadAIBefore = true
                    }

                }

            } else if messages[messages.firstIndex(of: message)! - 1].mine {
                isMinebefore = true
            } else {
                isMinebefore = false
            }

            if messages.firstIndex(of: message)! != (messages.count - 1) {

                if messages[messages.firstIndex(of: message)! + 1].isAI {

                    // checks if the message after is an AI and identifies it.

                    if messages[messages.firstIndex(of: message)! + 1].id.components(separatedBy: ".")[0] == "AI" {
                        isAIAfter = true
                    } else {
                        if messages[messages.firstIndex(of: message)! + 1].mine {

                            // checks if the unread messages AI is mine. if it is then it will be hidden and I must arrange the messages to appear as there is nothing in between. if it is mine then they will act as there is a separator in between.

                            isMyUnReadAIAfter = true

                            if messages[messages.firstIndex(of: message)! + 2].isAI {
                                isMineAfterMyUnReadAI = false
                            } else if messages[messages.firstIndex(of: message)! + 2].mine {
                                isMineAfterMyUnReadAI = true
                            } else {
                                isMineAfterMyUnReadAI = false
                            }

                        } else {
                            isUnReadAIAfter = true
                        }

                    }

                } else if messages[messages.firstIndex(of: message)! + 1].mine {
                    isMineAfter = true
                } else {
                    isMineAfter = false
                }
            } else {
                isLast = true
            }
        }
    }

    if message.mine {

        if isMyUnReadAIBefore {
            print("this is working before")
            if isAIBefore || isUnReadAIBefore || !isMineBeforeMyUnReadAI {
                isFirst = true
            } else {
                isFirst = false
            }
        } else {
            if isAIBefore || !isMinebefore || isUnReadAIBefore {
                isFirst = true
            } else {
                isFirst = false
            }
        }
        
        if !isLast {
            if isMyUnReadAIAfter {
                print("this is working after")
                if isAIAfter || isUnReadAIAfter || !isMineAfterMyUnReadAI {
                    isLast = true
                } else {
                    isLast = false
                }
            } else {
                if isAIAfter || !isMineAfter || isUnReadAIAfter {
                    isLast = true
                } else {
                    isLast = false
                }
            }
        }

        if isFirst && isLast {
            isAlone = true
            isLast = false
            isFirst = false
            isMiddle = false
        } else if !isFirst && !isLast {
            isMiddle = true
            isLast = false
            isFirst = false
            isAlone = false
        }

        if isFirst && !isLast {
            return Message(chatID: chatID, id: message.id, message: message.message, time: message.time, mine: message.mine, corners: mineFirstCorners, seen: message.seen, isAI: message.isAI, isLast: false)
        } else if !isFirst && isLast {
            
            if messages[messages.count - 1].id == message.id {
                return Message(chatID: chatID, id: message.id, message: message.message, time: message.time, mine: message.mine, corners: mineLastCorners, seen: message.seen, isAI: message.isAI, isLast: true)
            } else {
                return Message(chatID: chatID, id: message.id, message: message.message, time: message.time, mine: message.mine, corners: mineLastCorners, seen: message.seen, isAI: message.isAI, isLast: false)
            }
            
        } else if isAlone {
            return Message(chatID: chatID, id: message.id, message: message.message, time: message.time, mine: message.mine, corners: aloneCorners, seen: message.seen, isAI: message.isAI, isLast: false)
        } else if isMiddle {
            return Message(chatID: chatID, id: message.id, message: message.message, time: message.time, mine: message.mine, corners: mineMiddleCorners, seen: message.seen, isAI: message.isAI, isLast: false)
        } else {
            return Message(chatID: chatID, id:"Error", message: "unkown message type, please screenshot and report", time: "", mine: false, corners: [], seen: true, isAI: true, isLast: false)
        }
    } else {

        if isMyUnReadAIBefore {
            if isAIBefore || isMinebefore || isUnReadAIBefore || isMineBeforeMyUnReadAI {
                isFirst = true
            } else {
                isFirst = false
            }
        } else {
            if isAIBefore || isMinebefore || isUnReadAIBefore {
                isFirst = true
            } else {
                isFirst = false
            }
        }
        
        if !isLast {
            if isMyUnReadAIAfter {
                
                if isAIAfter || isMineAfter || isUnReadAIAfter || isMineAfterMyUnReadAI {
                    isLast = true
                } else {
                    isLast = false
                }
            } else {
                if isAIAfter || isMineAfter || isUnReadAIAfter {
                    isLast = true
                } else {
                    isLast = false
                }
            }
        }

        if isFirst && isLast {
            isAlone = true
            isLast = false
            isFirst = false
        } else if !isFirst && !isLast {
            isMiddle = true
            isLast = false
            isFirst = false
        }

        if isFirst && !isLast {
            return Message(chatID: chatID, id: message.id, message: message.message, time: message.time, mine: message.mine, corners: notMineFirstCorners, seen: message.seen, isAI: message.isAI, isLast: false)
        } else if !isFirst && isLast {
            return Message(chatID: chatID, id: message.id, message: message.message, time: message.time, mine: message.mine, corners: notMineLastCorners, seen: message.seen, isAI: message.isAI, isLast: false)
        } else if isAlone {
            return Message(chatID: chatID, id: message.id, message: message.message, time: message.time, mine: message.mine, corners: aloneCorners, seen: message.seen, isAI: message.isAI, isLast: false)
        } else if isMiddle {
            return Message(chatID: chatID, id: message.id, message: message.message, time: message.time, mine: message.mine, corners: notMineMiddleCorners, seen: message.seen, isAI: message.isAI, isLast: false)
        } else {
            return Message(chatID: chatID, id:"Error", message: "unkown message type, please screenshot and report", time: "", mine: false, corners: [], seen: true, isAI: true, isLast: false)
        }

    }
}
