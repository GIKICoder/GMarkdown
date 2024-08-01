//
//  ViewController.swift
//  GMarkdownExample
//
//  Created by GIKI on 2024/8/1.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView: UICollectionView!
    let items = ["Markdown Render"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "GMarkdownExample"
        // 设置布局
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 70)
        layout.minimumLineSpacing = 0
        
        // 初始化 UICollectionView
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        
        // 注册 cell
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.view.addSubview(collectionView)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        // 配置 cell
        let label = UILabel(frame: CGRect(x: 16, y: 22, width: 200, height: 25))
        label.text = items[indexPath.item]
        label.textAlignment = .left
        cell.contentView.addSubview(label)
        
        // 添加右箭头
        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.frame = CGRect(x: cell.contentView.frame.width - 50, y: (cell.contentView.frame.height - 20)/2, width: 20, height: 20)
        cell.contentView.addSubview(arrow)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 点击某一行后的处理
        print("Selected item: \(items[indexPath.item])")
      if indexPath.item == 0 {
        self.navigationController?.pushViewController(MarkdownRenderController(), animated: true)
      }
    }
}
