//
//  GridViewController.swift
//  ProfilePage
//
//  Created by Tatiana Lazarenko on 22.01.2026.
//

import UIKit

protocol ScrollableViewController: AnyObject {
    var collectionView: UICollectionView { get }
    var delegate: ProfileViewControllerDelegate? { get set }
    
    func updateContentInset(top: CGFloat)
    func setContentOffset(_ offset: CGFloat)
    func setContentOffsetWithoutDelegate(_ offset: CGFloat)
}

final class GridViewController: UIViewController, ScrollableViewController {
    weak var delegate: ProfileViewControllerDelegate?
    
    var color: UIColor = .red
    var numberOfItems: Int = 30
    
    private var shouldNotifyDelegate = true
    private var isFirst = true
    private var pendingOffset: CGFloat?
    
    
    init(color: UIColor, numberOfItems: Int) {
        super.init(nibName: nil, bundle: nil)
        self.color = color
        self.numberOfItems = numberOfItems
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constants.spacing
        layout.minimumLineSpacing = Constants.spacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .white
        cv.register(GridCell.self, forCellWithReuseIdentifier: GridCell.identifier)
        cv.alwaysBounceVertical = true
        cv.backgroundColor = .gray
        return cv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        let visibleHeight = collectionView.bounds.height
        let targetHeight = visibleHeight - Constants.headerHeight
        
        if contentHeight < targetHeight {
            let extra = visibleHeight - contentHeight - Constants.topOffset
            collectionView.contentInset.bottom = extra
        } else {
            collectionView.contentInset.bottom = 20
        }
        
        guard isFirst else { return }
        
        if let pending = pendingOffset {
            shouldNotifyDelegate = false
            collectionView.contentOffset = CGPoint(x: 0, y: pending)
            pendingOffset = nil
            
            DispatchQueue.main.async { [weak self] in
                self?.shouldNotifyDelegate = true
                self?.isFirst = false
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func updateContentInset(top: CGFloat) {
        collectionView.contentInset = UIEdgeInsets(top: -top, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
    }
    
    func setContentOffset(_ offset: CGFloat) {
        shouldNotifyDelegate = true
        collectionView.contentOffset = CGPoint(x: 0, y: offset)
    }
    
    func setContentOffsetWithoutDelegate(_ offset: CGFloat) {
        pendingOffset = offset
        
        if collectionView.bounds.width > 0 {
            shouldNotifyDelegate = false
            collectionView.contentOffset = CGPoint(x: 0, y: offset)
            
            DispatchQueue.main.async { [weak self] in
                self?.shouldNotifyDelegate = true
            }
        }
    }
}

extension GridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.identifier, for: indexPath) as! GridCell
        cell.configure(with: indexPath.item, and: color)
        return cell
    }
}

extension GridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = Constants.spacing * CGFloat(Constants.columns - 1) + 32
        let width = (collectionView.bounds.width - totalSpacing) / CGFloat(Constants.columns)
        return CGSize(width: width, height: Constants.cellHeight)
    }
}

extension GridViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.setIsPaging(false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldNotifyDelegate else { return }
        delegate?.childDidScroll(scrollView, offset: scrollView.contentOffset.y)
    }
}
