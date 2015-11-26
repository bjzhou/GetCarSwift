//
//  AddCarViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/5/17.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

protocol AddCarDelegate {
    func onCarAdded(license: String, name: String, brandIndex: Int)
}

class AddCarViewController: UITableViewController, BrandsDelegate {

    var brand = 0
    var delegate: AddCarDelegate?

    @IBOutlet weak var license: UITextField!
    @IBOutlet weak var name: UITextField!

    func brandChanged(index: Int) {
        brand = index
        NSLog("brandChanged : " + String(index))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let brandsViewController = segue.destinationViewController as! BrandsViewController
        brandsViewController.delegate = self
        brandsViewController.currentBrand = brand
    }

    @IBAction func onAddAction(sender: UIBarButtonItem) {
        delegate?.onCarAdded(license.text ?? "", name: name.text ?? "", brandIndex: brand)
        navigationController?.popViewControllerAnimated(true)
    }
}
