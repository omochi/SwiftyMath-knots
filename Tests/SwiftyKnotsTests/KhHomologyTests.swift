//
//  KHTests.swift
//  SwiftyKnots
//
//  Created by Taketo Sano on 2018/04/04.
//

import XCTest
import SwiftyMath
import SwiftyHomology
@testable import SwiftyKnots

class HovanovHomologyTests: XCTestCase {
    
    typealias Kh = KhovanovHomology<𝐙>
    
    func testUnknot() {
        let K = Link.unknot
        let H = Kh(K)
        
        XCTAssertEqual(H.gradedEulerCharacteristic, JonesPolynomial(K, normalized: false))
        XCTAssertEqual(H[0, -1].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[0,  1].dictionaryDescription, [0 : 1])
    }
    
    func testUnknot_RM1() {
        let K = Link(planarCode: [1,2,2,1])
        let H = Kh(K)
        
        XCTAssertEqual(H[0, -1].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[0,  1].dictionaryDescription, [0 : 1])
    }

    func testUnknot_RM2() {
        let K = Link(planarCode: [1,4,2,1], [2,4,3,3])
        let H = Kh(K)

        XCTAssertEqual(H[0, -1].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[0,  1].dictionaryDescription, [0 : 1])
    }
    
    func test3_1_Z() {
        let K = Knot(3, 1)
        let H = Kh(K)
        
        XCTAssertEqual(H.gradedEulerCharacteristic, JonesPolynomial(K, normalized: false))
        
        XCTAssertEqual(H[-3, -9].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[-2, -7].dictionaryDescription, [2 : 1])
        XCTAssertEqual(H[-2, -5].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[-0, -3].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[-0, -1].dictionaryDescription, [0 : 1])
    }
    
    func test4_1_Z() {
        let K = Knot(4, 1)
        let H = Kh(K)
        
        XCTAssertEqual(H.gradedEulerCharacteristic, JonesPolynomial(K, normalized: false))
        
        XCTAssertEqual(H[-2, -5].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[-1, -3].dictionaryDescription, [2 : 1])
        XCTAssertEqual(H[-1, -1].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[ 0, -1].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[ 0, -1].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[ 1,  1].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[ 2,  3].dictionaryDescription, [2 : 1])
        XCTAssertEqual(H[ 2,  5].dictionaryDescription, [0 : 1])
    }
    
    func test5_1_Z() {
        let K = Knot(5, 1)
        let H = Kh(K)
        
        XCTAssertEqual(H[-5, -15].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[-4, -13].dictionaryDescription, [2 : 1])
        XCTAssertEqual(H[-4, -11].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[-3, -11].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[-2,  -9].dictionaryDescription, [2 : 1])
        XCTAssertEqual(H[-2,  -7].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[ 0,  -5].dictionaryDescription, [0 : 1])
        XCTAssertEqual(H[ 0,  -3].dictionaryDescription, [0 : 1])
    }
}
