//
//  ViewController.swift
//  Patrick_Videos
//
//  Created by pratik on 20/09/18.
//  Copyright © 2018 pratik. All rights reserved.
//

import UIKit
//
//class ViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//}



import UIKit
import AVKit

public struct VideoName {
    static let video1 = "video1"
    static let video2 = "video2"
}

public struct MediaType {
    static let video = 1
    static let image = 2
}

class ExpandableModel {
    
    var id: Int = 0
    var videoTitle: String?
    var description: String?
    var isExpandable: Bool = false
    
    init(videoTitle: String?, description: String?, isExpandable: Bool = false) {
        self.videoTitle = videoTitle
        self.description = description
        self.isExpandable = isExpandable
    }
}


class ViewController: UIViewController {
    
    @IBOutlet weak var collView: UICollectionView!
    var timer: Timer?
    var isVideoPlaying: Bool = false
    
    var expandableModelArray = [ExpandableModel]()

    @IBOutlet weak var collectionView: UICollectionView!
    
    var lastSelectedIndexPath : IndexPath? = nil

    var expandedIndexPath: IndexPath? {
        didSet {
            switch expandedIndexPath {
            case .some(let index):
                //tableView.reloadRows(at: [index], with: .automatic)
                collectionView.reloadItems(at: [index])
            case .none:
                //tableView.reloadRows(at: [oldValue!], with: .automatic)
                collectionView.reloadItems(at: [oldValue!])
            }
        }
    }
    
    
    // ------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: - Memory management method
    
    // ------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.initialSetup()
        checkForTheVisibleVideo()
        
        
        expandableModelArrayFilling()
        
        //
    }
    
    
    func expandableModelArrayFilling() {
        for _ in 0..<10 {
            expandableModelArray.append(ExpandableModel(videoTitle: "video2", description: "", isExpandable: false))
        }
        collectionView.reloadData()

    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ------------------------------------------------------------------------------------------
    // MARK:
    // MARK: - Custom Methods
    
    // ------------------------------------------------------------------------------------------
    /*
    func initialSetup() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkForTheVisibleVideo), userInfo: nil, repeats: true)
        }
        timer?.fire()
    }*/
    
    // ------------------------------------------------------------------------------------------
    
    //@objc
    func checkForTheVisibleVideo() {
        if !isVideoPlaying {
            let visibleCell = self.collView.indexPathsForVisibleItems
            if visibleCell.count > 0 {
                for indexPath in visibleCell {
                    if self.isVideoPlaying {
                        break
                    }
                    if let cell = self.collView.cellForItem(at: indexPath) as? CustomCell,cell.mediaType == MediaType.video {
                        if cell.player == nil{
                            cell.player = AVPlayer(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: VideoName.video2, ofType: "mp4")!))
                            cell.playerLayer = AVPlayerLayer.init(player: cell.player)
                            cell.playerLayer?.frame = cell.imgView.frame
                            cell.imgView.layer.addSublayer(cell.playerLayer!)
                            NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: cell.player?.currentItem)
                            cell.player?.addPeriodicTimeObserver(forInterval: CMTime.init(seconds: 1, preferredTimescale: 1), queue: .main, using: { (time) in
                                if cell.player?.currentItem?.status == .readyToPlay {
                                    
                                    let timeDuration : Float64 = CMTimeGetSeconds((cell.player?.currentItem?.asset.duration)!)
                                    cell.lblDuration.text = self.getDurationFromTime(time: timeDuration)
                                    
                                    let currentTime : Float64 = CMTimeGetSeconds((cell.player?.currentTime())!)
                                    cell.lblStart.text = self.getDurationFromTime(time: currentTime)
                                    cell.slider.maximumValue = Float(timeDuration.rounded())
                                    cell.slider.value = Float(currentTime.rounded())
                                }
                            })
                        }
//                        cell.player?.play()
//                        //cell.btnPlay.setImage(#imageLiteral(resourceName: "pause_video"), for: .normal)
//                        self.isVideoPlaying = true
                        
                        cell.player?.pause()
                        //cell.btnPlay.setImage(#imageLiteral(resourceName: "pause_video"), for: .normal)
                        self.isVideoPlaying = false
                    }
                }
            }
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.collView.reloadData()
        })
        
    }
    
 
    
    // ------------------------------------------------------------------------------------------
    /*
    @objc func videoDidFinishPlaying() {
        self.isVideoPlaying = false
        let visibleItems: Array = self.collView.indexPathsForVisibleItems
        
        if visibleItems.count > 0 {
            
            for currentCell in visibleItems {
                
                guard let cell = self.collView.cellForItem(at: currentCell) as? CustomCell else {
                    return
                }
                if cell.player != nil {
                    cell.player?.seek(to: kCMTimeZero)
                    cell.player?.play()
                }
            }
            
        }
    }
    */
    
    @objc func videoDidFinishPlaying() {
        self.isVideoPlaying = false
        let visibleItems: Array = self.collView.indexPathsForVisibleItems
        
        //if visibleItems.count > 0 {
            
//            for currentCell in visibleItems {
            
                guard let cell = self.collView.cellForItem(at: lastSelectedIndexPath!) as? CustomCell else {
                    return
                }
                if cell.player != nil {
                    cell.player?.seek(to: kCMTimeZero)
                    cell.player?.play()
                }
//            }
            
//        }
    }
    
    
    // ------------------------------------------------------------------------------------------
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            guard let cell = self.collView.cellForItem(at: IndexPath.init(item: slider.tag, section: 0)) as? CustomCell else {
                return
            }
            switch touchEvent.phase {
            case .began:
                cell.player?.pause()
            case .moved:
                cell.player?.seek(to: CMTimeMake(Int64(slider.value), 1))
            case .ended:
                cell.player?.seek(to: CMTimeMake(Int64(slider.value), 1))
                cell.player?.play()
            default:
                break
            }
        }
    }
    
    // ------------------------------------------------------------------------------------------
    
    func getDurationFromTime(time: Float64)-> String {
        
        let date : Date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
        dateFormatter.dateFormat = time < 3600 ? "mm:ss" : "HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    // ------------------------------------------------------------------------------------------
    
    @IBAction func btnPlayTapped(_ sender: UIButton) {
        
        let indexPath = IndexPath.init(item: sender.tag, section: 0)
        guard let cell = self.collView.cellForItem(at: indexPath) as? CustomCell else {
            return
        }
        if isVideoPlaying {
            self.isVideoPlaying = false
            //cell.btnPlay.setImage(#imageLiteral(resourceName: "play_video"), for: .normal)
            cell.player?.pause()
        }else{
            if cell.player == nil {
                cell.player = AVPlayer(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: VideoName.video2, ofType: "mp4")!))
                cell.playerLayer = AVPlayerLayer(player: cell.player!)
                cell.playerLayer?.frame = cell.imgView.frame
                cell.imgView.layer.addSublayer(cell.playerLayer!)
                NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: cell.player?.currentItem)
            }
            //cell.btnPlay.setImage(#imageLiteral(resourceName: "pause_video"), for: .normal)
            cell.player?.play()
            self.isVideoPlaying = true
        }
        
    }
    
    // ------------------------------------------------------------------------------------------
    // MARK: -
    // MARK: - View life cycle methods
    // ------------------------------------------------------------------------------------------
    
   
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return expandableModelArray.count
    }
    
    // ------------------------------------------------------------------------------------------
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.collView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as? CustomCell {
      
            
            let model = expandableModelArray[indexPath.row]

            cell.mediaType = MediaType.video
            
            
            if model.isExpandable == true {
                
                if cell.player == nil {
                    cell.player = AVPlayer(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: model.videoTitle, ofType: "mp4")!))
                    cell.playerLayer = AVPlayerLayer(player: cell.player!)
                    cell.playerLayer?.frame = cell.imgView.frame
                    cell.imgView.layer.addSublayer(cell.playerLayer!)
                    NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: cell.player?.currentItem)
                }
                //cell.btnPlay.setImage(#imageLiteral(resourceName: "pause_video"), for: .normal)
                cell.player?.play()
                self.isVideoPlaying = true
                
            } else {
                
                if cell.player == nil {
                    cell.player = AVPlayer(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: model.videoTitle, ofType: "mp4")!))
                    cell.playerLayer = AVPlayerLayer(player: cell.player!)
                    cell.playerLayer?.frame = cell.imgView.frame
                    cell.imgView.layer.addSublayer(cell.playerLayer!)
                    NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: cell.player?.currentItem)
                }
                
                self.isVideoPlaying = false
                //cell.btnPlay.setImage(#imageLiteral(resourceName: "play_video"), for: .normal)
                cell.player?.pause()
                
            }
 //*/
            /*
            if isVideoPlaying {
                self.isVideoPlaying = false
                //cell.btnPlay.setImage(#imageLiteral(resourceName: "play_video"), for: .normal)
                cell.player?.pause()
            }else{
                if cell.player == nil {
                    cell.player = AVPlayer(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: model.videoTitle, ofType: "mp4")!))
                    cell.playerLayer = AVPlayerLayer(player: cell.player!)
                    cell.playerLayer?.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 50, height: (UIScreen.main.bounds.size.height - 64) * 0.3)
                    cell.imgView.layer.addSublayer(cell.playerLayer!)
                    NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: cell.player?.currentItem)
                }
                //cell.btnPlay.setImage(#imageLiteral(resourceName: "pause_video"), for: .normal)
                //cell.player?.play()
                //self.isVideoPlaying = true
            }
 */
            cell.btnPlay.tag = indexPath.row
            cell.slider.tag = indexPath.row
            //cell.btnPlay.addTarget(self, action: #selector(btnPlayTapped(_:)), for: .touchUpInside)
            //cell.slider.addTarget(self, action: #selector(self.onSliderValChanged(slider:event:)), for: .valueChanged)
            return cell
        }
        return UICollectionViewCell()
    }
    
    // ------------------------------------------------------------------------------------------
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height / 3)
    }
    
    // ------------------------------------------------------------------------------------------
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cellToHide = cell as? CustomCell else {
            return
        }
        
        if cellToHide.player != nil {
            cellToHide.player?.pause()
            cellToHide.playerLayer?.removeFromSuperlayer()
            cellToHide.player = nil
            //cellToHide.btnPlay.setImage(#imageLiteral(resourceName: "play_video"), for: .normal)
            self.isVideoPlaying = false
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let model = expandableModelArray[indexPath.row]

        
        if let lastSelectedImage = lastSelectedIndexPath {
            if let cell = collectionView.cellForItem(at: lastSelectedImage) as? CustomCell {

                if cell.player == nil {
                    cell.player = AVPlayer(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: model.videoTitle, ofType: "mp4")!))
                    cell.playerLayer = AVPlayerLayer(player: cell.player!)
                    cell.playerLayer?.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 50, height: (UIScreen.main.bounds.size.height - 64) * 0.3)
                    cell.imgView.layer.addSublayer(cell.playerLayer!)
                    NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: cell.player?.currentItem)
                }
                
                
                self.isVideoPlaying = false
                //cell.btnPlay.setImage(#imageLiteral(resourceName: "play_video"), for: .normal)
                cell.player?.pause()

            }
        }
        
        if let cell = collectionView.cellForItem(at: indexPath) as? CustomCell {
            //cell.selectedImage.isHidden = false
            
            lastSelectedIndexPath = indexPath
            
            
            if cell.player == nil {
                cell.player = AVPlayer(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: model.videoTitle, ofType: "mp4")!))
                cell.playerLayer = AVPlayerLayer(player: cell.player!)
                cell.playerLayer?.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 50, height: (UIScreen.main.bounds.size.height - 64) * 0.3)
                cell.imgView.layer.addSublayer(cell.playerLayer!)
                NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: cell.player?.currentItem)
            }
            
            
            self.isVideoPlaying = true
            //cell.btnPlay.setImage(#imageLiteral(resourceName: "play_video"), for: .normal)
            cell.player?.play()

        }
        
        
       /*
        let expandableModelObject = expandableModelArray[indexPath.row]
        for item: ExpandableModel in expandableModelArray {
            
            if item.id == expandableModelObject.id {
                item.isExpandable = !item.isExpandable
            } else {
                item.isExpandable = false
                
            }
        }
        
        switch expandedIndexPath {
        case .some where expandedIndexPath == indexPath:
            //Click on expandable cell then close it.
            expandedIndexPath = nil
        case .some(let expandedIndex) where expandedIndex != indexPath:
            //New Cell link, already any cell expand -> old close and new expand
            expandedIndexPath = nil
            expandedIndexPath = indexPath
        default:
            //Click on Cell, no cell is expandable.
            expandedIndexPath = indexPath
        }
        
        */
        //collectionView.reloadItems(at: [indexPath])
        
        /*
        
        
        let indexPath = indexPath
        guard let cell = self.collView.cellForItem(at: indexPath) as? CustomCell else {
            return
        }
        
        
        if isVideoPlaying {
            self.isVideoPlaying = false
            //cell.btnPlay.setImage(#imageLiteral(resourceName: "play_video"), for: .normal)
            cell.player?.pause()
        }else{
            if cell.player == nil {
                cell.player = AVPlayer(url: URL.init(fileURLWithPath: Bundle.main.path(forResource: VideoName.video2, ofType: "mp4")!))
                cell.playerLayer = AVPlayerLayer(player: cell.player!)
                //cell.playerLayer?.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 50, height: (UIScreen.main.bounds.size.height - 64) * 0.3)
                
                cell.playerLayer?.frame = cell.imgView.frame
                cell.imgView.layer.addSublayer(cell.playerLayer!)
                NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: cell.player?.currentItem)
            }
            //cell.btnPlay.setImage(#imageLiteral(resourceName: "pause_video"), for: .normal)
            cell.player?.play()
            self.isVideoPlaying = true
        }
    */
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
    
}

// Custom Cell Class

class CustomCell: UICollectionViewCell {
    
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var mediaType: Int!
}
