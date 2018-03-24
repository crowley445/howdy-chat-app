//
//  GroupInfoViewController.swift
//  howdy-chat-app
//
//  Created by Brian  Crowley on 24/03/2018.
//  Copyright © 2018 Brian Crowley. All rights reserved.
//

import UIKit

class GroupInfoViewController: UIViewController {

    @IBOutlet weak var infoView : UIView!
    @IBOutlet weak var visualEffectView : UIVisualEffectView!
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var participantsLabel: UILabel!
    
    var effect : UIVisualEffect!
    var height : NSLayoutConstraint!
    var members : [User]!
    var infoViewOriginalHeight : CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        infoViewOriginalHeight = infoView.frame.size.height
        height = NSLayoutConstraint(item: infoView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1)
        view.addConstraints([height])
        
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        infoView.isHidden = true
        participantsLabel.alpha = 0
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animateOut)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    func animateIn() {

        infoView.isHidden = false
        infoView.alpha = 0
        collectionView.alpha = 0
        height.constant = infoViewOriginalHeight
        self.collectionView.reloadData()
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.visualEffectView.effect = self.effect
                self.infoView.alpha = 1
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25, animations: {
                self.collectionView.alpha = 1
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25, animations: {
                self.participantsLabel.alpha = 1
            })
            
        }, completion: nil)
    }
    
    
    @objc func animateOut() {

        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: {
                self.collectionView.alpha = 0
                self.participantsLabel.alpha = 0
            })
            
            self.height.constant = 1

            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.75, animations: {
                self.view.layoutIfNeeded()
                self.visualEffectView.effect = nil
                self.infoView.alpha = 0
            })
            
        }) { _ in
            self.dismiss( animated: false, completion: nil )
        }
    }
}

extension GroupInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return members.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PARTICIPANTS_CELL_ID, for: indexPath) as? ContactCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(withUser: members[indexPath.row])
        return cell
    }
}



