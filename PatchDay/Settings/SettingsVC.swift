//
//  SettingsVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/20/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

typealias UITimePicker = UIDatePicker
typealias SettingsKey = PDStrings.SettingsKey

class SettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Description: This is the view controller for the Settings View.  The Settings View is where the user may select their defaults, which are saved and used during future PatchDay use.  The defaults can alMOEstrogenst be broken up into two topics:  the Schedule Outlets and the Notification Outlets.  The Schedule Outlets include the interval that the patches expire, and the number of patches in the schedule.  The Notification Outlets include the Bool for whether the user wants to receive a reminder, and the time before patch expiration when the user wants to receive the reminder.  There is also a Bool for whether the user wishes to use the "Autofill Site Functionality". PDDefaults is the object responsible saving and loading the settings that the user chooses here.
    
    // Top level
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var settingsStack: UIStackView!
    @IBOutlet private weak var settingsView: UIView!
    
    // Labels
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet private weak var reminderTimeLabel: UILabel!
    @IBOutlet weak var reminderTimeSettingsLabel: UILabel!

    // Pickers
    @IBOutlet weak var deliveryMethodPicker: UIPickerView!
    @IBOutlet private weak var expirationIntervalPicker: UIPickerView!
    @IBOutlet private weak var countPicker: UIPickerView!
    @IBOutlet weak var themePicker: UIPickerView!

    // Buttons
    @IBOutlet private weak var intervalButton: UIButton!
    @IBOutlet weak var deliveryMethodButton: UIButton!
    @IBOutlet private weak var countButton: UIButton!
    @IBOutlet weak var countArrowButton: UIButton!
    @IBOutlet weak var themeButton: UIButton!
    
    // Other
    @IBOutlet private weak var receiveReminderSwitch: UISwitch!
    @IBOutlet weak var reminderTimeSlider: UISlider!
    
    // Trackers
    private var whichTapped: SettingsKey?
    private var selectedRow: Int?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = PDStrings.VCTitles.settings
        countLabel.text = PDStrings.ColonedStrings.count
        countButton.tag = 10
        settingsView.backgroundColor = UIColor.white
        setTopConstraint()
        loadButtonSelectedStates()
        loadButtonDisabledStates()
        delegatePickers()
        loadDeliveryMethod()
        loadReminder_bool()
        loadInterval()
        loadCount()
        loadRemindMinutes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        State.oldDeliveryCount = Defaults.getQuantity()
    }
    
    // MARK: - Actions
    
    @IBAction func reminderTimeValueChanged(_ sender: Any) {
        let v = Int(reminderTimeSlider.value.rounded())
        reminderTimeSettingsLabel.text = String(v)
        Defaults.setNotificationMinutesBefore(to: v)
        appDelegate.notificationsController.resendAllEstrogenNotifications()
        
    }
    
    @IBAction private func reminderTimeTapped(_ sender: Any) {
        openOrClosePicker(key: PDStrings.SettingsKey.notif)
    }
    
    @IBAction func deliveryMethodButtonTapped(_ sender: Any) {
        openOrClosePicker(key: PDStrings.SettingsKey.deliv)
    }
    
    @IBAction private func intervalButtonTapped(_ sender: Any) {
        openOrClosePicker(key: PDStrings.SettingsKey.interval)
    }
    
    @IBAction private func countButtonTapped(_ sender: Any) {
        openOrClosePicker(key: PDStrings.SettingsKey.count)
    }
    
    @IBAction func receiveReminder_switched(_ sender: Any) {
        let shouldReceive = receiveReminderSwitch.isOn
        if shouldReceive {
            enableNotificationButtons()
        } else {
            disableNotificationButtons()
        }
        Defaults.setNotify(to: shouldReceive)       // save
    }
    
    // MARK: - Public
    
    /// Resets the title of the Estrogens tab bar item to either "Patches" or "Injections".
    public func resetEstrogensVCTabBarItem() {
        let v = Schedule.totalDue(interval: Defaults.getTimeInterval())
        // Estrogen icon
        if let vcs = navigationController?.tabBarController?.viewControllers, vcs.count > 0 {
            vcs[0].tabBarItem.badgeValue = v > 0 ? String(v) : nil
            if Defaults.usingPatches() {
                vcs[0].tabBarItem.image = #imageLiteral(resourceName: "Patch Icon")
                vcs[0].tabBarItem.selectedImage = #imageLiteral(resourceName: "Patch Icon")
                vcs[0].tabBarItem.title = PDStrings.VCTitles.patches
            } else {
                vcs[0].tabBarItem.image = #imageLiteral(resourceName: "Injection Icon")
                vcs[0].tabBarItem.selectedImage = #imageLiteral(resourceName: "Injection Icon")
                vcs[0].tabBarItem.title = PDStrings.VCTitles.injections
            }
            vcs[0].awakeFromNib()
        }
    }
      
    // MARK: - Data loaders
    
    private func loadDeliveryMethod() {
        deliveryMethodButton.setTitle(Defaults.getDeliveryMethod(),
                                      for: .normal)
    }
    
    private func loadInterval() {
        intervalButton.setTitle(Defaults.getTimeInterval(),
                                for: .normal)
    }
    
    private func loadCount() {
        let count = Defaults.getQuantity()
        countButton.setTitle("\(count)", for: .normal)
        if !Defaults.usingPatches() {
            countButton.isEnabled = false
            countArrowButton.isEnabled = false
            if Defaults.getQuantity() != 1 {
                Defaults.setQuantityWithoutWarning(to: 1)
            }
        }
    }

    private func loadReminder_bool() {
        receiveReminderSwitch.setOn(Defaults.notify(), animated: false)
    }
    
    private func loadRemindMinutes() {
        if receiveReminderSwitch.isOn {
            let v = Defaults.getNotificationMinutesBefore()
            reminderTimeSlider.value = Float(v)
            reminderTimeSettingsLabel.text = String(v)
            reminderTimeSettingsLabel.textColor = UIColor.black
        } else {
            reminderTimeSettingsLabel.textColor = UIColor.lightGray
        }
    }

    // MARK: - Picker Functions
    
    private func delegatePickers() {
        deliveryMethodPicker.delegate = self
        expirationIntervalPicker.delegate = self
        countPicker.delegate = self
    }
    
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    internal func pickerView(_ pickerView: UIPickerView,
                             numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0;
        
        if let key = getWhichTapped() {
            switch key {
            case PDStrings.SettingsKey.deliv:                            // DELIVERY METHOD
                numberOfRows = PDStrings.PickerData.deliveryMethods.count
            case PDStrings.SettingsKey.count:                                     // COUNT
                numberOfRows = PDStrings.PickerData.counts.count
            case PDStrings.SettingsKey.interval:                                  // INTERVAL
                numberOfRows = PDStrings.PickerData.expirationIntervals.count
            default:
                print("Error:  Improper context when selecting picker selections count")
            }
        }
        return numberOfRows
        
    }
    
    internal func pickerView(_ pickerView: UIPickerView,
                             titleForRow row: Int,
                             forComponent component: Int) -> String? {
        var title = " "
        if let key = getWhichTapped() {
            let count = getPickerCount(from: key)
            if row < count && row >= 0 {
                switch key {
                case PDStrings.SettingsKey.deliv:
                    title = PDStrings.PickerData.deliveryMethods[row]
                case PDStrings.SettingsKey.interval:
                    title = PDStrings.PickerData.expirationIntervals[row]
                case PDStrings.SettingsKey.count:
                    title = PDStrings.PickerData.counts[row]
                default:
                    print("Error:  Improper context for loading PickerView")
                }
            }
        }
        return title
    }
    
    internal func pickerView(_ pickerView: UIPickerView,
                             didSelectRow row: Int,
                             inComponent component: Int) {
        selectedRow = row
    }
    
    /** Selector method for openOrClose(picker, buttonTapped, selections)
     // -- loads proper UI elements specific to each picker
     // -- hides everything that is not that picker
     
     // key is either "interval" , "count" , "notifications" */
    private func openOrClosePicker(key: SettingsKey) {
        
        // Change member variable for determining correct picker
        setWhichTapped(to: key)
        switch key {
        case PDStrings.SettingsKey.deliv:                // DELIVERY METHOD
            deliveryMethodPicker.reloadAllComponents()
            deselectEverything(except: "dm")
            openOrClose(picker: deliveryMethodPicker,
                        buttonTapped: deliveryMethodButton,
                        selections: PDStrings.PickerData.deliveryMethods,
                        key: key)
        case PDStrings.SettingsKey.interval:                      // INTERVAL
            expirationIntervalPicker.reloadAllComponents()
            deselectEverything(except: "i")
            openOrClose(picker: expirationIntervalPicker,
                        buttonTapped: intervalButton,
                        selections: PDStrings.PickerData.expirationIntervals,
                        key: key)
        case PDStrings.SettingsKey.count:                         // COUNT
            countPicker.reloadAllComponents()
            deselectEverything(except: "c")
            openOrClose(picker: countPicker,
                        buttonTapped: countButton,
                        selections: PDStrings.PickerData.counts,
                        key: key)
        default:
            print("Error: Improper context for loading UIPicker.")
        }
    }
    
    /** Select the button,
       And for count, set global variable necessary for animation,
       And close the picker,
       Then, save newly set User Defaults */
    private func closePicker(_ buttonTapped: UIButton,_ picker: UIPickerView,_ key: SettingsKey) {
        buttonTapped.isSelected = false
        picker.isHidden = true
        switch key {
        case PDStrings.SettingsKey.count :
            State.oldDeliveryCount = Defaults.getQuantity()
        default :
            break
        }
        self.saveFromPicker(key)
    }
    
    private func openPicker(_ buttonTapped: UIButton,_ selections: [String],_ picker: UIPickerView) {
        // Picker starting row
        if let title = buttonTapped.titleLabel,
            let readText = title.text,
            let selectedRowIndex = selections.index(of: readText) {
                picker.selectRow(selectedRowIndex, inComponent: 0, animated: true)
            }
        UIView.transition(with: picker as UIView,
                          duration: 0.4,
                          options: .transitionFlipFromTop,
                          animations: { picker.isHidden = false },
                          completion: nil)
    }
    
    // For regular pickers
    private func openOrClose(picker: UIPickerView,
                             buttonTapped: UIButton,
                             selections: [String],
                             key: SettingsKey) {
        if picker.isHidden == false {
            closePicker(buttonTapped, picker, key)
        } else {
            buttonTapped.isSelected = true
            openPicker(buttonTapped, selections, picker)
        }
    }
    
    // MARK: - Saving
    
    private func saveDeliveryMethodChange(_ row: Int) {
        if row < PDStrings.PickerData.deliveryMethods.count && row >= 0 {
            let choice = PDStrings.PickerData.deliveryMethods[row]
            setButtonsFromDeliveryMethodChange(choice:  choice)
            deliveryMethodButton.setTitle(choice, for: .normal)
            handleSiteScheduleChanges(choice: choice)
        } else {
            print("Error: saving delivery method for index for row  + \(row)")
        }
    }
    
    private func saveCountChange(_ row: Int) {
        let oldCount = State.oldDeliveryCount
        if row < PDStrings.PickerData.counts.count && row >= 0,
            let newCount = Int(PDStrings.PickerData.counts[row]) {
            let reset = makeResetClosure(oldCount: oldCount)
            let cancel = makeCancelClosure(oldCount: oldCount)
            Defaults.setQuantityWithWarning(to: newCount,
                                            oldCount: oldCount,
                                            reset: reset,
                                            cancel: cancel)
            countButton.setTitle("\(newCount)", for: .normal)
        } else {
            print("Error: saving count for index for row \(row)")
        }
    }
    
    private func saveIntervalChange(_ row: Int) {
        if row < PDStrings.PickerData.expirationIntervals.count && row >= 0 {
            let choice = PDStrings.PickerData.expirationIntervals[row]
            Defaults.setTimeInterval(to: choice)
            intervalButton.setTitle(choice, for: .normal)
            appDelegate.notificationsController.resendAllEstrogenNotifications()
        } else {
            print("Error: saving expiration interval for row \(row)")
        }
    }
 
    /// Saves values from pickers (NOT a function for TimePickers though).
    private func saveFromPicker(_ key: SettingsKey) {
        if let row = selectedRow {
            let oldHighest = Defaults.getQuantity() - 1
            switch key {
            case PDStrings.SettingsKey.deliv:
                saveDeliveryMethodChange(row)
            case PDStrings.SettingsKey.count:
                saveCountChange(row)
            case PDStrings.SettingsKey.interval:
                saveIntervalChange(row)
            default:
                print("Error: Improper context when saving details from picker")
            }
            resendNotifications(oldHighest: oldHighest)
        }
    }
    
    // MARK: - Setters and getters
    
    private func setWhichTapped(to: SettingsKey?) {
        whichTapped = to
    }
    
    private func getWhichTapped() -> SettingsKey? {
        return whichTapped
    }
    
    private func getBackgroundColor() -> UIColor {
        if let color = settingsView.backgroundColor {
            return color
        }
        return UIColor.white
    }
    
    // MARK: - View loading and altering
    
    private func enableNotificationButtons() {
        reminderTimeSlider.isEnabled = true
        reminderTimeSettingsLabel.textColor = UIColor.black
    }
    
    private func disableNotificationButtons() {
        reminderTimeSlider.isEnabled = false
        reminderTimeSettingsLabel.textColor = UIColor.lightGray
        reminderTimeSettingsLabel.text = "0"
        Defaults.setNotificationMinutesBefore(to: 0)
        reminderTimeSlider.value = 0
    }
    
    private func deselectEverything(except: String) {
        if except != "dm" {
            deliveryMethodPicker.isHidden = true
            deliveryMethodButton.isSelected = false
        }
        if except != "i" {
            expirationIntervalPicker.isHidden = true
            intervalButton.isSelected = false
        }
        if except != "c" {
            countPicker.isHidden = true
            countButton.isSelected = false
        }
    }
    
    private func loadButtonSelectedStates() {
        deliveryMethodButton.setTitle(PDStrings.ActionStrings.save, for: .selected)
        intervalButton.setTitle(PDStrings.ActionStrings.save, for: .selected)
        countButton.setTitle(PDStrings.ActionStrings.save, for: .selected)
    }
    
    private func loadButtonDisabledStates() {
        countButton.setTitleColor(UIColor.lightGray, for: .disabled)
    }
    
    private func setTopConstraint() {
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiom.phone) {
            topConstraint.constant = 100
        }
    }
    
    private func getPickerCount(from key: SettingsKey) -> Int {
        switch (key) {
        case PDStrings.SettingsKey.deliv:
            return PDStrings.PickerData.deliveryMethods.count
        case PDStrings.SettingsKey.interval:
            return PDStrings.PickerData.expirationIntervals.count
        case PDStrings.SettingsKey.count:
            return PDStrings.PickerData.counts.count
        default:
            return 0
        }
    }
    
    private func setButtonsFromDeliveryMethodChange(choice: String) {
        if choice == PDStrings.PickerData.deliveryMethods[1] {
            countButton.setTitle(PDStrings.PickerData.counts[0], for: .disabled)
            countButton.setTitle(PDStrings.PickerData.counts[0], for: .normal)
            countButton.isEnabled = false
            countArrowButton.isEnabled = false
        } else {
            countButton.setTitle(PDStrings.PickerData.counts[2], for: .disabled)
            countButton.setTitle(PDStrings.PickerData.counts[2], for: .normal)
            countButton.isEnabled = true
            countArrowButton.isEnabled = true
        }
    }
    
    private func handleSiteScheduleChanges(choice: String) {
        let usingPatches = Defaults.usingPatches()
        if EstrogenScheduleRef.isEmpty() &&
            SiteScheduleRef.isDefault(usingPatches: usingPatches) {
            Defaults.setDeliveryMethod(to: choice)
            Defaults.setSiteIndex(to: 0)
            resetEstrogensVCTabBarItem()
            Schedule.setEstrogenDataForToday()
        } else {
            alertForChangingDeliveryMethod(choice: choice)
        }
    }
    
    private func alertForChangingDeliveryMethod(choice: String) {
        PDAlertController.alertForChangingDeliveryMethod(newMethod: choice,
                                                         oldMethod: Defaults.getDeliveryMethod(),
                                                         oldCount: Defaults.getQuantity(),
                                                         deliveryButton: deliveryMethodButton,
                                                         countButton: countButton,
                                                         settingsVC: self)
    }
    
    private func setTabBadge() {
        let tabController = self.navigationController?.tabBarController
        if let vcs = tabController?.viewControllers, vcs.count > 0 {
            let interval = Defaults.getTimeInterval()
            let c = EstrogenScheduleRef.totalDue(interval)
            let item = vcs[0].navigationController?.tabBarItem
            item?.badgeValue = (c > 0) ? "\(c)" : nil
        }
    }
    
    private func makeResetClosure(oldCount: Int) -> ((Int) -> ()) {
        let reset: (Int) -> () = {
            newCount in
            self.setTabBadge()
            self.cancelNotifications(newCount: newCount, oldCount: oldCount)
        }
        return reset
    }
    
    private func makeCancelClosure(oldCount: Int) -> ((Int) -> ()) {
        let cancel: (Int) -> () = {
            oldCount in
            self.countButton.setTitle(String(oldCount), for: .normal)
        }
        return cancel
    }
    
    private func resendNotifications(oldHighest: Int) {
        let newHighest = Defaults.getQuantity() - 1
        appDelegate.notificationsController.resendEstrogenNotifications(upToRemove: oldHighest,
                                                                        upToAdd: newHighest)
    }
    
    private func cancelNotifications(newCount: Int, oldCount: Int) {
        for i in (newCount-1)..<oldCount {
            appDelegate.notificationsController.cancelEstrogenNotification(at: i)
        }
    }
}

extension SettingsVC: UIScrollViewDelegate {
    
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return settingsStack
    }
}
