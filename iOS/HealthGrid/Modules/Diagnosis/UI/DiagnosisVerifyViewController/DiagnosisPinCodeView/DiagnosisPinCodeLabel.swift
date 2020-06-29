import UIKit

public class DiagnosisPinCodeLabel: UILabel {

    private var _style: DiagnosisPinCodeEntryViewStyle?
    
    public var dropShadow = true
    
    public var animateWhileSelected = true
    
    public var isSelected = false {
        didSet { if oldValue != isSelected { updateSelectedState() } }
    }
    
    public var isError = false {
        didSet {  updateErrorState() }
    }
    
    // MARK: - Initializers

    public init(_ style: DiagnosisPinCodeEntryViewStyle?) {
        super.init(frame: CGRect.zero)
        setStyle(style)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Overrides
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        _style?.onLayoutSubviews(self)
    }
    
    // MARK: - Public methods

    public func setStyle(_ style: DiagnosisPinCodeEntryViewStyle?) {
        _style = style
        _style?.onSetStyle(self)
    }

    // MARK: - Private methods
    
    private func updateSelectedState() {
        _style?.onUpdateSelectedState(self)
    }
    
    private func updateErrorState() {
        _style?.onUpdateErrorState(self)
    }
}
