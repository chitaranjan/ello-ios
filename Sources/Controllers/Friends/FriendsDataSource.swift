//
//  FriendsDataSource.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import WebKit

class FriendsDataSource: NSObject, UICollectionViewDataSource {

    typealias StreamContentReady = () -> ()

    enum CellIdentifier: String {
        case CommentHeader = "StreamCommentHeaderCell"
        case Header = "StreamHeaderCell"
        case Footer = "StreamFooterCell"
        case Image = "StreamImageCell"
        case Text = "StreamTextCell"
        case Comment = "StreamCommentCell"
        case Unknown = "StreamUnknownCell"
    }

    var indexFile:String?
    var contentReadyClosure:StreamContentReady?
    var streamCellItems:[StreamCellItem] = []
    let testWebView:UIWebView
    let sizeCalculator:StreamTextCellSizeCalculator

    init(testWebView: UIWebView) {
        self.testWebView = testWebView
        self.sizeCalculator = StreamTextCellSizeCalculator(webView: testWebView)
        super.init()
    }
    
    func postForIndexPath(indexPath:NSIndexPath) -> Post? {
        if indexPath.item >= streamCellItems.count {
            return nil
        }
        return streamCellItems[indexPath.item].streamable as? Post
    }
    
    func cellItemsForPost(post:Post) -> [StreamCellItem]? {
        return streamCellItems.filter({ (item) -> Bool in
            if let cellPost = item.streamable as? Post {
                return post.postId == cellPost.postId
            }
            else {
                return false
            }
        })
    }

    func addStreamables(streamables:[Streamable], completion:StreamContentReady) {
        self.contentReadyClosure = completion
        self.streamCellItems = self.createStreamCellItems(streamables)
    }

    func updateHeightForIndexPath(indexPath:NSIndexPath?, height:CGFloat) {
        if let indexPath = indexPath {
            streamCellItems[indexPath.item].cellHeight = height
        }
    }

    func heightForIndexPath(indexPath:NSIndexPath) -> CGFloat {
        return streamCellItems[indexPath.item].cellHeight ?? 0.0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return streamCellItems.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item < countElements(streamCellItems) {
            let streamCellItem = streamCellItems[indexPath.item]

            switch streamCellItem.type {
            case .Header, .CommentHeader:
                return headerCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            case .BodyElement, .CommentBodyElement:
                return bodyCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            case .Footer:
                return footerCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
            default:
                return UICollectionViewCell()
            }
        }
       
        return UICollectionViewCell()
    }
    
    private func headerCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {

        var headerCell:StreamHeaderCell = StreamHeaderCell()
        switch streamCellItem.streamable.kind {
        case .Comment:
            headerCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.CommentHeader.rawValue, forIndexPath: indexPath) as StreamCommentHeaderCell
        default:
            headerCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Header.rawValue, forIndexPath: indexPath) as StreamHeaderCell
        }
        
        
        if let avatarURL = streamCellItem.streamable.author?.avatarURL? {
            headerCell.setAvatarURL(avatarURL)
        }

        headerCell.timestampLabel.text = NSDate().distanceOfTimeInWords(streamCellItem.streamable.createdAt)

        headerCell.usernameLabel.text = "@" + (streamCellItem.streamable.author?.username ?? "meow")
        return headerCell
    }
    
    private func bodyCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {

        switch streamCellItem.data!.kind {
        case Block.Kind.Image:
            return imageCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case Block.Kind.Text:
            return textCell(streamCellItem, collectionView: collectionView, indexPath: indexPath)
        case Block.Kind.Unknown:
            return collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Unknown.rawValue, forIndexPath: indexPath) as UICollectionViewCell
        }
    }

    private func imageCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamImageCell {
        let imageCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Image.rawValue, forIndexPath: indexPath) as StreamImageCell
        if let photoData = streamCellItem.data as ImageBlock? {
            if let photoURL = photoData.url? {
                imageCell.setImageURL(photoURL)
            }
        }
        return imageCell
    }

    private func textCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamTextCell {
        let textCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Text.rawValue, forIndexPath: indexPath) as StreamTextCell
        textCell.contentView.alpha = 0.0
        if let textData = streamCellItem.data as TextBlock? {
            textCell.webView.loadHTMLString(StreamTextCellHTML.postHTML(textData.content), baseURL: NSURL(string: "/"))
        }
        return textCell
    }
    
    private func footerCell(streamCellItem:StreamCellItem, collectionView: UICollectionView, indexPath: NSIndexPath) -> StreamFooterCell {
        if let post = streamCellItem.streamable as? Post {
            let footerCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.Footer.rawValue, forIndexPath: indexPath) as StreamFooterCell
            footerCell.views = post.viewsCount?.localizedStringFromNumber()
            footerCell.comments = post.commentsCount?.localizedStringFromNumber()
            footerCell.reposts = post.repostsCount?.localizedStringFromNumber()
            
            return footerCell
        }
        
        return StreamFooterCell()
    }

    private func createStreamCellItems(streamables:[Streamable]) -> [StreamCellItem] {
        let parser = StreamCellItemParser()
        var cellItems = parser.streamCellItems(streamables)

        let textElements = cellItems.filter {
            return $0.data as? TextBlock != nil
        }

        self.sizeCalculator.processCells(textElements, {
            self.streamCellItems += cellItems
            if let ready = self.contentReadyClosure {
                ready()
            }
        })

        return self.streamCellItems
    }
}