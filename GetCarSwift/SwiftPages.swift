//
//  SwiftPages.swift
//  SwiftPages
//
//  Created by Gabriel Alvarado on 6/27/15.
//  Copyright (c) 2015 Gabriel Alvarado. All rights reserved.
//

import UIKit

public class SwiftPages: UIView, UIScrollViewDelegate {

    //Items variables
    private var containerView: UIView!
    private var scrollView: UIScrollView!
    private var topBar: UIView!
    private var animatedBar: UIView!
    //private var viewControllerIDs: [String] = []
    private var buttonTitles: [String] = []
    private var buttonImages: [UIImage] = []
    private var pageViews: [UIViewController] = []

    //Container view position variables
    private var xOrigin: CGFloat = 0
    private var yOrigin: CGFloat = 0
    private var distanceToBottom: CGFloat = 0

    //Color variables
    private var topBarImage = R.image.pages_bg()
    private var buttonsTextColor = UIColor.white
    private var containerViewBackground = UIColor.gaikeBackgroundColor()

    //Item size variables
    private var topBarHeight: CGFloat = 36
    private var animatedBarHeight: CGFloat = 4

    //Bar item variables
    private var transparentTopBar: Bool = true
    private var aeroEffectInTopBar: Bool = false //This gives the top bap a blurred effect, also overlayes the it over the VC's
    private var buttonsWithImages: Bool = false
    private var barShadow: Bool = false
    private var buttonsTextFontAndSize: UIFont = UIFont.systemFont(ofSize: 16)

    // MARK: - Positions Of The Container View API -
    public func setOriginX(_ origin: CGFloat) { xOrigin = origin }
    public func setOriginY(_ origin: CGFloat) { yOrigin = origin }
    public func setDistanceToBottom (_ distance: CGFloat) { distanceToBottom = distance }

    // MARK: - API's -
    public func setTopBarImage(_ image: UIImage?) { topBarImage = image }
    public func setButtonsTextColor(_ color: UIColor) { buttonsTextColor = color }
    public func setContainerViewBackground(_ color: UIColor) { containerViewBackground = color }
    public func setTopBarHeight(_ pointSize: CGFloat) { topBarHeight = pointSize}
    public func setAnimatedBarHeight(_ pointSize: CGFloat) { animatedBarHeight = pointSize}
    public func setButtonsTextFontAndSize(_ fontAndSize: UIFont) { buttonsTextFontAndSize = fontAndSize}
    public func enableAeroEffectInTopBar(_ boolValue: Bool) { aeroEffectInTopBar = boolValue}
    public func enableButtonsWithImages(_ boolValue: Bool) { buttonsWithImages = boolValue}
    public func enableBarShadow(_ boolValue: Bool) { barShadow = boolValue}
    public func getPageViewController(_ index: Int) -> UIViewController? { return pageViews[index] }

    public override func draw(_ rect: CGRect) {
        if containerView == nil {
            initSubViews()
        }
    }

    func initSubViews() {

        //Size Of The Container View
        let pagesContainerHeight = self.frame.height - yOrigin - distanceToBottom
        let pagesContainerWidth = self.frame.width

        //Set the containerView, every item is constructed relative to this view
        containerView = UIView(frame: CGRect(x: xOrigin, y: yOrigin, width: pagesContainerWidth, height: pagesContainerHeight))
        containerView.backgroundColor = containerViewBackground
        self.addSubview(containerView)

        //Set the scrollview
        if (aeroEffectInTopBar || transparentTopBar) {
            scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height))
        } else {
            scrollView = UIScrollView(frame: CGRect(x: 0, y: topBarHeight, width: containerView.frame.size.width, height: containerView.frame.size.height - topBarHeight))
        }
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.delaysContentTouches = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.bounces = false
        containerView.addSubview(scrollView)

        //Set the top bar
        topBar = UIView(frame: CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: topBarHeight))
        let imageView = UIImageView(image: topBarImage)
        imageView.frame = topBar.frame
        topBar.addSubview(imageView)
        if (aeroEffectInTopBar) {
            //Create the blurred visual effect
            //You can choose between ExtraLight, Light and Dark
            topBar.backgroundColor = UIColor.clear
            let blurEffect: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = topBar.bounds
            blurView.translatesAutoresizingMaskIntoConstraints = false
            topBar.addSubview(blurView)
        }
        containerView.addSubview(topBar)

        //Set the top bar buttons
        var buttonsXPosition: CGFloat = 0
        var buttonNumber = 0
        //Check to see if the top bar will be created with images ot text
        if (!buttonsWithImages) {
            for _ in buttonTitles {
                var barButton: UIButton!
                barButton = UIButton(frame: CGRect(x: buttonsXPosition, y: 0, width: containerView.frame.size.width/(CGFloat)(pageViews.count), height: topBarHeight))
                barButton.backgroundColor = UIColor.clear
                barButton.titleLabel!.font = buttonsTextFontAndSize
                barButton.setTitle(buttonTitles[buttonNumber], for: UIControlState())
                barButton.setTitleColor(buttonsTextColor, for: UIControlState())
                barButton.tag = buttonNumber
                barButton.addTarget(self, action: #selector(SwiftPages.barButtonAction(_:)), for: UIControlEvents.touchUpInside)
                topBar.addSubview(barButton)
                buttonsXPosition = containerView.frame.size.width/(CGFloat)(pageViews.count) + buttonsXPosition
                buttonNumber += 1
            }
        } else {
            for item in buttonImages {
                var barButton: UIButton!
                barButton = UIButton(frame: CGRect(x: buttonsXPosition, y: 0, width: containerView.frame.size.width/(CGFloat)(pageViews.count), height: topBarHeight))
                barButton.backgroundColor = UIColor.clear
                barButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
                barButton.setImage(item, for: UIControlState())
                barButton.tag = buttonNumber
                barButton.addTarget(self, action: #selector(SwiftPages.barButtonAction(_:)), for: UIControlEvents.touchUpInside)
                topBar.addSubview(barButton)
                buttonsXPosition = containerView.frame.size.width/(CGFloat)(pageViews.count) + buttonsXPosition
                buttonNumber += 1
            }
        }


        //Set up the animated UIView
        animatedBar = UIImageView(image: R.image.scroll_bar())
        animatedBar.frame = CGRect(x: 0, y: topBarHeight - animatedBarHeight + 1, width: (containerView.frame.size.width/(CGFloat)(pageViews.count))*0.8, height: animatedBarHeight)
        animatedBar.center.x = containerView.frame.size.width/(CGFloat)(pageViews.count * 2)
        //animatedBar.backgroundColor = animatedBarColor
        containerView.addSubview(animatedBar)

        //Add the bar shadow (set to true or false with the barShadow var)
        if (barShadow) {
            let shadowView = UIView(frame: CGRect(x: 0, y: topBarHeight, width: containerView.frame.size.width, height: 4))
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = shadowView.bounds
            gradient.colors = [UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.28).cgColor, UIColor.clear.cgColor]
            shadowView.layer.insertSublayer(gradient, at: 0)
            containerView.addSubview(shadowView)
        }

        let pageCount = pageViews.count

        //Defining the content size of the scrollview
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageCount),
            height: pagesScrollViewSize.height)

        //Load the pages to show initially
        loadVisiblePages()
    }

    // MARK: - Initialization Functions -
    public func initializeWithVCsArrayAndButtonTitlesArray (_ vcs: [UIViewController], buttonTitlesArray: [String], sender: UIViewController) {
        //Important - Titles Array must Have The Same Number Of Items As The viewControllerIDs Array
        if vcs.count == buttonTitlesArray.count {
            for vc in vcs {
                sender.addChildViewController(vc)
                vc.didMove(toParentViewController: sender)
                pageViews.append(vc)
            }
            buttonTitles = buttonTitlesArray
            buttonsWithImages = false
        } else {
            print("Initilization failed, the VC array count does not match the button titles array count.")
        }
    }

    public func initializeWithVCsArrayAndButtonImagesArray (_ vcs: [UIViewController], buttonImagesArray: [UIImage], sender: UIViewController) {
        //Important - Images Array must Have The Same Number Of Items As The viewControllerIDs Array
        if vcs.count == buttonImagesArray.count {
            for vc in vcs {
                sender.addChildViewController(vc)
                vc.didMove(toParentViewController: sender)
                pageViews.append(vc)
            }
            buttonImages = buttonImagesArray
            buttonsWithImages = true
        } else {
            print("Initilization failed, the VC ID array count does not match the button images array count.")
        }
    }

    public func loadPage(_ page: Int) {
        if page < 0 || page >= pageViews.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }

        var frame = scrollView.bounds
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0.0

        let newPageView = pageViews[page]
        newPageView.view.frame = frame
        scrollView.addSubview(newPageView.view)
    }

    public func loadVisiblePages() {
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))

        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1

        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
    }

    public func barButtonAction(_ sender: UIButton?) {
        let index: Int = sender!.tag
        switchPage(index)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()

        //The calculations for the animated bar's movements
        //The offset addition is based on the width of the animated bar (button width times 0.8)
        let offsetAddition = (containerView.frame.size.width/(CGFloat)(pageViews.count))*0.1
        animatedBar.frame = CGRect(x: (offsetAddition + (scrollView.contentOffset.x/(CGFloat)(pageViews.count))), y: animatedBar.frame.origin.y, width: animatedBar.frame.size.width, height: animatedBar.frame.size.height)
    }

    var prevPage = 0
    var currentPage = 0

    public func switchPage(_ index: Int) {
        guard index < pageViews.count else {
            return
        }
        prevPage = getCurrentPage()
        let pagesScrollViewSize = scrollView.frame.size
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.contentOffset = CGPoint(x: pagesScrollViewSize.width * (CGFloat)(index), y: 0)
            }, completion: { _ in
                self.currentPage = self.getCurrentPage()
                self.pageViews[self.prevPage].viewDidDisappear(true)
                self.pageViews[self.currentPage].viewDidAppear(true)
        })
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        prevPage = getCurrentPage()
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if currentPage != getCurrentPage() {
            currentPage = getCurrentPage()

            pageViews[prevPage].viewDidDisappear(true)
            pageViews[currentPage].viewDidAppear(true)
        }
    }

    func getCurrentPage() -> Int {
        return getPage(self.scrollView.contentOffset.x)
    }

    func getPage(_ byOffset: CGFloat) -> Int {
        return Int(byOffset / self.scrollView.frame.size.width)
    }

}
