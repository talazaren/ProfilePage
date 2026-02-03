//
//  MenuBar.swift
//  ProfilePage
//
//  Created by Tatiana Lazarenko on 22.01.2026.
//

import UIKit

final class MenuBar: UIView {
    weak var delegate: ProfileViewControllerDelegate?

    private let tabs = ["Posts", "Likes", "Reposts"]
    private let menuCell = "menuCell"
    private weak var indicatorView: UIView?
    private var trackView: UIView!
    private var indicatorLeftConstraint: NSLayoutConstraint!

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.showsHorizontalScrollIndicator = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: menuCell)
        setupUI()
        setupHorizontalBar()
        select(index: 0, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        addSubview(collectionView)
        
        collectionView.contentInset.left = 16
        collectionView.contentInset.right = 16
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupHorizontalBar() {
        let track = UIView()
        track.backgroundColor = UIColor.systemGray4
        track.translatesAutoresizingMaskIntoConstraints = false
        addSubview(track)
        trackView = track

        NSLayoutConstraint.activate([
            track.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            track.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            track.bottomAnchor.constraint(equalTo: bottomAnchor),
            track.heightAnchor.constraint(equalToConstant: 1.5)
        ])

        let indicator = GradientIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        track.addSubview(indicator)
        
        indicatorView = indicator
        indicatorLeftConstraint = indicator.leadingAnchor.constraint(equalTo: track.leadingAnchor)

        NSLayoutConstraint.activate([
            indicatorLeftConstraint,
            indicator.topAnchor.constraint(equalTo: track.topAnchor),
            indicator.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            indicator.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: 1 / 3)
        ])
    }
    
    
    func select(index: Int, animated: Bool) {
        let indexPath = IndexPath(item: index, section: 0)

        collectionView.selectItem(
            at: indexPath,
            animated: animated,
            scrollPosition: .centeredHorizontally
        )

        moveIndicator(to: index, animated: animated)
    }
    
    private func moveIndicator(to index: Int, animated: Bool) {
        let itemWidth = trackView.bounds.width / CGFloat(tabs.count)
        indicatorLeftConstraint.constant = itemWidth * CGFloat(index)
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
    }
}


extension MenuBar: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tabs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: menuCell,
            for: indexPath
        ) as! MenuCell

        cell.label.text = tabs[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (bounds.width - 32) / CGFloat(tabs.count), height: bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.scrollToMenuIndex(indexPath.item)
        moveIndicator(to: indexPath.item, animated: true)
    }
}

final class GradientIndicatorView: UIView {
    private let gradientLayer = CAGradientLayer.gradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}


final class MenuCell: UICollectionViewCell {
    let label: GradientLabel = {
        let label = GradientLabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override var isSelected: Bool {
        didSet {
            updateAppearance(animated: true)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
    }

    func configure(title: String) {
        label.text = title
        label.setNeedsLayout()
    }
    
    private func setupUI() {
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    private func updateAppearance(animated: Bool) {
        let changes = {
            self.label.setGradientEnabled(self.isSelected)
        }
        
        if animated {
            UIView.transition(
                with: label,
                duration: 0.2,
                options: .transitionCrossDissolve,
                animations: changes
            )
        } else {
            changes()
        }
    }
}



extension CAGradientLayer {
    static func gradientLayer() -> Self {
        let layer = Self()
        layer.colors = colors()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }
    
    private static func colors() -> [CGColor] {
        let beginColor: UIColor = UIColor(named: "turPurpleGradient") ?? .purple
        let endColor: UIColor = UIColor(named: "turBlueGradient") ?? .blue
        return [beginColor.cgColor, endColor.cgColor]
    }
}

extension UIView {
    func gradientColor(bounds: CGRect, gradientLayer: CAGradientLayer) -> UIColor? {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        gradientLayer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return UIColor(patternImage: image)
    }
}

final class GradientLabel: UILabel {
    private var colors: [UIColor] = [UIColor(named: "turPurpleGradient") ?? .purple, UIColor(named: "turBlueGradient") ?? .blue]
    private var startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5)
    private var endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5)
    private var textColorLayer: CAGradientLayer = CAGradientLayer()
    private var isGradientEnabled: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyColors()
    }
    
    func update(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
        applyColors()
    }
    
    private func setup() {
        isAccessibilityElement = true
        applyColors()
    }
    
    func setGradientEnabled(_ enabled: Bool) {
        isGradientEnabled = enabled
        applyColors()
    }
    
    private func applyColors() {
        guard  bounds.width > 0, bounds.height > 0 else { return }
        
        if isGradientEnabled {
            let gradient = getGradientLayer(bounds: bounds)
            textColor = UIView().gradientColor(bounds: bounds, gradientLayer: gradient)
        } else {
            textColor = UIColor(named: "turGray") ?? .gray
        }
    }
    
    private func getGradientLayer(bounds: CGRect) -> CAGradientLayer {
        textColorLayer.frame = bounds
        textColorLayer.colors = colors.map{ $0.cgColor }
        textColorLayer.startPoint = startPoint
        textColorLayer.endPoint = endPoint
        return textColorLayer
    }
    
}

