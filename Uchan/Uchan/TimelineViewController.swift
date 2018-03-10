//
//  TimelineViewController.swift
//  Uchan
//
//  Created by Joyce on 2018/3/5.
//  Copyright © 2018年 Joy. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UINavigationBarDelegate  {
    // youtube api
    var apiKey = "AIzaSyAZC6dymTciLawKjS5Pys-K2MPHzXrXprY"
    // UI Data
    var sortedVideoList:Array<VideoDataType> = []
    var channelDict:Dictionary<String, ChannelDataType> = [:]
    // UI
    let cellIdentifer = "com.joy.Uchan.timelineVideo"
    @IBOutlet weak var videoTableView: UITableView!
    // DB
    var db:SQLiteConnect?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedVideoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = videoTableView.dequeueReusableCell(withIdentifier: cellIdentifer, for: indexPath)
        let videoTitleTextView = cell.viewWithTag(1) as! UITextView
        let videoThumbnailImageView = cell.viewWithTag(2) as! UIImageView
        let dateLabel = cell.viewWithTag(3) as! UILabel
        let channelTitleLabel = cell.viewWithTag(4) as! UILabel
        let channelThumbnailImageView = cell.viewWithTag(5) as! UIImageView
       
        let ii = indexPath.row
        videoTitleTextView.text = sortedVideoList[ii].title
        videoThumbnailImageView.image = UIImage(data:try! Data(contentsOf: sortedVideoList[ii].thumbnail))
        dateLabel.text = sortedVideoList[ii].getDate()
        channelTitleLabel.text = sortedVideoList[ii].channel
        channelThumbnailImageView.image = UIImage(data: try! Data(contentsOf:(channelDict[sortedVideoList[ii].channel]?.thumbnail)!))
        
        return cell
    }
    
    func sortList(){
        var tmpChanList:Array<Array<VideoDataType>> = []
        var tmp:Array<VideoDataType> = []
       
        for ii in channelDict{
            print("*** \(ii.value.title) ***")
            if(ii.value.videoList == nil){
                
            }else{
                tmpChanList.append(ii.value.videoList!)
            }
        }
        
        for ii in 0..<tmpChanList.count{
            tmp.append(tmpChanList[ii].first!)
            tmpChanList[ii].removeFirst(1)
        }
        
        
        repeat{
            let min = tmp.min(by: {$0.date > $1.date})
            sortedVideoList.append(min!)
            let ii = tmp.index(where: {$0.videoid == min?.videoid})
            tmp[ii!] = tmpChanList[ii!].first!
            tmpChanList[ii!].removeFirst(1)
            if(tmpChanList[ii!].isEmpty){break}
        }while(sortedVideoList.count<50)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        videoTableView.delegate = self
        videoTableView.dataSource = self
        
        channelDict.removeAll()
        sortedVideoList.removeAll()
        // connect to DB fetch subscription
        let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
        print("*inVDL* sqlite path : \(sqlitePath) ***")
        
        db = SQLiteConnect(path: sqlitePath)
        
        let channelList = (db?.fetchAll())!
        for chan in channelList{
            channelDict[chan.title] = chan
        }

        // load video
        let semaphEndLoad = DispatchSemaphore.init(value: 0)
        for chan in channelList{
            DispatchQueue.global().async {
                self.requestGetVideos(channelPlayListID: chan.playlistid!, completion: { (data) in
                    self.processVedioData(data: data)
                    semaphEndLoad.signal()
                })
            }
        }
        for _ in channelList {semaphEndLoad.wait()}
        sortList()

        for kk in channelDict.keys{
            print("** \(channelDict[kk]!.title)")
        }
        
       
    }
    
    func requestGetVideos(channelPlayListID:String, completion: @escaping (Data) -> Void ) {
        let request = URLRequest(url:URL(string: "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=\(channelPlayListID)&key=\(apiKey)")!)
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
    
    private func processVedioData(data: Data){
        let decoder: JSONDecoder = JSONDecoder()
        if let dataList = try? decoder.decode( JSONFormat.video.self, from: data){
            var videoList:Array<VideoDataType> = []
            for item in dataList.items{
                let video:VideoDataType = VideoDataType(title: item.snippet.title,
                                                        channel: item.snippet.channelTitle,
                                                        description: item.snippet.description,
                                                        date: item.snippet.publishedAt,
                                                        thumbnail: item.snippet.thumbnails.default.url,
                                                        videoid: item.snippet.resourceId.videoId)
                videoList.append(video)
            }
            channelDict[dataList.items[0].snippet.channelTitle]?.videoList = videoList
        } else {
            print("JSON Video : error")
        }
    }
    
     

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playVideoSegue"{
            
            let playVideoViewController:PlayVideoViewController = segue.destination as! PlayVideoViewController
            let ii:Int = videoTableView.indexPathForSelectedRow!.row
            playVideoViewController.video = sortedVideoList[ii]
            playVideoViewController.channelThumbnail = channelDict[sortedVideoList[ii].channel]?.thumbnail
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewDidLoad()
        DispatchQueue.main.async {
            self.videoTableView.reloadData()
            print("show new Sorted List ")
        }

        
    }

}
