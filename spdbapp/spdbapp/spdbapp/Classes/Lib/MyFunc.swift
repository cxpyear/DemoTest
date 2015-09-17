//
//  MyFunc.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/9/8.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Foundation



var CurrentDidChangeNotification = "CurrentDidChangeNotification"
var CurrentDidChangeName = "CurrentDidChangeName"

//var CurrentDidChangeNotification = "CurrentDidChangeNotification"
var IPDidChangeName = "IPDidChangeName"


//返回颜色
func SHColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return UIColor(red: (red)/255.0, green: (green)/255.0, blue: (blue)/255.0, alpha: 1)

}

func getFilePath(docPath: String) -> String{
    return NSHomeDirectory().stringByAppendingPathComponent("Documents/\(docPath)")
}


//func dataToModel(data: AnyObject, model: AnyObject)  -> AnyObject {
////    var model = NSObject()
//    var mirror = reflect(model)
//    //{ $0 == "." }
//    for var i = 1 ; i < mirror.count ; i++ {
//        println("mirror\(i) = \(mirror[i].0)====type = \(mirror[i].1.valueType)")
////        var str = "\(mirror[i].1.valueType)"
////
////        if str == "Swift.Array<spdbapp.GBAgenda>"
//    }
//    
//    if data.isKindOfClass(NSDictionary.self) == false{
//        println("data不是一个字典")
//        return false
//    }else{
//        var dict = NSDictionary(dictionary: data as! NSDictionary)
//        for var i = 0 ; i < dict.count ; i++ {
//            var key = dict.keyEnumerator().allObjects[i] as! String
//            if let keyValue: AnyObject = dict.valueForKey(key){
//                println("key = \(key)==========val = \(keyValue)")
//                
//                for var i = 1; i < mirror.count ; i++ {
//                    if mirror[i].0 == key{
//                        model.setValue(keyValue, forKeyPath: mirror[i].0)
//                    }
//                }
//                
//            }
//        }
//        return model
//    }
//}
