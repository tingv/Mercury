//
//  MessageViewModel.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 17/05/24.
//

import SwiftUI
import TDLibKit
import AVFAudio

class MessageViewModel: NSObject, ObservableObject {
    
    var message: Message
    var chat: Chat
    
    @Published var user: User?
    @Published var isPlaying: Bool = false
    @Published var isLoading: Bool = false
    
    var textAlignment: HorizontalAlignment {
        message.isOutgoing ? .trailing : .leading
    }
    
    var showSender: Bool {
        if message.isOutgoing {
            return false
        }
        
        switch chat.type {
        case .chatTypePrivate(_):
            return false
        default:
            return true
        }
    }
    
    var showBubble: Bool {
        switch message.content {
        case .messagePhoto(_) :
            return false
        default:
            return true
        }
    }
    
    var senderID: Int64 {
        switch message.senderId {
        case .messageSenderUser(let messageSenderUser):
            messageSenderUser.userId
        case .messageSenderChat(let messageSenderChat):
           messageSenderChat.chatId
        }
    }
    
    var date: String {
        Date(fromUnixTimestamp: message.date).stringDescription
    }
    
    var userFullName: String {
        guard let user else { return "placeholder" }
        var string = user.firstName
        if user.lastName != "" {
            string += " " + user.lastName
        }
        
        return string
    }
    
    var userNameRedaction: RedactionReasons {
        userFullName == "placeholder" ? .placeholder : []
    }
    
    var titleColor: Color {
        return Color(fromUserId: senderID)
    }
    
    var isSending: Bool {
        return self.message.sendingState != nil
    }
    
    init(message: Message, chat: Chat) {
        self.message = message
        self.chat = chat
        super.init()
        
        initUser()
    }
    
    private func initUser() {
        Task { [weak self] in
            guard let self else { return }
            let user = try? await TDLibManager.shared.client?.getUser(userId: self.senderID)
            DispatchQueue.main.async {
                withAnimation {
                    self.user = user
                }
            }
        }
    }
    
    func play() {
        
        switch message.content {
        case .messageVoiceNote(let message):
            playVoiceNote(voiceNote: message.voiceNote)
            
        default:
            return
        }
    
    }
    
    private func playVoiceNote(voiceNote: VoiceNote) {
        
        Task {
            
            await MainActor.run { isLoading = true }
            let filePath = await FileService.getFile(for: voiceNote.voice)
            await MainActor.run { isLoading = false }
            
            guard let filePath else {
                print("[CLIENT] [\(type(of: self))] [\(#function)] filePath is nil")
                return
            }
            
            do {
                
                let audioSession = AVAudioSession.sharedInstance()
                try audioSession.setCategory(.playback, mode: .default)
                try audioSession.setActive(true)
                
                let audioPlayer = try AVAudioPlayer(contentsOf: filePath)
                audioPlayer.isMeteringEnabled = true
                audioPlayer.volume = 1.0
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
            } catch {
                print("[CLIENT] [\(type(of: self))] [\(#function)] audioPlayer error: \(error)")
            }
            
            await MainActor.run {
                isPlaying = true
            }
        }
    }
    
}

extension MessageViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag { isPlaying = false }
    }
}
