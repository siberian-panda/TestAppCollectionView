//
//  ResourceManager.swift
//  TestAppCollection
//
//  Created by Artem Farafonov on 17.10.2021.
//

import UIKit

class ResourceManager: NSObject {
    
    private var resourcesData: [DataSourceItem] = []
    private var fileManager = ResourceFileManager()
    private var requestController = ResourceRequestController()
    private var viewController: ViewController?
    private var resourceList: [String] = []
    
    override init() {
        super.init()
        
        _resetResourcesData()
        _loadCachedResourceList()
        
        self.requestController.delegate = self
        
        _handleViewController()
    }
    
    private func _handleViewController() {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController,
           let rootViewController = navigationController.viewControllers.first as? ViewController {
            _setupViewController(viewController: rootViewController)
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                self._handleViewController()
            })
        }
    }
    
    private func _setupViewController(viewController: ViewController) {
        self.viewController = viewController
        self.viewController?.delegate = self
        self.viewController?.dataSource = resourcesData
        self.viewController?.reloadData()
    }
    
    private func _resourceName(for itemIndex: Int) -> String {
        "\(UUID.init()).jpeg"
    }
    
    private func _resetResourcesData() {
        resourcesData = [DataSourceItem(),
                         DataSourceItem(),
                         DataSourceItem(),
                         DataSourceItem(),
                         DataSourceItem(),
                         DataSourceItem()]
    }
    
    private func _updateResourcesData(itemIndex: Int, image: UIImage?, error: String?) {
        resourcesData[itemIndex].image = image
        resourcesData[itemIndex].error = error
        viewController?.dataSource = resourcesData
    }
    
    private func _removeResource(for itemIndex: Int) {
        guard resourcesData.count > itemIndex else {
            return
        }
        let resourceName = resourceList[itemIndex]
        fileManager.removeResourceFile(with: resourceName)
        _updateResourceList(resourceName: nil, index: itemIndex)
        resourcesData.remove(at: itemIndex)
    }
    
    private func _removeAllResources() {
        for (index, _) in resourceList.enumerated() {
            let resourceName = resourceList[index]
            fileManager.removeResourceFile(with: resourceName)
        }
        resourceList = []
        _saveCachedResourceList()
        resourcesData.removeAll()
    }
    
    private func _loadCachedResourceList() {
        guard let resourceList = UserDefaults.standard.object(forKey: UserDefaultsKey.resourceList) as? [String] else {
            return
        }
        self.resourceList = resourceList
    }
    
    private func _saveCachedResourceList() {
        UserDefaults.standard.setValue(resourceList, forKey: UserDefaultsKey.resourceList)
    }
    
    private func _updateResourceList(resourceName: String?, index: Int) {
        if let resourcename = resourceName {
            _addResourceToList(resourceName: resourcename, index: index)
        } else {
            _removeResourceFromList(index: index)
        }
    }
    
    private func _addResourceToList(resourceName: String, index: Int) {
        guard !resourceList.contains(resourceName) else {
            return
        }
        if resourceList.count > index, resourcesData.count > index {
            resourceList[index] = resourceName
        } else {
            resourceList.append(resourceName)
        }
        _saveCachedResourceList()
    }
    
    private func _removeResourceFromList(index: Int) {
        guard resourcesData.count > index else {
            return
        }
        resourceList.remove(at: index)
        _saveCachedResourceList()
    }
    
}

extension ResourceManager: ResourceRequestControllerDelegate {
    
    private func _save(data: Data, for itemIndex: Int) {
        let resourceName = _resourceName(for: itemIndex)
        if let _ = fileManager.save(data: data, with: resourceName) {
            _updateResourceList(resourceName: resourceName, index: itemIndex)
        }
    }
    
    func resourceRequestController(_ controller: ResourceRequestController, didLoadResource data: Data, for index: Int) {
        _save(data: data, for: index)
        _updateResourcesData(itemIndex: index, image: UIImage(data: data), error: nil)
    }
    
    func resourceRequestController(_ controller: ResourceRequestController, didFailToLoadResourceFor index: Int, error: NSError) {
        _updateResourcesData(itemIndex: index, image: nil, error: error.localizedDescription)
    }
    
}

extension ResourceManager: ViewControllerDelegate {
    
    func viewController(_ controller: UIViewController, didUpdate visibleItemsIndexPathes: [IndexPath], from collectionView: UICollectionView) {
        for indexPath in visibleItemsIndexPathes.sorted(by: { left, right -> Bool in
            return left.item < right.item
        }) {
            if resourceList.count > indexPath.item, resourcesData.count > indexPath.item,
               let data = fileManager.readResourceFile(with: resourceList[indexPath.item]) {
                _updateResourcesData(itemIndex: indexPath.item, image: UIImage(data: data), error: nil)
                continue
            }
            requestController.loadResource(for: indexPath.item)
        }
    }
    
    func viewController(_ controller: UIViewController, didSelectItemAt indexPath: IndexPath, from collectionView: UICollectionView) {
        _removeResource(for: indexPath.item)
        viewController?.removeItem(at: indexPath)
    }
    
    func viewController(_ controller: UIViewController, didResponseDataReloadingFor collectionView: UICollectionView, completionHandler: @escaping () -> Void) {
        let currentResourcesList = resourceList
        _removeAllResources()
        _resetResourcesData()
        viewController?.dataSource = resourcesData
        for (index, _) in currentResourcesList.enumerated() {
            requestController.loadResource(for: index)
        }
        completionHandler()
    }
    
}
