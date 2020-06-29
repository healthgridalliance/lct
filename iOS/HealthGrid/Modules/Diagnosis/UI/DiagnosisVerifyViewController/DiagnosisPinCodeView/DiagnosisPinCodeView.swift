import UIKit
import RxSwift
import RxCocoa

public enum DiagnosisPinCodeResetType {
    case none, onUserInteraction, afterError(_ delay: TimeInterval)
}

public typealias PinCodeValidator = (_ code: String) -> Bool

private enum InterfaceLayoutDirection {
    case ltr, rtl
}

public final class DiagnosisPinCodeView: UIView {
    
    private lazy var _stack = UIStackView(frame: bounds)
    private lazy var _textField = UITextField(frame: bounds)
    
    private var _code = "" {
        didSet { codeDidChanged.onNext(_code) }
    }
    
    private var _activeIndex: Int {
        return _code.count == 0 ? 0 : _code.count - 1
    }

    private var _layoutDirection: InterfaceLayoutDirection = .ltr

    public var isError = false {
        didSet { if oldValue != isError { updateErrorState() } }
    }
    
    public var length: Int = 6 {
        willSet { createLabels() }
    }
    
    public var spacing: CGFloat = 8 {
        willSet { if newValue != spacing { _stack.spacing = newValue } }
    }

    public var keyBoardType = UIKeyboardType.numberPad {
        willSet { _textField.keyboardType = newValue }
    }
    
    public var animateSelectedInputItem = true
    
    public var shakeOnError = true
    public var resetAfterError = DiagnosisPinCodeResetType.none
        
    public let codeEntered = BehaviorRelay<String?>(value: nil)
    public let codeDidChanged = PublishSubject<String>()
    public let beginEditing = PublishSubject<Void>()
    public let isCodeValid = PublishSubject<Bool>()
    
    public var validator: PinCodeValidator?

    public var onSettingStyle: (() -> DiagnosisPinCodeEntryViewStyle)? {
        didSet { createLabels() }
    }
    
    // MARK: - Initializers

    public convenience init() {
        self.init(frame: CGRect.zero)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Life cycle
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    // MARK: Overrides

    @discardableResult
    override public func becomeFirstResponder() -> Bool {
        onBecomeActive()
        return super.becomeFirstResponder()
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onBecomeActive()
    }
    
    // MARK: Public methods

    public func resetCode() {
        _code = ""
        _textField.text = nil
        _stack.arrangedSubviews.forEach({ ($0 as! DiagnosisPinCodeLabel).text = nil })
        isError = false
    }
    
    // MARK: Private methods
    
    private func setup() {
        setupTextField()
        setupStackView()

        if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft {
            _layoutDirection = .rtl
        }

        createLabels()
    }
    
    private func setupStackView() {
        _stack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _stack.alignment = .fill
        _stack.axis = .horizontal
        _stack.distribution = .fillEqually
        _stack.spacing = spacing
        addSubview(_stack)
    }
    
    private func setupTextField() {
        _textField.keyboardType = keyBoardType
        _textField.autocapitalizationType = .none
        _textField.isHidden = true
        _textField.delegate = self
        _textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _textField.addTarget(self, action: #selector(self.onTextChanged(_:)), for: .editingChanged)
        
        if #available(iOS 12.0, *) { _textField.textContentType = .oneTimeCode }
        
        addSubview(_textField)
    }
    
    @objc private func onTextChanged(_ sender: UITextField) {
        let text = sender.text!
        
        if _code.count > text.count {
            deleteChar(text)
            var index = _code.count - 1
            if index < 0 { index = 0 }
            highlightActiveLabel(index)
        } else {
            appendChar(text)
            let index = _code.count - 1
            highlightActiveLabel(index)
        }
        
        if _code.count == length {
            _textField.resignFirstResponder()
            codeEntered.accept(_code)
        }
        isCodeValid.onNext(_code.count == length)
    }
    
    private func deleteChar(_ text: String) {
        let index = text.count
        let previous = _stack.arrangedSubviews[index] as! UILabel
        previous.text = ""
        _code = text
    }
    
    private func appendChar(_ text: String) {
        if text.isEmpty { return }

        let index = text.count - 1
        let activeLabel = _stack.arrangedSubviews[index] as! UILabel
        let charIndex = text.index(text.startIndex, offsetBy: index)
        activeLabel.text = String(text[charIndex])
        _code += activeLabel.text!
    }
    
    private func highlightActiveLabel(_ activeIndex: Int) {
        for i in 0 ..< _stack.arrangedSubviews.count {
            let label = _stack.arrangedSubviews[normalizeIndex(index: i)] as! DiagnosisPinCodeLabel
            label.isSelected = i == normalizeIndex(index: activeIndex)
        }
    }
    
    private func turnOffSelectedLabel() {
        let label = _stack.arrangedSubviews[_activeIndex] as! DiagnosisPinCodeLabel
        label.isSelected = false
    }
    
    private func createLabels() {
        _stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for _ in 1 ... length { _stack.addArrangedSubview(DiagnosisPinCodeLabel(onSettingStyle?())) }
    }
    
    private func updateErrorState() {
        if isError {
            turnOffSelectedLabel()
            if shakeOnError { shakeAnimation() }
        }
        _stack.arrangedSubviews.forEach({ ($0 as! DiagnosisPinCodeLabel).isError = isError })
    }
    
    private func shakeAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-15.0, 15.0, -15.0, 15.0, -12.0, 12.0, -10.0, 10.0, 0.0]
        animation.delegate = self
        layer.add(animation, forKey: "shake")
    }
    
    private func onBecomeActive() {
        _textField.becomeFirstResponder()
        highlightActiveLabel(_activeIndex)
    }

    private func normalizeIndex(index: Int) -> Int {
        return _layoutDirection == .ltr ? index : length - 1 - index
    }
}


extension DiagnosisPinCodeView: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        beginEditing.onNext(())
        handleErrorStateOnBeginEditing()
    }
    
    public func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        return (validator?(string) ?? true) && _code.count < length
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if isError { return }
        turnOffSelectedLabel()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func handleErrorStateOnBeginEditing() {
        if isError, case DiagnosisPinCodeResetType.onUserInteraction = resetAfterError {
            return resetCode()
        }
        isError = false
    }
}

extension DiagnosisPinCodeView: CAAnimationDelegate {
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if !flag { return }
        switch resetAfterError {
            case let .afterError(delay):
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { self.resetCode() }
            default: break
        }
    }
}
