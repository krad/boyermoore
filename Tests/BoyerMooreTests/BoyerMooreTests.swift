import XCTest
@testable import BoyerMoore

class BoyerMooreTests: XCTestCase {
    
    func test_that_we_can_find_a_some_numbers() {

        let input: [UInt8] = [0,1,2,3,4,5,6,7,8,9]
        
        ////////////////////////////////////////////
        let sample         = Array(input[1...3])
        let result         = input.search(sample)
        XCTAssertNotNil(result)
        XCTAssertEqual(sample.count, 3)

        let grab = Array(input[result!])
        XCTAssertEqual(grab, sample)
        
        ////////////////////////////////////////////
        let sample2 = Array(input[4...6])
        let result2 = input.search(sample2)
        XCTAssertNotNil(result2)
        XCTAssertEqual(3, sample2.count)
        let grab2 = Array(input[result2!])
        XCTAssertEqual(grab2, sample2)

        ////////////////////////////////////////////
        let sample3 = Array(input[6...7])
        let result3 = input.search([6, 7])
        XCTAssertNotNil(result3)
        XCTAssertEqual(2, sample3.count)

        let grab3 = Array(input[result3!])
        XCTAssertEqual(grab3, sample3)

        ////////////////////////////////////////////
        let input2: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                               0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                               0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                               7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
                               0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                               0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                               0, 0, 0, 0, 0, 0, 0, 0, 0, 0,]
        
        let sample4 = Array(input2[30...32])
        let result4 = input2.search(sample4)
        XCTAssertNotNil(result4)
        XCTAssertEqual(3, sample4.count)

        let grab4 = Array(input2[result4!])
        XCTAssertEqual(grab4, sample4)
    }
    
    func test_that_we_can_find_structs() {

        // Build a random array of vertices
        var input  = stride(from: 1.0, to: 101.0, by: 1.0).map { Vertex(x: $0, y: $0 ) }
        XCTAssertEqual(100, input.count)

        // Take a sample of that array for simplicity sake
        let sample = Array(input[50...60])
        XCTAssertEqual(11, sample.count)

        let result = input.search(sample)
        XCTAssertNotNil(result)

        let grab = Array(input[result!])
        XCTAssertEqual(grab, sample)

    }

    func test_that_we_can_find_a_string() {
        let input = "we hold these truths to be self evident that all men are created equal"
        let result = input.search("truth")
        XCTAssertNotNil(result)
        let wtfApple = input.characters.enumerated().map { $0.element }[result!]
        let grab = String(wtfApple)
        XCTAssertEqual("truth", grab)
        
    }
    
    func test_that_we_can_iterate_over_every_instance_of_a_pattern() {
        let input: [UInt8] = [0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 7, 0, 0, 0, 0, 0, 0, 0,]

        var cnt = 0
        for range in input.searchAll([0, 0, 7]) {
            XCTAssertEqual(range.lowerBound, (cnt * 10))
            XCTAssertEqual(range.upperBound, (cnt * 10) + 3)
            cnt += 1
        }
        XCTAssertEqual(cnt, 7)
    }
    
    func test_that_we_can_iterate_over_every_instance_of_a_pattern_in_a_string() {
        
        let input: String = "Buffalo buffalo Buffalo buffalo buffalo buffalo Buffalo buffalo."
        var cnt = 0
        for _ in input.searchAll("buffalo") {
            cnt += 1
        }
        XCTAssertEqual(cnt, 5)
        
    }

    static var allTests = [
        ("test_that_we_can_find_a_some_numbers", test_that_we_can_find_a_some_numbers),
        ("test_that_we_can_find_structs", test_that_we_can_find_structs),
        ("test_that_we_can_find_a_string", test_that_we_can_find_a_string),
    ]
}


struct Vertex {
    var x: Float
    var y: Float
    
    var hashValue: Int {
        return x.hashValue + y.hashValue
    }
    
}

func ==(lhs: Vertex, rhs: Vertex) -> Bool {
    return (lhs.x == rhs.x && lhs.y == rhs.y)
}

extension Vertex: Hashable {}


