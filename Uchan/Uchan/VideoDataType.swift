//
//  VideoDataType.swift
//  Uchan
//
//  Created by Joyce on 2018/3/7.
//  Copyright © 2018年 Joy. All rights reserved.
//


class VideoDataType {
    var title:String
    var channel:String
    var description:String
    var date:Date
    var thumbnail:URL
    var videoid:String
    
    init(title:String, channel:String, description:String, date:String, thumbnail:String, videoid:String){
        self.title = title
        self.channel = channel
        self.description = description
        self.videoid = videoid
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        self.date = dateFormatter.date(from: date)!
        self.thumbnail = URL(string: thumbnail)!
    }
    func getDate()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return dateFormatter.string(from: self.date)
    }
}
