//
//  AudioPickerViewController.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

let THPlaybackEndedNotification = Notification.Name("THPlaybackEndedNotification")

let HEADER_HEIGHT = 34.0

let AudioItemTableViewCellID = "AudioItemTableViewCell";

class AudioPickerViewController: UIViewController {

    var playbackMediator: PlaybackMediator?
    
    var defaultVoiceOver: AudioItem? {
        get {
            return voiceOverItems.first
        }
    }
    var defaultMusicTrack: AudioItem? {
        get {
            return musicItems.first
        }
    }
    
    lazy var musicItems: [AudioItem] = {
        var items = [AudioItem]()
        for (index, url) in musicURLs().enumerated() {
            let item = AudioItem(url: url)
            item.prepare { (result) in
                
            }
            items.append(item)
        }
        return items
    }()
    lazy var voiceOverItems: [AudioItem] = {
        var items = [AudioItem]()
        for (index, url) in voiceOverURLs().enumerated() {
            let item = AudioItem(url: url)
            item.prepare { (result) in
                
            }
            items.append(item)
        }
        return items
    }()
    var allAudioItems: [Array<AudioItem>]?
    var previewCompleted: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allAudioItems = [musicItems ,voiceOverItems]
        
        self.tableView.separatorStyle = .singleLine;
        self.tableView.separatorInset = .zero;
        tableView.register(UINib(nibName: "AudioItemTableViewCell", bundle: nil), forCellReuseIdentifier: AudioItemTableViewCellID)
        NotificationCenter.default.addObserver(self, selector: #selector(previewComplete(notification:)), name: THPlaybackEndedNotification, object: nil)
        
    }
    
    @objc
    func previewComplete(notification: Notification) {
        previewCompleted = true
        tableView.reloadData()
    }

    
    func musicURLs() -> [URL] {
        return Bundle.main.urls(forResourcesWithExtension: "m4a", subdirectory: "Music")!
    }

    func voiceOverURLs() -> [URL] {
        return Bundle.main.urls(forResourcesWithExtension: "m4a", subdirectory: "VoiceOvers")!
    }
}

extension AudioPickerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AudioItemTableViewCellID, for: indexPath) as! AudioItemTableViewCell
        let item = allAudioItems?[indexPath.section][indexPath.row]
        cell.titleLabel.text = item?.title
        cell.previewButton.isSelected = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = allAudioItems?[indexPath.section][indexPath.row] else {return}
        let type = indexPath.section == 0 ? MediaTrackType.music : MediaTrackType.commontary
        playbackMediator?.addMediaItem(item: item, toTimelineTrack: type)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allAudioItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Music" : "Voice Overs";
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAudioItems?[section].count ?? 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(HEADER_HEIGHT)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(HEADER_HEIGHT * 1.5)
    }
    
    
    func indexPathForButton(sender: UIButton) -> IndexPath {
        let point = sender.convert(sender.center, to: tableView)
        return tableView.indexPathForRow(at: point)!
    }
}
