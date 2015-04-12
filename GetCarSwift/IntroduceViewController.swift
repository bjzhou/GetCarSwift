//
//  IntroduceViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class IntroduceViewController: UIViewController, UIScrollViewDelegate {
    
    let CONTENT_DABAOWEI = "大包围装饰的学名是车身空气扰流组件，一般\n来说，汽车大包围由前包围，后包围和侧包围\n组成，前后包围有全包围式和半包围式两种形\n式：全包围式是将原有保险杠拆除，然后装上\n大包围，或将大包围套在原保险杠表面；半包\n围是在原保险杠的下部附加一装饰件，这样可\n以不拆除保险杠，侧包围又称侧杠包围或侧杠\n裙边。由于汽车在发生撞击时，保险杠可以起\n到缓冲和吸震的作用，而且它是在汽车设计时\n经过精密计算得出的结果，可以最大限度的保\n护乘员，所以出于安全考虑，与全包围相比半\n包围更具有优势，但美中不足的是半包围达不\n到全包围的那种整体美感。"
    
    let CONTENT_HOURAO = "后扰流板（Slingshot Autosculpt）是指在\n车尾上方安装的附加板。因为车体一般是一个\n不规则流线体，车辆将空气分开，空气从车辆\n四周流过，而当流过车顶后，这部分空气会开\n始向下流动，而这里气流的流动速度会根据车\n尾的形状决定，比如车尾为了更加漂亮，所以\n很多车尾造型都比较陡峭，所以气流速度也会\n越快，也就会形成如机翼一样的效果得到向上\n的升力，而后扰流板的作用就是在不增加车体\n重量的前提下降低车辆行驶中所受到的上升\n力。"
    
    let CONTENT_LUNGU = "轮毂又叫轮圈、轱辘、胎铃，是轮胎内廓支撑\n轮胎的圆桶形的、中心装在轴上的金属部件。\n轮毂根据直径、宽度、成型方式、材料不同种\n类繁多。一颗轮毂包括了很多参数，而且每一\n个参数都会影响到车辆的使用，所以在改装和\n保养轮毂之前，先要确认好这些参数。"
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSizeMake(view.bounds.size.width * 3, view.bounds.height - 64 - 49)
        scrollView.delegate = self;
        
        addSubViewToScrollVIew(0, title: "大包围", iconName: IMAGE_DABAOWEI, message: CONTENT_DABAOWEI)
        addSubViewToScrollVIew(1, title: "后扰流板", iconName: IMAGE_HOURAO, message: CONTENT_HOURAO)
        addSubViewToScrollVIew(2, title: "轮毂", iconName: IMAGE_LUNGU, message: CONTENT_LUNGU)
    }
    
    func addSubViewToScrollVIew(index: Int, title: String, iconName: String, message: String) {
        var subView = IntroduceCotentView(frame: CGRectMake(20 + CGFloat(view.bounds.size.width) * CGFloat(index), 20, view.bounds.size.width - 40, view.bounds.size.height - 270))
        subView.translatesAutoresizingMaskIntoConstraints()
        subView.title.text = title
        subView.icon.image = UIImage(named: iconName)
        subView.message.text = message
        scrollView.addSubview(subView)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageControl.currentPage = (Int)(scrollView.contentOffset.x / view.bounds.size.width)
    }

}
