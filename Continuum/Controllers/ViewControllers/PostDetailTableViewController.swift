//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Maxwell Poffenbarger on 2/4/20.
//  Copyright © 2020 Max Poff. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var followPostButton: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    //MARK: - Properties
    var post: Post?{
        didSet{
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let post = post else { return }
        
        PostController.sharedInstance.fetchComments(for: post) { (_) in
            DispatchQueue.main.async {
                PostController.sharedInstance.incrementCommentCount(for: post) { (success) in
                    print("set comment count")
                }
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Methods
    @objc func updateViews() {
        
        guard let post = post else { return }
        
        photoImageView.image = post.photo
        tableView.reloadData()
        updateFollowPostButtonText()
    }
    
    func updateFollowPostButtonText(){
        
        guard let post = post else { return }
        
        PostController.sharedInstance.checkForSubscription(to: post) { (found) in
            
            DispatchQueue.main.async {
                let followPostButtonText = found ? "Unfollow Post" : "Follow Post"
                self.followPostButton.setTitle(followPostButtonText, for: .normal)
                self.buttonStackView.layoutIfNeeded()
            }
        }
    }
    
    func presentCommentAlertController() {
        
        let alertController = UIAlertController(title: "Add a Comment", message: "Be careful. You can't delete your comments...", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Type comment here..."
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let commentAction = UIAlertAction(title: " Add Comment", style: .default) { (_) in
            
            guard let commentText = alertController.textFields?.first?.text, !commentText.isEmpty,
                let post = self.post else { return }
            
            PostController.sharedInstance.addComment(text: commentText, post: post, completion: { (comment) in
            })
            
            self.tableView.reloadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(commentAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Actions
    @IBAction func commentButtonTapped(_ sender: Any) {
        presentCommentAlertController()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        
        guard let comment = post?.caption else { return }
        
        let shareSheet = UIActivityViewController(activityItems: [comment], applicationActivities: nil)
        
        present(shareSheet, animated: true, completion: nil)
    }
    
    @IBAction func followButtonTapped(_ sender: Any) {
        
        guard let post = post else { return }
        
        PostController.sharedInstance.toggleSubscriptionTo(commentsForPost: post, completion: { (success, error) in
            
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                return
            }
            self.updateFollowPostButtonText()
        })
    }
}//End of class

// MARK: - Extension - Table View Data Source
extension PostDetailTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row]
        
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.timestamp.stringWith(dateStyle: .medium, timeStyle: .short)
        
        return cell
    }
}
