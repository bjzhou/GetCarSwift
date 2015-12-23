//
//  CarInfoView.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/12/23.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RxSwift

class CarInfoView: UIView {

    private var button: UIButton!
    private var textLabel: UILabel!
    private var buttonDispose: Disposable?

    var didButtonTapped: () -> Void = {} {
        didSet {
            buttonDispose?.dispose()
            buttonDispose = button.rx_tap.subscribeNext(didButtonTapped)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10

        button = UIButton()
        button.contentHorizontalAlignment = .Left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: button, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0))

        textLabel = UILabel()
        textLabel.numberOfLines = 0
        self.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: textLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: textLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 105))
    }

    func updateLogo(logoUrl: String) {
        button.kf_setImageWithURL(NSURL(string: logoUrl)!, forState: .Normal, placeholderImage: R.image.example_car_logo)
    }

    func updateText(title: String, year: String? = nil, detail: String? = nil, license: String? = nil) {
        let attrStr = NSMutableAttributedString(string: title)
        var text = ""
        if let year = year where year.trim() != "" {
            text += year + " "
        }
        if let detail = detail where detail.trim() != "" {
            text += detail
        }
        if let license = license where license.trim() != "" {
            if text == "" {
                text += license
            } else {
                text += "\n" + license
            }
        }
        if text != "" {
            attrStr.appendAttributedString(NSAttributedString(string: "\n\(text)", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName: UIColor.darkGrayColor()]))
        }
        textLabel.attributedText = attrStr
    }
}
