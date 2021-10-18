//
//  CollectionViewFlowLayout.swift
//  TestAppCollection
//
//  Created by Artem Farafonov on 17.10.2021.
//

import UIKit

class CollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) {
            attributes.frame = CGRect(x: attributes.frame.maxX + CollectionViewSizing.itemInset,
                                      y: attributes.frame.origin.y,
                                      width: attributes.frame.width,
                                      height: attributes.frame.height)
            return attributes
        }
        return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
    
}
