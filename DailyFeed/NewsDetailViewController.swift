//
//  NewsDetailViewController.swift
//  DailyFeed
//
//  Created by Sumit Paul on 27/12/16.
//

import UIKit
import SafariServices
import RealmSwift
import Alamofire
import ObjectMapper
//import McPicker

class NewsDetailViewController: UIViewController, SFSafariViewControllerDelegate, UIViewControllerTransitioningDelegate {
    
    // MARK: - Variable declaration
    
    var receivedNewsItem: DailyFeedRealmModel?
    
    var receivedNewsSourceLogo: String?
    
    var articleStringURL: String?
    
    var receivedItemNumber: Int?
    
    var isLanguageRightToLeftDetailView: Bool = false
    
    // MARK: - IBOutlets
    @IBOutlet weak var newsImageView: TSImageView! {
        didSet {
            newsImageView.layer.masksToBounds = true
            guard let imageURL = receivedNewsItem?.urlToImage else { return }
            newsImageView.downloadedFromLink(imageURL)
        }
    }
    
    @IBOutlet weak var newsTitleLabel: UILabel! {
        didSet {
            newsTitleLabel.text = receivedNewsItem?.title
            newsTitleLabel.alpha = 0.0
            if isLanguageRightToLeftDetailView {
                newsTitleLabel.textAlignment = .right
            } else {
                newsTitleLabel.textAlignment = .left
            }
        }
    }
    
    typealias JSONDict = [String : Any]
    var summary : Array<SummaryModel> = []
    var articles : Array<Article> = []
    let summarySize = 5
    
    // SMMRY API
    func smmryRequest (url : String) {
        
        let request = "http://api.smmry.com/&SM_API_KEY=FBD2CB310A&SM_WITH_BREAK&SM_LENGTH=\(summarySize)&SM_URL=\(url)"
        
        Alamofire.request(request, encoding: URLEncoding(), headers: nil).responseJSON { response in
            
            if let responseJSON = response.result.value as? JSONDict {
                // if the articleData does not work, move onto the next
                guard let article = Mapper<Article>().map(JSON: responseJSON) else { return }
                self.articles.append(article)
                self.contentTextView.text = String(self.articles[0].summary.dropFirst())
                    .replacingOccurrences(of: "[BREAK]", with: "\n\n")
                .replacingOccurrences(of: "\n\n ", with: "\n\n")
            }
        }
            
    }

// Text before full article
@IBOutlet weak var contentTextView: UITextView! {
    didSet {
        smmryRequest(url: (receivedNewsItem?.url)!)
        // contentTextView.text = articles[0].title
        contentTextView.textColor = .gray
        contentTextView.alpha = 0.0
        contentTextView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        contentTextView.sizeToFit()
        if isLanguageRightToLeftDetailView {
            contentTextView.textAlignment = .right
        } else {
            contentTextView.textAlignment = .left
        }
    }
}

@IBOutlet weak var newsAuthorLabel: UILabel! {
    didSet {
        
        // fix
        guard let publishedDate = receivedNewsItem?.publishedAt.dateFromTimestamp?.relativelyFormatted(short: false) else {
            return // newsAuthorLabel.text("Full article...", for: .normal)
        }
        
        newsAuthorLabel.text = "\(receivedNewsItem?.author ?? "X minutes ago.") • \(publishedDate)"
        newsAuthorLabel.alpha = 0.0
        if isLanguageRightToLeftDetailView {
            newsAuthorLabel.textAlignment = .right
        } else {
            newsAuthorLabel.textAlignment = .left
        }
    }
}

@IBOutlet weak var backButton: UIButton! {
    didSet {
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowRadius = 2.0
        backButton.layer.shadowOpacity = 1.0
        backButton.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
}

@IBOutlet weak var shareButton: UIButton! {
    didSet {
        shareButton.layer.shadowColor = UIColor.black.cgColor
        shareButton.layer.shadowRadius = 2.0
        shareButton.layer.shadowOpacity = 1.0
        shareButton.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
}

@IBOutlet weak var swipeLeftButton: UIButton! {
    didSet {
        
        swipeLeftButton.layer.cornerRadius = 10.0
        swipeLeftButton.setTitle("Summarized in \(summarySize) sentences • Full article...", for: .normal)
        switch Reach().connectionStatus() {
        case .unknown, .offline:
            swipeLeftButton.isEnabled = false
            swipeLeftButton.backgroundColor = .lightGray
            
        case .online(_):
            swipeLeftButton.isEnabled = true
        }
    }
}

@IBOutlet weak var newsSourceImageView: TSImageView! {
    didSet {
        guard let newsSourceLogo = receivedNewsSourceLogo else { return }
        //newsSourceImageView.downloadedFromLink(newsSourceLogo)
        
    }
}

//    @IBOutlet weak var summarySizeLabel: UILabel!
//    
//    @IBAction func sentenceSummary(_ sender: Any) {
//        let data: [[String]] = [["Kevin", "Lauren", "Kibby", "Stella"]]
//        McPicker.showAsPopover(data: data, fromViewController: self, barButtonItem: sender as? UIBarButtonItem) { (selections: [Int : String]) -> Void in
//            if let name = selections[0] {
//                self.summarySizeLabel.text = name
//            }
//        }
//    }
    
    
    // black number box
@IBOutlet weak var newsItemNumberLabel: UILabel! {
    didSet {
        guard let newsItemNumber = receivedItemNumber else { return }
        newsItemNumberLabel.text = String(newsItemNumber)
        newsItemNumberLabel.alpha = 1.0
        newsItemNumberLabel.clipsToBounds = true
        newsItemNumberLabel.layer.cornerRadius = 5.0
    }
}


// MARK: - View Controller Lifecycle Methods
override func viewDidLoad() {
    super.viewDidLoad()
    //Hide Nav bar
    navigationController?.setNavigationBarHidden(true, animated: true)
    // Setting the newsImageView gradient
    newsImageView.addGradient([UIColor(white: 0, alpha: 0.6).cgColor, UIColor.clear.cgColor,
                               UIColor(white: 0, alpha: 0.6).cgColor],
                              locations: [0.0, 0.05, 0.85])
    
    //Setting articleStringURL for state restoration
    articleStringURL = receivedNewsItem?.url
    
    if #available(iOS 11.0, *) {
        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.isEnabled = true
        newsImageView.addInteraction(dragInteraction)
    }
}

override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    newsTitleLabel.center.y += 20
    newsAuthorLabel.center.y += 20
    contentTextView.center.y += 20
    
    UIView.animate(withDuration: 0.07, delay: 0.0, options: .curveEaseIn, animations: {
        self.newsTitleLabel.alpha = 1.0
        self.newsTitleLabel.center.y -= 20
        self.newsAuthorLabel.alpha = 1.0
        self.newsAuthorLabel.center.y -= 20
        self.newsItemNumberLabel.alpha = 1.0
    })
    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
        self.contentTextView.center.y -= 20
        self.contentTextView.alpha = 1.0
    })
}

override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    newsImageView.updateNewsImageView(25.0)
}

// MARK: - Status Bar Color
override var prefersStatusBarHidden: Bool {
    return true
}

// MARK: - Back Button Dismiss action
@IBAction func dismissButtonTapped() {
    presentingViewController?.dismiss(animated: true, completion: nil)
}

// MARK: - Back dismiss swipe
@IBAction func swipeToDismiss(_ sender: UISwipeGestureRecognizer) {
    presentingViewController?.dismiss(animated: true, completion: nil)
}

// MARK: - share article
@IBAction func shareArticle(_ sender: UIButton) {
    
    fadeUIElements(with: 0.0)
    
    let delay = DispatchTime.now() + 0.11
    DispatchQueue.main.asyncAfter(deadline: delay) {
        
        guard let shareURL = self.articleStringURL,
            let articleImage = self.captureScreenShot(),
            let articleToBookmarkData = self.receivedNewsItem else {return}
        
        let bookmarkactivity = BookmarkActivity()
        
        bookmarkactivity.bookMarkSuccessful = {
            self.showErrorWithDelay("Bookmarked Successfully!")
        }
        
        let activityVC = UIActivityViewController(activityItems: [shareURL, articleImage, articleToBookmarkData],
                                                  applicationActivities: [bookmarkactivity])
        
        activityVC.excludedActivityTypes = [.saveToCameraRoll,
                                            .copyToPasteboard,
                                            .airDrop,
                                            .addToReadingList,
                                            .assignToContact,
                                            .postToTencentWeibo,
                                            .postToVimeo,
                                            .print,
                                            .postToWeibo]
        
        activityVC.completionWithItemsHandler = {(activityType, completed: Bool, _, _) in
            self.fadeUIElements(with: 1.0)
        }
        
        // Popover for iPad only
        
        let popOver = activityVC.popoverPresentationController
        popOver?.sourceView = self.shareButton
        popOver?.sourceRect = self.shareButton.bounds
        self.present(activityVC, animated: true, completion: nil)
    }
}

// Helper to toggle UI elements before and after screenshot capture
func fadeUIElements(with alpha: CGFloat) {
    UIView.animate(withDuration: 0.1) {
        self.backButton.alpha = alpha
        self.shareButton.alpha = alpha
        self.swipeLeftButton.alpha = alpha
    }
}

// Helper method to generate article screenshots
func captureScreenShot() -> UIImage? {
    //Create the UIImage
    let bounds = UIScreen.main.bounds
    UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
    self.view.drawHierarchy(in: bounds, afterScreenUpdates: false)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
    
}

@IBAction func openArticleInSafari(_ sender: UIButton) {
    openInSafari()
}

// Helper method to open articles in Safari
func openInSafari() {
    guard let articleString = articleStringURL, let url = URL(string: articleString) else { return }
    let svc = MySafariViewController(url: url)
    svc.delegate = self
    self.present(svc, animated: true, completion: nil)
}
}

@available(iOS 11.0, *)
extension NewsDetailViewController: UIDragInteractionDelegate {
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = newsImageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        return [item]
    }
    
}
