//
//  SocketManager.swift
//  <%= @project %>
//
//  Created by <%= @author %> on <%= @date %>.
//  Copyright © 2018 ForaSoft. All rights reserved.
//

import UIKit

import SocketIO
import RxSwift
import SwiftyJSON
import RxAppState

// MARK: Public Methods Definition

private protocol PublicMethods {
    func isSocketConnected() -> Bool
    func isSocketConnecting() -> Bool
    func disconnect()
    func connect()
    
    // TODO: Add custom EMIT methods
}

// MARK: Class Definition

class SocketManager {
    
    // MARK: Public Properties
    
    class var shared: SocketManager {
        if SocketManager.instance == nil {
            SocketManager.instance = SocketManager()
        }
        
        return SocketManager.instance!
    }
    
    private(set) var connected: Observable<Any>!
    private(set) var disconnected: Observable<Any>!
    
    // TODO: Add RECIEVE method as Observable
    private(set) var exampleObservableEvent: Observable<[String : Any]?>!

    // MARK: Private Properties
    
    private var socketManager: SocketIO.SocketManager!
    private let infoPlistService = InfoPlistService()
    
    private static var instance: SocketManager?
    
    // MARK: Init Methods & Superclass Overriders
    
    init() {
        connect()
    }
}

// MARK: Public Methods

extension SocketManager: PublicMethods {
    func connect() {
        let socketServer = infoPlistService.serverURL().replacingOccurrences(of: "com/", with: "com:") + infoPlistService.serverPort()
        let socketServerURL = URL(string: socketServer)!
        
        var configuration = SocketIOClientConfiguration()
        configuration.insert(.reconnects(true))
        configuration.insert(.reconnectAttempts(-1))
        configuration.insert(.log(false))
        
        socketManager = SocketIO.SocketManager(socketURL: socketServerURL, config: configuration)
        
        addDefaultSocketEvents()
        addCustomSocketEvents()
        
        socketManager.defaultSocket.connect()
    }
    
    func disconnect() {
        socketManager.defaultSocket.disconnect()
        SocketManager.instance = nil
    }
    
    func isSocketConnected() -> Bool {
        let isConnected = socketManager.defaultSocket.status == SocketIOStatus.connected ? true : false
        return isConnected
    }
    
    func isSocketConnecting() -> Bool {
        let isConnecting = socketManager.defaultSocket.status == SocketIOStatus.connecting ? true : false
        return isConnecting
    }
    
    // TODO: Add custom EMIT methods
    // EXAMPLE
//    func getLastMessages(_ userIdentifier: String, completion: ((_ unreadIdetifier: [String: Any]?) -> ())?) {
//        let parameters : [String : Any] = [
//            Keys.roomIdentifier : userIdentifier
//        ]
//
//        sendEvent(withName: Events.getLastDialogs, parameters: parameters) { data in
//            let json = JSON(data)
//            let responses = json[1].dictionaryObject
//            completion?(responses)
//        }
//    }
}

// MARK: Configure Sockets

private extension SocketManager {
    func addDefaultSocketEvents() {
        connected = Observable.create({ (observer) -> Disposable in
            self.socketManager.defaultSocket.on(clientEvent: .connect) { (data, ack) in
                observer.onNext("")
            }
            return Disposables.create()
        })
        
        disconnected = Observable.create({ (observer) -> Disposable in
            self.socketManager.defaultSocket.on(clientEvent: .reconnect) { (data, ack) in
                #if DEBUG
                    print("Socket disconnected")
                #endif
                observer.onNext("")
            }
            self.socketManager.defaultSocket.on(clientEvent: .disconnect) { (data, ack) in
                #if DEBUG
                    print("Socket disconnected")
                #endif
                observer.onNext("")
            }
            return Disposables.create()
        })
        
        socketManager.defaultSocket.onAny { (event) in
            #if DEBUG
                print("\(Date()) socket RECEIVE \(event.event) with \(event.items ?? [])")
            #endif
        }
    }
    
    func addCustomSocketEvents() {
        // TODO: Add custom RECIEVE methods
//        exampleObservableEvent = Observable.create({ (observer) -> Disposable in
//            self.socketManager.defaultSocket.on(Events.example) { (data, ack) in
//                let json = JSON(data)
//                let responses = json[1].dictionaryObject
//                observer.onNext(responses)
//            }
//            return Disposables.create()
//        })
    }
}

// MARK: Support Methods

private extension SocketManager {
    private func sendEvent(withName name: String, parameters: Any) {
        self.sendEvent(withName: name, parameters: parameters, completion: nil)
    }
    
    private func sendEvent(withName name: String, parameters: Any, completion: AckCallback?) {
        #if DEBUG
            print("\(Date()) socket EMIT \(name) with \(parameters)")
        #endif
        
        if let callback = completion {
            self.socketManager.defaultSocket.emitWithAck(name, with: [parameters]).timingOut(after: 30.0, callback: { (data) in
                #if DEBUG
                    print("\(Date()) socket CALLBACK \(name) with \(data)")
                #endif
                
                callback(data)
            })
        } else {
            self.socketManager.defaultSocket.emit(name, with: [parameters])
        }
    }
}
