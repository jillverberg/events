//
//  InfoPlistService.swift
//  <%= @project %>
//
//  Created by <%= @author %> on <%= @date %>.
//  Copyright © 2018 ForaSoft. All rights reserved.
//

import Foundation

class InfoPlistService {
    private struct Keys {
        static let keysAndTokens = "ConstantsDictionary"
        
        static let serverURL = "server_url"
        static let serverPort = "server_port"
        static let hockeyAppApplicationIdentifier = "hockeyapp_app_identifier"
        static let securityToken = "security_token"
        static let socketToken = "socket_token"
    }
    
    // MARK: Public Properties
    
    static let shared = InfoPlistService()
    
    // MARK: Private Properties
    
    private var info: [String:Any]?
    
    // MARK: Init Methods & Superclass Overriders
    
    init() {
        info = Bundle.main.object(forInfoDictionaryKey: Keys.keysAndTokens) as? [String:Any]
    }
    
    // MARK: Public Methods
    
    /// Gets HockeyApp application identifier from Info.plist for current build scheme.
    ///
    /// - returns: HockeyApp application identifier or nil.
    ///
    func hockeyAppApplicationIdentifier() -> String? {
        if let string = info?[Keys.hockeyAppApplicationIdentifier] as? String {
            let clearString = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            return clearString
        }
        
        return nil
    }
    
    /// Gets server URL value from Info.plist for current build scheme.
    ///
    /// - returns: Server URL as a string.
    ///
    func serverURL() -> String {
        if let string = info?[Keys.serverURL] as? String {
            let clearString = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            return clearString
        }
        
        return ""
    }
    
    /// Gets server port value from Info.plist for current build scheme.
    ///
    /// - returns: Server port as a string.
    ///
    func serverPort() -> String {
        if let string = info?[Keys.serverPort] as? String {
            let clearString = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            return clearString
        }
        
        return ""
    }
    
    /// Gets security token value from Info.plist for current build scheme.
    ///
    /// - returns: Security token URL as a string.
    ///
    func securityToken() -> String {
        if let string = info?[Keys.securityToken] as? String {
            let clearString = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            return clearString
        }
        
        return ""
    }
    
    /// Gets socket token value from Info.plist for current build scheme.
    ///
    /// - returns: Security token URL as a string.
    ///
    func socketToken() -> String {
        if let string = info?[Keys.socketToken] as? String {
            let clearString = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            return clearString
        }
        
        return ""
    }
    
}
