//
//  InfoEditViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/16.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

enum InfoEditMode: Int {
    case Sex
    case Nickname
    case Address
    case District
    case Sign
}

class InfoEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var mode: InfoEditMode = .Sex
    var nickname = ""

    init(mode: InfoEditMode) {
        super.init(nibName: nil, bundle: nil)
        self.mode = mode
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initSubView()
    }

    func initSubView() {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height), style: UITableViewStyle.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "infoEdit")
        self.view.addSubview(tableView)

        switch mode {
        case .Sex:
            self.title = "性别"
        case .Nickname:
            self.title = "昵称"
            tableView.allowsSelection = false
            let saveItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.Done, target: self, action: "didSave")
            self.navigationItem.setRightBarButtonItem(saveItem, animated: false)
        default:
            break
        }
    }

    func didSave() {
        switch mode {
        case .Nickname:
            Mine.sharedInstance.nickname = nickname
            _ = User.updateInfo(nickname: nickname).subscribeNext { user in
                if let nickname = user.data?.nickname {
                    Mine.sharedInstance.nickname = nickname
                }
            }
        default:
            break
        }

        self.navigationController?.popViewControllerAnimated(true)
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .Sex:
            return 2
        case .Nickname:
            return 1
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("infoEdit", forIndexPath: indexPath)

        switch mode {
        case .Sex:
            if indexPath.row == 0 {
                cell.textLabel?.text = "男"
            } else {
                cell.textLabel?.text = "女"
            }
            cell.accessoryView = UIImageView(image: indexPath.row != Mine.sharedInstance.sex ? R.image.accessory_selected : R.image.accessory)
        case .Nickname:
            let textField = UITextField(frame: CGRect(x: 8, y: 20, width: cell.frame.width - 16, height: cell.frame.height - 40))
            textField.text = Mine.sharedInstance.nickname
            textField.clearButtonMode = .WhileEditing
            textField.becomeFirstResponder()
            _ = textField.rx_text.subscribeNext { text in
                if text.characters.count > 15 {
                    textField.text = text.substringToIndex(text.startIndex.advancedBy(15))
                }
                self.nickname = textField.text!
            }
            cell.addSubview(textField)
            break
        default:
            break
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch mode {
        case .Sex:
            Mine.sharedInstance.sex = indexPath.row == 1 ? 0 : 1
            _ = User.updateInfo(sex: indexPath.row == 1 ? 0 : 1).subscribeNext { user in
                if let sex = user.data?.sex {
                    Mine.sharedInstance.sex = sex
                }
            }
            tableView.reloadData()
            self.navigationController?.popViewControllerAnimated(true)
        default:
            break
        }
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}
