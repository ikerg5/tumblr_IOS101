//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import NukeExtensions

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    //table view numberOfRows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return posts.count
    }
    //tablView cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        
        
        let post = posts[indexPath.row]

        // Set the summary text
        cell.postLabel.text = post.summary

        // Load the first photo (if any)
        if let photo = post.photos.first {
            let url = photo.originalSize.url
            NukeExtensions.loadImage(with: url, into: cell.imagePostView)
        }

        return cell
        
    }

    
    @IBOutlet weak var tableView: UITableView!
    
    
    private var posts: [Post] = [] // declare array variable for posts

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        fetchPosts()
    }
    

    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                
                let blog = try JSONDecoder().decode(Blog.self, from: data)
    

                DispatchQueue.main.async { [weak self] in

                    let posts = blog.response.posts


                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                    
                    self?.posts = posts
                    self?.tableView.reloadData() // asign self to table view
                    
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}
