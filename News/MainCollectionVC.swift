//
//  MainCollectionVC.swift
//  News
//
//  Created by Kevin Hall on 3/15/18.
//  Copyright © 2018 Kevin Hall. All rights reserved.
//

import Foundation
import UIKit
import MWFeedParser
import SVProgressHUD
import AFNetworking
import KINWebBrowser
import SafariServices
import SwiftLinkPreview

class mainCollection: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MWFeedParserDelegate, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //"https://www.nasa.gov/rss/dyn/breaking_news.rss"
    //"http://www.texanerin.com/feed"
    //"https://www.theverge.com/rss/index.xml"
    
    // hardcoded rss url to be parsed
    var url = "https://www.nasa.gov/rss/dyn/breaking_news.rss"
    
    // stores the items fetched from the rss
    var items = [MWFeedItem]()
    
    // colors for table & navbar
    var backColor = UIColor.black
    var wordColor = UIColor.white
    
    // the images in
    var images : [String: UIImage] = [:]
    
    let session = URLSession.shared
    let wq = SwiftLinkPreview.defaultWorkQueue
    let rq = DispatchQueue.main
    let cache = InMemoryCache()
    
    var slp = SwiftLinkPreview()
    
    private let leftAndRightPaddings: CGFloat =  1.0
    private let numberOfItemsPerRow: CGFloat =  2.0
    private let heightAdjustment: CGFloat =  100.0

    
    //MARK:: - View overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        
        slp = SwiftLinkPreview(session: session,
                               workQueue: wq,
                               responseQueue: rq,
                               cache: cache)
        
        DispatchQueue.main.async(execute: { () -> Void in
            //request the feed
            self.request()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:: - CollectionView Methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as? CustomCollectionViewCell {
            
            let item = self.items[indexPath.row] as MWFeedItem
            let url = URL(string: item.link)
            let slpItem = self.slp.cache.slp_getCachedResponse(url: (url?.absoluteString)!)
            if slpItem != nil {
                let imgurl = slpItem![SwiftLinkResponseKey.image]

            }
            cell.configureCell(link: (url?.absoluteString)!, headline: item.title)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.items[indexPath.row] as MWFeedItem
                
        let url = URL(string: item.link)
        let svc = SFSafariViewController(url: url!, entersReaderIfAvailable: true)
        svc.dismissButtonStyle = .close
        svc.hidesBottomBarWhenPushed = true
        svc.configuration.barCollapsingEnabled = true
        svc.preferredBarTintColor = UIColor.black
        svc.preferredControlTintColor = wordColor
        svc.delegate = self
        self.present(svc, animated: false, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (collectionView.frame.width - leftAndRightPaddings) / numberOfItemsPerRow
        return CGSize(width: width,height: width + heightAdjustment)
    }
    
    
    //MARK:: - feed parser
    
    func request() {
        print(url)
        let URL = Foundation.URL(string: url)
        let feedParser = MWFeedParser(feedURL: URL)
        feedParser?.connectionType = ConnectionTypeSynchronously
        feedParser?.delegate = self
        feedParser?.parse()
        
    }
    
    func feedParserDidStart(_ parser: MWFeedParser!) {
        self.items = [MWFeedItem]()
        self.collectionView.reloadData()
    }
    
    func feedParserDidFinish(_ parser: MWFeedParser!) {
        SVProgressHUD.dismiss()
        self.collectionView.reloadData()
    }

    func feedParser(_ parser: MWFeedParser!, didParseFeedInfo info: MWFeedInfo!) {
        print(info.url)
        self.title = info.title
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func feedParser(_ parser: MWFeedParser!, didParseFeedItem item: MWFeedItem!) {
        self.items.append(item)
    }
    
    // Safari viewer
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: false, completion: nil)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = backColor
    }
    
}
