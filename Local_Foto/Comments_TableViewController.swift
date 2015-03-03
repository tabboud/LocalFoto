//
//  Comments_TableViewController.swift
//  Local_Foto
//
//  Created by Tony on 3/3/15.
//  Copyright (c) 2015 Abbouds Corner. All rights reserved.
//

import UIKit

class Comments_TableViewController: UITableViewController {
    var media: InstagramMedia!
    let sharedIGEngine = InstagramEngine.sharedEngine()
    var comments = [InstagramComment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
                self.tableView.estimatedRowHeight = 64.0
                self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Need to enable SCOPE first
        self.fetchComments()
    }

    
    func fetchComments(){
        self.sharedIGEngine.getCommentsOnMedia(self.media.Id, withSuccess: {(comments)->Void in
                self.comments = comments as [InstagramComment]
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
            }, failure: {(error)->Void in
                println("error getting comments on media")
        })
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as Comments_TableViewCell
        
        let commentInfo = self.comments[indexPath.row]
        
        cell.setComment(commentInfo.text)
        cell.setProfilePhoto(commentInfo.user.profilePictureURL)
        cell.setCommentTime("time")
        cell.setUserName(commentInfo.user.username)

        cell.selectionStyle = .None
//        cell.delegate = self

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
