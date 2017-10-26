// MARK: - Extension that performs the search.
// Only works with collections that contain Hashable elements that are indexed by Int's
public extension Collection where Self.Element: Hashable,
                            Self.Indices.Element == Int {
    
    
    /// Find the first instance of a pattern in a collection
    ///
    /// - Parameter pattern: The pattern to search for
    /// - Returns: A Range representing where the pattern begins and ends in a Collection
    public func search(_ pattern: Self) -> Range<Int>? {
        return self.search(pattern, startingAt: pattern.underestimatedCount - 1)
    }
    
    internal func search(_ pattern: Self, startingAt: Int) -> Range<Int>? {
        guard pattern.underestimatedCount > 0, startingAt < self.underestimatedCount else { return nil }
        
        
        /// Build the skip table.  This helps us to determine how far ahead to skip when we have a miss.
        var skipTable: [Self.Element: Int] = [:]
        for (i, c) in pattern.enumerated() {
            skipTable[c] = pattern.underestimatedCount - i - 1
        }
        
        /// Create a reversed index of the pattern we're searching for
        let patternIndices = pattern.indices.reversed()
        var rangeStart     = 0
        
        /// Set the point in the collection where we want to start searching from
        var idx = startingAt
        
        /// Loop over the collection and search
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
                    
                    // We had a miss.  Use the skip table to determine how far ahead fo move the index
                    if let shift = skipTable[currentValue] {
                        idx += shift
                    } else {
                        idx += pattern.underestimatedCount // Miss wasn't in the skip table.  Move 1 pattern length ahead.
                    }
                    
                    // Reset the range start so we begin at the end of the pattern on the next read
                    rangeStart = 0
                    break
                }
            }
        }
        
        return nil
    }

    
    /// Finds all the ranges of a pattern within a collection
    ///
    /// - Parameter pattern: Pattern to search for
    /// - Returns: An iterator that can be looped over for each of the Range's
    public func searchAll(_ pattern: Self) -> BoyerMooreIterator<Self> {
        return BoyerMooreIterator(collection: self,
                                  pattern: pattern,
                                  currentIdx: pattern.underestimatedCount - 1)
    }
    
    
    /// Returns each of the subsequences between ranges delimited by a pattern.
    ///
    /// - Parameters:
    ///   - pattern: The pattern to split the input on
    ///   - includeSeperator: Should we include the pattern as a part of the SubSequence or not
    /// - Returns: A SubSequence of the collection based on the ranges
    public func chunk(with pattern: Self, includeSeperator: Bool = false) -> BoyerMooreChunkedIterator<Self> {
        return BoyerMooreChunkedIterator(collection: self,
                                         pattern: pattern,
                                         currentIdx: pattern.underestimatedCount - 1,
                                         includeSeperator: includeSeperator)
    }

}

// MARK: - Conveinence extension for String
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


// MARK: - Iterators for accessing all search results.

/// Iterator struct for returning all ranges in a collection
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


/// Iterator struct for returning all chunks in a collection
public struct BoyerMooreChunkedIterator<Base: Collection>: Sequence, IteratorProtocol where Base.Element: Hashable, Base.Indices.Element == Int {
    
    let collection: Base
    let pattern: Base
    var currentIdx: Int
    let includeSeperator: Bool
    
    var lastRange: Range<Int>? = nil
    
    init(collection: Base, pattern: Base, currentIdx: Int, includeSeperator: Bool) {
        self.collection       = collection
        self.pattern          = pattern
        self.currentIdx       = currentIdx
        self.includeSeperator = includeSeperator
    }
    
    mutating public func next() -> Base.SubSequence? {
        if let currentRange = self.collection.search(self.pattern, startingAt: currentIdx) {

            var result: Base.SubSequence?
            if let prevRange = self.lastRange {
                result = makeSubSequence(with: prevRange, and: currentRange)
            } else {

                // This is our first time through
                if let nextRange = self.collection.search(self.pattern, startingAt: currentIdx + currentRange.upperBound) {
                    result = makeSubSequence(with: currentRange, and: nextRange)
                }
            }

            self.lastRange = currentRange
            currentIdx = currentRange.upperBound + 1
            return result
        }
        return nil
    }
    
    private func makeSubSequence(with startRange: Range<Int>, and endRange: Range<Int>) -> Base.SubSequence {
        let startIdx = self.includeSeperator ? startRange.lowerBound : startRange.upperBound
        return self.collection[startIdx..<endRange.lowerBound]
    }
}

