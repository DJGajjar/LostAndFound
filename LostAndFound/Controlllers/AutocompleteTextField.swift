//  AutocompleteTextField.swift
//  AutocompleteTextField
//  Created by Roman Panichkin on 4/21/18.
//  Copyright © 2018 Roman Panichkin. All rights reserved.

import UIKit

/// Protocol defines methods that you use to manage the performing of autocomplete
protocol AutocompleteTextFieldDelegate: class {
    /// Tells the delegate that text field performed autocomplete with given suggestion
    func textField(_ textField: AutocompleteTextField, didComplete suggestion: String)
}

/// TextField with autocomlete feature. Shows one autocomplete suggestion as part of the typed word
class AutocompleteTextField: UITextField, UITextFieldDelegate {
    // MARK: - public properties
    weak var autocompleteDelegate: AutocompleteTextFieldDelegate?

    /// Padding of the autocomplete suggestion label
    @IBInspectable var padding: CGFloat = 0

    /// The color of the autocomplete suggestion label's text. Default value matches the default placeholder color
    @IBInspectable var completionColor: UIColor = UIColor(white: 0, alpha: 0.22)

    lazy var completionFont: UIFont = { [unowned self] in
        return self.font ?? .systemFont(ofSize: 14.0)
    }()

    /// Array of autocomplete suggestions
    var suggestions: [String] = [""]

    /// Move the suggestion label up or down. Sometimes there's a small difference, and this can be used to fix it.
    var pixelCorrection: CGFloat = 0

    /// Updates the suggestion when the text is changed programmatically using 'field.text'
    override var text: String? {
        didSet {
            if let text = text {
                suggestion = suggestionToShow(searchTerm: text)
                setLabelContent(suggestion: suggestion ?? "")
            }
        }
    }

    // MARK:- private properties
    /// Autocomplete suggestion label
    private var label = UILabel()
    /// Current suggestion displayed
    private(set) var suggestion: String? {
        didSet {
            let value = suggestion ?? ""
            setLabelContent(suggestion: value)
        }
    }

    //MARK:- initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(textChanged(textField:)), for: .editingChanged)
        delegate = self
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(textChanged(textField:)), for: .editingChanged)
        delegate = self
        setupLabel()
    }

    ///- Parameter frame: The text field frame
    ///- Parameter suggestions: Array of autocomplete suggestions
    convenience init(frame: CGRect, suggestions: [String]) {
        self.init(frame: frame)
        self.suggestions = suggestions
    }

    //MARK:- Layout
    // Override to set frame of the suggestion label whenever the textfield frame changes.
    override func layoutSubviews() {
        label.frame = CGRect(x: padding, y: pixelCorrection, width: bounds.size.width - padding * 2, height: bounds.size.height)
        super.layoutSubviews()
    }

    //override to set padding
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + padding, y: bounds.origin.y, width: bounds.size.width - (padding * 2), height: bounds.size.height)
    }

    //override to set padding
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    //override to set padding on placeholder
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    //MARK:- Setup methods
    /// Sets up the suggestion label with the same font styling and alignment as the textfield.
    private func setupLabel() {
        setLabelContent()
        label.lineBreakMode = .byClipping
        // If the textfield has one of the default styles, we need to create some padding
        // otherwise there will be a offset in x-led.
        switch borderStyle {
        case .roundedRect, .bezel, .line:
            padding = 8
        default:
            break
        }
        addSubview(label)
    }

    //MARK:- Content update
    /// Set content of the suggestion label.
    /// - parameter text: Suggestion text
    private func setLabelContent(suggestion: String = "") {
        if suggestion.count < 1 {
            label.attributedText = nil
            return
        }

        // create an attributed string instead of the regular one.
        // In this way we can hide the letters in the suggestion that the user has already written.
        let attributedString = NSMutableAttributedString(string: suggestion, attributes: [.font: completionFont, .foregroundColor: completionColor])

        // Hide the letters that are under the fields text.
        // If the suggestion is Chicago and the user has written Chi
        // we want to hide those letters from the suggestion and display them as regular text.
        attributedString.addAttribute(.foregroundColor, value: UIColor.clear, range: NSRange(location:0, length:text!.count))
        label.attributedText = attributedString
        label.textAlignment = textAlignment
    }

    /// Scans through the suggestions array and finds a suggestion that matches the searchTerm.
    /// - parameter searchTerm: What to search for
    private func suggestionToShow(searchTerm: String) -> String? {
        if searchTerm == "" {
            return ""
        }
        suggestion = nil
        let foundSuggestions = suggestions.compactMap { suggestion -> String? in
            if suggestion.lowercased() == searchTerm.lowercased() {
                return suggestion
            } else if suggestion.lowercased().hasPrefix(searchTerm.lowercased()) {
                let start = suggestion.index(suggestion.startIndex, offsetBy: searchTerm.count)
                let end = suggestion.endIndex
                return searchTerm + suggestion[start..<end]
            } else {
                return nil
            }
        }

        /// There is a case: suppose suggestions = ["New York", "New York Knicks"] and user types "New Y".
        /// Found suggestion, in this case, would be both "New York" and "New York Knicks".
        /// We need to show autocomplete hint for "New York" not "New York Knicks", so simply return the shortest value.
        let shortestSuggestion = foundSuggestions.sorted { $1.count > $0.count }.first
        return shortestSuggestion
    }

    //MARK:- Events
    /// Triggered whenever the field text changes.
    @objc private func textChanged(textField: UITextField) {
        if let text = self.text {
            suggestion = !text.isEmpty ? suggestionToShow(searchTerm: text) : ""
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        suggestion = suggestionToShow(searchTerm: textField.text!)
        performAutocomplete(textField: textField)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        setLabelContent(suggestion: suggestion ?? "")
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let suggestion = suggestion, !suggestion.isEmpty, suggestion == text {
            performAutocomplete(textField: textField)
        } else {
            setLabelContent(suggestion: "")
        }
    }

    private func performAutocomplete(textField: UITextField) {
        if let supposedSuggestion = suggestionToShow(searchTerm: textField.text!) {
            text = supposedSuggestion
            autocompleteDelegate?.textField(self, didComplete: supposedSuggestion)
        }
    }
}
