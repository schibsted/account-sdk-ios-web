import UIKit
import SwiftUI

class FooterView: UIStackView {
    let viewModel: SimplifiedLoginViewModel
    
    lazy var internalConstraints: [NSLayoutConstraint] = {
        let popularBrandsHeights = popularBrandsImageViews.map{ $0.heightAnchor.constraint(equalToConstant: 32) }
        let popularBrandsWidths = popularBrandsImageViews.map{ $0.widthAnchor.constraint(equalToConstant: 32) }
        return popularBrandsWidths + popularBrandsHeights + [schibstedIconImageView.heightAnchor.constraint(equalToConstant: 16),
            schibstedIconImageView.widthAnchor.constraint(equalToConstant: 100)]
    }()
    
    // Eco system
    
    private lazy var ecoSystemBarStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var schibstedIconImageView: UIImageView = {
        let view = UIImageView()
        let image: UIImage = UIImage(named: viewModel.schibstedLogoName, in: Bundle.accountSDK(for: FooterView.self), compatibleWith: nil) ?? UIImage()
        
        view.image = image
        view.contentMode = .center
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    private lazy var popularBrandsStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = -6
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var popularBrandsImageViews: [UIImageView] = {
        var views = [UIImageView]()
        for imageName in viewModel.iconNames {
            views.append(getRoundedImageView(name: imageName))
        }
        
        return views
    }()
    
    // Privacy
    
    private lazy var explanationLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = -1
        
        view.text = viewModel.explanationText// TODO: Insert client_name
        view.font = UIFont.systemFont(ofSize: 12)
        view.textAlignment = .center
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(red: 102/255, green: 101/255, blue: 108/255, alpha: 1)
        
        return view
    }()
    
    lazy var privacyURLButton: UIButton = {
        let view = UIButton()
        let attributes:  [NSAttributedString.Key: Any] = [ .underlineStyle : NSUnderlineStyle.single.rawValue,
                                                           .font: UIFont.systemFont(ofSize: 12),
                                                           .foregroundColor: UIColor(red: 53/255, green: 52/255, blue: 58/255, alpha: 1)
        ]
        let attributedText = NSAttributedString(string: viewModel.privacyPolicyTitle,
                                                 attributes: attributes)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.setAttributedTitle(attributedText, for: .normal)
        
        return view
    }()
    
    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        ////  Ecosystem
        for iv in popularBrandsImageViews {
            popularBrandsStackView.addArrangedSubview(iv)
        }
        popularBrandsStackView.reverseSubviewsZIndex()
        
        ecoSystemBarStackView.addArrangedSubview(popularBrandsStackView)
        ecoSystemBarStackView.addArrangedSubview(schibstedIconImageView)
        self.addArrangedSubview(ecoSystemBarStackView)
        
        ////  Privacy and Explanation
        self.addArrangedSubview(explanationLabel)
        self.addArrangedSubview(privacyURLButton)
        
    }
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func getRoundedImageView(name: String) -> UIImageView {
        let view = UIImageView()
        
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        let image  = UIImage(named: name, in: Bundle.accountSDK(for: FooterView.self), compatibleWith: nil) ?? UIImage()
        view.image = image
        
        return view
    }
}

private extension UIStackView {
    func reverseSubviewsZIndex(setNeedsLayout: Bool = true) {
        let stackedViews = self.arrangedSubviews
        stackedViews.forEach {
            self.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        stackedViews.reversed().forEach(addSubview(_:))
        stackedViews.forEach(addArrangedSubview(_:))
        
        if setNeedsLayout {
            stackedViews.forEach { $0.setNeedsLayout() }
        }
    }
}
