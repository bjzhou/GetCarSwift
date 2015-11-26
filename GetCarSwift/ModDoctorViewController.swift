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

    let titles = ["大包围", "后扰流板", "轮毂"]
    let icons = [R.image.gz_baowei, R.image.gz_hourao, R.image.gz_lunkuo]
    let contents = ["大包围装饰的学名是车身空气扰流组件，一般来说，汽车大包围由前包围，后包围和侧包围组成，前后包围有全包围式和半包围式两种形式：全包围式是将原有保险杠拆除，然后装上大包围，或将大包围套在原保险杠表面；半包围是在原保险杠的下部附加一装饰件，这样可以不拆除保险杠，侧包围又称侧杠包围或侧杠裙边。由于汽车在发生撞击时，保险杠可以起到缓冲和吸震的作用，而且它是在汽车设计时经过精密计算得出的结果，可以最大限度的保护乘员，所以出于安全考虑，与全包围相比半包围更具有优势，但美中不足的是半包围达不到全包围的那种整体美感。", "后扰流板（Slingshot Autosculpt）是指在车尾上方安装的附加板。因为车体一般是一个不规则流线体，车辆将空气分开，空气从车辆四周流过，而当流过车顶后，这部分空气会开始向下流动，而这里气流的流动速度会根据车尾的形状决定，比如车尾为了更加漂亮，所以很多车尾造型都比较陡峭，所以气流速度也会越快，也就会形成如机翼一样的效果得到向上的升力，而后扰流板的作用就是在不增加车体重量的前提下降低车辆行驶中所受到的上升力。", "轮毂又叫轮圈、轱辘、胎铃，是轮胎内廓支撑轮胎的圆桶形的、中心装在轴上的金属部件。轮毂根据直径、宽度、成型方式、材料不同种类繁多。一颗轮毂包括了很多参数，而且每一个参数都会影响到车辆的使用，所以在改装和保养轮毂之前，先要确认好这些参数。"]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 380
    }

}

extension ModDoctorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(R.reuseIdentifier.mod_intro, forIndexPath: indexPath)
        cell?.titleLabel.text = titles[indexPath.row]
        cell?.iconView.image = icons[indexPath.row]
        cell?.messageLabel.text = contents[indexPath.row]
        return cell!
    }
}
