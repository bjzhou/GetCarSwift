//
//  TrackTableViewCell.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/20.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit

protocol TrackCellDelegate {
    func didTrackChanged()
}

class TrackTableViewCell: UITableViewCell {

    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var trackBg: UIImageView!
    @IBOutlet weak var trackStar: UIImageView!
    @IBOutlet weak var loveButton: UIButton!
    @IBOutlet weak var loveLabel: UILabel!
    @IBOutlet weak var trackStarLabel: UILabel!
    @IBOutlet weak var loveView: UIView!
    @IBOutlet weak var mask: UIView!

    var sid = 0

    var lovedCount = 1000 {
        didSet {
            updateLoveLabel()
        }
    }

    var hideStar = false {
        didSet {
            trackStar.hidden = hideStar
            trackStarLabel.hidden = hideStar
            loveView.hidden = hideStar
        }
    }

    var delegate: TrackCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        loveButton.setImage(UIImage(), forState: .Selected)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func didTapLove(sender: UIButton) {
        sender.selected = !sender.selected
        _ = Praise.praise(sid: sid, status: sender.selected ? 1 : 0).subscribeNext { res in
        }
        lovedCount = lovedCount + (sender.selected ? 1 : -1)
        delegate?.didTrackChanged()
    }

    func updateLoveLabel() {
        let loveStr = (loveButton.selected ? "已" : "") + "想去"
        if lovedCount <= 0 {
            loveLabel.text = loveStr
        } else if lovedCount >= 1000 {
            loveLabel.text = loveStr + "(999+)"
        } else {
            loveLabel.text = loveStr + "(\(lovedCount))"
        }
    }

}
