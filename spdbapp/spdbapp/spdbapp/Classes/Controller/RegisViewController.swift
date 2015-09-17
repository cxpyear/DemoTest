//
//  RegisViewController.swift
//  spdbapp
//
//  Created by GBTouchG3 on 15/6/26.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit


var bNeedRefresh = true

var MyDeviceId = "MyDeviceId"
var MyDeviceName = "MyDeviceName"


class RegisViewController: UIViewController, UIAlertViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var viewparent: UIView!
    @IBOutlet weak var btnOK: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var btnOffLine: UIButton!
    @IBOutlet weak var viewInput: UIView!
    
    @IBOutlet weak var lblCurrentUserName: UILabel!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var btnHelp: UIButton!
    @IBOutlet weak var btnShare: UIButton!
//    @IBOutlet weak var btnHelp: UIButton!
    var kbHeight: CGFloat!
    
    var myUser = GBUser()
    
    var bNeedMove = true
    var bNeedInit = true
    
    var myBox = GBBox()
    var bNeedPostNote = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("path = \(NSHomeDirectory())")
        

        
        txtName.delegate = self
        txtPwd.delegate = self
        
        btnOK.layer.cornerRadius = 8
        btnOK.addTarget(self, action: "goLogin", forControlEvents: UIControlEvents.TouchUpInside)
        btnOffLine.layer.cornerRadius = 8
        

//        NetConnection().httpGet(server.meetingServiceUrl)
        self.loading.hidden = true
        
        //WARNING 记得正式运行时要改过来
//        self.btnOK.backgroundColor = UIColor.grayColor()
//        self.btnOK.enabled = false
        
        
        self.btnOK.enabled = true
        self.btnOK.backgroundColor = SHColor(143 , 1 , 41)
        
//        if self.bNeedInit == true{
//            bNeedInit = false
//            self.lblInitMessage.hidden = true
//        }

        
        btnHelp.addTarget(self, action: "showHelpView", forControlEvents: UIControlEvents.TouchUpInside)
        
        btnShare.addTarget(self, action: "shareApp", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func shareApp(){
        var shareUrl = "http://www.shgbit.com/spadapp"
        UIApplication.sharedApplication().openURL(NSURL(string: shareUrl)!)
    }
    
    func showHelpView(){
        var helpVC = NewFeatureViewController()
        self.presentViewController(helpVC, animated: true, completion: nil)
    }
    

    @IBAction func getOffLineMeeting(sender: UIButton) {
        bNeedRefresh = false
        var userInfoPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
        var userinfo = NSDictionary(contentsOfFile: userInfoPath)
        
        self.myUser.id = userinfo?.objectForKey("id") as! String
        self.myUser.username = userinfo?.objectForKey("username") as! String
        self.myUser.name = userinfo?.objectForKey("name") as! String
        self.myUser.password = userinfo?.objectForKey("password") as! String
        self.myUser.type = userinfo?.objectForKey("type") as! String
        self.myUser.role = userinfo?.objectForKey("role") as! String
        
        
        println("role = \(userinfo)")
        appManager.appGBUser = self.myUser

        bNeedRefresh = false
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let agendaVC: AgendaViewController = storyboard.instantiateViewControllerWithIdentifier("agenda") as! AgendaViewController
        
        self.presentViewController(agendaVC, animated: true, completion: nil)
    }
    
    /**
    登录方法
    */
    func goLogin(){
        
        bNeedRefresh = true
        self.loading.hidden = false
        self.loading.startAnimating()
        
        var name = txtName.text.trimAllString()
        var pwd = txtPwd.text.trimAllString()
        
        //如果当前box绑定对象为空，则要进行登录验证，否则获取其权限直接登录
        var userInfoPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
        var userinfo = NSDictionary(contentsOfFile: userInfoPath)
        
        var dictName = userinfo?.objectForKey("username") as? String
        
        if (self.myUser.username == dictName) {
          
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let agendaVC: AgendaViewController = storyboard.instantiateViewControllerWithIdentifier("agenda") as! AgendaViewController
            self.presentViewController(agendaVC, animated: true, completion: nil)
            self.loading.stopAnimating()

        }else{
        
        let paras = [ "username" : name, "password" : pwd ]
             
        Alamofire.request(.POST, server.loginServiceUrl ,parameters: paras, encoding: .JSON).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request,response, data, error) ->
            Void in
           
            println("data = \(data)")
            if error != nil{
                println("login err = \(error)")
                UIAlertView(title: "提示", message: "登录失败，无法连接到服务器", delegate: self, cancelButtonTitle: "确定").show()
                self.loading.stopAnimating()
                return
            } else if(response?.statusCode != 200){
                UIAlertView(title: "提示", message: "登录失败，用户名或密码错误", delegate: self, cancelButtonTitle: "确定").show()
                self.txtName.text = ""
                self.txtPwd.text = ""
                self.loading.stopAnimating()
                self.txtName.becomeFirstResponder()
                return
            }
            
            self.myUser.username = data?.objectForKey("username") as! String
            self.myUser.name = data?.objectForKey("name") as! String
            self.myUser.password = data?.objectForKey("password") as! String
            self.myUser.type = data?.objectForKey("type") as! String
            self.myUser.role = data?.objectForKey("role") as! String

            self.saveUserInfo()
            
            appManager.appGBUser = self.myUser
            
            
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let agendaVC: AgendaViewController = storyboard.instantiateViewControllerWithIdentifier("agenda") as! AgendaViewController
            self.presentViewController(agendaVC, animated: true, completion: nil)
            self.loading.stopAnimating()
        }
        }
    }
    
    func saveUserInfo(){
        var UserInfoPath = NSHomeDirectory().stringByAppendingPathComponent("Documents/UserInfo.txt")
        var manager = NSFileManager.defaultManager()
        if manager.fileExistsAtPath(UserInfoPath){
            manager.removeItemAtPath(UserInfoPath, error: nil)
        }
        manager.createFileAtPath(UserInfoPath, contents: nil, attributes: nil)
        
        var info = NSMutableDictionary()
        info["id"] = self.myUser.id
        info["username"] = self.myUser.username
        info["name"] = self.myUser.name
        info["type"] = self.myUser.type
        info["role"] = self.myUser.role
        info["password"] = self.myUser.password
        info.writeToFile(UserInfoPath, atomically: true)
    }

    
    func defaultsSettingsChanged() {
        let standardDefaults = NSUserDefaults.standardUserDefaults()
        var filepath = NSHomeDirectory().stringByAppendingPathComponent("Documents/SettingsConfig.txt")
        var settingsDict: NSMutableDictionary = NSMutableDictionary()
        
        // 监听txtFileURL是否发生改变  默认情况下是192.168.16.142
        var value = standardDefaults.stringForKey("txtBoxURL")
        if value == nil{
            value = "192.168.21.48"
        }
        settingsDict.setObject(value!, forKey: "txtBoxURL")
    
        var b = settingsDict.writeToFile(filepath, atomically: true)
        println("url new value ============ \(value)")
        
        var isClearHistoryInfo = standardDefaults.boolForKey("clear_historyInfo")
        if isClearHistoryInfo == true{
            server.clearHistoryInfo("pdf")
        }
        
        var isClearConfigInfo = standardDefaults.boolForKey("clear_configInfo")
        if isClearConfigInfo == true{
            server.clearHistoryInfo("txt")
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
  
    
    
    private var mycontext = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.userView.hidden = true
        isCurrentDeviceRegister()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "defaultsSettingsChanged", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    
   
    

    
    
    func postIdtoRegister(){
        var paras = ["id": GBNetwork.getMacId()]
        Alamofire.request(.POST, server.boxServiceUrl, parameters: paras, encoding: .JSON).responseJSON(options: NSJSONReadingOptions.AllowFragments, completionHandler: { (request, response, data, error) -> Void in
            if error != nil{
                println("post macid error = \(error)")
                return
            }else{
                println("post macid response = \(response?.statusCode.description)")
            }
            
            self.userView.hidden = true
            self.viewInput.hidden = false
        })

    }
    
    
//    func getKeys(){
//        var user = GBUser()
//        var mirror = reflect(user)
//        for var i = 0 ; i < mirror.count ; i++ {
//            println("mirror\(i) = \(mirror[i].0)")
//        }
//    }
    
    
//    func dataToModel(data: AnyObject, model: AnyObject) -> AnyObject  {
//        //        var model = NSObject()
//        //        getKeys()
//        
//        var mirror = reflect(model)
//        
//        var aClass = user.self
//        
//        if data.isKindOfClass(NSDictionary.self) == false{
//            println("data不是一个字典")
//            return
//        }else{
//            var dict = NSDictionary(dictionary: data as! NSDictionary)
//            for var i = 0 ; i < dict.count ; i++ {
//                var key = dict.keyEnumerator().allObjects[i] as! String
//                if let keyValue: AnyObject = dict.valueForKey(key){
//                    println("key = \(key)==========val = \(keyValue)")
//                    
//                    for var i = 1; i < mirror.count ; i++ {
//                        if mirror[i].0 == key{
//                            model.setValue(keyValue, forKeyPath: mirror[i].0)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
  
    
    func getMemberInfo(memberid: String){
        var urltest = server.memberServiceUrl + "/" + memberid
        Alamofire.request(.GET, urltest).responseJSON(options: NSJSONReadingOptions.MutableContainers, completionHandler: { (request, response, data, membererror) -> Void in
            //如果返回错误则break
            if membererror != nil{
                println("membererror error = \(membererror)")
                return
            }else{
                println("response data = \(data)")
//将当前获取到的member信息和userinfo.txt中的member信息比较，若完全一致，则直接跳转到快速登录界面，否则先保存当前的member信息，并跳转到快速登录界面
                
//                var user = self.dataToModel(data!, model: GBUser()) as! GBUser
//                println("user.name = \(user.name)")
//                println("user.id = \(user.id)")
//                println("user.password = \(user.password)")
//                println("user.type = \(user.type)")
//                println("user.role = \(user.role)")
//                println("user.username = \(user.username)")
                
                self.myUser.id = data?.objectForKey("id") as! String
                self.myUser.username = data?.objectForKey("username") as! String
                self.myUser.name = data?.objectForKey("name") as! String
                self.myUser.password = data?.objectForKey("password") as! String
                self.myUser.type = data?.objectForKey("type") as! String
                self.myUser.role = data?.objectForKey("role") as! String
                

                self.saveUserInfo()
                
                appManager.appGBUser = self.myUser
                
                self.viewInput.hidden = true
                self.userView.hidden = false
                self.lblCurrentUserName.text = "当前用户: \(self.myUser.username)"
            }
        })

    }

    
    func isCurrentDeviceRegister(){

        //将当前Mac－ID发get请求，
        //如果返回了memberid，表明该设备已经注册过，则继续将该memberid发get请求，
            //若返回了当前用户的所有信息，将其与之前保存的用户信息比较，如果都一样，则直接进入快速登录界面
            //若与之前的用户信息不一致，则进入登录界面
        //如果未返回当前memberid，表明该设备未注册，发post请求将该设备至web端注册，并且进入登录界面
        var str = server.boxServiceUrl + "/" + GBNetwork.getMacId()
        var urlStr = NSURL(string: str)!
        println("box service url ====== \(urlStr)")
        
        Alamofire.request(.GET, str).responseJSON(options: NSJSONReadingOptions.MutableContainers) { (request, response, data, error) -> Void in
            if error != nil{
                println("isCurrentDeviceRegister error = \(error)")
                return
            }else{
                    println("isCurrentDeviceRegister response = \(response?.statusCode.description) ")
                    if response?.statusCode.description == "400"{
                        self.postIdtoRegister()
                    }else{
                        var json = JSON(data!)
                        
                        
                        
                        var memberid = json["memberid"].stringValue
                        
                        if memberid.isEmpty == false && memberid != "0" {
                            self.getMemberInfo(memberid)
                        }
                    }
            }
        }
      }
    
    
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        self.txtName.resignFirstResponder()
        self.txtPwd.resignFirstResponder()
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == txtName{
            txtPwd.becomeFirstResponder()
        }else if textField == txtPwd{
            goLogin()
        }
        return true
    }
  
    
    override func viewWillDisappear(animated: Bool) {
         super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
//                println("size hide = \(keyboardSize)======needMove = \(self.bNeedMove)")
                
                if self.bNeedMove == true{
                    kbHeight = 0
                }else{
                    kbHeight = self.view.frame.height * 0.15
                    bNeedMove = true
                }
                self.animateTextField(false)
            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
//                println("size show = \(keyboardSize)======needMove = \(self.bNeedMove)")
                
                if keyboardSize.width >= 1024 && self.bNeedMove == true{
                    kbHeight = self.view.frame.height * 0.15
                    self.bNeedMove = false
                }else{
                    kbHeight = 0
                }
                self.animateTextField(true)
            }
        }
    }
    
    func animateTextField(up: Bool) {
        var movement = (up ? -kbHeight : kbHeight)
//        println("movement = \(movement)")
        UIView.animateWithDuration(0.3, animations: {
            self.middleView.frame = CGRectOffset(self.middleView.frame, 0, movement)
            self.viewInput.frame = CGRectOffset(self.viewInput.frame, 0, movement)
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
