//
//  IntroduceViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/4/11.
//  Copyright (c) 2015年 周斌佳. All rights reserved.
//

import UIKit

class ModDoctorViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let titles = ["大包围", "后扰流板", "轮毂", "避震器", "排气系统", "平衡拉杆", "刹车", "尾翼"]
    let icons = [R.image.gz_baowei, R.image.gz_hourao, R.image.gz_lunkuo, R.image.gz_bizhen, R.image.gz_paiqi, R.image.gz_pingheng, R.image.gz_shache, R.image.gz_weiyi]
    let contents = ["大包围装饰的学名是车身空气扰流组件，一般来说，汽车大包围由前包围，后包围和侧包围组成，前后包围有全包围式和半包围式两种形式：全包围式是将原有保险杠拆除，然后装上大包围，或将大包围套在原保险杠表面；半包围是在原保险杠的下部附加一装饰件，这样可以不拆除保险杠，侧包围又称侧杠包围或侧杠裙边。由于汽车在发生撞击时，保险杠可以起到缓冲和吸震的作用，而且它是在汽车设计时经过精密计算得出的结果，可以最大限度的保护乘员，所以出于安全考虑，与全包围相比半包围更具有优势，但美中不足的是半包围达不到全包围的那种整体美感。", "后扰流板（Slingshot Autosculpt）是指在车尾上方安装的附加板。因为车体一般是一个不规则流线体，车辆将空气分开，空气从车辆四周流过，而当流过车顶后，这部分空气会开始向下流动，而这里气流的流动速度会根据车尾的形状决定，比如车尾为了更加漂亮，所以很多车尾造型都比较陡峭，所以气流速度也会越快，也就会形成如机翼一样的效果得到向上的升力，而后扰流板的作用就是在不增加车体重量的前提下降低车辆行驶中所受到的上升力。", "轮毂又叫轮圈、轱辘、胎铃，是轮胎内廓支撑轮胎的圆桶形的、中心装在轴上的金属部件。轮毂根据直径、宽度、成型方式、材料不同种类繁多。一颗轮毂包括了很多参数，而且每一个参数都会影响到车辆的使用，所以在改装和保养轮毂之前，先要确认好这些参数。", "避震器（Shock Absorber；Damper）的需求是由于弹簧不能马上稳定下来，也就是说弹簧被压缩再放开以后，它会持续一段时间又伸又缩，所以避震器可以吸收车轮遇到凹凸路面所引起的震动，使乘坐舒适。", "汽车排气系统是指收集并且排放废气的系统，一般由排气歧管，排气管，催化转换器，排气温度传感器，汽车消声器和排气尾管等组成。在进排气系统改装中，排气系统的改装更为受到欢迎，因为排气系统尤其是其尾段，不但露于车外清晰可见，而且还可以发出慑人的音频和声响，是少数能直接为车 主提供视觉与听觉双重感观刺激的改装部件。原厂的排气系统由于要顾及成本、噪声污染和各地不同的排放标准等限制，在设计时都会非常保守，并会在一定程度上 因排气效率不高而限制了发动机的性能表现。", "汽车改装常用的平衡拉杆，俗称“顶吧、拉杆”。吧（BAR）的英文含义是拉杆的意思。平衡杆的作用当左右两轮行经相同的路面凸起或窟窿时，平衡杆并不会产生作用。但是如果左右轮分别通过不同路面凸起或窟窿时，也就是左右两轮的水平高度不同时，会造成杆身的扭转，产生防倾阻力（Roll Resistance）抑制车身滚动。", "刹车,也称为制动，是指使运行中的机车、车辆及其他运输工具或机械等停止或减低速度的动作。制动的一般原理是在机器的高速轴上固定一个轮或盘，在机座上安装与之相适应的闸瓦、带或盘，在外力作用下使之产生制动力矩。刹车装置也就是可以减慢车速的机械制动装置，又名减速器。简单来说：汽车刹车踏板在方向盘下面，踩住刹车踏板，则使刹车杠杆联动受压并传至到刹车鼓上的刹车片卡住刹车轮盘，使汽车减速或停止运行。", "尾翼，专业的叫法为扰流板，属于汽车空气动力套件中的一部分。尾翼的主要作用是为了减少车辆尾部的升力，如果车尾的升力比车头的升力大，就容易导致车辆过度转向、后轮抓地力减少以及高速稳定性变差。"]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 380
    }

    override func viewDidLayoutSubviews() {
    }
}

extension ModDoctorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.mod_intro, forIndexPath: indexPath)
        cell?.titleLabel.text = titles[indexPath.row]
        cell?.iconView.image = icons[indexPath.row]
        cell?.messageLabel.text = contents[indexPath.row]
        return cell!
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < -57) {
            scrollView.contentOffset = CGPointMake(0, -57)
        }
    }
}
