import UIKit

public final class DiagnosisPinCodeBorderStyle: DiagnosisPinCodeEntryViewStyle {

    private var _font: UIFont
    private var _textColor: UIColor
    private var _errorTextColor: UIColor
    private var _cornerRadius: CGFloat
    private var _borderColor: UIColor
    private var _borderWidth: CGFloat
    private var _selectedBorderColor: UIColor
    private var _errorBorderColor: UIColor
    private var _backgroundColor: UIColor
    private var _selectedBackgroundColor: UIColor

    public required init(
        font: UIFont = Typography.extraLarge(.bold).font(),
        textColor: UIColor = .main,
        errorTextColor: UIColor = .errorRed,
        cornerRadius: CGFloat = 8,
        borderWidth: CGFloat = 1,
        borderColor: UIColor = .white,
        selectedBorderColor: UIColor = .buttonBlue,
        errorBorderColor: UIColor = .errorRed,
        backgroundColor: UIColor = .white,
        selectedBackgroundColor: UIColor = .white) {
        _font = font
        _textColor = textColor
        _errorTextColor = errorTextColor
        _cornerRadius = cornerRadius
        _borderWidth = borderWidth
        _borderColor = borderColor
        _selectedBorderColor = selectedBorderColor
        _errorBorderColor = errorBorderColor
        _backgroundColor = backgroundColor
        _selectedBackgroundColor = selectedBackgroundColor
    }

    public func onSetStyle(_ label: DiagnosisPinCodeLabel) {
        let layer = label.layer
        layer.cornerRadius = _cornerRadius
        layer.borderColor = _borderColor.cgColor
        layer.borderWidth = _borderWidth
        layer.backgroundColor = _backgroundColor.cgColor
        label.textAlignment = .center
        label.font = _font
        label.textColor = _textColor
        
        if label.dropShadow {
            label.layer.shadowColor = UIColor.pinCodeShadow.cgColor
            label.layer.shadowOffset = CGSize(width: 0, height: 3)
            label.layer.shadowOpacity = 1.0
            label.layer.shadowRadius = 3.0
            label.layer.masksToBounds = false
        }
    }

    public func onUpdateSelectedState(_ label: DiagnosisPinCodeLabel) {
        let layer = label.layer

        if label.isSelected {
            layer.borderColor = _selectedBorderColor.cgColor
            layer.backgroundColor = _selectedBackgroundColor.cgColor

            if label.animateWhileSelected {
                let colors = [_borderColor.cgColor,
                _selectedBorderColor.cgColor,
                _selectedBorderColor.cgColor,
                _borderColor.cgColor]

                let animation = animateSelection(keyPath: #keyPath(CALayer.borderColor), values: colors)
                layer.add(animation, forKey: "borderColorAnimation")
            }
        } else {
            layer.removeAllAnimations()
            layer.borderColor = _borderColor.cgColor
            layer.backgroundColor = _backgroundColor.cgColor
        }
    }

    public func onUpdateErrorState(_ label: DiagnosisPinCodeLabel) {
        if label.isError {
            label.layer.removeAllAnimations()
            label.layer.borderColor = _errorBorderColor.cgColor
            label.textColor = _errorTextColor
        } else {
            label.layer.borderColor = _borderColor.cgColor
            label.textColor = _textColor
        }
    }

    public func onLayoutSubviews(_ label: DiagnosisPinCodeLabel) {}
}
