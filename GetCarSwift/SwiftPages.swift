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
    private var topBarImage = R.image.pages_bg
    private var buttonsTextColor = UIColor.whiteColor()
    private var containerViewBackground = UIColor.gaikeBackgroundColor()
    
    //Item size variables
    private var topBarHeight: CGFloat = 36
    private var animatedBarHeight: CGFloat = 5
    
    //Bar item variables
    private var transparentTopBar: Bool = true
    private var aeroEffectInTopBar: Bool = false //This gives the top bap a blurred effect, also overlayes the it over the VC's
    private var buttonsWithImages: Bool = false
    private var barShadow: Bool = false
    private var buttonsTextFontAndSize: UIFont = UIFont.systemFontOfSize(16)
    
    // MARK: - Positions Of The Container View API -
    public func setOriginX (origin : CGFloat) { xOrigin = origin }
    public func setOriginY (origin : CGFloat) { yOrigin = origin }
    public func setDistanceToBottom (distance : CGFloat) { distanceToBottom = distance }
    
    // MARK: - API's -
    public func setTopBarImage(image: UIImage?) { topBarImage = image }
    public func setButtonsTextColor (color : UIColor) { buttonsTextColor = color }
    public func setContainerViewBackground (color : UIColor) { containerViewBackground = color }
    public func setTopBarHeight (pointSize : CGFloat) { topBarHeight = pointSize}
    public func setAnimatedBarHeight (pointSize : CGFloat) { animatedBarHeight = pointSize}
    public func setButtonsTextFontAndSize (fontAndSize : UIFont) { buttonsTextFontAndSize = fontAndSize}
    public func enableAeroEffectInTopBar (boolValue : Bool) { aeroEffectInTopBar = boolValue}
    public func enableButtonsWithImages (boolValue : Bool) { buttonsWithImages = boolValue}
    public func enableBarShadow (boolValue : Bool) { barShadow = boolValue}
    public func getPageViewController(index: Int) -> UIViewController? { return pageViews[index] }
    
    override public func drawRect(rect: CGRect)
    {
        containerView?.removeFromSuperview()

        //Size Of The Container View
        let pagesContainerHeight = self.frame.height - yOrigin - distanceToBottom
        let pagesContainerWidth = self.frame.width

        if pagesContainerWidth <= 320 && topBarHeight >= 36 {
            topBarHeight = 24
        }

        //Set the containerView, every item is constructed relative to this view
        containerView = UIView(frame: CGRectMake(xOrigin, yOrigin, pagesContainerWidth, pagesContainerHeight))
        containerView.backgroundColor = containerViewBackground
        self.addSubview(containerView)
        
        //Set the scrollview
        if (aeroEffectInTopBar || transparentTopBar) {
            scrollView = UIScrollView(frame: CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height))
        } else {
            scrollView = UIScrollView(frame: CGRectMake(0, topBarHeight, containerView.frame.size.width, containerView.frame.size.height - topBarHeight))
        }
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.delaysContentTouches = false
        scrollView.backgroundColor = UIColor.clearColor()
        scrollView.bounces = false
        containerView.addSubview(scrollView)
        
        //Set the top bar
        topBar = UIView(frame: CGRectMake(0, 0, containerView.frame.size.width, topBarHeight))
        let imageView = UIImageView(image: topBarImage)
        imageView.frame = topBar.frame
        topBar.addSubview(imageView)
        if (aeroEffectInTopBar) {
            //Create the blurred visual effect
            //You can choose between ExtraLight, Light and Dark
            topBar.backgroundColor = UIColor.clearColor()
            let blurEffect: UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
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
            for _ in buttonTitles
            {
                var barButton: UIButton!
                barButton = UIButton(frame: CGRectMake(buttonsXPosition, 0, containerView.frame.size.width/(CGFloat)(pageViews.count), topBarHeight))
                barButton.backgroundColor = UIColor.clearColor()
                barButton.titleLabel!.font = buttonsTextFontAndSize
                barButton.setTitle(buttonTitles[buttonNumber], forState: UIControlState.Normal)
                barButton.setTitleColor(buttonsTextColor, forState: UIControlState.Normal)
                barButton.tag = buttonNumber
                barButton.addTarget(self, action: "barButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
                topBar.addSubview(barButton)
                buttonsXPosition = containerView.frame.size.width/(CGFloat)(pageViews.count) + buttonsXPosition
                buttonNumber++
            }
        } else {
            for item in buttonImages
            {
                var barButton: UIButton!
                barButton = UIButton(frame: CGRectMake(buttonsXPosition, 0, containerView.frame.size.width/(CGFloat)(pageViews.count), topBarHeight))
                barButton.backgroundColor = UIColor.clearColor()
                barButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                barButton.setImage(item, forState: .Normal)
                barButton.tag = buttonNumber
                barButton.addTarget(self, action: "barButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
                topBar.addSubview(barButton)
                buttonsXPosition = containerView.frame.size.width/(CGFloat)(pageViews.count) + buttonsXPosition
                buttonNumber++
            }
        }
        
        
        //Set up the animated UIView
        animatedBar = UIImageView(image: R.image.scroll_bar)
        animatedBar.frame = CGRectMake(0, topBarHeight - animatedBarHeight + 1, (containerView.frame.size.width/(CGFloat)(pageViews.count))*0.8, animatedBarHeight)
        animatedBar.center.x = containerView.frame.size.width/(CGFloat)(pageViews.count * 2)
        //animatedBar.backgroundColor = animatedBarColor
        containerView.addSubview(animatedBar)

        //Add the bar shadow (set to true or false with the barShadow var)
        if (barShadow) {
            let shadowView = UIView(frame: CGRectMake(0, topBarHeight, containerView.frame.size.width, 4))
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = shadowView.bounds
            gradient.colors = [UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.28).CGColor, UIColor.clearColor().CGColor]
            shadowView.layer.insertSublayer(gradient, atIndex: 0)
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
    public func initializeWithVCsArrayAndButtonTitlesArray (VCsArray: [UIViewController], buttonTitlesArray: [String], sender: UIViewController)
    {
        //Important - Titles Array must Have The Same Number Of Items As The viewControllerIDs Array
        if VCsArray.count == buttonTitlesArray.count {
            for vc in VCsArray {
                sender.addChildViewController(vc)
                vc.didMoveToParentViewController(sender)
                pageViews.append(vc)
            }
            buttonTitles = buttonTitlesArray
            buttonsWithImages = false
        } else {
            print("Initilization failed, the VC array count does not match the button titles array count.")
        }
    }
    
    public func initializeWithVCsArrayAndButtonImagesArray (VCsArray: [UIViewController], buttonImagesArray: [UIImage], sender: UIViewController)
    {
        //Important - Images Array must Have The Same Number Of Items As The viewControllerIDs Array
        if VCsArray.count == buttonImagesArray.count {
            for vc in VCsArray {
                sender.addChildViewController(vc)
                vc.didMoveToParentViewController(sender)
                pageViews.append(vc)
            }
            buttonImages = buttonImagesArray
            buttonsWithImages = true
        } else {
            print("Initilization failed, the VC ID array count does not match the button images array count.")
        }
    }
    
    public func loadPage(page: Int)
    {
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
    
    public func loadVisiblePages()
    {
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
    
    public func barButtonAction(sender: UIButton?)
    {
        let index: Int = sender!.tag
        switchPage(index)
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView)
    {
        // Load the pages that are now on screen
        loadVisiblePages()
        
        //The calculations for the animated bar's movements
        //The offset addition is based on the width of the animated bar (button width times 0.8)
        let offsetAddition = (containerView.frame.size.width/(CGFloat)(pageViews.count))*0.1
        animatedBar.frame = CGRectMake((offsetAddition + (scrollView.contentOffset.x/(CGFloat)(pageViews.count))), animatedBar.frame.origin.y, animatedBar.frame.size.width, animatedBar.frame.size.height);
    }
    
    var prevPage = 0
    var currentPage = 0
    
    public func switchPage(index: Int) {
        guard index < pageViews.count else {
            return
        }
        prevPage = getCurrentPage()
        let pagesScrollViewSize = scrollView.frame.size
        UIView.animateWithDuration(0.3, animations: {
            self.scrollView.contentOffset = CGPointMake(pagesScrollViewSize.width * (CGFloat)(index), 0)
            }, completion: { _ in
                self.currentPage = self.getCurrentPage()
                self.pageViews[self.prevPage].viewDidDisappear(true)
                self.pageViews[self.currentPage].viewDidAppear(true)
        })
    }

    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        prevPage = getCurrentPage()
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if currentPage != getCurrentPage() {
            currentPage = getCurrentPage()

            pageViews[prevPage].viewDidDisappear(true)
            pageViews[currentPage].viewDidAppear(true)
        }
    }
    
    func getCurrentPage() -> Int {
        return getPage(self.scrollView.contentOffset.x)
    }
    
    func getPage(byOffset: CGFloat) -> Int {
        return Int(byOffset / self.scrollView.frame.size.width)
    }
    
}
