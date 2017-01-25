//
//  ViewController.swift
//  MemeMe
//
//  Created by Brenten Schlangen on 1/4/17.
//  Copyright © 2017 bschlangen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    UITextFieldDelegate {

    // Mark: OUTLETS
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    var memedImage: UIImage!
    var meme: Meme!

    
    struct Meme {
        var topText = "TOP"
        var bottomText = "BOTTOM"
        var originalImage : UIImage?
        var memedImage : UIImage?
    }
    
    @IBAction func shareAction(_ sender: Any) {
        // 1. generate a memed image
        self.memedImage = generateMemedImage()
        // 2. define an instance of the ActivityViewController
        // 3. pass the ActivityViewController a memedImage as an activity item
        let shareController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        shareController.completionWithItemsHandler = {(activityType, completed, returnedItems, error) in
            if completed {
                self.save()
            }}
        // 4. present the ActivityViewController
        present(shareController, animated: true, completion: nil)
    }
    
    
    @IBAction func pickAnImage(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        if sender.tag == 0 {
            // select image from photo library
            pickerController.sourceType = .photoLibrary
        }
        else {
            // Use Camera
            pickerController.sourceType = .camera
        }
        present(pickerController, animated: true, completion: nil)
    }
    
    func setupTextField(_ textField: UITextField){
        // Setup the text for the text views
        let textAttributes : [String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -4.0
        ]
      
        textField.defaultTextAttributes = textAttributes
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = true
        
        // Assign the text field delegates
        textField.delegate = self
    }
    
    // Mark: OVERRIDDEN METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        setupTextField(topTextField)
        setupTextField(bottomTextField)
        
        actionButton.isEnabled = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        subscribeToKeyboardNotifications()
    }
    
    @IBAction func textfieldActivated(_ sender: UITextField) {
        if sender.text == "TOP" || sender.text == "BOTTOM" {
         sender.text = " "
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    // Callback for image picker selection
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
        }
        dismiss(animated: true, completion: nil)
        actionButton.isEnabled = true
        print("selected an image in picker")
    }
    
    // Callback for image picker cancellation
    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        print("cancelled picker")
        
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // Creates a new meme
    func save() {
        self.meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
    }
    
    // Creates and returns an image combined with the top and bottom text fields
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        
        return memedImage
    }
    
    
    /*
     * Keyboard Related Methods
     *
     */
    // Prepare the views/textfields for the keyboard to slide up
    func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    // Return the height of the keyboard
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // Set this view controller as a listener to keyboard events
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    // Stop listening to keyboard events
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
}

