//
//  SiteVC.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

class SiteVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    private var siteScheduleIndex: Int = -1
    private var hasChanged: Bool = false
    private var namePickerSet =
        Array(patchData.siteSchedule.unionDefault(deliveryMethod: patchData.defaults.deliveryMethod.value))
    
    @IBOutlet weak var siteStack: UIStackView!
    
    @IBOutlet weak var nameStackVertical: UIStackView!

    @IBOutlet weak var nameStackHorizontal: UIStackView!
    @IBOutlet weak var verticalLineByNameTextField: UIView!
    @IBOutlet weak var typeNameButton: UIButton!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var namePicker: UIPickerView!
    @IBOutlet weak var gapAboveImage: UIView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imagePickerDoneButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var siteImage: UIImageView!
    @IBOutlet weak var imagePicker: UIPickerView!
    
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    private var imagePickerDelegate: SiteImagePickerDelegate?
    
    struct ImageStruct {
        let image: UIImage
        let imageKey: SiteName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiom.phone) {
            topConstraint.constant = 100
        }
        nameText.autocapitalizationType = .words
        loadSave()
        disableSave()
        nameText.borderStyle = .none
        nameText.delegate = self
        namePicker.delegate = self
        namePicker.isHidden = true
        loadImagePickeR()
        typeNameButton.setTitleColor(UIColor.lightGray, for: .disabled)
        loadTitle()
        loadImage()
        typeNameButton.setTitle(PDStrings.ActionStrings.type, for: .normal)
        verticalLineByNameTextField.backgroundColor = bottomLine.backgroundColor
        nameText.restorationIdentifier = "select"
        applyTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        applyTheme()
    }
    
    public func setSiteScheduleIndex(to index: Int) {
        siteScheduleIndex = index
    }
    
    // MARK: - Actions
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        let t = patchData.defaults.theme.value
        let deliv = patchData.defaults.deliveryMethod.value
        let images = PDImages.siteImages(theme: t, deliveryMethod: deliv)
        let imgF = PDImages.imageToSiteName(_:)
        let imageStruct = setImage(images: images, imageNameFunction: imgF)
        imagePicker.isHidden = true
        siteImage.image = imageStruct.image
        siteImage.isHidden = false
        imageButton.isEnabled = true
        typeNameButton.isEnabled = true
        nameText.isEnabled = true
        imagePickerDoneButton.isEnabled = false
        imagePickerDoneButton.isHidden = true
        enableSave()
        patchData.siteSchedule.setImageId(at: siteScheduleIndex,
                                to: imageStruct.imageKey,
                                deliveryMethod: deliv)
    }
    
    @IBAction func imageButtonTapped(_ sender: Any) {
        siteImage.isHidden = true
        imageButton.isEnabled = false
        imagePickerDelegate?.openPicker() {
            self.typeNameButton.isEnabled = false
            self.imageButton.isEnabled = false
            self.nameText.isEnabled = false
            self.imagePickerDoneButton.isHidden = false
            self.imagePickerDoneButton.isEnabled = true
        }
    }
    
    @IBAction func typeTapped(_ sender: Any) {
        nameText.restorationIdentifier = "type"
        nameText.becomeFirstResponder()
    }
    
    @objc func saveButtonTapped(_ sender: Any) {
        if let name = nameText.text {
            // Updating existing site
            let i = siteScheduleIndex
            let count = patchData.siteSchedule.count()
            switch i {
            case 0..<count :
                patchData.siteSchedule.setName(at: i, to: name)
            case count :
                if let _ = patchData.siteSchedule.insert() {
                    patchData.siteSchedule.setName(at: i, to: name)
                }
            default : break
            }
        }
        segueToSitesVC()
    }
    
    // MARK: - Text field
    
    internal func textFieldDidBeginEditing(_ textField: UITextField) {
        enableSave()
        typeNameButton.setTitle(PDStrings.ActionStrings.done, for: .normal)
        nameText.removeTarget(self,
                                    action: #selector(typeTapped(_:)),
                                    for: .touchUpInside)
        switch textField.restorationIdentifier {
        case "type" :
            nameText.isEnabled = true
            textField.restorationIdentifier = "select"
            typeNameButton.addTarget(self,
                                     action: #selector(closeTextField),
                                     for: .touchUpInside)
        case "select" :
            view.endEditing(true)
            nameText.isEnabled = false
            openPicker(namePicker)
            typeNameButton.addTarget(self,
                                     action: #selector(closePicker),
                                     for: .touchUpInside)
        default : break
        }
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeTextField()
        return true
    }
    
    @objc internal func closeTextField() {
        view.endEditing(true)
        nameText.restorationIdentifier = "select"
        switch nameText.text {
        case "" :
            nameText.text = PDStrings.PlaceholderStrings.new_site
        case let name :
            if let n = name {
                patchData.siteSchedule.setName(at: siteScheduleIndex, to: n)
            }
        }
        loadImage()
        typeNameButton.setTitle(PDStrings.ActionStrings.type, for: .normal)
        nameText.removeTarget(self,
                              action: #selector(closeTextField),
                              for: .touchUpInside)
        typeNameButton.addTarget(self,
                                 action: #selector(typeTapped(_:)),
                                 for: .touchUpInside)
    }
    
    // MARK: - Picker functions
    
    @objc private func openPicker(_ picker: UIPickerView) {
        UIView.transition(with: picker as UIView,
                          duration: 0.4,
                          options: .transitionFlipFromTop,
                          animations: {
                            picker.isHidden = false;
                            self.bottomLine.isHidden = true;
                            self.siteImage.isHidden = true })
        if let n = nameText.text, let i = namePickerSet.firstIndex(of: n) {
            namePicker.selectRow(i, inComponent: 0, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return namePickerSet.count
    }
    
    internal func pickerView(_ pickerView: UIPickerView,
                             attributedTitleForRow row: Int,
                             forComponent component: Int) -> NSAttributedString? {
        let attrs = [NSAttributedString.Key.foregroundColor : appDelegate.themeManager.text_c]
        let n = namePickerSet[row]
        let attributedString = NSAttributedString(string: n, attributes: attrs)
        return attributedString
    }
 
    internal func pickerView(_ pickerView: UIPickerView,
                             didSelectRow row: Int,
                             inComponent component: Int) {
        self.nameText.text = self.namePickerSet[row]
        closePicker()
    }
    
    @objc internal func closePicker() {
        self.namePicker.isHidden = true;
        self.bottomLine.isHidden = false;
        self.siteImage.isHidden = false;
        nameText.restorationIdentifier = "select"
        typeNameButton.setTitle(PDStrings.ActionStrings.type, for: .normal)
        nameText.removeTarget(self,
                              action: #selector(closePicker),
                              for: .touchUpInside)
        self.typeNameButton.addTarget(self,
                                      action: #selector(self.typeTapped(_:)),
                                      for: .touchUpInside)
        self.nameText.isEnabled = true
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    // MARK: - Private
    
    private func setImage(images: [UIImage],
                          imageNameFunction: ((UIImage) -> SiteName)) -> ImageStruct {
        let image = images[imagePicker.selectedRow(inComponent: 0)]
        let imageKey = imageNameFunction(image)
        return ImageStruct(image: image, imageKey: imageKey)
    }
    
    private func segueToSitesVC() {
        if let sb = storyboard, let navCon = navigationController,
            let sitesVC = sb.instantiateViewController(withIdentifier: "SitesVC_id") as? SitesVC {
            sitesVC.siteNames = patchData.siteSchedule.getNames()
            navCon.popViewController(animated: true)
        }
    }
    
    private func loadTitle() {
        let sites = patchData.siteSchedule.sites
        if siteScheduleIndex >= 0 && siteScheduleIndex < sites.count {
            let site = sites[siteScheduleIndex]
            title = "\(PDStrings.TitleStrings.site) \(siteScheduleIndex + 1)"
            nameText.text = site.getName()
        } else {
            title = "\(PDStrings.TitleStrings.site) \(sites.count + 1)"
        }
    }
    
    private func loadImage() {
        let deliv = patchData.defaults.deliveryMethod.value
        let theme = appDelegate.themeManager.theme
        if let name = nameText.text {
            var image: UIImage
            var sitesWithImages = PDSiteStrings.getSiteNames(for: deliv)
            if name == PDStrings.PlaceholderStrings.new_site {
                image = PDImages.newSiteImage(theme: theme, deliveryMethod: deliv)
            } else if let site = patchData.siteSchedule.getSite(at: siteScheduleIndex),
                let imgId = site.getImageIdentifer(),
                let i = sitesWithImages.firstIndex(of: imgId) {
                image = PDImages.siteNameToImage(sitesWithImages[i],
                                                 theme: theme,
                                                 deliveryMethod: deliv)
            } else {
                image = PDImages.custom(theme: theme, deliveryMethod: deliv)
            }
            UIView.transition(with: siteImage, duration:0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.siteImage.image = image },
                              completion: nil)
        }
    }
    
    private func loadImagePickeR() {
        let deliv = patchData.defaults.deliveryMethod.value
        if let site = patchData.siteSchedule.getSite(at: siteScheduleIndex) {
            imagePickerDelegate = SiteImagePickerDelegate(with: imagePicker,
                                                          and: siteImage,
                                                          saveButton: navigationItem.rightBarButtonItem!,
                                                          selectedSite: site,
                                                          deliveryMethod: deliv)
        }
        imagePicker.delegate = imagePickerDelegate
        imagePicker.dataSource = imagePickerDelegate
    }
    
    private func loadSave() {
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: PDStrings.ActionStrings.save,
                            style: .plain,
                            target: self,
                            action: #selector(saveButtonTapped(_:)))
    }
    
    private func enableSave() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func disableSave() {
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func applyTheme() {
        view.backgroundColor = appDelegate.themeManager.bg_c
        nameStackVertical.backgroundColor = appDelegate.themeManager.bg_c
        nameStackHorizontal.backgroundColor = appDelegate.themeManager.bg_c
        typeNameButton.setTitleColor(appDelegate.themeManager.text_c, for: .normal)
        nameText.textColor = appDelegate.themeManager.text_c
        nameText.backgroundColor = appDelegate.themeManager.bg_c
        siteImage.backgroundColor = appDelegate.themeManager.bg_c
        gapAboveImage.backgroundColor = appDelegate.themeManager.bg_c
    }
}
