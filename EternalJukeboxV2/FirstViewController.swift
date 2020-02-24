//
//  FirstViewController.swift
//  EternalJukeboxV2
//
//  Created by Bryce Harty on 1/28/20.
//  Copyright © 2020 OrangeTeam. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    fileprivate let SpotifyClientID = "d9f3190f802641938b898e9a418faf9e"
    fileprivate let SpotifyRedirectURI = URL(string: "OrangeTeam.EternalJukebox://login-callback")!
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI)
        
        configuration.playURI = "spotify:track:7p5bQJB4XsZJEEn6Tb7EaL"
        
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
    
        
        return configuration
    }()
    
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
    }()

    fileprivate var lastPlayerState: SPTAppRemotePlayerState?
    var defualtCallback: SPTAppRemoteCallback?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    // MARK: -UI Element Links to Function

    
    @IBAction func Login(_ sender: Any) {
        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate]
         
        if #available(iOS 11, *) {
                   // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
            sessionManager.initiateSession(with: scope, options: .clientOnly)
        } else {
                   // Use this on iOS versions < 11 to use SFSafariViewController
            sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
               }
        //let trackid = "08td7MxkoHQkXnWAYD8d6Q"
        //appRemote.authorizeAndPlayURI(trackid)
        
        //sleep(7)
        //appRemote.connectionParameters.accessToken = sessionManager.session?.accessToken
        //appRemote.connect()
        
        //let test = appRemote.isConnected
        //print(test)
        //appRemote.connect()
        //test = appRemote.isConnected
        //print(test)

    }
    
    
    @IBAction func Play(_ sender: Any) {
        ///this works it just does not do anything
        //SPTAppRemotePlayerAPI.pause(nil)
//        self.appRemote.playerAPI?.pause(defualtCallback)
    
  //      self.appRemote.playerAPI?.seek(toPosition: 15, callback: nil)
        //appRemote.playerAPI?.seekForward15Seconds(defaultCallback)
        

        //
//        var test = appRemote.isConnected
//        print(test)
//        appRemote.connect()
//        test = appRemote.isConnected
//        print(test)
        
        
    }
    
    
    
    
    // MARK: - SPTSessionManagerDelegate
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        appRemote.connectionParameters.accessToken = session.accessToken
        print("HOLY GHOST")
        //connects the appRemote
        appRemote.connect()
    }
    
    // MARK: -SPTAppRemoteDelegate
    
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        //updateViewBasedOnConnected()
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print("ERROR 2")
                print("Error subscribing to player state:" + error.localizedDescription)
            }
        })
        ///fetchPlayerState()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        //updateViewBasedOnConnected()
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        //updateViewBasedOnConnected()
        lastPlayerState = nil
    }
    
    //MARK: - SPTAppRemotePlayerAPIDelegate
    
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        //update(playerState: playerState)
    }
    
    //MARK: -Private Helpers
    
    fileprivate func presentAlertController(title: String, message: String, buttonTitle: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        controller.addAction(action)
        present(controller, animated: true)
    }
    func fetchSpotProfile(accessToken: String){
        let tokenURLFull = "https://api.spotify.com/v1/me"
        let verify: NSURL = NSURL(string: tokenURLFull)!
        let request: NSMutableURLRequest = NSMutableURLRequest(url: verify as URL)
        request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if error == nil {
                let result = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [AnyHashable: Any]
                //AccessToken
                print("Spotify Access Token: \(accessToken)")
                //Spotify Handle
                let spotifyId: String! = (result?["id"] as! String)
                print("Spotify Id: \(spotifyId ?? "")")
                //Spotify Display Name
                let spotifyDisplayName: String! = (result?["display_name"] as! String)
                print("Spotify Display Name: \(spotifyDisplayName ?? "")")
                //Spotify Email
                let spotifyEmail: String! = (result?["email"] as! String)
                print("Spotify Email: \(spotifyEmail ?? "")")
                //Spotify Profile Avatar URL
                let spotifyAvatarURL: String!
                let spotifyProfilePicArray = result?["images"] as? [AnyObject]
                if (spotifyProfilePicArray?.count)! > 0 {
                    spotifyAvatarURL = spotifyProfilePicArray![0]["url"] as? String
                } else {
                    spotifyAvatarURL = "Not exists"
                }
                print("Spotify Profile Avatar URL: \(spotifyAvatarURL ?? "")")
            }
        }
    }

}
