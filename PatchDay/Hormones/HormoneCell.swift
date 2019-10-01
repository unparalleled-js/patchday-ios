//
//  HormoneCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class HormoneCell: UITableViewCell {
    
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeButton: MFBadgeButton!
    
    private let sdk: PatchDataDelegate!

    public var index = -1
    
    public func load(sdk: PatchDataDelegate) {
        self.sdk = sdk
        backgroundColor = app.theme.bgColor
        let q = sdk.defaults.quantity.value.rawValue
        setThemeColors(at: index)
        switch (index) {
        case 0..<q :
            let interval = sdk.defaults.expirationInterval
            let method = sdk.defaults.deliveryMethod.value
            let theme = sdk.defaults.theme.value
            if let mone = sdk.hormones.at(index) {
    
                let isExpired = mone.isExpired
                let img = PDImages.getImage(for: mone, theme: theme, deliveryMethod: method)
                let title = getTitle(at: index, interval)
                configureDate(when: isExpired)
                configureBadge(at: index, isExpired: isExpired, deliveryMethod: deliv)
                self.setDateLabel(title)
                animateEstrogenButtonChanges(at: index, theme: theme, newImage: img, newTitle: title)
                selectionStyle = .default
                stateImage.isHidden = false
            }
        case q...3 :
            animateEstrogenButtonChanges(at: index, theme: theme)
            fallthrough
        default : reset()
        }
    }
    
    /// Determines the start of the week title for a schedule button.
    private func getTitle(at index: Int, _ interval: ExpirationIntervalUD) -> String {
        var title: String = ""
        typealias Strings = PDStrings.ColonedStrings
        if let mone = sdk.hormones.at(index), let exp = mone.expiration {
            switch sdk.deliveryMethod {
            case .Patches:
                let intro = mone.isExpired ? Strings.expired : Strings.expires
                title += intro + PDDateHelper.dayOfWeekString(date: exp)
            case .Injections:
                let day = PDDateHelper.dayOfWeekString(date: mone.date)
                title += Strings.lastInjected + day
            }
        }
        return title
    }
    
    /// Animates the making of an estrogen button if there were estrogen data changes.
    private func animateEstrogenButtonChanges(at index: Index,
                                              theme: PDTheme,
                                              newImage: UIImage?=nil,
                                              newTitle: String?=nil) {
        let mone = sdk.hormones.at(index)
        sdk.state.isCerebral = PDImages.representsSiteless(<#T##img: UIImage##UIImage#>)
        let isAnimating = shouldAnimate(estrogenOptional, at: index)
        if isAnimating {
            UIView.transition(with: stateImage as UIView,
                              duration: 0.75,
                              options: .transitionCrossDissolve, animations: {
                self.stateImage.image = newImage
            }, completion: nil)
        } else {
            stateImage.image = newImage
        }
    }
    
    private func setDateLabel(_ title: String?) {
        self.dateLabel.textColor = app.theme.textColor
        self.dateLabel.text = title
    }
    
    private func shouldAnimate(_ estro: Hormonal?, at index: Index, hormoneQuantity: Int, sdk: PatchDataDelegate) -> Bool {
        var dateChanged: Bool = false
        var siteChange: Bool = false
        var isGone: Bool = false
        if index < hormoneQuantity {
            if let _ = estro?.date {
                dateChanged = sdk.state.hormoneDateDidChange(at: index)
            }
            // Newly changed site and none else (date didn't change).
            bodilyChanged = sdk.state.hormonalBodilyDidChange(at: index)
        }
        // Is exiting the schedule.
        let decreased = state.decreasedQuantity
        let isGreaterThanNewCount = index >= q
        isGone = decreased && isGreaterThanNewCount
        return (
            sortFromEstrogenDateChange
            || isSiteChange
            || state.isNew
            || isGone
        )
    }

    private func reset() {
        selectedBackgroundView = nil
        dateLabel.text = nil
        badgeButton.titleLabel?.text = nil
        stateImage.image = nil
        selectionStyle = .none
        badgeButton.badgeValue = nil
    }

    private func setThemeColors(at index: Int) {
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = app.theme.selectedColor
        backgroundColor = app.theme.getCellColor(at: index)
    }

    private func configureDate(when isExpired: Bool) {
        dateLabel.textColor = isExpired ? UIColor.red : UIColor.black
        dateLabel.font = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ?
            UIFont.systemFont(ofSize: 15) :
            UIFont.systemFont(ofSize: 38)
    }

    private func configureBadge(at index: Int, isExpired: Bool, deliveryMethod: DeliveryMethod) {
        badgeButton.restorationIdentifier = String(index)
        badgeButton.setType(deliveryMethod: deliveryMethod)
        badgeButton.badgeValue = isExpired ? "!" : nil
    }
}
