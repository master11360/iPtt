//
//  ANSIMgr.swift
//  iPtt
//
//  Created by Ming on 2022/2/20.
//  Copyright © 2022 Ming. All rights reserved.
//

import Foundation

class AnsiParser {
    var isNeedEraseScreen = false
    private(set) var curResponse = ""
    
    func parse(_ str: String) {
        curResponse = str
        isNeedEraseScreen = eraseEntireScreenIfNeeded()
        removeColorCode()
//        result = removeCursorControlCode(result)
//        return result
    }
    
    func eraseEntireScreenIfNeeded() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "\\u001B\\u005B[2][J]", options: [.useUnicodeWordBoundaries])
            let match = regex.matches(in: curResponse, options: [], range: NSRange(location: 0, length: curResponse.count))
            guard !match.isEmpty, let range = match.first?.range else { return false }
            curResponse = String(curResponse[curResponse.index(curResponse.startIndex, offsetBy: range.upperBound)...])
            return true
        } catch {
            print("[test] regex error: \(error)")
            return false
        }
    }
    
    func removeColorCode() {
        do {
            let regex = try NSRegularExpression(pattern: "\\u001B\\u005B([0-9|22-29]*;*)*m", options: [.useUnicodeWordBoundaries])
//            let matches = regex.matches(in: str, options: [], range: NSRange(location: 0, length: str.count))
//            for match in matches {
//                print(str[str.index(str.startIndex, offsetBy: match.range.lowerBound)..<str.index(str.startIndex, offsetBy: match.range.upperBound)])
//            }
            curResponse = regex.stringByReplacingMatches(in: curResponse, options: [], range: NSRange(location: 0, length: curResponse.count), withTemplate: "")
        } catch {
            print("[test] regex error: \(error)")
        }
    }
    
    func removeCursorControlCode(_ str: String) -> String {
        var result = str
        do {
            let regex = try NSRegularExpression(pattern: "\\u001B\\u005B[H]", options: [.useUnicodeWordBoundaries])
            result = regex.stringByReplacingMatches(in: str, options: [], range: NSRange(location: 0, length: str.count), withTemplate: "")
        } catch {
            print("[test] regex error: \(error)")
        }
        return result
    }
    
    
    
    func isEscapeChar(_ char: Character) -> Bool {
        let unicodes = char.unicodeScalars
        guard unicodes.count == 1, let firstUnicode = unicodes.first else { return false }
        return firstUnicode.value == 0x1b
    }
    
    func isCSIChar(_ char: Character) -> Bool {
        let unicodes = char.unicodeScalars
        guard unicodes.count == 1, let firstUnicode = unicodes.first else { return false }
        return firstUnicode.value == 0x5b
    }
}
