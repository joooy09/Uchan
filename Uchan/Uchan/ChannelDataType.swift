//
//  ChannelDataType.swift
//  Uchan
//
//  Created by Joyce on 2018/3/7.
//  Copyright © 2018年 Joy. All rights reserved.
//


class ChannelDataType {
    var channelid:String
    var title:String
    var thumbnail:URL
    var description:String
    var playlistid:String?
    var videoList:[VideoDataType]?
    var nextPageInfo:String?
    
    init(channelid:String, title:String, thumbnail:String, description:String, playlistid:String?, videoList:[VideoDataType]? ,nextPageInfo:String?){
        self.title = title
        self.thumbnail = URL(string: thumbnail)!
        self.description = description
        self.channelid = channelid
        self.playlistid = playlistid
        self.videoList = videoList
        self.nextPageInfo = nextPageInfo
    }

}
