//
//  DownLoadFiles.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/5/19.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire


class DownloadFile: NSObject {
    var filebar: Float = 0
    var fileid: String = ""
    var filename: String = ""
}
var downloadlist:[DownloadFile] = []

class DownLoadManager: NSObject {
    
    //判断当前文件夹是否存在jsondata数据，如果不存在，则继续进入下面的步骤
    //如果存在该数据，则判断当前json与本地jsonlocal是否一致，如果一致，则打印 json数据信息已经存在，return
    class func isSameJSONData(jsondata: NSData) -> Bool {
        
        var localJSONPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
        var filemanager = NSFileManager.defaultManager()
        
        if filemanager.fileExistsAtPath(localJSONPath){
            let jsonLocal = filemanager.contentsAtPath(localJSONPath)
          
            if jsonLocal == jsondata {
                println("json数据信息已经存在")
                return true
            }
            return false
        }
        return false
    }
    
    class func isSamePDFFile(fileid: String) -> Bool {
        var filePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(fileid).pdf")
        
        var filemanager = NSFileManager.defaultManager()
        
        if filemanager.fileExistsAtPath(filePath){
            for var i = 0; i < downloadlist.count; ++i {
                if fileid == downloadlist[i].fileid {
                    downloadlist[i].filebar = 1
                }
            }
            return true
        }
        return false
    }
    
    class func isStart(bool: Bool){
        if bool == true{
            downloadTest()
            downLoadJSON()
        }
    }
    
    
    class func downloadTest(){
        var meeting = appManager.current
        var meetingid = meeting.id
        var sourcesInfo = meeting.sources
        
        println("sourcesInfo.count = \(sourcesInfo.count)")
        
        
        for var i = 0 ; i < sourcesInfo.count ; i++ {
            var fileid = sourcesInfo[i].id
            
            var filename = String()
            
            //根据source的id去寻找对应的name
//            if let sources = json["source"].array{
//                for var k = 0 ; k < sources.count ; k++ {
//                    if fileid == sources[k]["id"].stringValue{
//                        filename = sources[k]["name"].stringValue
//                    }
//                }
//            }

            
            var isfind:Bool = false
            var downloadCurrentFile = DownloadFile()
            downloadCurrentFile.filebar = 0
            downloadCurrentFile.fileid = fileid
            
            if downloadlist.count==0{
                downloadlist.append(downloadCurrentFile)
            }
            else {
                for var i = 0; i < downloadlist.count  ; ++i {
                    if fileid == downloadlist[i].fileid {
                        isfind = true
                    }
                }
                if !isfind {
                    downloadlist.append(downloadCurrentFile)
                }
            }
            
            //http://192.168.2.101:10086/gbtouch/meetings/e9f63596-ddac-4d19-996b-cd592d1b77af/570de66d-e17c-40e9-9daa-60e3e3b56894.pdf
            var filepath = server.downloadFileUrl + "gbtouch/meetings/\(meetingid)/\(fileid).pdf"
            var getPDFURL = NSURL(string: filepath)
            let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
            println("filepath  = \(filepath)")
            
            
            //判断../Documents是否存在当前filename为名的文件，如果存在，则返回；如不存在，则下载文件
            var b = self.isSamePDFFile(fileid)
            if b == false{
                Alamofire.download(.GET, getPDFURL!, destination).progress {
                    (_, totalBytesRead, totalBytesExpectedToRead) in
                    dispatch_async(dispatch_get_main_queue()) {
                        var processbar: Float = Float(totalBytesRead)/Float(totalBytesExpectedToRead)
                        
                        downloadCurrentFile.fileid = fileid
                        downloadCurrentFile.filebar = processbar
                        
                        for var i = 0; i < downloadlist.count  ; ++i {
                            if fileid == downloadlist[i].fileid {
                                if processbar > downloadlist[i].filebar {
                                    downloadlist[i].filebar = processbar
                                }
                            }
                        }
                        
                        if totalBytesRead == totalBytesExpectedToRead {
                            println("\(fileid)   下载成功")
                        }
                    }
                }
            }
            else if b == true{
                println("\(fileid)文件已存在")
            }
            
        }
    }
    
    
    
    class func isFileDownload(id: String) -> Bool{
        var filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents/\(id).pdf")
        var manager = NSFileManager.defaultManager()
        if manager.fileExistsAtPath(filepath){
            return true
        }else{
            return false
        }
    }
    
    
    //下载json数据到本地并保存
    class func downLoadJSON(){
        
        Alamofire.request(.GET, server.meetingServiceUrl).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (_, _, data, err) -> Void in
            var jsonFilePath = NSHomeDirectory().stringByAppendingPathComponent("Documents/jsondata.txt")
            
            println("\(data)")
            
            if(err != nil){
                println("下载当前json出错，error ===== \(err)")
                return
            }
            var jsondata = NSJSONSerialization.dataWithJSONObject(data!, options: NSJSONWritingOptions.allZeros, error: nil)
            
            //如果当前json和服务器上的json数据不一样，则保存。保存成功提示：当前json保存成功，否则提示：当前json保存失败。
            var bool = self.isSameJSONData(jsondata!)
            if !bool{
                var b = jsondata?.writeToFile(jsonFilePath, atomically: true)
                if (b! == true) {
                    NSLog("当前json保存成功")
                }
                else{
                    NSLog("当前json保存失败")
                }
                
            }
            
            var manager = NSFileManager.defaultManager()
            if !manager.fileExistsAtPath(jsonFilePath){
                var b = manager.createFileAtPath(jsonFilePath, contents: nil, attributes: nil)
                if b{
                    println("创建json成功")
                }
            }
        }
    }
    
}
