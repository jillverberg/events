//
//  ErrorsTexts.swift
//  giftadvice
//
//  Created by Efimenko George on 02/02/19.
//  Copyright © 2019 Efimenko George. All rights reserved.
//

// MARK: Errors Titles and Texts

extension AppTexts {
    struct Errors {
        struct Texts {
//            static func <#exampleErrorText#>() -> String {
//                return <#exampleErrorText#>
//            }
//            
            static func screenDisconnected() -> String {
                return "Screen was disconnected."
            }
            
            static func consultationStopped() -> String {
                return "Consultation was stopped."
            }
            
            static func badServerData() -> String {
                return "Server error. Bad data."
            }
            
            static func requestTimedOut() -> String {
                return "Server isn't reachable. Please, try again later."
                
            }
            
            static func internetNotReachable() -> String {
                return "Your device is not connected to the Internet. Please check connection and try again."
            }
            
            static func socketNotConnected() -> String {
                return "Some problem with socket connection."
            }
        }
        
        struct Titles {
            static func errorOccurred() -> String {
                return "An error has occurred"
            }
            
            static func errorsOccurred() -> String {
                return "An errors has occurred:"
            }
            
            static func mediaPermissionsDenied(microphonePermitted: Bool, cameraPermitted: Bool) -> String {
                if !microphonePermitted && !cameraPermitted {
                    return "Microphone and camera permissions are denied"
                } else if !microphonePermitted {
                    return "Microphone permission is denied"
                } else {
                    return "Camera permission is denied"
                }
            }
        }
    }
}
