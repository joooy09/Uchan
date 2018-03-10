//
//  SearchViewController.swift
//  Uchan
//
//  Created by Joyce on 2018/3/6.
//  Copyright © 2018年 Joy. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {
    /*
    struct channelJSON:Codable{
        struct Item:Codable {
            struct Id:Codable {
                let kind:String
                let channelId:String
            }
            struct Snippet:Codable {
                struct Thumbnails:Codable {
                    struct ThumbnailsItem:Codable {
                        let url:String
                    }
                    let `default`:ThumbnailsItem
                }
                let publishedAt:String
                let channelId:String
                let title:String
                let description:String
                let thumbnails:Thumbnails
            }
            let kind:String
            let etag:String
            let id:Id
            let snippet:Snippet
        }
        let nextPageToken:String
        let regionCode:String
        let items:[Item]
    }
 */
    
    struct channelPlaylistIdJSON:Codable{
        struct Items:Codable {
            struct ContentDetails:Codable {
                struct RelatedPlaylists:Codable {
                    let uploads:String
                }
                let relatedPlaylists:RelatedPlaylists
            }
            let contentDetails:ContentDetails
        }
        let items:[Items]
    }
    
    var apiKey = "AIzaSyAZC6dymTciLawKjS5Pys-K2MPHzXrXprY"
    var cellIdentifer:String!
    var searchResultList:Array<ChannelDataType> = []
    var playListId:String?
    
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var keywordText: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func goSerch(_ sender:UIButton){
        searchResultList.removeAll()
        
        var searchChannelString:String
        searchChannelString = keywordText.text!
        if (searchChannelString.range(of: " ") != nil){
            searchChannelString=searchChannelString.replacingOccurrences(of: " ", with: "+")
        }
        let request = URLRequest(url: URL(string: "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=5&q=\(searchChannelString)&type=channel&key=\(apiKey)")!)
        let semaphoreEndSearch = DispatchSemaphore.init(value: 0)
        DispatchQueue.global().async {
            self.fetchedDataByDataTask(from: request, completion:{(data) in
                self.processSearchChannelData(data: data)
                semaphoreEndSearch.signal()
            })
        }
        semaphoreEndSearch.wait()
        for i in 0..<self.searchResultList.count{
            print(self.searchResultList[i].title)
        }
            
        //load table
        DispatchQueue.main.async {
            self.searchResultTableView.reloadData()
        }
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
        
     func processSearchChannelData(data: Data){
        let decoder: JSONDecoder = JSONDecoder()
            if let dataList = try? decoder.decode(JSONFormat.channel.self, from: data){
                for i in 0..<dataList.items.count{
                    let item:ChannelDataType = ChannelDataType(channelid: dataList.items[i].snippet.channelId,
                                                               title: dataList.items[i].snippet.title,
                                                               thumbnail: dataList.items[i].snippet.thumbnails.`default`.url,
                                                               description: dataList.items[i].snippet.description,
                                                               playlistid: nil,
                                                               videoList: nil, nextPageInfo: nil)
                    searchResultList.append(item)
                }
            } else {
                DispatchQueue.main.async {
                    self.errorLabel.text = "Wrong Channel Keyword!"
                }
            }
        }
    func processSearchChannelPlayListIdData(data: Data){
        let decoder: JSONDecoder = JSONDecoder()
        if let dataList = try? decoder.decode(channelPlaylistIdJSON.self, from: data){
            
            searchResultList[searchResultTableView.indexPathForSelectedRow!.row].playlistid = dataList.items[0].contentDetails.relatedPlaylists.uploads
            playListId = dataList.items[0].contentDetails.relatedPlaylists.uploads
        } else {
            print("searchResultTableView.indexPathForSelectedRow!.index! ERROR")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = searchResultTableView.dequeueReusableCell(withIdentifier: cellIdentifer, for: indexPath)
        let channelNameTextView = cell.viewWithTag(21) as!UITextView
        let channelImageView = cell.viewWithTag(22) as!UIImageView
        let channelDescriptionTextView = cell.viewWithTag(23) as! UITextView
     
        channelNameTextView.text = searchResultList[indexPath.row].title
        channelImageView.image = UIImage(data:try! Data(contentsOf:searchResultList[indexPath.row].thumbnail))!
        channelDescriptionTextView.text = searchResultList[indexPath.row].description

        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellIdentifer = "com.joy.Uchan.search"
        searchResultTableView.delegate = self
        searchResultTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "channelSegue"{
            let request = URLRequest(url: URL(string: "https://www.googleapis.com/youtube/v3/channels?part=contentDetails&id=\(searchResultList[(searchResultTableView.indexPathForSelectedRow?.row)!].channelid)&key=\(apiKey)")!)
        
            let semaphoreEndPrepare = DispatchSemaphore.init(value: 0)
            DispatchQueue.global().async {
                self.fetchedDataByDataTask(from: request, completion:{(data) in
                    self.processSearchChannelPlayListIdData(data: data)
                    semaphoreEndPrepare.signal()
                })
            }
            semaphoreEndPrepare.wait()
            let channelViewController:ChannelViewController = segue.destination as! ChannelViewController
            let i = searchResultTableView.indexPathForSelectedRow!.row
            channelViewController.channel = searchResultList[i]
        }
        
    }



}
