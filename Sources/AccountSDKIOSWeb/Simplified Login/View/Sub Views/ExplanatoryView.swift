import UIKit

class ExplanatoryView: UIView {
    let viewModel: SimplifiedLoginViewModel

    private lazy var explanationLabel: UILabel = {
        let text = String.localizedStringWithFormat(viewModel.localizationModel.loginIncentive)
        let font = UIFont.preferredFont(forTextStyle: .subheadline)
        let view = UILabel.paragraphLabel(localizedString: text,
                                          font: font)
        return view
    }()

    lazy var internalConstraints: [NSLayoutConstraint] = {
        return [ explanationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                 explanationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                 explanationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                 explanationLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2),
                 explanationLabel.topAnchor.constraint(equalTo: topAnchor, constant: 2)]
    }()

    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(explanationLabel)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UILabel {
    static func paragraphLabel(localizedString: String,
                               font: UIFont = UIFont.preferredFont(forTextStyle: .footnote)) -> UILabel {
        let view = UILabel()
        view.numberOfLines = -1

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        paragraphStyle.alignment = .center
        let attrString = NSMutableAttributedString(string: localizedString)

        attrString.addAttributes([
            .paragraphStyle: paragraphStyle,
            .font: font,
            .foregroundColor: SchibstedColor.textLightGray.value
        ], range: NSRange(location: 0, length: attrString.length))

        view.attributedText = attrString
        view.adjustsFontForContentSizeCategory = true
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }
}
