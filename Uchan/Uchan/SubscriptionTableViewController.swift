//
//  SubscriptionTableViewController.swift
//  Uchan
//
//  Created by Joyce on 2018/3/7.
//  Copyright © 2018年 Joy. All rights reserved.
//

import UIKit

class SubscriptionTableViewController: UITableViewController {
    var db:SQLiteConnect?
    var channelList:Array<ChannelDataType> = []
   
    @IBOutlet var channelTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        channelTableView.delegate = self
        channelTableView.dataSource = self
        
        let sqlitePath = NSHomeDirectory() + "/Documents/sqlite3.db"
        print(sqlitePath)
        
        db = SQLiteConnect(path: sqlitePath)
        channelList = (db?.fetchAll())!
        
        channelTableView.reloadData()
        for ii in channelList{
            print("**********")
            print("\(ii.title)")
            print("\(ii.thumbnail)")
            print("\(ii.description)")
        }
        
        /*
        if(db?.createTable())!{print("create table sus")}
 
        if (db?.insert(channelid: "UCj_z-Zeqk8LfwVxx0MUdL-Q",
                       title: "上班不要看 NSFW",
                       thumbnail: "https://yt3.ggpht.com/-OAl2QeRgZXM/AAAAAAAAAAI/AAAAAAAAAAA/WB3JFKrq6cY/s88-c-k-no-mo-rj-c0xffffff/photo.jpg",
                       description: "那是一個特別寒冷的冬天，呱吉和小火車在下雪的台北成立了一個只有兩人的工作室。 慢慢地，越來越多快樂小夥伴的加入....我們持續在創作有趣...",
                       playlistid: "UUj_z-Zeqk8LfwVxx0MUdL-Q"))! {
            print("Inser 上班不要看")
        }
         
         db?.delete(channelid: "UCj_z-Zeqk8LfwVxx0MUdL-Q")
         let c1:ChannelDataType? = (db?.fetch(channelid: "UCj_z-Zeqk8LfwVxx0MUdL-Q"))
     */
        
     
      
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channelList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.joy.Uchan.subChannel", for: indexPath)

        let channelLabel = cell.viewWithTag(41) as! UILabel
        let channelThumbnailImageView = cell.viewWithTag(42) as! UIImageView
        let channelDescriptionTextView = cell.viewWithTag(43) as! UITextView
        
        channelLabel.text = channelList[indexPath.row].title
        channelThumbnailImageView.image = UIImage(data:try! Data(contentsOf:channelList[indexPath.row].thumbnail))!
        channelDescriptionTextView.text = channelList[indexPath.row].description
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
