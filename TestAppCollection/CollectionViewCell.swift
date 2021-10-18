//
//  CollectionViewCell.swift
//  TestAppCollection
//
//  Created by Artem Farafonov on 15.10.2021.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    private var _activityIndicator: UIActivityIndicatorView?
    private var _imageView: UIImageView?
    private var _label: UILabel?
    
    public var image: UIImage? {
        get {
            _imageView?.image
        } set {
            _imageView?.image = newValue
            
            if newValue == nil, _label?.text == nil {
                _activityIndicator?.startAnimating()
            } else {
                _activityIndicator?.stopAnimating()
            }
        }
    }
    
    public var errorMessage: String? {
        get {
            _label?.text
        } set {
            _label?.text = newValue
            
            if newValue == nil, _imageView?.image == nil {
                _activityIndicator?.startAnimating()
            } else {
                _activityIndicator?.stopAnimating()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightGray
        _createSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _updateSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backgroundColor = .lightGray
        _imageView?.image = nil
        _label?.text = nil
        image = nil
        errorMessage = nil
    }
    
    private func _createSubviews() {
        _activityIndicator = UIActivityIndicatorView(style: .gray)
        if let activityIndicator = _activityIndicator {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.frame = CGRect(x: self.bounds.width / 2 - activityIndicator.frame.width / 2,
                                               y: self.bounds.height / 2 - activityIndicator.frame.height / 2,
                                               width: activityIndicator.frame.width,
                                               height: activityIndicator.frame.height)
            self.addSubview(activityIndicator)
        }
        
        _imageView = UIImageView(frame: self.bounds)
        _imageView?.backgroundColor = .clear
        _imageView?.contentMode = .scaleAspectFill
        _imageView?.clipsToBounds = true
        self.addSubview(_imageView!)
        
        _label = UILabel()
        self.addSubview(_label!)
    }
    
    private func _updateSubviews() {
        _imageView?.frame = self.bounds
        if let activityIndicator = _activityIndicator {
            activityIndicator.frame = CGRect(x: self.bounds.width / 2 - activityIndicator.frame.width / 2,
                                             y: self.bounds.height / 2 - activityIndicator.frame.height / 2,
                                             width: activityIndicator.frame.width,
                                             height: activityIndicator.frame.height)
        }
    }
    
}

extension UICollectionViewCell {
    
    class func reuseIdentifier() -> String {
        var result = NSStringFromClass(self) as NSString
        result = result.substring(from: result.range(of: ".").location + 1) as NSString
        return result as String
    }
    
}
