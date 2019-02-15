//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by DevMountain on 2/12/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  // MARK: - Table view data source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return PostController.shared.posts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostTableViewCell
    let post = PostController.shared.posts[indexPath.row]
    cell.post = post
    return cell
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toPostDetailVC" {
      let destinationVC = segue.destination as! PostDetailTableViewController
      guard let indexPath = tableView.indexPathForSelectedRow else { return }
      let post = PostController.shared.posts[indexPath.row]
      destinationVC.post = post
    }
  }
}
