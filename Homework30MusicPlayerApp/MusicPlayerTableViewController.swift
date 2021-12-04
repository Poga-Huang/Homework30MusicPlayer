//
//  MusicPlayerTableViewController.swift
//  Homework30MusicPlayerApp
//
//  Created by 黃柏嘉 on 2021/12/3.
//

import UIKit
import AVFoundation
import SpriteKit
enum PlayMode{
    case play
    case pause
}

class MusicPlayerTableViewController: UITableViewController {
    
    //圖片
    @IBOutlet weak var musicView: UIView!
    @IBOutlet weak var musicImageView: CDImage!
    @IBOutlet weak var musicBackImageView: UIImageView!
    @IBOutlet weak var musicImageBackView: UIView!
    //歌名歌手
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    //進度
    @IBOutlet weak var remainLabel: UILabel!
    //播放鍵
    @IBOutlet weak var playButton: UIButton!
    
    //variable
    var player = AVPlayer()
    var numberFormatter = NumberFormatter()
    var isPlaying = false
    var timer:Timer?
    var dataIndex = 0
    let dataArray:[SongData] = [
        SongData(singer: "韋禮安", songName: "如果可以", duration: 272),
        SongData(singer: "周興哲", songName: "如果能幸福", duration: 259),
        SongData(singer: "謝和弦", songName: "備胎", duration: 272),
        SongData(singer: "八三夭", songName: "想見你想見你想見你", duration: 240),
        SongData(singer: "陳勢安", songName: "好愛好散", duration: 289)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //numberFormatter
        numberFormatter.formatWidth = 2
        numberFormatter.paddingCharacter = "0"
        
        //圖片背景陰影
        musicImageBackView.layer.cornerRadius = 150
        musicImageBackView.layer.shadowColor = UIColor.black.cgColor
        musicImageBackView.layer.shadowOffset = CGSize(width: 5, height: 5)
        musicImageBackView.layer.shadowOpacity = 0.5
        
        //環形進度條
        makeProgressCircle(percentage: 0)
        
        //背景特效
        let skView = SKView(frame: musicView.frame)
        musicView.insertSubview(skView, at: 0)
        let scene = SKScene(size: skView.frame.size)
        skView.presentScene(scene)
        let emitterNode = SKEmitterNode(fileNamed: "MyParticle")
        emitterNode?.particleColorSequence = nil
        emitterNode?.particleColorBlendFactor = 1.0
        emitterNode?.particleColor = UIColor.white
        scene.addChild(emitterNode!)
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        
        //初始載入音樂
        loadMusicInformation(Index: dataIndex)
        //圖片旋轉
        self.musicImageView.rotate()
        
    }
    
    //播放鍵&暫停鍵
    @IBAction func playAndPause(_ sender: UIButton) {
        if isPlaying == false{
            executePlayOrPause(mode: .play, Index: dataIndex)
        }else{
            executePlayOrPause(mode: .pause, Index: dataIndex)
        }
        
    }
    
    //下一首
    @IBAction func next(_ sender: UIButton) {
        if dataIndex < 4{
            dataIndex += 1
            loadMusicInformation(Index: dataIndex)
            executePlayOrPause(mode: .play, Index: dataIndex)
        }else{
            dataIndex = 0
            loadMusicInformation(Index: dataIndex)
            executePlayOrPause(mode: .play, Index: dataIndex)
        }
        
    }
    
    //上一首
    @IBAction func back(_ sender: UIButton) {
        
        if dataIndex > 0{
            dataIndex -= 1
            loadMusicInformation(Index: dataIndex)
            executePlayOrPause(mode: .play, Index: dataIndex)
        }else{
            dataIndex = 4
            loadMusicInformation(Index: dataIndex)
            executePlayOrPause(mode: .play, Index: dataIndex)
        }

    }
    //滑動音量
    @IBAction func setVolume(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    
    //製作環形進度條
    func makeProgressCircle(percentage:CGFloat){
        
        let degree = CGFloat.pi/180
        let startDegree:CGFloat = 270
        let lineWidth:CGFloat = 10
        let radius:CGFloat = 170
        let center:CGPoint = CGPoint(x: 207, y: 225)
        
        //灰色底
        let progressBackPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: degree*0, endAngle: degree*360, clockwise: true)
        let progressBackLayer = CAShapeLayer()
        progressBackLayer.path = progressBackPath.cgPath
        progressBackLayer.fillColor = UIColor.clear.cgColor
        progressBackLayer.strokeColor = UIColor.lightGray.cgColor
        progressBackLayer.lineWidth = lineWidth
        musicView.layer.addSublayer(progressBackLayer)
        
        //中心白底
        let centerCircle = UIBezierPath(arcCenter: center, radius: 30, startAngle: degree*0, endAngle: degree*360, clockwise: true)
        let centerLayer = CAShapeLayer()
        centerLayer.path = centerCircle.cgPath
        centerLayer.fillColor = UIColor.white.cgColor
        musicView.layer.addSublayer(centerLayer)
        
        
        //進度條
        let endDegree = startDegree+(360*percentage)
        let progressLinePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: degree*startDegree, endAngle: degree*endDegree, clockwise: true)
        let progressLayer = CAShapeLayer()
        progressLayer.path = progressLinePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.systemPink.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        musicView.layer.addSublayer(progressLayer)
        
        //時間Label
        remainLabel.center = center
        musicView.addSubview(remainLabel)
    }
    //讀取音樂和資訊
    func loadMusicInformation(Index:Int){
        musicImageView.image = UIImage(named: dataArray[Index].songName)
        musicBackImageView.image =  UIImage(named: dataArray[Index].songName)
        singerLabel.text = "\(dataArray[Index].singer)"
        songLabel.text = "\(dataArray[Index].songName)"
        if let url = Bundle.main.url(forResource: dataArray[Index].songName, withExtension: ".mp3"){
            player = AVPlayer(url: url)
            player.volume = 2.5
        }
    }

    //執行播放或暫停
    func executePlayOrPause(mode:PlayMode,Index:Int){
        switch mode {
        case .play:
            player.play()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(musicTime), userInfo: nil, repeats: true)
            playButton.setImage(UIImage(named: "pause.filled"), for: .normal)
            isPlaying = true
        case .pause:
            player.pause()
            timer?.invalidate()
            playButton.setImage(UIImage(named: "play.filled"), for: .normal)
            isPlaying = false
        }
    }
    
    
    @objc func musicTime(){
        //環形進度條
        let progressPercent = CGFloat(player.currentTime().seconds/Double(dataArray[dataIndex].duration))
        makeProgressCircle(percentage: progressPercent)
        
        //時間文字 & progress View
        let remainMinuteText = numberFormatter.string(from: NSNumber(value: Int(Double(dataArray[dataIndex].duration)-player.currentTime().seconds)/60))
        let remainSecondText = numberFormatter.string(from: NSNumber(value: Int(Double(dataArray[dataIndex].duration)-player.currentTime().seconds)%60))
        remainLabel.text = remainMinuteText! + ":" + remainSecondText!
       
        //播完自動換下一首
        if Int(player.currentTime().seconds) == dataArray[dataIndex].duration{
            if dataIndex > 0 && dataIndex < 4{
                dataIndex += 1
                loadMusicInformation(Index: dataIndex)
                executePlayOrPause(mode: .play, Index: dataIndex)
            }else if dataIndex == 0{
                dataIndex = 4
                loadMusicInformation(Index: dataIndex)
                executePlayOrPause(mode: .play, Index: dataIndex)
            }else if dataIndex == 4{
                dataIndex = 0
                loadMusicInformation(Index: dataIndex)
                executePlayOrPause(mode: .play, Index: dataIndex)
            }
        }
    }
    
    
}
