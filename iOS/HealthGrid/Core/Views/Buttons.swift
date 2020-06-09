import UIKit
import RxSwift
import RxCocoa

public enum ButtonStyle {
    case primary(title: String)
    case blue(title: String)
    case clear(title: String)
    case assetsIcon(name: String, colour: UIColor?, dimension: CGFloat)
}

open class StyledButton: RippleButton {
    
    fileprivate var iconImageView: UIImageView?
    
    open override var isEnabled: Bool {
        didSet {
            setStyle(buttonStyle)
            super.isEnabled = self.isEnabled
        }
    }
    
    open var buttonStyle: ButtonStyle = .primary(title: "") {
        didSet {
            setStyle(buttonStyle)
        }
    }
    
    private let activityIndicator = UIActivityIndicatorView()
    
    //just an alias of isSaving for now
    public var isBusy: Bool = true {
        didSet {
            isSaving = isBusy
        }
    }
    
    public var isSaving: Bool = false {
        didSet {
            if isSaving {
                activityIndicator.startAnimating()
                titleLabel?.alpha = 0.0
            } else {
                activityIndicator.stopAnimating()
                titleLabel?.alpha = 1.0
            }
        }
    }
    public var buttonHandler: (() -> Void)?
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setupButton()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    public override init() {
        super.init(frame: CGRect.zero)
        setupButton()
    }
    
    private func setupButton() {
        
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 8.0
        
        guard titleLabel != nil else {
            return
        }
        
        addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        activityIndicator.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20.0).isActive = true
        
        //I believe you can have multiple targets. So this is safe.
        self.addTarget(self, action: #selector(StyledButton.didPressButton), for: .touchUpInside)
    }

    fileprivate func setStyle(_ style: ButtonStyle) {
        isSaving = false
        
        switch style {
        case .primary(let title):
            
            backgroundColor = isEnabled ? <|.main : <|.lightGray
            setTitleColor(<|.white, for: UIControl.State())
            borderWidth = 0.0
            alpha = 1.0
            
            if let icon = iconImageView {
                icon.removeFromSuperview()
            }
            
            setAttributedTitle(title.palette(.white).typography(.normal(.bold)), for: UIControl.State())
        case .blue(let title):
            let titleColor: UIColor = isEnabled ? <|.white : <|.white
            backgroundColor = isEnabled ? <|.custom(colour: .buttonBlue) : <|.custom(colour: .buttonGray)
            setTitleColor(titleColor, for: UIControl.State())
            borderWidth = 0.0
            alpha = 1.0
            
            if let icon = iconImageView {
                icon.removeFromSuperview()
            }
            
            setAttributedTitle(title.palette(.custom(colour: titleColor)).typography(.normal(.bold)), for: UIControl.State())
        case .clear(let title):
            
            backgroundColor = .clear
            setTitleColor(<|.custom(colour: .buttonBlue), for: UIControl.State())
            borderWidth = 0.0
            alpha = 1.0
            
            if let icon = iconImageView {
                icon.removeFromSuperview()
            }
            
            setAttributedTitle(title.palette(.custom(colour: .buttonBlue)).typography(.extraSmall(.bold)), for: UIControl.State())
        case .assetsIcon(let name, let color, let dimension):
            backgroundColor = UIColor.clear
            borderColor = UIColor.clear
            borderWidth = 0
            alpha = isEnabled ? 1.0 : 0.5
            
            if let icon = iconImageView {
                icon.removeFromSuperview()
            }
            if let color = color {
                setAssetsIcon(name, palette: .custom(colour: color), dimension: dimension)
            } else {
                setAssetsIcon(name, palette: nil, dimension: dimension)
            }
        }
    }
    
    fileprivate func setAssetsIcon(_ name: String, palette: Palette?, dimension: CGFloat) {
        iconImageView = nil
        guard let image = UIImage(named: name) else { return }
        let iv = UIImageView(image: image)
        addSubview(iv)
        if let palette = palette {
            iv.tintColor = palette.color()
        }
        iv.contentMode = .center
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: dimension).isActive = true
        iv.heightAnchor.constraint(equalToConstant: dimension).isActive = true
        iv.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        iv.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        iconImageView = iv
    }
    
    @objc private func didPressButton(){
        self.buttonHandler?()
    }
    
    open var buttonCornerRadius: Float = 0 {
        didSet{
            layer.cornerRadius = CGFloat(buttonCornerRadius)
        }
    }
    
}

open class RippleButton: UIButton {
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setupRipple()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupRipple()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupRipple()
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        setupRipple()
    }
    
    // #mark Ripple
    
    fileprivate var rippleMask: CAShapeLayer? {
        get {
            if !rippleOverBounds {
                let maskLayer = CAShapeLayer()
                maskLayer.path = UIBezierPath(roundedRect: bounds,
                                              cornerRadius: layer.cornerRadius).cgPath
                return maskLayer
            } else {
                return nil
            }
        }
    }
    
    fileprivate var originalShadowRadius: CGFloat = 0
    fileprivate var originalShadowOpacity: Float = 0
    fileprivate var originalShadowOffset: CGSize = .zero
    fileprivate var touchCenterLocation: CGPoint?
    
    let rippleView = UIView()
    let rippleBackgroundView = UIView()
    
    var rippleOverBounds: Bool = false
    open var shadowRippleRadius: Float = 1
    open var shadowRippleOpacity: CGFloat = 1
    open var shadowRippleOffset = CGSize(width: 0, height: 1)
    open var shadowRippleEnable: Bool = true
    open var trackTouchLocation: Bool = false
    open var touchUpAnimationTime: Double = 0.6
    
    open var ripplePercent: Float = 0.8 {
        didSet {
            setupRippleView()
        }
    }
    
    open var rippleColor: UIColor = UIColor.black.withAlphaComponent(0.2) {
        didSet {
            rippleView.backgroundColor = rippleColor
        }
    }
    
    open var rippleBackgroundColor: UIColor = UIColor.clear {
        didSet {
            rippleBackgroundView.backgroundColor = rippleBackgroundColor
        }
    }
    
    fileprivate func setupRippleView() {
        let size: CGFloat = bounds.width * CGFloat(ripplePercent)
        let x: CGFloat = (bounds.width/2) - (size/2)
        let y: CGFloat = (bounds.height/2) - (size/2)
        let corner: CGFloat = size/2
        
        rippleView.backgroundColor = rippleColor
        rippleView.frame = CGRect(x: x, y: y, width: size, height: size)
        rippleView.layer.cornerRadius = corner
    }
    
    fileprivate func setupRipple() {
        setupRippleView()
        
        rippleBackgroundView.backgroundColor = rippleBackgroundColor
        rippleBackgroundView.frame = bounds
        rippleBackgroundView.addSubview(rippleView)
        rippleBackgroundView.alpha = 0
        addSubview(rippleBackgroundView)
        
        layer.shadowRadius = 0
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowColor = UIColor(white: 0.0, alpha: 0.5).cgColor
    }
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        if trackTouchLocation {
            touchCenterLocation = touch.location(in: self)
        } else {
            touchCenterLocation = nil
        }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            self.rippleBackgroundView.alpha = 1
        }, completion: nil)
        
        rippleView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [UIView.AnimationOptions.curveEaseOut, UIView.AnimationOptions.allowUserInteraction],
                       animations: {
                        self.rippleView.transform = CGAffineTransform.identity
        }, completion: nil)
        
        if shadowRippleEnable {
            originalShadowRadius = layer.shadowRadius
            originalShadowOpacity = layer.shadowOpacity
            originalShadowOffset = layer.shadowOffset
            
            let radiusAnim = CABasicAnimation(keyPath:"shadowRadius")
            radiusAnim.toValue = shadowRippleRadius
            
            let opacityAnim = CABasicAnimation(keyPath:"shadowOpacity")
            opacityAnim.toValue = shadowRippleOpacity
            
            let offsetAnim = CABasicAnimation(keyPath:"shadowOffset")
            offsetAnim.toValue = shadowRippleOffset
            
            let groupAnim = CAAnimationGroup()
            groupAnim.duration = 0.2
            groupAnim.fillMode = CAMediaTimingFillMode.forwards
            groupAnim.isRemovedOnCompletion = false
            groupAnim.animations = [radiusAnim, opacityAnim, offsetAnim]
            
            layer.add(groupAnim, forKey:"shadow")
        }
        return super.beginTracking(touch, with: event)
    }
    
    override open func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        animateToNormal()
    }
    
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        animateToNormal()
    }
    
    fileprivate func animateToNormal() {
        
        UIView.animate(withDuration: 0.1, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            self.rippleBackgroundView.alpha = 1
        }, completion: {(_: Bool) -> Void in
            UIView.animate(withDuration: self.touchUpAnimationTime, delay: 0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                self.rippleBackgroundView.alpha = 0
            }, completion: nil)
        })
        
        
        UIView.animate(withDuration: 0.7, delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction],
                       animations: {
                        self.rippleView.transform = CGAffineTransform.identity
                        
                        let radiusAnim = CABasicAnimation(keyPath:"shadowRadius")
                        radiusAnim.toValue = self.originalShadowRadius
                        
                        let opacityAnim = CABasicAnimation(keyPath:"shadowOpacity")
                        opacityAnim.toValue = self.originalShadowOpacity
                        
                        let offsetAnim = CABasicAnimation(keyPath:"shadowOffset")
                        offsetAnim.toValue = self.originalShadowOffset
                        
                        let groupAnim = CAAnimationGroup()
                        groupAnim.duration = 0.7
                        groupAnim.fillMode = CAMediaTimingFillMode.forwards
                        groupAnim.isRemovedOnCompletion = false
                        groupAnim.animations = [radiusAnim, opacityAnim, offsetAnim]
                        
                        self.layer.add(groupAnim, forKey:"shadowBack")
        }, completion: nil)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        setupRippleView()
        if let knownTouchCenterLocation = touchCenterLocation {
            rippleView.center = knownTouchCenterLocation
        }
        
        rippleBackgroundView.layer.frame = bounds
        rippleBackgroundView.layer.mask = rippleMask
    }
    
}

class CheckboxButton: RippleButton {
        
    public override init() {
        super.init()
        
        backgroundColor = .clear
        self.shadowRippleEnable = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    override public var isSelected: Bool {
        didSet {
            let image = isSelected ? UIImage(named: "ic_privacy_check_box_active") : UIImage(named: "ic_privacy_check_box_inactive")
            setImage(image, for: .normal)
        }
    }
    
    func updateCornerRadius() {
        layer.cornerRadius = 4
    }
    
}

class SettingsButton: RippleButton {
        
    public var buttonHandler: (() -> Void)?
    
    public override init() {
        super.init()
        
        backgroundColor = .white
        contentHorizontalAlignment = .left
        addTarget(self, action: #selector(SettingsButton.didPressButton), for: .touchUpInside)
        isSelected = false
        setImage(nil, for: UIControl.State())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
        updateLayerProperties()
        updateInsets()
    }
    
    override public var isSelected: Bool {
        didSet {
            let image = isSelected ? UIImage(named: "ic_settings_checkbox_selected") : UIImage(named: "ic_settings_checkbox_unselected")
            setImage(image, for: .normal)
            setTitleColor(isSelected ? .buttonBlue : .main, for: .normal)
        }
    }
    
    private func updateCornerRadius() {
        layer.cornerRadius = 8
    }
    
    private func updateLayerProperties() {
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 5.0
        layer.masksToBounds = false
    }
    
    private func updateInsets() {
        if let _ = imageView?.image {
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: imageView!.frame.width)
        } else {
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        }
        imageEdgeInsets = UIEdgeInsets(top: 0, left: bounds.width - 37, bottom: 0, right: 0)
    }
    
    @objc private func didPressButton(){
        self.buttonHandler?()
    }
    
}

extension Reactive where Base: StyledButton {
    
    public func styledTitle(for controlState: UIControl.State = []) -> Binder<String?> {
        return Binder(self.base) { button, title -> Void in
            if let oldAttributedTitle = button.attributedTitle(for: controlState), let title = title {
                let mutableAttributedTitle = NSMutableAttributedString(attributedString: oldAttributedTitle)
                mutableAttributedTitle.replaceCharacters(in: NSMakeRange(0, mutableAttributedTitle.length), with: title)
                button.setAttributedTitle(mutableAttributedTitle, for: controlState)
            }
        }
    }
    
}
