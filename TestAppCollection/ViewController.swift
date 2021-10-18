//
//  ViewController.swift
//  TestAppCollection
//
//  Created by Artem Farafonov on 15.10.2021.
//

import UIKit

struct DataSourceItem {
    
    var image: UIImage?
    var error: String?
    
}

protocol ViewControllerDelegate: NSObject {
    
    func viewController(_ controller: UIViewController, didUpdate visibleItemsIndexPathes: [IndexPath], from collectionView: UICollectionView)
    func viewController(_ controller: UIViewController, didSelectItemAt indexPath: IndexPath, from collectionView: UICollectionView)
    func viewController(_ controller: UIViewController, didResponseDataReloadingFor collectionView: UICollectionView, completionHandler: @escaping () -> Void)
    
}

class ViewController: UIViewController {
    
    public weak var delegate: ViewControllerDelegate?
    
    private var _collectionView: UICollectionView?
    private var _collectionViewRefreshControl: UIRefreshControl?
    
    private var _dataSource: [DataSourceItem] = []
    
    // MARK: - Public
    
    public var dataSource: [DataSourceItem] {
        get {
            _dataSource
        } set {
            _dataSource = newValue
            
            _setupVisibleCells()
        }
    }
    
    public func removeItem(at indexPath: IndexPath) {
        _collectionView?.performBatchUpdates {
            self._dataSource.remove(at: indexPath.item)
            self._collectionView?.deleteItems(at: [indexPath])
        } completion: { flag in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self._sendDidUpdateVisibleItemsIndexPathes()
            }
        }
    }
    
    // MARK: - Private
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _createCollectionView()
        _createRefreshControl()
        
        self.view.addSubview(_collectionView!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _sendDidUpdateVisibleItemsIndexPathes()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard self.traitCollection != previousTraitCollection else {
            return
        }
        _sendDidUpdateVisibleItemsIndexPathes()
    }
    
    // MARK: Delegate sending
    
    private func _sendDidUpdateVisibleItemsIndexPathes() {
        guard let delegate = self.delegate,
              let collectionView = _collectionView else {
            return
        }
        delegate.viewController(self, didUpdate: collectionView.indexPathsForVisibleItems, from: collectionView)
    }
    
    private func _sendDidSelectItem(at indexPath: IndexPath) {
        guard let delegate = self.delegate,
              let collectionView = _collectionView else {
            return
        }
        delegate.viewController(self, didSelectItemAt: indexPath, from: collectionView)
    }
    
    private func _sendDidResponseDataReloading() {
        guard let delegate = self.delegate,
              let collectionView = _collectionView else {
            return
        }
        delegate.viewController(self, didResponseDataReloadingFor: collectionView, completionHandler: {
            self._collectionView?.reloadData()
            self._collectionViewRefreshControl?.endRefreshing()
        })
    }
    
    // MARK: Helpers
    
    private func _createCollectionView() {
        _collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: _collectionViewLayout())
        _collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _collectionView?.backgroundColor = .clear
        _collectionView?.delegate = self
        _collectionView?.dataSource = self
        _collectionView?.isPrefetchingEnabled = false
        _collectionView?.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.reuseIdentifier())
    }
    
    private func _collectionViewLayout() -> UICollectionViewLayout {
        let flowLayout = CollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        return flowLayout
    }
    
    private func _createRefreshControl() {
        _collectionViewRefreshControl = UIRefreshControl()
        _collectionViewRefreshControl?.addTarget(self, action: #selector(_reloadData), for: .valueChanged)
        _collectionView?.addSubview(_collectionViewRefreshControl!)
    }
    
    @objc private func _reloadData() {
        _collectionViewRefreshControl?.beginRefreshing()
        _sendDidResponseDataReloading()
    }
    
    private func _setupVisibleCells() {
        guard let collectionView = _collectionView else {
            return
        }
        let dispatchWorkItem = DispatchWorkItem {
            for indexPath in collectionView.indexPathsForVisibleItems {
                if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                    cell.image = self._dataSource[indexPath.item].image
                }
            }
        }
        if Thread.current.isMainThread {
            dispatchWorkItem.perform()
        } else {
            DispatchQueue.main.async(execute: dispatchWorkItem)
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reuseIdentifier(), for: indexPath) as! CollectionViewCell
        cell.image = _dataSource[indexPath.item].image
        return cell;
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _sendDidSelectItem(at: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _sendDidUpdateVisibleItemsIndexPathes()
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    private var _collectionViewItemSize: CGSize {
        get {
            CGSize(width: UIScreen.main.bounds.width - CollectionViewSizing.itemInset * 2,
                   height: UIScreen.main.bounds.width - CollectionViewSizing.itemInset * 2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        _collectionViewItemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: CollectionViewSizing.itemInset,
                     left: CollectionViewSizing.itemInset,
                     bottom: CollectionViewSizing.itemInset,
                     right: CollectionViewSizing.itemInset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        CollectionViewSizing.itemInset
    }
    
}
