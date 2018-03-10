//
//  ChannelViewController.swift
//  Uchan
//
//  Created by Joyce on 2018/3/6.
//  Copyright © 2018年 Joy. All rights reserved.
//

import UIKit

class ChannelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UINavigationBarDelegate {
    /*
    struct videoJSON:Codable {
        struct Items:Codable {
            struct Snippet:Codable {
                struct Thumbnails:Codable {
                    struct Img:Codable {
                        let url:String
                    }
                    let `default`:Img
                }
                struct ResourceId:Codable {
                    let videoId:String
                }
                let publishedAt:String
                let title:String
                let description:String
                let thumbnails:Thumbnails
                let resourceId:ResourceId
            }
            let snippet:Snippet
        }
        let nextPageToken:String
        let items:[Items]
    }
 */
    
    var apiKey = "AIzaSyAZC6dymTciLawKjS5Pys-K2MPHzXrXprY"
    var channel:ChannelDataType!
    var videoList:Array<VideoDataType> = []
    var Identifier: String?
    let dateFormatter = DateFormatter()
    var db:SQLiteConnect?
    
    @IBOutlet weak var channelNameTextView: UITextView!
    @IBOutlet weak var channelThumbnailImageView: UIImageView!
    @IBOutlet weak var videoTableView: UITableView!
    @IBOutlet weak var subButton: UIButton!
    
    @IBAction func subscribe(_ sender:UIButton){
        if(subButton.currentTitle == "Subscribe"){
            //訂閱
            if (db?.insert(channelid:channel.channelid,
                           title: channel.title,
                           thumbnail: "\(channel.thumbnail)",
                           description: channel.description,
                           playlistid: channel.playlistid!))! {
                print("Insert")
                subButton.setTitle("Unbscribe", for: .normal)
                
            }
        }else{
            //退訂
            if(db?.delete(channelid:channel.channelid))!{
                subButton.setTitle("Subscribe", for: .normal)
            }else{
                print("delete error")
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = videoTableView.dequeueReusableCell(withIdentifier: Identifier!)
        
        let videoNameTextView = cell?.viewWithTag(31) as! UITextView
        let videoThumbnailImageView = cell?.viewWithTag(32) as! UIImageView
        let videoDateLabel = cell?.viewWithTag(33) as! UILabel
        
        videoNameTextView.text = videoList[indexPath.row].title
        videoThumbnailImageView.image = UIImage(data: try! Data(contentsOf:(videoList[indexPath.row].thumbnail)))
        videoDateLabel.text = dateFormatter.string(from: videoList[indexPath.row].date)
        return cell!
    }
    
    func fetchedDataByDataTask(from request: URLRequest, completion: @escaping (Data) -> Void){
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil{
                print(error!)
            }else{
                guard let data = data else{return}
                completion(data)
            }
        }
        task.resume()
    }
    
    func processVideoData(data: Data){
        let decoder: JSONDecoder = JSONDecoder()
        if let dataList = try? decoder.decode(JSONFormat.video.self, from: data){
            for item in dataList.items{
                let video = VideoDataType(title: item.snippet.title,
                                          channel: channel.title,
                                          description: item.snippet.description,
                                          date: item.snippet.publishedAt,
                                          thumbnail: item.snippet.thumbnails.`default`.url,
                                          videoid: item.snippet.resourceId.videoId)
                videoList.append(video)
            }
            print("video JSON SUS")
        } else {
            print( "video JSON error")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        videoTableView.dataSource = self
        videoTableView.delegate = self
        Identifier = "com.joy.Uchan.channelVideoList"
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        
        channelNameTextView.text = channel.title
        channelThumbnailImageView.image = UIImage(data: try! Data(contentsOf:(channel.thumbnail)))
        
        let request = URLRequest(url: URL(string: "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=\(channel.playlistid!)&key=\(apiKey)")!)
        print("*** URL *** \("https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=\(channel.playlistid!)&key=\(apiKey)")")
        let semaphoreEndPrepare = DispatchSemaphore.init(value: 0)
        DispatchQueue.global().async {
            self.fetchedDataByDataTask(from: request, completion:{(data) in
                self.processVideoData(data: data)
                semaphoreEndPrepare.signal()
            })
        }
        
        let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
        print(sqlitePath)
        db = SQLiteConnect(path: sqlitePath)
        if(db?.createTable())!{print("create table sus")}
        let c1:ChannelDataType? = (db?.fetch(channelid: channel.channelid))
        if(c1 != nil){
            subButton.setTitle("Unsubscribe", for: .normal)
        }else{
            subButton.setTitle("Subscribe", for: .normal)
        }
        
        semaphoreEndPrepare.wait()
        videoTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "channel_playVideoSegue"{
            let playVideoViewController:PlayVideoViewController = segue.destination as! PlayVideoViewController
            let ii = videoTableView.indexPathForSelectedRow!.row
            playVideoViewController.video = videoList[ii]
            playVideoViewController.channelThumbnail = channel.thumbnail
        }
    }
    


}
