//
//  JSONFormat.swift
//  Uchan
//
//  Created by Joyce on 2018/3/8.
//  Copyright © 2018年 Joy. All rights reserved.
//

class JSONFormat{
    struct channel:Codable{
        struct Item:Codable {
            struct Id:Codable {
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
            let id:Id
            let snippet:Snippet
        }
        let nextPageToken:String
        let regionCode:String
        let items:[Item]
    }
    
    struct video:Codable {
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
                let channelId:String
                let title:String
                let description:String
                let thumbnails:Thumbnails
                let channelTitle:String
                let playlistId:String
                let resourceId:ResourceId
            }
            let snippet:Snippet
        }
        var nextPageToken:String?
        let items:[Items]
    }

}
