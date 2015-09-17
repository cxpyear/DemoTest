//
//  ViewController.swift
//  spdbapp
//
//  Created by tommy on 15/5/7.
//  Copyright (c) 2015年 shgbit. All rights reserved.
//

import UIKit
import Alamofire

class AgendaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {

    @IBOutlet weak var tvAgenda: UITableView!
    @IBOutlet weak var lblMeetingName: UILabel!
   
   
    @IBOutlet weak var loading: UIActivityIndicatorView!

    var agendaNameInfo = String()
    var agendaIndex = 0
    
    var gbAgendInfo = [GBAgenda]()
    
    var bottomBarView =  BottomBarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        gbAgendInfo = appManager.current.agendas
        
        if !gbAgendInfo.isEmpty{
            self.loading.hidden = true
        }

        tvAgenda.rowHeight = 70
        var cell = UINib(nibName: "AgendaTableViewCell", bundle: nil)
        self.tvAgenda.registerNib(cell, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(TopbarView.getTopBarView(self))

        bottomBarView = BottomBarView().getBottomInstance(self)
        self.view.addSubview(bottomBarView)
        bottomBarView.returnBtnBack(self, action: "back")

        Poller().start(self, method: "autoHideBottomBarView:", timerInter: 5.0)
        
        self.lblMeetingName.text = appManager.current.name
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "hideOrShowBottomBar:")
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        
        
        self.tvAgenda.reloadData()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        //当前议程非空或者当前会议非空，停止loading
        if !gbAgendInfo.isEmpty{
            self.loading.stopAnimating()
        }
        if appManager.current.isEqual(nil) == true{
            self.loading.stopAnimating()
        }
        
        if bNeedRefresh == true{
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "getCurrentChange:", name: CurrentDidChangeNotification, object: nil)
        }else{
            appManager.current = builder.loadOffLineMeeting()
            self.lblMeetingName.text = appManager.current.id.isEmpty ? "暂无会议" : appManager.current.name
            self.gbAgendInfo = appManager.current.agendas
            self.tvAgenda.reloadData()
            self.loading.stopAnimating()
        }
    }
    
    func getCurrentChange(notification: NSNotification){
        self.lblMeetingName.text = appManager.current.id.isEmpty ? "暂无会议" : appManager.current.name
        self.gbAgendInfo = appManager.current.agendas
        self.tvAgenda.reloadData()
        self.loading.stopAnimating()
        //只有当前会议不为空时才下载
        if appManager.current.id.isEmpty == false{
            DownLoadManager.isStart(true)
        }
        
        if appManager.current.id.isEmpty{
            UIAlertView(title: "提示", message: "当前无会议,请回到登录界面开启离线会议" , delegate: self, cancelButtonTitle: "确定").show()
        }
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var registerVC = storyBoard.instantiateViewControllerWithIdentifier("view") as! RegisViewController
        self.presentViewController(registerVC, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        if bNeedRefresh == true{
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    
    func hideOrShowBottomBar(gesture: UITapGestureRecognizer){
        self.bottomBarView.hidden = !self.bottomBarView.hidden
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gbAgendInfo.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: AgendaTableViewCell = (tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! AgendaTableViewCell)

        var currentAgenda = gbAgendInfo[indexPath.row] as GBAgenda
        var startArray: [String] = currentAgenda.starttime.componentsSeparatedByString(" ")
        var endArray: [String] = currentAgenda.endtime.componentsSeparatedByString(" ")
        
        cell.lblDate.text = startArray[0]
        if startArray.count == 2 && endArray.count == 2{
            cell.lblTime.text = "\(startArray[1]) - \(endArray[1])"
        }
        cell.lblReporter.text = currentAgenda.reporter
        cell.lbAgenda.text = currentAgenda.name

        
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        
        var name = gbAgendInfo[indexPath.row].name
        self.agendaNameInfo = name
        self.agendaIndex = indexPath.row
        
        self.performSegueWithIdentifier("toSource", sender: self)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Create a new variable to store the instance of DocViewController
        if segue.identifier ==  "toSource" {
            var obj = segue.destinationViewController as! SourceFileViewcontroller
            obj.agendaNameInfo = self.agendaNameInfo
            obj.agendaIndex = self.agendaIndex
        }
    }

    
    func autoHideBottomBarView(timer: NSTimer){
        if self.bottomBarView.hidden == false{
            self.bottomBarView.hidden = true
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func back(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
