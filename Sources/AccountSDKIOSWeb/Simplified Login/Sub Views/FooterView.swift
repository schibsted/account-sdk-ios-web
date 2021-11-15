import UIKit
import SwiftUI

class FooterView: UIStackView {
    let viewModel: SimplifiedLoginViewModel
    
    lazy var internalConstraints: [NSLayoutConstraint] = {
        let popularBrandsHeights = popularBrandsImageViews.map{ $0.heightAnchor.constraint(equalToConstant: 27) }
        let popularBrandsWidths = popularBrandsImageViews.map{ $0.widthAnchor.constraint(equalToConstant: 27) }
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
        let image: UIImage = UIImage(named: viewModel.schibstedLogoName, in: Bundle(for: SimplifiedLoginViewController.self), compatibleWith: nil) ?? UIImage()
        
        view.image = image
        view.contentMode = .center
        view.contentMode = .scaleAspectFit

        return view
    }()
    
    private lazy var popularBrandsStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 5
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
        
        view.text = viewModel.localisation.explanationText// TODO: Insert client_name
        view.font = UIFont.systemFont(ofSize: 12)
        view.textAlignment = .center
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(red: 102/255, green: 101/255, blue: 108/255, alpha: 1)
        
        return view
    }()
    
    private lazy var privacyURLLabel: UILabel = {
        let view = UILabel()
        let attributes:  [NSAttributedString.Key: Any] = [ .underlineStyle : NSUnderlineStyle.single.rawValue,
                                                           .font: UIFont.systemFont(ofSize: 12),
                                                           .foregroundColor: UIColor(red: 53/255, green: 52/255, blue: 58/255, alpha: 1)
        ]
        view.attributedText = NSAttributedString(string: viewModel.localisation.privacyPolicyTitle,
                                                 attributes: attributes)
                                                 
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        ////  Ecosystem
        for iv in popularBrandsImageViews {
            popularBrandsStackView.addArrangedSubview(iv) // TODO> make brand icons overlapping
        }
        ecoSystemBarStackView.addArrangedSubview(popularBrandsStackView)
        ecoSystemBarStackView.addArrangedSubview(schibstedIconImageView)
        self.addArrangedSubview(ecoSystemBarStackView)
        
        ////  Privacy and Explanation
        self.addArrangedSubview(explanationLabel)
        self.addArrangedSubview(privacyURLLabel)

    }
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func getRoundedImageView(name: String) -> UIImageView {
        let view = UIImageView()
        
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        let image  = UIImage(named: name, in: Bundle(for: SimplifiedLoginViewController.self), compatibleWith: nil) ?? UIImage()
        view.image = image
        
        return view
    }
}
