//
//  PlayVideoViewController.swift
//  Uchan
//
//  Created by Joyce on 2018/3/6.
//  Copyright © 2018年 Joy. All rights reserved.
//

import UIKit

class PlayVideoViewController: UIViewController {
    public var channelThumbnail:URL!
    public var video:VideoDataType!
    
    @IBOutlet weak var videoNameText: UITextView!
    @IBOutlet weak var videoDateLabel: UILabel!
    @IBOutlet weak var videoDescriptionTextView: UITextView!
    
    @IBOutlet weak var playerView: YTPlayerView!
    
    @IBOutlet weak var channelThumbnailImageView: UIImageView!
    
    @IBOutlet weak var channelNameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        videoNameText.text = video.title
        videoDateLabel.text = video.getDate()
        videoDescriptionTextView.text = video.description
        channelThumbnailImageView.image = UIImage(data: try! Data(contentsOf: channelThumbnail))
        channelNameLabel.text = video.channel
        playerView.load(withVideoId: video.videoid)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
