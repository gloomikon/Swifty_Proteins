import UIKit

extension UILabel {
    func setAttributedTextWithSubscripts(text: String, indicesOfSubscripts: [Int]) {
        let font = self.font!
        let subscriptFont = font.withSize(font.pointSize * 0.7)
        let subscriptOffset = -font.pointSize * 0.3
        let attributedString = NSMutableAttributedString(string: text,
                                                         attributes: [.font : font])
        for index in indicesOfSubscripts {
            let range = NSRange(location: index, length: 1)
            attributedString.setAttributes([.font: subscriptFont,
                                            .baselineOffset: subscriptOffset],
                                           range: range)
        }
        self.attributedText = attributedString
    }
}
