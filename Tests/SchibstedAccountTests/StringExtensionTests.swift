//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Testing
import Foundation

@testable import SchibstedAccount

@Suite
struct StringExtensionTests {
    @Test(arguments: [1, 10, 20, 30, 50, 100])
    func secureRandomStringLength(length: Int) throws {
        let sut = try #require(String.secureRandom(length: length))
        #expect(sut.count == length)
    }

    @Test
    func secureRandomStringZeroLength() {
        let sut = String.secureRandom(length: 0)
        #expect(sut == nil)
    }

    @Test
    func secureRandomStringNegativeLength() {
        let sut = String.secureRandom(length: -5)
        #expect(sut == nil)
    }

    @Test
    func secureRandomStringCharacterSet() throws {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

        for testLength in [1, 10, 50, 100] {
            let sut = try #require(String.secureRandom(length: testLength))
            let resultCharacterSet = CharacterSet(charactersIn: sut)
            #expect(allowedCharacters.isSuperset(of: resultCharacterSet))
        }
    }

    @Test
    func secureRandomStringUniqueness() {
        let results = (0..<100).compactMap { _ in String.secureRandom(length: 20) }

        #expect(results.count == 100)

        let uniqueResults = Set(results)
        #expect(uniqueResults.count == 100)
    }

    @Test
    func removeTrailingSlash() {
        #expect("https://example.com/".removeTrailingSlash() == "https://example.com")
        #expect("https://example.com".removeTrailingSlash() == "https://example.com")
        #expect("/path/to/resource/".removeTrailingSlash() == "/path/to/resource")
        #expect("/path/to/resource".removeTrailingSlash() == "/path/to/resource")
        #expect("/".removeTrailingSlash() == "")
        #expect("".removeTrailingSlash() == "")
        #expect("multiple//slashes/".removeTrailingSlash() == "multiple//slashes")
    }
}
