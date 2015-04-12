//
//  IntroduceCotentView.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class IntroduceCotentView: UIView {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var message: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NSBundle.mainBundle().loadNibNamed("IntroduceContentView", owner: self, options: nil)
        
        view.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
        view.layer.cornerRadius = 20.0
        
        addSubview(view)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
