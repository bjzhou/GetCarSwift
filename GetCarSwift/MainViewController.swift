//
//  MainViewController.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/9/26.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let realm = try! Realm()
        let track0 = RmRaceTrack(value: ["id": 0, "name": "直线赛道", "sightView": "straight_race", "isDeveloped": true])
        let track1 = RmRaceTrack(value: ["id": 1, "name": "上海天马赛车场", "address": "上海市松江区沈砖公路3000号", "introduce": "上海天马赛车场（STC）位于上海松江，自2004年9月26日正式投入运营，是长江三角地区仅有的两家专业赛车场之一。经权威机构——国际汽车运动联合会（FIA）验收合格认证的F3赛道已达到国际安全标准，为体验试车、日常练车以及赛车运动提供专业、安全、差异化服务。", "isDeveloped": true, "mapCenter": [31.075861269594, 121.120193376859, 0], "mapZoom": 16.3, "startLoc": ["latitude": 31.0767290992663, "longitude": 121.118461205797], "leaveLoc": [31.076772747002, 121.12084837178, 0], "passLocs": [["latitude": 31.074202813552, "longitude": 121.122138209538], ["latitude": 31.0765154547976, "longitude": 121.119096889323], ["latitude": 31.0752325428113, "longitude": 121.121573354806], ["latitude": 31.0773631380887, "longitude": 121.117991819228]], "cycle": true])
        let track2 = RmRaceTrack(value: ["id": 2, "name": "鄂尔多斯国际赛车场", "address": "中国内蒙古鄂尔多斯市康巴什新区", "introduce": "位于中国内蒙古鄂尔多斯占地106公顷，赛道全长3.751公里，路面宽度12至15米，最大落差32米，被称为中国第一条国际山地赛道，是西北地区第一座国际赛车场，面积仅次于上海国际赛车场，赛道落差巨大，富有挑战性。赛道共18个弯，设计最高时速达296公里/小时。2010年9月这里被国际汽联认证为国际二级赛道，是第一条由中国人独立设计、施工并可升级为F1赛道的国际二级赛道，是世界上第一条以动物形态构筑整体线形的赛道。", "isDeveloped": false, "mapCenter": [39.6241296116, 109.8749789485, 0], "mapZoom": 16.5])
        let track3 = RmRaceTrack(value: ["id": 3, "name": "河南禹州大禹赛车场", "address": "河南省禹州市颍北新区", "introduce": "禹州大禹赛车场是全国第一个专业跨界拉力赛车场。赛车场由国外专业设计公司设计，主体建筑及其他相关建筑约5万平方米，包括主副看台、赛场指挥中心、新闻中心、维修区、赛车学校等。赛车场主副看台拥有近5000个座位，是一个集汽车运动、汽车文化与汽车商业活动为一体的大型运动场所，同时也是汽车上、中、下游厂商进行产品试验、发布、推广或品牌宣传、公关等商务活动的一个优秀平台。", "isDeveloped": false, "mapCenter": [34.1634000000, 113.5144400000, 0], "mapZoom": 16.5])
        let track4 = RmRaceTrack(value: ["id": 4, "name": "郑州MRC赛车场", "address": "郑州北四环、黄河公铁两用桥西测黄河滩内", "introduce": "郑州MRC赛车场是一条全新赛道，占地100亩，赛道全长1.3公里，宽10--15米，16个弯道，八个右弯，八个左弯。弯道设置惊险刺激，能充分展现赛车在绕弯和加速时的各项性能。同时能让选手倍感挑战性和趣味性。赛车场内设有接待大厅、餐厅和看台，是集汽车、摩托车、卡丁车、飘移、F4方程式等公路赛车的综合赛车场。同时赛车场内有国家级专业赛车教练，对车迷朋友提高驾驶技术和想进入专业车手的朋友会有非常大的帮助。", "isDeveloped": false, "mapCenter": [34.9089320000, 113.6723330000, 0], "mapZoom": 16.5])
        let track5 = RmRaceTrack(value: ["id": 5, "name": "西安长安赛车场", "address": "西安市长安区东大镇罗汉洞村西侧", "introduce": "西安长安赛车场坐落于西安市长安区东大镇罗汉洞村西侧，环山旅游线和休闲垂钓区的中心地带，东有西安市秦岭野生动物园、上王农家乐、上林宫、沣峪森林公园等。西有亚建高尔夫球场、髙冠瀑布风景区、祥峪森林公园、太平森林公园等。赛车场提供改装赛车体验、赛车手培训等服务，可提供场地及活动支持。", "isDeveloped": false, "mapCenter": [34.0244300000,108.7821000000, 0], "mapZoom": 16.5])
        let track6 = RmRaceTrack(value: ["id": 6, "name": "江苏万驰国际赛车场", "address": "江苏南京万驰国际赛车场", "introduce": "江苏南京万驰国际赛车场，是继上海天马赛车后，华东地区第二条F3级别的赛道，也是目前江苏省内唯一一条通过FIA安全认证的专业赛道。主赛道整体造型呈“F”字型，单圈长度为2014米，赛道宽度在9米至24米之间，平均宽度为16.5米。赛道逆时针方向行驶，除了主赛道外，场还拥有4种不同的赛道组合方式，8处左转弯道和3处右转弯道共计11个弯道。这条赛道的亮点在后半段连续弯道，不断变径变向让人很难找到或者错失每个弯的弯心。", "isDeveloped": false, "mapCenter": [31.6727000000, 119.0372300000, 0], "mapZoom": 16.5])
        let track7 = RmRaceTrack(value: ["id": 7, "name": "温州瑶溪国际赛车场", "address": "浙江省温州市龙湾区河头龙西路", "introduce": "温州瑶溪国际赛车场建成于2010年11月，总面积约35亩，交通便利。赛道为多种组合型赛道，路面为全部柏油。其中短道拉力赛道长度约为1.3公里，可组合区域面积约为11000平方米。赛场可承接短道拉力赛、卡丁车赛、漂移赛等专业汽车赛事。", "isDeveloped": false, "mapCenter": [27.9446500000, 120.7719600000, 0], "mapZoom": 16.5])
        let track8 = RmRaceTrack(value: ["id": 8, "name": "北京金港国际赛车场", "address": "北京市朝阳区金盏乡金港大道1号", "introduce": "北京金港国际赛道是北京目前唯一的高等级汽车赛道，于2000年建成，位于北京东部的朝阳区，可容纳两万余观众。赛道由三部分构成：国际F3赛道、4×4越野赛道和安全驾驶体验场地。国际F3赛道由澳大利亚专业设计师MichaelMcDonough设计，全长2.4公里。设计最高时速为180公里/小时，平均时速120公里/小时。可容纳25辆车同时发车。连续弯道多达4处，惊险刺激、极具挑战性。", "isDeveloped": false, "mapCenter": [40.0170400000, 116.5659700000, 0], "mapZoom": 16.5])
        let track9 = RmRaceTrack(value: ["id": 9, "name": "上海国际赛车场", "address": "上海市嘉定区伊宁路2000号近嘉定汽车城", "introduce": "赛车场赛道总长度7公里左右，由F1赛道和其它类型赛道组成。F1赛道单圈长度为5.451公里，宽度12至18米。赛道整体造型犹如一个翩翩起舞的“上”字。它既有利于大马力引擎发挥的高速赛道，又具有挑战性、充分体现车手技术的弯道。除了部分与F1赛事共用外，还可以举办各类不同的赛事（举办其他赛事时赛道图略有变化）。", "isDeveloped": false, "mapCenter": [31.3369100000, 121.2252500000, 0], "mapZoom": 16.5])
        let track10 = RmRaceTrack(value: ["id": 10, "name": "CDIC成都国际赛车场", "address": "四川省成都市锦江区石胜路87号", "introduce": "西南地区第一条国际赛车场，符合国际GP2标准。每年成都国际赛车场举办CTCC等多项赛事，也吸引着众多重庆，云南，贵州的车迷到访。成都国际赛车场的运动设施包括： GP2赛道、越野车赛道和安全驾驶体验场。可举办国际、国内汽车、摩托车赛事。GP2赛道全长3.331KM，宽12—22米，弯道14个，大直线长度830米，最高设计时速可达280公里。安全驾驶体验场为一个375*55米的柏油结构路面，设有50米钢板喷水和 50米柏油喷水，可作模拟雪地、雨地测试。", "isDeveloped": false, "mapCenter": [30.5841700000, 104.1222100000, 0], "mapZoom": 16.5])
        let track11 = RmRaceTrack(value: ["id": 11, "name": "广东国际赛车场", "address": "广东省肇庆高新技术产业开发区高新产业开发区大旺大道", "introduce": "广东国际赛车场按照F3级别设计建造，总投资人民币2.8亿。赛车场位于广东肇庆高新技术产业开发区南端的大旺大道侧，占地550亩，赛道全长2.82公里，具有5处左转弯道及8处右转弯道。赛道各项指标均符合国际汽车运动联合会F3赛道标准。赛道的标准宽度为12－15米，发车直道和相邻的两个弯道宽度均为15m，最高设计时速约为250km/h。赛道顺时针方向进行，在有限的土地上通过赛道线形的组合变化，最大地满足了赛事安全性、运动性的要求。", "isDeveloped": false, "mapCenter": [23.2673400000, 112.8235700000, 0], "mapZoom": 16.5])
        let track12 = RmRaceTrack(value: ["id": 12, "name": "珠海国际赛车场", "address": "广东省珠海市香洲区金鼎镇创新一路", "introduce": "珠海国际赛车场位于珠海经济特区金鼎镇。创建於1996年，是中国国内第一座符合国际汽车联盟一级方程式标准的国际级赛车场。珠海国际赛车场为世界一流赛车手壮观的超车表演提供了具有挑战性的弯道，顺时针方向的赛道有4个向左弯，10个向右弯，2条分别长900米及500米的直道。珠海国际赛车场是中国第一个永久性的国际赛车场，建成于1996年11月，同时举办了中国历史上第一次在国际级赛车场进行的国际赛事。", "isDeveloped": false, "mapCenter": [22.3723350000, 113.5652430000, 0], "mapZoom": 16.5])
        let track13 = RmRaceTrack(value: ["id": 13, "name": "澳门东望洋赛道", "address": "澳门友谊大马路207号澳门格兰披治赛车大楼", "introduce": "由澳门市区街道改建，举办一年一度世界著名的澳门格兰披治赛车。包含澳门F3，WTCC等多项赛事，在以前，在澳门胜出是方程式车手通往F1的门票，因为该赛道狭小危险。东望洋跑道（或称东望洋赛道、东望洋环山圈）是澳门举行澳门格兰披治大赛车的赛车跑道，是全世界上唯一同时举行房车赛和电自行车赛的街道赛场地。整条赛道环绕东望洋山的市区，澳门举行澳门举行有上坡下坡路，最阔路面14米，最窄仅7米，有“东方的摩纳哥赛道”之称。", "isDeveloped": false, "mapCenter": [22.1955120000, 113.5638200000, 0], "mapZoom": 16.5])
        let track100 = RmRaceTrack(value: ["id": 100, "name": "日本铃鹿赛道", "address": "7992 Inoucho，Suzuka, Mie Prefecture 510-0295，日本", "introduce": "赛道处于大阪和名古屋之间，在东京的西南面，铃鹿赛车场自从1987年就开始主办F1方程式赛事。赛道最独特的地方是它的8字型模式。它由许多不同形式的弯路和直路所构成。因此它为赛车提供了顺时针和逆时针的动向。赛车普遍会采用软级或中级的调校，悬挂则一般会调校得比较硬，以应付一些赛道上的一些凹凸位，不过整体来说赛道都是平滑的。", "isDeveloped": false, "mapCenter": [34.845831, 136.538974, 0], "mapZoom": 16.5])
        let track101 = RmRaceTrack(value: ["id": 101, "name": "日本富士国际赛车场", "address": "日本，〒410-1307 静岡県駿東郡，小山町中日向694", "introduce": "富士国际赛车场是一条坐落于富士山脚下的赛车场，简称“FSW”，原营运公司为“富士赛道有限公司”，简称FISCO，隶属于本田公司。2000年后被丰田公司收购。富士赛道始建于1960年代早期，并在1976年承办了日本境内的第一场F1大奖赛。", "isDeveloped": false, "mapCenter": [35.368248, 138.937375, 0], "mapZoom": 16.5])
        let track102 = RmRaceTrack(value: ["id": 102, "name": "巴林国际赛车场", "address": "Gate 255, Gulf of Bahrain Avenue,Umm Jidar 1062, Sakhir，巴林", "introduce": "巴林国际赛道由德国专家赫尔曼·蒂尔克设计，用了16个月建设，估计耗资1.5亿美元。最为突出的特点是与沙漠毗邻，这是历史上的F1赛道从未有过的。每年只有冬夏两季，冬季干燥，夏季湿热，最高气温可达30摄氏度。从赛道设计来看，F1赛车的平均圈速预计为1分33秒，赛车的平均时速为210公里。巴林赛道共由六条赛道组成，单圈长5.417Km，比赛共进行57圈，总行程308.427Km，最大上坡度3.6%，最大下坡度5.6%，有15个弯道，大直路长1090米。", "isDeveloped": false, "mapCenter": [26.031880, 50.512857, 0], "mapZoom": 16.5])
        let track103 = RmRaceTrack(value: ["id": 103, "name": "印第安纳波利斯赛道", "address": "4790 W 16th St，Indianapolis, IN 46222", "introduce": "美国印地安那波利斯赛道最初是以超过300万块砖头所砌成，因此\"砖厂\"之名不胫而走，启用于1909年，并在 1961年改铺柏油路面，在1950到1960年之间举办过十一次的F1大赛，是一个相当有历史的赛道。现在的印地安那波利斯赛道总长4.192公里，由负责工程建设的主任凯文-弗尔贝斯设计。", "isDeveloped": false, "mapCenter": [39.795626, -86.235301, 0], "mapZoom": 16.5])
        let track104 = RmRaceTrack(value: ["id": 104, "name": "澳大利亚阿尔伯特公园赛道", "address": "Aughtie Dr，Albert Park VIC 3206，澳大利亚", "introduce": "墨尔本有“花园城市”的美誉，阿尔伯特公园更是风景如画，所以在F1的16站比赛中，这站比赛的沿途风景是最漂亮的，阿尔伯特公园也被称为全世界最美的赛车场地。由于墨尔本赛道是由公园改建的，观众与赛道的距离也特别近，因此临场感受尤其强烈，再加上观众可以步行绕赛道外围，感受不同地点的震撼，更是其他赛道所望尘莫及的。这是世界上最好的赛道之一。不管是从结构布局上来说还是从赛道的安全保障来说，该赛道都树立了高的标准。", "isDeveloped": false, "mapCenter": [-37.849565, 144.969944, 0], "mapZoom": 16.5])
        let track105 = RmRaceTrack(value: ["id": 105, "name": "马来西亚雪邦赛道", "address": "Jalan Pekeliling，64000 Klia，Selangor，马来西亚", "introduce": "雪邦赛道于1998年11月建成完工，1999年承办F1大奖赛。赛车场方宣称雪邦是座拥有最高级的观众席及高科技设备的F1赛车场。赛道的设计兼顾了车手与观众，设计者在主看台，设计了一个被宇宙飞船采用的“香蕉叶”形状的顶棚，就如同建筑专家Hermann Tilke所说：“观众们从这里可以看到每个车手的白眼球。”赛场的主观众席可容纳30000人，其他的区域则可容纳80000人。", "isDeveloped": false, "mapCenter": [2.759736, 101.731745, 0], "mapZoom": 16.5])
        let track106 = RmRaceTrack(value: ["id": 106, "name": "德国纽伯格林赛道", "address": "Nürburgring Boulevard 1，53520 Nürburg，德国", "introduce": "纽博格林赛道位于漂亮的郊区，拥有庞大沙地的纽博格林赛道对车手来说是个不可多得的既快速又安全的赛场。纽博格林赛道处于德国境内，在科隆市西南约44英里。赛道的长度5.148km，赛车要跑赛60圈。", "isDeveloped": false, "mapCenter": [50.334290, 6.942673, 0], "mapZoom": 16.5])
        let track107 = RmRaceTrack(value: ["id": 107, "name": "德国霍根海姆赛道", "address": "Am Motodrom，68766 Hockenheim，德国", "introduce": "霍根海姆赛道改造之前又快又长，有四条直道从森林中穿过，因此地面温度会忽冷忽热，这对轮胎是个考验。这个赛车场以快速著名。它主要是由直路所组成，不过却被数个很慢的弯所干扰。像蒙扎一样，弯中的抓着力将会因为直路的速度而牺牲。车队们都会采用较硬的悬挂调校和低下压力。它是整个赛季中最长的赛道之一。2002年经过赫尔曼·提尔克先生的改建工程后，现在的霍根海姆赛道从一条与蒙扎赛道齐名的高速赛道变成了一条“标准”的欧洲赛道。", "isDeveloped": false, "mapCenter": [49.330140, 8.570893, 0], "mapZoom": 16.5])
        let track108 = RmRaceTrack(value: ["id": 108, "name": "英国银石赛道", "address": "Towcester, Northamptonshire NN12 8TN，英国", "introduce": "位于英国中央地带的银石赛道，是全世界汽车赛事最频繁的赛道之一，银石更是英国赛车工业的发源地。银石赛道的前身是一座二次大战时的军用机场，1948年起开始举办英国大奖赛，并在1950年成为第一场F1世界锦标赛的赛场。虽然举办了全世界第一场F1赛事，但银石赛道也并非理所当然的是英国大奖赛的唯一场地。从1955年开始，英国大奖赛就由Aintree与银石赛道轮流交替地举办。到了1964年，英国大奖赛又与同样深受英国人喜爱的BranDSHatch赛道轮流举办。直到1987年开始，银石赛道才真正成为英国大奖赛的代名词。", "isDeveloped": false, "mapCenter": [52.073472, -1.014631, 0], "mapZoom": 16.5])
        let track109 = RmRaceTrack(value: ["id": 109, "name": "西班牙加泰罗尼亚赛道", "address": "Camino Mas Moreneta，08160 Montmeló，Barcelona，西班牙", "introduce": "西班牙的加泰罗尼亚赛道建于1991年，赛道全长4.627公里，是被国际上公认的最贴近完美的跑道。这赛道常被各车队用来进行赛车测试，所以各车队及车手对这个赛道都相当地熟悉。这条赛道对现场观众来说也是个感观很好的赛道，赛场设计者充分考虑到观众的视野，而且赛场周边交通方便，即使在周日决赛也都不会发生交通堵塞。赛道拥有很长的直线道和长距离的高速与低速的弯道，其起跑点的直线道几乎是所有F1赛道中最长的一条路段，这对于赛车的引擎是一大考验。", "isDeveloped": false, "mapCenter": [41.568476, 2.257031, 0], "mapZoom": 16.5])
        let track110 = RmRaceTrack(value: ["id": 110, "name": "西班牙瓦伦西亚街区赛道", "address": "Autovía A3 Valencia-Madrid，46380 Cheste，Valencia，西班牙", "introduce": "这条由F1赛道设计师蒂尔克设计的瓦伦西亚街道赛道全长为5.4735公里，共有25个弯角，包括11个左弯和14个右弯，赛道最窄处为12米。据官方透露，此赛道的最高时速仅次于美国印第安纳波利斯和意大利蒙扎赛道。预测平均圈速为1分37秒，最低时速为每小时95.2公里，最高时速为323.3公里，平均时速201.3公里。赛道围绕着瓦伦西亚海港中心和码头而建，这里也是举办美洲杯帆船赛的码头，赛场共有20个看台，可容纳10万名观众。", "isDeveloped": false, "mapCenter": [39.486100, -0.630501, 0], "mapZoom": 16.5])
        let track111 = RmRaceTrack(value: ["id": 111, "name": "法国勒芒赛道", "address": "Route du Chemin aux Boeufs，72100 Le Mans，法国", "introduce": "勒芒赛道，建于1965年，这条举办勒芒-布加迪大奖赛的著名赛道坐落于勒芒市（法国西北部城市）以南5公里，巴黎西南部200公里的地方。以每年一度（开始于1906年）的24小时全天赛车而闻名，其中内场4.185公里为MOTOGP所使用的赛道。这是一条全长13.5千米的环形跑道，沥青和水泥路面由高速公路和街区公路封闭而成，平均时速超过200千米。在赛道上有一段长约6千米的直道，赛车在这段直道上的时速可高达390千米，在24小时的比赛中，车子们要在这段直道上高速行驶6小时，对赛车的性能和车手的耐力都是极大的考验。", "isDeveloped": false, "mapCenter": [47.938211, 0.210328, 0], "mapZoom": 16.5])
        let track112 = RmRaceTrack(value: ["id": 112, "name": "匈牙利亨格罗林赛道", "address": "Mogyoród，Versenypálya 0222/2/3/6，2146，匈牙利", "introduce": "布达佩斯的匈格罗宁赛道原本全长仅3.975公里，但在2003年首次做了大幅的修改，赛道全长变成4.381公里，比赛圈数由原来的77圈减少为70圈。弯曲的赛道设计，使赛车的平均速度高不起来，属于中低速型赛道，这对轮胎的磨耗相当大，因此车队的Pit stop通常会采取两停的策略。由于布达佩斯大奖赛通常是在炎热的夏季比赛，这对于赛车与车手都是一种煎熬。", "isDeveloped": false, "mapCenter": [47.581943, 19.250611, 0], "mapZoom": 16.5])
        let track113 = RmRaceTrack(value: ["id": 113, "name": "摩纳哥蒙特卡洛赛道", "address": "摩纳哥蒙特卡洛", "introduce": "世界四大知名赛道之一，以街道为赛道，是F1赛道中最短的一条，并拥有F1赛道中最慢的弯角和著名的隧道。同时因为在街道比赛，车队的加油站也很小很窄。但是由于赛道的技巧性强，悬挂和轮胎都很重要，这站比赛的冠军也是许多车手梦寐以求的。", "isDeveloped": false, "mapCenter": [43.740375, 7.421111, 0], "mapZoom": 16.5])
        let track114 = RmRaceTrack(value: ["id": 114, "name": "阿布扎比亚斯码头赛道", "address": "Yas Marina Circuit，Abu Dhabi，阿拉伯联合酋长国", "introduce": "阿布扎比亚斯码头赛道是举办F1阿布扎比大奖赛的场地，它位于波斯湾石油强国阿联酋首都阿布扎比东海岸的亚斯，距阿布扎比国际机场仅15分钟车程，著名的法拉利主题公园也坐落这里。这条赛道的独特设计不仅在于赛道及周边环境，配套设施规模也相当惊人，包括7个豪华酒店的2200张床位，以及可以停泊150艘小船的港口，包括长度超过60米的船只。亚斯滨海假日酒店共有500间客房，且横跨赛道，在房间里便可俯瞰赛道全景。另外60米高的太阳能塔也为酒店住客们提供了不一样的视觉享受。", "isDeveloped": false, "mapCenter": [24.467363, 54.609460, 0], "mapZoom": 16.5])
        let track115 = RmRaceTrack(value: ["id": 115, "name": "印度佛陀国际赛车场", "address": "Jaypee Sports City, Yamuna Expressway, Sector-25, YEIDA，Gautam Buddh Nagar，Greater Noida, Uttar Pradesh 203201，印度", "introduce": "印度佛陀国际赛道又称布达国际赛道是位于印度北方邦大诺伊达的一条赛道，临近首都新德里。赛道举办的最著名赛事是自2011年开始进行的世界一级方程式锦标赛印度大奖赛。赛道于2011年10月18日正式启用，全长5.137公里，由设计过多条F1赛道的德国建筑家赫尔曼·提尔克规划建造。2012年9月，这一赛道还举办了世界超级跑车锦标赛GT1级别的赛事。2013年，世界摩托车锦标赛[8]以及世界超级摩托车锦标赛也将在此举办分站赛事。", "isDeveloped": false, "mapCenter": [28.350573, 77.534681, 0], "mapZoom": 16.5])
        let track116 = RmRaceTrack(value: ["id": 116, "name": "拉古纳西卡赛道", "address": "1021 Monterey Salinas Hwy，Salinas, CA 93908", "introduce": "拉古纳-西卡赛道位于美国西海岸的加利福尼亚，这是一条在北美非常著名的赛车跑道。拉古纳-西卡是美国印地赛车、北美运动车赛和摩托GP的举办地之一。该赛道始建于1958年，后来经过几次改建。现在的拉古纳-西卡赛道全长3.602公里，有11个弯道。这条赛道最有特色之处在于他的高低起伏，弯道之间的高度落差非常惊人。", "isDeveloped": false, "mapCenter": [36.584497, -121.753410, 0], "mapZoom": 16.5])
        let track117 = RmRaceTrack(value: ["id": 117, "name": "美国奥斯汀赛道", "address": "美国德克萨斯州奥斯汀", "introduce": "奥斯汀F1赛道位于美国德克萨斯州的特拉维斯县，占地面积超过700英亩。由赫尔曼-提克负责设计，单圈长度5.5公里，总共包含20个弯道。奥斯汀赛道是一条永久性的赛道，它将从2012起成为F1美国大奖赛的新举办地，合同为期十年直至2021年。赛道有一条非常长的直道，两头都有一个发夹弯，而这里也是单个DRS区域的位置。它还有许多个弯角，这向世界上其他赛道的一些伟大弯角致敬。比如说，第一弯是一个上坡弯，与70年代伟大的奥地利赛道相似，随后还有一些高速的组合弯角与银石的Maggotts/Becketts很相像。", "isDeveloped": false, "mapCenter": [30.270333, -97.743797, 0], "mapZoom": 16.5])
        try! realm.write {
            realm.add(track0, update: true)
            realm.add(track1, update: true)
            realm.add(track2, update: true)
            realm.add(track3, update: true)
            realm.add(track4, update: true)
            realm.add(track5, update: true)
            realm.add(track6, update: true)
            realm.add(track7, update: true)
            realm.add(track8, update: true)
            realm.add(track9, update: true)
            realm.add(track10, update: true)
            realm.add(track11, update: true)
            realm.add(track12, update: true)
            realm.add(track13, update: true)
            realm.add(track100, update: true)
            realm.add(track101, update: true)
            realm.add(track102, update: true)
            realm.add(track103, update: true)
            realm.add(track104, update: true)
            realm.add(track105, update: true)
            realm.add(track106, update: true)
            realm.add(track107, update: true)
            realm.add(track108, update: true)
            realm.add(track109, update: true)
            realm.add(track110, update: true)
            realm.add(track111, update: true)
            realm.add(track112, update: true)
            realm.add(track113, update: true)
            realm.add(track114, update: true)
            realm.add(track115, update: true)
            realm.add(track116, update: true)
            realm.add(track117, update: true)
        }

        self.addChildViewController(R.storyboard.gkbox.initialViewController!)
        self.addChildViewController(R.storyboard.track.initialViewController!)
        self.addChildViewController(R.storyboard.mod.initialViewController!)
        self.addChildViewController(R.storyboard.mine.initialViewController!)

        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.gaikeRedColor()], forState:.Selected)

        //UILabel.appearance().font = UIFont.systemFontOfSize()

    }

    override func viewDidLayoutSubviews() {
        for item in self.tabBar.items! {
            item.image = item.image?.imageWithRenderingMode(.AlwaysOriginal)
        }
    }
}
