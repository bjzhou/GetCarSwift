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

    var sid = 0

    var lovedCount = 1000 {
        didSet {
            updateLoveLabel()
        }
    }

    var hideStar = false {
        didSet {
            trackStar.isHidden = hideStar
            trackStarLabel.isHidden = hideStar
            loveView.isHidden = hideStar
        }
    }

    var delegate: TrackCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        loveButton.setImage(UIImage(), for: .selected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func didTapLove(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        _ = Praise.praise(sid: sid, status: sender.isSelected ? 1 : 0).subscribeNext { res in
            self.lovedCount = self.lovedCount + (sender.isSelected ? 1 : -1)
            self.delegate?.didTrackChanged()
        }
    }

    func updateLoveLabel() {
        let loveStr = (loveButton.isSelected ? "已" : "") + "想去"
        if lovedCount <= 0 {
            loveLabel.text = loveStr
        } else if lovedCount >= 1000 {
            loveLabel.text = loveStr + "(999+)"
        } else {
            loveLabel.text = loveStr + "(\(lovedCount))"
        }
    }

}
