//
//  ModStoreDetailViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/8/9.
//  Copyright © 2015年 &#21608;&#25996;&#20339;. All rights reserved.
//

import UIKit

class ModStoreDetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let topBgs = ["bmw3_top_bg", "bmw3_top_bg2"]

    override func viewDidLoad() {
        super.viewDidLoad()

        initPageView()
    }

    func initPageView() {
        scrollView.layoutIfNeeded()
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(topBgs.count), height: scrollView.frame.size.height)
        for var i=0;i<topBgs.count;i++ {
            let imageView = UIImageView(image: UIImage(named: topBgs[i]))
            imageView.frame = CGRectMake(scrollView.frame.size.width * CGFloat(i), 0, scrollView.frame.size.width, scrollView.frame.size.height)
            scrollView.addSubview(imageView)
        }
        scrollView.delegate = self
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = index
    }

    @IBAction func onPageChanged(sender: UIPageControl) {
        let index = sender.currentPage
        scrollView.setContentOffset(CGPointMake(scrollView.frame.size.width*CGFloat(index), 0), animated: true)
    }
}
