//
//  LanguageManager.swift
//  SwiftTest
//
//  Created by user on 2026/2/28.
//
// 获取当前语言及数字代码映射

import Foundation

class LanguageManager {
    
    // 语言数字代码映射
    static let languageCodes: [String: Int] = [
        // 中文
        "zh": 1,
        "zh-Hans": 1, //中文（简体）—— Hans 代表 Han Simplified
        "zh-CN": 1, //中文（中国大陆）
        "zh-SG": 1, //中文（新加坡）
        
        //中文繁体
        "zh-Hant": 1, //Hant 代表 Han Traditional
        "zh-TW": 1, //中文（中国台湾）
        "zh-HK": 1, //中文（中国香港）
        
        // 英语
        "en": 0,
        "en-US": 0,
        "en-GB": 0,
        "en-AU": 0,
        
        // 日语
        "ja": 4,
        "ja-JP": 4,
        
//        // 韩语
//        "ko": 5,
//        "ko-KR": 5,
        
        // 法语
        "fr": 6,
        "fr-FR": 6,
        "fr-CA": 6,
        
        // 德语
        "de": 7,
        "de-DE": 7,
        "de-AT": 7,
        
        // 西班牙语
        "es": 8,
        "es-ES": 8,
        "es-MX": 8,
        
        // 俄语
        "ru": 9,
        "ru-RU": 9,
        
        // 其他常见语言
        "it": 10,      // 意大利语
//        "pt": 11,      // 葡萄牙语
//        "nl": 12,      // 荷兰语
//        "sv": 13,      // 瑞典语
//        "da": 14,      // 丹麦语
//        "fi": 15,      // 芬兰语
//        "no": 16,      // 挪威语
//        "pl": 17,      // 波兰语
//        "cs": 18,      // 捷克语
//        "hu": 19,      // 匈牙利语
//        "tr": 20,      // 土耳其语
//        "ar": 21,      // 阿拉伯语
//        "he": 22,      // 希伯来语
//        "th": 23,      // 泰语
//        "vi": 24,      // 越南语
//        "id": 25,      // 印尼语
//        "ms": 26,      // 马来语
//        "hi": 27       // 印地语
    ]
    
    /// 获取当前语言的数字代码
    static var currentLanguageCode: Int {
        let preferredLang = Bundle.main.preferredLocalizations.first ?? "en"
        return languageCode(for: preferredLang)
    }
    
    /// 根据语言字符串获取数字代码
    static func languageCode(for language: String) -> Int {
        // 直接匹配完整语言代码
        if let code = languageCodes[language] {
            return code
        }
        
        // 匹配基础语言代码
        let baseLang = language.components(separatedBy: "-").first ?? language
        return languageCodes[baseLang] ?? 0 // 0表示未知
    }
    
    /// 获取当前语言的数字代码（带日志）
    static func logCurrentLanguageCode() {
        let preferredLang = Bundle.main.preferredLocalizations.first ?? "unknown"
        let code = languageCode(for: preferredLang)
        Log.debug("当前语言: \(preferredLang), 数字代码: \(code)")
    }
}

