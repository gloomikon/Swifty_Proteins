import Foundation

extension String {
    var indicesOfNumbers: [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        while searchStartIndex < self.endIndex,
            let range = self.rangeOfCharacter(from: CharacterSet.decimalDigits,
                                              range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            if index > 0 {
                let previousIndex = self.index(self.startIndex, offsetBy: index - 1)
                if let previousCharacter = self[previousIndex].unicodeScalars.first,
                    (previousCharacter == "." || previousCharacter == ",")
                {
                    indices.append(index - 1)
                }
            }
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        return indices
    }
}
