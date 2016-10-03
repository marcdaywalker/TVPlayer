//
//  ViewController.swift
//  TVPlayer
//
//  Created by Madriz on 7/9/16.
//  Copyright © 2016 MMApps. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var player = AVPlayer()
    
    var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
//        items = atresmedia.getCategories()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let item = items[indexPath.row]
        self.textView.text = item.itemDesc
        self.imageView.loadImageFromUrl(url: item.itemImageURL)
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let indexPath = context.nextFocusedIndexPath {
            let item = items[indexPath.row]
            self.textView.text = item.itemDesc
            self.imageView.loadImageFromUrl(url: item.itemImageURL)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activity.color = .darkGray
            cell.accessoryView = activity
            activity.startAnimating()
            nextStepForIndexPath(indexPath: indexPath)
        }
    }
    
    func nextStepForIndexPath (indexPath: IndexPath) {
        let item = items[indexPath.row]
        switch item.itemType {
        case .channel:
            atresmedia().getCategories(items: { (_items) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? ViewController,
                        let _items = _items,
                    let cell = self.tableView.cellForRow(at: indexPath) {
                    viewController.items = _items
                    self.present(viewController, animated: true, completion: {
                        cell.accessoryView = nil
                        cell.accessoryType = .disclosureIndicator
                    })
                }
            })
        case .category:
            atresmedia().getProgrammesForItem(item: item, items: { (_items) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? ViewController,
                    let _items = _items,
                    let cell = self.tableView.cellForRow(at: indexPath) {
                    viewController.items = _items
                    self.present(viewController, animated: true, completion: {
                        cell.accessoryView = nil
                        cell.accessoryType = .disclosureIndicator
                    })
                }
            })
        case .program:
            atresmedia().getEpisodesForItem(item: item, items: { (_items) in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? ViewController,
                    let _items = _items,
                    let cell = self.tableView.cellForRow(at: indexPath) {
                    viewController.items = _items
                    self.present(viewController, animated: true, completion: {
                        cell.accessoryView = nil
                        cell.accessoryType = .disclosureIndicator
                    })
                }
            })
        case .episode:
            atresmedia().getEpisodeDetailsForItem(item: item, path: { (_path) in
                if let stURL = _path,
                    let url = URL(string: stURL),
                    let cell = self.tableView.cellForRow(at: indexPath) {
                    
                    
                    let asset = AVAsset(url: url)
                    let playable = asset.isPlayable
                    
                    let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
                    exporter?.outputURL = URL(fileURLWithPath: NSTemporaryDirectory())
                    exporter?.outputFileType = AVFileTypeQuickTimeMovie
                    exporter?.exportAsynchronously(completionHandler: { 
                        print(exporter!.status.rawValue)
                        print("")
                    })
                    
                    
//                    let avPlayerItem = AVPlayerItem(asset:asset)
//                    self.player = AVPlayer(playerItem: avPlayerItem)
//                    
//                    let playerViewController = AVPlayerViewController()
//                    playerViewController.player = self.player
//                    
//                    self.present(playerViewController, animated: true, completion: {
//                        cell.accessoryView = nil
//                        self.player.play()
//                    })
                }
            })
        default:
            print("")
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // Configure the cell...
        let item = items[indexPath.row]
        cell.textLabel?.text = item.itemTitle
        if item.itemType != .episode {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
}
