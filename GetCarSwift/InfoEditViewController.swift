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
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height), style: UITableViewStyle.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "infoEdit")
        self.view.addSubview(tableView)

        switch mode {
        case .Sex:
            self.title = "性别"
        case .Nickname:
            self.title = "昵称"
            tableView.allowsSelection = false
            let saveItem = UIBarButtonItem(title: "保存", style: UIBarButtonItemStyle.done, target: self, action: #selector(InfoEditViewController.didSave))
            self.navigationItem.setRightBarButton(saveItem, animated: false)
        default:
            break
        }
    }

    func didSave() {
        switch mode {
        case .Nickname:
            if nickname.trim() == "" {
                Toast.makeToast(message: "请输入昵称")
                return
            }
            Mine.sharedInstance.nickname = nickname
            _ = User.updateInfo(nickname: nickname).subscribe(onNext: { res in
                if let user = res.data {
                    Mine.sharedInstance.updateLogin(user)
                }
            })
        default:
            break
        }

        _ = self.navigationController?.popViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .Sex:
            return 2
        case .Nickname:
            return 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "infoEdit", for: indexPath)

        switch mode {
        case .Sex:
            if (indexPath as NSIndexPath).row == 0 {
                cell.textLabel?.text = "男"
            } else {
                cell.textLabel?.text = "女"
            }
            cell.accessoryView = UIImageView(image: (indexPath as NSIndexPath).row != Mine.sharedInstance.sex ? R.image.accessory_selected() : R.image.accessory())
        case .Nickname:
            let textField = UITextField(frame: CGRect(x: 8, y: 20, width: cell.frame.width - 16, height: cell.frame.height - 40))
            textField.text = Mine.sharedInstance.nickname
            textField.clearButtonMode = .whileEditing
            textField.becomeFirstResponder()
            _ = textField.rx.text.takeUntil(self.rx.deallocated).subscribe(onNext: { text in
                if text.characters.count > 15 {
                    textField.text = text.substring(to: text.characters.index(text.startIndex, offsetBy: 15))
                }
                self.nickname = textField.text!
            })
            cell.addSubview(textField)
            break
        default:
            break
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch mode {
        case .Sex:
            Mine.sharedInstance.sex = (indexPath as NSIndexPath).row == 1 ? 0 : 1
            _ = User.updateInfo(sex: indexPath.row == 1 ? 0 : 1).subscribe(onNext: { res in
                if let user = res.data {
                    Mine.sharedInstance.updateLogin(user)
                }
            })
            tableView.reloadData()
            _ = self.navigationController?.popViewController(animated: true)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}
