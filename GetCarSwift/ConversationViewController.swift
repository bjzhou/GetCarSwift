//
//  ConversationViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 16/1/7.
//  Copyright © 2016年 周斌佳. All rights reserved.
//

import Foundation

class ConversationViewController: RCConversationViewController {

    var fromProfile = false
    var fromSearch = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if fromSearch {
            self.conversationMessageCollectionView.contentInset.top = 44
        }
    }

    override func didTapCellPortrait(_ userId: String!) {
        if fromProfile {
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            let vc = R.storyboard.friend.friend_profile
            vc?.uid = userId
            showViewController(vc!)
        }
    }
}
