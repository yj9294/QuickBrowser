//
//  TabVC.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/15.
//

import UIKit

class TabVC: BaseVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: [BrowserItem] = BrowserManager.defaults.items
    
    var selectItem: BrowserItem = BrowserManager.defaults.item

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: TabCell.reuseIdentifier, bundle: .main)
        self.collectionView.register(nib, forCellWithReuseIdentifier: TabCell.reuseIdentifier)
        FirebaseManager.logEvent(name: .tabShow)
    }
    
    @IBAction func addAction() {
        BrowserManager.defaults.items.forEach {
            $0.isSelect = false
        }
        BrowserManager.defaults.items.insert(.navgationItem, at: 0)
        self.dismiss(animated: true)
        FirebaseManager.logEvent(name: .tabNew, params: ["bro": "tab"])
    }

    @IBAction func doneAction() {
        BrowserManager.defaults.items.forEach {
            $0.isSelect = $0 == self.selectItem
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func backAction() {
        self.dismiss(animated: true)
    }
    
    func delete(_ item: BrowserItem) {
        BrowserManager.defaults.removeItem(item)
        self.dataSource = BrowserManager.defaults.items
        if self.selectItem == item {
            self.selectItem = BrowserManager.defaults.item
        }
        self.collectionView.reloadData()
    }
}

extension TabVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabCell.reuseIdentifier, for: indexPath)
        if let cell = cell as? TabCell {
            let item = dataSource[indexPath.row]
            cell.item = item
            cell.select = item == selectItem
            cell.closeHandle = { [weak self] in
                self?.delete(item)
            }
        }
        return cell
    }
    
}

extension TabVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectItem = self.dataSource[indexPath.row]
        collectionView.reloadData()
    }
}
