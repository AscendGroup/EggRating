//
//  EggRatingViewController.swift
//  Pods
//
//  Created by Somjintana K. on 21/12/2016.
//
//

import UIKit
import RateView

/// The protocol of the actions in EggRatingView.

public protocol EggRatingDelegate {
    func didRate(rating: Double)
    func didIgnoreToRate()
    func didRateOnAppStore()
    func didIgnoreToRateOnAppStore()
}

class EggRatingViewController: UIViewController {
    
    private let delegate = EggRating.delegate
    
    private var rating: Double = 0.0 {
        didSet {
            self.rateButton.setTitleColor(rating > 0.0 ? defaultTintColor : UIColor.grayColor(), forState: .Normal)
            self.rateButton.enabled = rating > 0.0
        }
    }
    
    private let defaultTintColor = UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha:1.0)

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var starContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        rating = 0.0
    }
    
    func setupView() {
        containerView.layer.cornerRadius = 10
        
        setupStarRateView()
        
        titleLabel.text = EggRating.titleLabelText
        descriptionLabel.text = EggRating.descriptionLabelText
        
        cancelButton.setTitle(EggRating.dismissButtonTitleText, forState: .Normal)
        cancelButton.setTitleColor(defaultTintColor, forState: .Normal)
        
        rateButton.setTitle(EggRating.rateButtonTitleText, forState: .Normal)
        rateButton.setTitleColor(defaultTintColor, forState: .Normal)
    }
    
    func setupStarRateView() {
        
        let starContainerViewFrame = starContainerView.frame
        
        guard let starRateView = RateView(rating: 0) else {
            return
        }
        
        starRateView.canRate = true
        starRateView.delegate = self
        starRateView.starFillColor = EggRating.starFillColor
        starRateView.starBorderColor = EggRating.starBorderColor
        starRateView.starNormalColor = EggRating.starNormalColor
        starRateView.step = 0.5
        starRateView.starSize = starContainerViewFrame.width/5.5
        starRateView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        let frame = CGRect(x: (starContainerViewFrame.width - starRateView.frame.width)/2, y: starContainerViewFrame.height/2 - starRateView.frame.height/2, width: starContainerViewFrame.width, height: starContainerViewFrame.height)
        
        starRateView.frame = frame
        starContainerView.addSubview(starRateView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendUserToAppStore() {
        
        guard let url = NSURL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(EggRating.itunesId)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software") else {
           return
        }
        
        UIApplication.sharedApplication().openURL(url)
        
        delegate?.didRateOnAppStore()
    }
    
    // MARK: - Action

    @IBAction func cancelButtonTouched(_ sender: UIButton) {
        self.view.backgroundColor = UIColor.clearColor()
        self.containerView.hidden = true
        self.delegate?.didIgnoreToRate()
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func rateButtonTouched(_ sender: UIButton) {
        self.view.backgroundColor = UIColor.clearColor()
        self.containerView.hidden = true
        
        let minRatingToAppStore = EggRating.minRatingToAppStore > 5 ? 5 : EggRating.minRatingToAppStore
        
        if rating >= minRatingToAppStore {
            showRateInAppStoreAlertController()
            
            // only save last rated version if user rates more than mininum score
            NSUserDefaults.standardUserDefaults().setObject(EggRating.appVersion, forKey: EggRatingUserDefaultsKey.lastVersionRatedKey.rawValue)
            
        } else {
            showDisadvantageAlertController()
        }
        
        delegate?.didRate(rating)
    }
    
    // MARK: Alert
    
    func showDisadvantageAlertController() {
        
        let disadvantageAlertController = UIAlertController(title: EggRating.thankyouTitleLabelText, message: EggRating.thankyouDescriptionLabelText, preferredStyle: .Alert)
        
        disadvantageAlertController.addAction(UIAlertAction(title: EggRating.thankyouDismissButtonTitleText, style: .Default, handler: { (_) in
            self.dismissViewControllerAnimated(false, completion: nil)
        }))
        
        self.presentViewController(disadvantageAlertController, animated: true, completion: nil)
    }
    
    func showRateInAppStoreAlertController() {
        
        let rateInAppStoreAlertController = UIAlertController(title: EggRating.appStoreTitleLabelText, message: EggRating.appStoreDescriptionLabelText, preferredStyle: .Alert)
        
        rateInAppStoreAlertController.addAction(UIAlertAction(title: EggRating.appStoreDismissButtonTitleText, style: .Default, handler: { (_) in
            self.dismissViewControllerAnimated(false, completion: nil)
            self.delegate?.didIgnoreToRateOnAppStore()
        }))
        
        rateInAppStoreAlertController.addAction(UIAlertAction(title: EggRating.appStoreRateButtonTitleText, style: .Default, handler: { (_) in
            self.sendUserToAppStore()
            self.dismissViewControllerAnimated(false, completion: nil)
        }))
        
        self.presentViewController(rateInAppStoreAlertController, animated: true, completion: nil)
    }
    
}

extension EggRatingViewController: RateViewDelegate {
    
    func rateView(_ rateView: RateView!, didUpdateRating rating: Float) {
        self.rating = Double(rating)
    }
}
