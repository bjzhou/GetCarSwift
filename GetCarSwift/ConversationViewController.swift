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
            let vc = UIStoryboard(name: "friend", bundle: Bundle.main).instantiateViewController(withIdentifier: "friend_profile") as? FriendProfileViewController
            vc?.uid = userId
            showViewController(vc!)
        }
    }
}
