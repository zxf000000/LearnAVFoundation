//
//  VideoPickerViewController.swift
//  FifteenSeconds_Swift
//

//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import AVKit

let VideoPickerItemCellID = "VideoItemTableViewCell"
let VideoItemCellHeight: CGFloat = 64

class VideoPickerViewController: UIViewController {

    var mediaPlaybackMediator: PlaybackMediator?
    
    var defaultItems: [VideoItem]? {
        get {
            return [VideoItem]() + videoItems[0..<3]
        }
    }

    lazy var videoItems: [VideoItem] = {
       var items = [VideoItem]()
        for (index, url) in self.videoURLs().enumerated() {
            let item = VideoItem(url: url)
            item.prepare {[weak self] (result) in
                guard let strongSelf = self else {return}
                ///
                DispatchQueue.main.async {
                    strongSelf.initialItemLoaded = true
                    strongSelf.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                }

            }
            items.append(item)
        }
        return items
    }()
    
    var initialItemLoaded: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(white: 0.206, alpha: 1)
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "VideoItemTableViewCell", bundle: nil), forCellReuseIdentifier: VideoPickerItemCellID)
        
    }

}

extension VideoPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoItems.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: VideoPickerItemCellID, for: indexPath) as! VideoItemTableViewCell
        registCellAction(cell: cell)
        let item = videoItems[indexPath.row]
        cell.setThumbnails(thumbnails: item.thumbnails ?? [UIImage]())
        
        cell.tapAddButtonBlock = {[weak self] in
            let item = self?.videoItems[indexPath.row]
            self?.mediaPlaybackMediator?.addMediaItem(item: item!, toTimelineTrack: .video)
        }
        
        return cell
    }
    
    func registCellAction(cell: VideoItemTableViewCell) {
        cell.playButton.addTarget(self, action: #selector(handlePreviewTap(sender:)), for: .touchUpInside)
//        cell.addButton.addTarget(self, action: #selector(handleAddMediaItemTap(sender:)), for: .touchUpOutside)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return VideoItemCellHeight
    }
    
    @objc
    func handlePreviewTap(sender: UIButton) {
        let indexPath = indexPathForButton(sender: sender)
        let item = videoItems[indexPath.row]
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(playerItem: AVPlayerItem(asset: item.asset!))
        present(playerVC, animated: true, completion: nil)
    }
    @objc
    func handleAddMediaItemTap(sender: UIButton) {
        let indexPath = indexPathForButton(sender: sender)
        let item = videoItems[indexPath.row]
        mediaPlaybackMediator?.addMediaItem(item: item, toTimelineTrack: .video)
    }
    
    
    func indexPathForButton(sender: UIButton) -> IndexPath {
        let point = sender.convert(sender.center, to: tableView)
        return tableView.indexPathForRow(at: point)!
    }

    func videoURLs() -> [URL] {
        var urls = [URL]()
        
        urls.append(contentsOf: Bundle.main.urls(forResourcesWithExtension: "mov", subdirectory: nil)!)
        urls.append(contentsOf: Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil)!)

        return urls;
    }
    
}
