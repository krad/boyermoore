public struct BoyerMooreIterator<Base: Collection>: Sequence, IteratorProtocol where Base.Element: Hashable, Base.Indices.Element == Int {

    let collection: Base
    let pattern: Base
    var currentIdx: Int
    
    mutating public func next() -> Range<Int>? {
        if let result = self.collection.search(self.pattern, startingAt: currentIdx) {
            currentIdx = result.upperBound + 1
            return result
        }
        
        return nil
    }
    
}

public extension Collection where Self.Element: Hashable,
                            Self.Indices.Element == Int {
    
    public func searchAll(_ pattern: Self) -> BoyerMooreIterator<Self> {
        return BoyerMooreIterator(collection: self,
                                  pattern: pattern,
                                  currentIdx: pattern.underestimatedCount - 1)
    }
    
    public func search(_ pattern: Self) -> Range<Int>? {
        return self.search(pattern, startingAt: pattern.underestimatedCount - 1)
    }
    
    internal func search(_ pattern: Self, startingAt: Int) -> Range<Int>? {
        guard pattern.underestimatedCount > 0, startingAt < self.underestimatedCount else { return nil }
        
        var skipTable: [Self.Element: Int] = [:]
        for (i, c) in pattern.enumerated() {
            skipTable[c] = pattern.underestimatedCount - i - 1
        }
        
        // Create a reversed index of the pattern we're searching for
        let patternIndices = pattern.indices.reversed()
        var rangeStart     = 0
        
        var idx = startingAt
        while idx < self.count {
            // Loop over the reverse pattern index
            for p in patternIndices {
                
                let currentIdx     = idx - rangeStart
                let currentValue   = self[currentIdx]
                let currentPattern = pattern[p]
                
                // Check if we have a match
                if currentValue == currentPattern {
                    
                    // Check if we have a complete match
                    if(rangeStart == pattern.underestimatedCount - 1) {
                        // Return range for the complete match
                        return Range(currentIdx...(currentIdx + rangeStart))
                    }
                    
                    // Go backwards through the pattern by one
                    rangeStart += 1
                    
                } else {
                    
                    if let shift = skipTable[currentValue] {
                        idx += shift
                    } else {
                        idx += pattern.underestimatedCount
                    }
                    
                    rangeStart = 0
                    break
                }
            }
        }
        
        return nil
    }
    

}

public extension String {
    
    public func search(_ pattern: String) -> Range<Int>? {
        let pat = pattern.unicodeScalars.map { Int($0.value) }
        return self.unicodeScalars.map { Int($0.value) }.search(pat)
    }
    
    public func searchAll(_ pattern: String) -> BoyerMooreIterator<[Int]> {
        let pat = pattern.unicodeScalars.map { Int($0.value) }
        let col = self.unicodeScalars.map { Int($0.value) }
        return BoyerMooreIterator(collection: col, pattern: pat, currentIdx: pat.underestimatedCount - 1)
    }
}
