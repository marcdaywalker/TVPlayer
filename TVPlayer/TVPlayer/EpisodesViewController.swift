//
//  EpisodesViewController.swift
//  TVPlayer
//
//  Created by Madriz on 14/9/16.
//  Copyright © 2016 MMApps. All rights reserved.
//

import UIKit
import AVKit

class EpisodesViewController: UIViewController {
    
    struct Episode {
        var titleEpisode: String?
        var contentPk: String?
        
        init(dic: NSDictionary) {
            
            if let episode = dic.object(forKey: "episode") as? [String:AnyObject],
                 let title = episode["title"] as? String,
                 let titleSection = episode["titleSection"] as? String,
                 let type = episode["type"]  as? String, type == "FREE" {
                
                titleEpisode = String("\(titleSection) - \(title)")
                contentPk = episode["contentPk"] as? String
            }
            
        }
    }
    
    @IBOutlet weak var tableview: UITableView!
    fileprivate var episodes = [Episode]()
    fileprivate var player = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        if let url = URL(string: "https://servicios.atresplayer.com/api/highlights") {
            //            let request = NSURLRequest(URL: url)
            let mutableRequest = NSMutableURLRequest(url: url)
            mutableRequest.addValue("Dalvik/1.6.0 (Linux; U; Android 4.3; GT-I9300 Build/JSS15J", forHTTPHeaderField: "User-Agent")
            let request: URLRequest = mutableRequest.copy() as! URLRequest
            var response: URLResponse?
            let a = try! NSURLConnection.sendSynchronousRequest(request, returning: &response)
            if let b = try! JSONSerialization.jsonObject(with: a, options: .allowFragments) as? NSDictionary {
                if let c = b["items"] as? NSArray {
                    for episode in c {
                        if let episode = episode as? NSDictionary {
                            let ep = Episode(dic: episode)
                            if ep.titleEpisode != nil {
                                episodes.append(ep)
                            }
                        }
                    }
                }
            }
        }

        
    }
    
    
    fileprivate func episodeSelected (_ episode: Episode) -> String? {
        guard let episode = episode.contentPk else { return nil }
        
        let token = d(episode, s1: "QWtMLXs414Yo+c#_+Q#K@NN)")
        
        let strURL = "https://servicios.atresplayer.com/api/urlVideo/\(episode)/android_phone/\(token)"
        let escapedString = strURL.addingPercentEscapes(using: String.Encoding.utf8)
        
        
        if let url = URL(string: escapedString!) {
            let mutableRequest = NSMutableURLRequest(url: url)
            mutableRequest.addValue("Dalvik/1.6.0 (Linux; U; Android 4.3; GT-I9300 Build/JSS15J", forHTTPHeaderField: "User-Agent")
            let request: URLRequest = mutableRequest.copy() as! URLRequest
            var response: URLResponse?
            let a = try! NSURLConnection.sendSynchronousRequest(request, returning: &response)
            if let b = try! JSONSerialization.jsonObject(with: a, options: .allowFragments) as? NSDictionary {
                if b["resultDes"] as? String ?? "KO" == "OK" {
                    let stURL = b.value(forKeyPath: "resultObject.es") as? String
                    return stURL
                }
            }
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension EpisodesViewController {
    func getApiTime () -> Int {
        if let url = URL(string: "https://servicios.atresplayer.com/api/admin/time") {
            let request = URLRequest(url: url)
            var response: URLResponse?
            let a = try! NSURLConnection.sendSynchronousRequest(request, returning: &response)
            
            if let b = String(data: a, encoding: String.Encoding.utf8), let rdo = CLong(b) {
                return rdo / 1000
            }
            
        }
        
        return -1
        
    }
    
    func d(_ s: String, s1: String) -> String {
        let l = 30000 + getApiTime()
        let s2 = e(s+String(l), s1: s1)
        return String("\(s)|\(String(l))|\(s2)")
    }
    
    func e(_ s: String, s1: String) -> String {
        let a = s.md5(s1)
        return hexdigest(a)
    }
    
    fileprivate func hexdigest(_ data: Data) -> String {
        var hex = String()
        let bytes = (data as NSData).bytes.bindMemory(to: CUnsignedChar.self, capacity: data.count)
        for i: Int in 0 ..< data.count {
            hex += String(format: "%02x", bytes[i])
        }
        return hex
    }
}

extension EpisodesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = episodes[(indexPath as NSIndexPath).row]
        if let stURL = episodeSelected(episode) {
            if let url = URL(string: stURL) {
                
    
                let asset = AVAsset(url: url)
                
                let avPlayerItem = AVPlayerItem(asset:asset)
                player = AVPlayer(playerItem: avPlayerItem)
                
                
                
                let avPlayerLayer  = AVPlayerLayer(player: player)
                avPlayerLayer.frame = CGRect(x: 0, y: 0, width: 500, height: 500)
                avPlayerLayer.backgroundColor = UIColor.red.cgColor
                self.view.layer.addSublayer(avPlayerLayer)
                player.play()
                
                
                
//                player = AVPlayer(url: url)
//                
//                print(url)
//                let playerController = AVPlayerViewController()
//                playerController.delegate = self
//                playerController.player =  player
//                
//                present(playerController, animated: true, completion: {
//                    let status = playerController.player?.status
//                    playerController.player?.play()
//                })
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension EpisodesViewController: AVPlayerViewControllerDelegate {

}

extension EpisodesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let episode = episodes[(indexPath as NSIndexPath).row] as? Episode {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.textLabel?.text = episode.titleEpisode
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
}
