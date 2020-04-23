//
//  TransitionViewController.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

protocol TransitionViewControllerDelegate {
    func transitionSelected()
}

class TransitionViewController: UITableViewController {
    public var delegate: TransitionViewControllerDelegate?
    
    var transition: VideoTransition?
    var transitionTypes: [String]?
    
    init(transition: VideoTransition) {
        super.init(nibName: nil, bundle: nil)
        self.transition = transition
        transitionTypes = ["None","Dissolve","Push"]
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.isScrollEnabled = false
        preferredContentSize = CGSize(width: 200, height: 140)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transitionTypes?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            cell?.selectionStyle = .none
        }
        let type = transitionTypes?[indexPath.row] ?? ""
        cell?.textLabel?.text = type
        if transition?.type == transitionTypeFrom(type: type) {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let currentIndexPath = tableView.indexPathForSelectedRow
        if currentIndexPath != indexPath {
            tableView.deselectRow(at: currentIndexPath!, animated: true)
        }
        return indexPath
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = transitionTypes?[indexPath.row]
        transition?.type = transitionTypeFrom(type: type!)
        tableView.reloadData()
        delegate?.transitionSelected()
        
    }
    
    func transitionTypeFrom(type: String) -> VideoTransitionType {
        if type == "Dissolve" {
            return .dissolve
        } else if type == "Push" {
            return .push
        } else {
            return .none
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
