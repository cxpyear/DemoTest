//
//  Models.swift
//  spdbapp
//
//  Created by tommy on 15/5/11.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import Foundation

protocol GBModelBaseAciton {
    func Add()
    func Update()
    func Del()
    func Find()
}

//meeting type
enum GBMeetingType {
    case HANGBAN, DANGBAN, DANGWEI, DONGSHI, ALL
}


class GBBase: NSObject {
    var basename = ""
}

class GBUser: NSObject {
    var id = String()
    var username = String()
    var name = String()
    var password = String()
    var type = String()
    var role = String()
}

class GBServer:NSObject{
    var id = String()
    var name = String()
    var chairname = String()
    var service = String()
    var createtime = String()
}


class GBBox: GBBase {
    var macId : String = "11-22-33-44-55-66"
    var type : String = ""
    var name: String = ""

    
    var connect: Bool = false
    
    override init(){
        super.init()
        type = ""
        macId = GBNetwork.getMacId()
        name = ""
        connect = false
    }
}


class GBMeeting: GBBase {
    var name: String = ""
    var startTime: NSDate = NSDate()
    var status: Bool?
    var id: String = ""
    var agendas = [GBAgenda]()
    var sources = [GBSource]()
    var member = [String]()
}

class GBSource : NSObject {
    var id: String
    var type: String
    var name: String
    var sourextension: String
    var sourpublic: String
    var link: String
    var aidlink: String
    var meetingtype: String
    var memberrole: String

    override init(){
        id = ""
        type = ""
        name = ""
        sourextension = ""
        sourpublic = ""
        link = ""
        aidlink = ""
        meetingtype = ""
        memberrole = ""
    }
}


class GBAgenda: NSObject {
    var id: String = ""
    var name: String = ""
    var source: [GBSource] = []
    var index: String = ""
    var starttime: String = ""
    var endtime: String = ""
    var reporter: String = ""
}


