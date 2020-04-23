//
//  AppSettings.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import Foundation



class AppSettings {
    static let shared = AppSettings()
    

    let TRANSITIONS_ENABLED_KEY =       "transitionsEnabled"
    let VOLUME_FADES_ENABLED_KEY =      "volumeFadesEnabled"
    let VOLUME_DUCKING_ENABLED_KEY =    "volumeDuckingEnabled"
    let TITLES_ENABLED_KEY =            "titlesEnabled"
    
    var transitionEnabled: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: TRANSITIONS_ENABLED_KEY)
        }
        get {
            return UserDefaults.standard.bool(forKey: TRANSITIONS_ENABLED_KEY)
        }
    }
    
    var volumeFadesEnabled: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: VOLUME_FADES_ENABLED_KEY)
        }
        get {
            return UserDefaults.standard.bool(forKey: VOLUME_FADES_ENABLED_KEY)
        }
    }
    
    var volumeDuckingEnabled: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: VOLUME_DUCKING_ENABLED_KEY)
        }
        get {
            return UserDefaults.standard.bool(forKey: VOLUME_DUCKING_ENABLED_KEY)
        }
    }
    
    var titlesEnabled: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: TITLES_ENABLED_KEY)
        }
        get {
            return UserDefaults.standard.bool(forKey: TITLES_ENABLED_KEY)
        }
    }

    func save() {
        UserDefaults.standard.synchronize()
    }
}
