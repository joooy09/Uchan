//
//  SubChannelViewController.swift
//  Uchan
//
//  Created by Joyce on 2018/3/7.
//  Copyright © 2018年 Joy. All rights reserved.
//

import UIKit

class SubChannelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var channelList:Array<ChannelDataType> = []
    var db:SQLiteConnect?
    
    @IBOutlet weak var channelTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        channelTableView.delegate = self
        channelTableView.dataSource = self
        
        let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
        print(sqlitePath)
        
        db = SQLiteConnect(path: sqlitePath)
        channelList = (db?.fetchAll())!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.joy.Uchan.subChannel", for: indexPath)
        
        let channelLabel = cell.viewWithTag(41) as! UILabel
        let channelThumbnailImageView = cell.viewWithTag(42) as! UIImageView
        let channelDescriptionTextView = cell.viewWithTag(43) as! UITextView

        channelLabel.text = channelList[indexPath.row].title
        channelThumbnailImageView.image = UIImage(data:try! Data(contentsOf:channelList[indexPath.row].thumbnail))!
        channelDescriptionTextView.text = channelList[indexPath.row].description
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "subscription_channelSegue"{
            let channelViewController:ChannelViewController = segue.destination as! ChannelViewController
            let ii = channelTableView.indexPathForSelectedRow!.row
            channelViewController.channel = channelList[ii]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewDidLoad()
        channelTableView.reloadData()
    }

}
