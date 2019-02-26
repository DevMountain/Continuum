//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by DevMountain on 2/12/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
  
  //MARK: - IBOutlets
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
  
  //MARK: - View Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let post = post else { return }
    PostController.shared.fetchComments(for: post) { (_) in
      DispatchQueue.main.async {
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
    //Check CloudKit for a subscription to this post and adjust the text of the button to reflect this
    PostController.shared.checkForSubscription(to: post) { (found) in
      DispatchQueue.main.async {
        let followPostButtonText = found ? "Unfollow Post" : "Follow Post"
        self.followPostButton.setTitle(followPostButtonText, for: .normal)
        //Asks the stackview to resize the button if it is necesssary to accomodate the new text
        self.buttonStackView.layoutIfNeeded()
      }
    }
  }
  
  func presentCommentAlertController() {
    let alertController = UIAlertController(title: "Add a Comment", message: "This app is anonymous. Have at it", preferredStyle: .alert)
    alertController.addTextField { (textField) in
      textField.placeholder = "Your witty comment here"
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let commentAction = UIAlertAction(title: "Comment", style: .default) { (_) in
      guard let commentText = alertController.textFields?.first?.text,
        !commentText.isEmpty,
        let post = self.post else { return }
      PostController.shared.addComment(text: commentText, post: post, completion: { (comment) in
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
    PostController.shared.toggleSubscriptionTo(commentsForPost: post, completion: { (success, error) in
      if let error = error{
        print("\(error.localizedDescription) \(error) in function: \(#function)")
        return
      }
      self.updateFollowPostButtonText()
    })
  }
}

// MARK: - UITableViewDataSource
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
