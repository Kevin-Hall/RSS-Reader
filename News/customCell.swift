//
//  customCell.swift
//  News
//
//  Created by Kevin Hall on 3/15/18.
//  Copyright © 2018 Kevin Hall. All rights reserved.
//

import Foundation
import UIKit
import SwiftLinkPreview

class CustomCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var headline: UILabel!
    
    let session = URLSession.shared
    let wq = SwiftLinkPreview.defaultWorkQueue
    let rq = DispatchQueue.main
    let cache = InMemoryCache()
    var slp = SwiftLinkPreview()
    
    override func awakeFromNib() {
        movieImage.clipsToBounds = true
        movieImage.layer.cornerRadius = 3
        movieImage.contentMode = .scaleAspectFill
        
        headline.font = UIFont(name: "Avenir-Heavy", size: 9)!
        headline.numberOfLines = 5
        headline.contentMode = .topLeft
        headline.lineBreakMode = .byWordWrapping
        
        slp = SwiftLinkPreview(session: session,
                               workQueue: wq,
                               responseQueue: rq,
                               cache: cache)
    }
    
    func configureCell(link: String,headline: String) {
        
        if let cached = self.slp.cache.slp_getCachedResponse(url: link) {
            // Cached response
            self.movieImage.imageFromServerURL(urlString: cached[SwiftLinkResponseKey.image] as! String)
        } else {
            // Perform preview
            self.slp.preview(link,
                             onSuccess: { result in
                                
                                //print("\(result)")
                                self.movieImage.imageFromServerURL(urlString: result[SwiftLinkResponseKey.image] as! String)
                                print("\n")
                                
            },
                             onError: { error in print("\(error)")
            })
        }
        
        self.headline.text = headline
    }
}


extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error.debugDescription)
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }
}
