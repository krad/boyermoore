# BoyerMoore

This package contains a very general implementation of the [Boyer-Moore algorithm](https://en.wikipedia.org/wiki/Boyer%E2%80%93Moore_string_search_algorithm).

It does so by extending the Collection protocol.

## Usage

Currently this package supports types that implement the Collection protocol where
the Element is Hashable and the subscript Index is of type Int

Call `search(_ pattern: T)` on the collection and a `Range` gets returned for
the first occurrence of the pattern.

### String search
```

let sourceText = "He felt all at once like an ineffectual moth,
                  fluttering at the windowpane of reality, dimly seeing it from outside."

let result = sourceText.search("moth") // #=> Range(40..<44)

```

### Byte search

```
let input: [UInt8] =  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                       7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 0, 0, 0, 0, 0, 0, 0, 0,]

let result = input.search([7, 7, 7]) #=> Range(30..<33)

```

### Iterating over all ranges

```
let input: [UInt8] =  [0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
                       0, 0, 7, 0, 0, 0, 0, 0, 0, 0,]

for range in input.searchAll([0, 0, 7]) {
  print(range)
}

// #=> 0..<3
// #=> 10..<13
// #=> 20..<23
// #=> 30..<33
// #=> 40..<43
// #=> 50..<53
// #=> 60..<63

```

## Details

The shift rules work using a skip table.

As necessity requires this package will be updated to support other search techniques.
