//
// Created by Vladislav on 21/08/2017.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

open class Utils {
    private static let DAY_SEC :Int64 = 24 * 3600;
    private static let WEEK_SEC :Int64 = 7 * DAY_SEC;
    private static let MONTH_SEC :Int64 = 31 * DAY_SEC;
    private static let YEAR_SEC :Int64 = 12 * MONTH_SEC;
    
    public static let stageQueue = Queue(name: "stageQueue")!

    public static func currentTimeMillis() -> Int64 {
        let nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble*1000)
    }

    public static func printData(_ data:Data!) {
        print(data.map { String(format: "%02x", $0) }.joined())
    }
    
    public static func validatePassword(_ password:String) -> Bool {
        let matched = password.utf8.count >= 8
        return matched
    }
    
    public static func validateEmail(_ email:String) -> Bool {
        let regexStr = ".+@.+\\..+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regexStr)
        return predicate.evaluate(with: email)
    }
    
    public static func validateLogin(_ login:String) -> Bool {
        if login.utf8.count < 3 { return false }
        
        let regexStr = "^[a-zA-Z0-9-_\\.]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regexStr)
        return predicate.evaluate(with: login)
    }

    static func formatUserDataName(_ user:UserData) -> String {
        if (user.name != nil && user.surname != nil && !user.name!.isEmpty && !user.surname!.isEmpty) {
            return "\(user.name!) \(user.surname!)"
        } else {
            return user.login!
        }
    }
    
    static func formatUserName(_ user:RPC.UserObject) -> String {
        if (user.first_name != nil && user.last_name != nil && !user.first_name.isEmpty && !user.last_name.isEmpty) {
            return "\(user.first_name!) \(user.last_name!)"
        } else {
            return user.login!
        }
    }

    static func showSuccesHud(vc: UIViewController) {
        let hud = MBProgressHUD.showAdded(to: vc.view, animated: true)
        hud.mode = .customView
        hud.label.text = "Success".localized

        hud.customView = UIImageView(image: #imageLiteral(resourceName: "Checkmark"))
        hud.hide(animated: true, afterDelay: 2)
        
    }
    
    public static func formatMessageDateTime(timestamp:Int32) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        
        if User.timeFormatIs24 {
            dateFormatter.dateFormat = "HH:mm"
        } else {
            dateFormatter.dateFormat = "hh:mm a"
        }
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))

        let result = dateFormatter.string(from: date)
        
        return result
    }
    
    public static func formatTxInfoTime(timestamp:Int32) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        
        if User.timeFormatIs24 {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        }
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        let result = dateFormatter.string(from: date)
        
        return result
    }

    public static func formatDateTimeChatHeader(timestamp:Int32) -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        dateFormatter.locale = NSLocale.current
        
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateNow = Date()
        
        let yearDiff = calendar.component(.year, from: date) - calendar.component(.year, from: dateNow)
        let monthDiff = calendar.component(.month, from: date) - calendar.component(.month, from: dateNow)
        let dayDiff = calendar.component(.day, from: date) - calendar.component(.day, from: dateNow)
        let weekDiff = calendar.component(.weekOfMonth, from: date) - calendar.component(.weekOfMonth, from: dateNow)
        var pattern = ""
        
        if dayDiff == 0 && monthDiff == 0 && weekDiff == 0 && yearDiff == 0 {
            return "Today".localized
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday".localized
        } else if weekDiff != 0 && yearDiff == 0 || yearDiff == 0 && monthDiff < 0
            || yearDiff == 0 && monthDiff == 0 && weekDiff == 0  && dayDiff < 0 {
            pattern = "d MMM"
        } else if yearDiff != 0  {
            pattern = "dd.MM.yyyy"
        } else {
            pattern = "HH:mm"
        }
        
        if !User.timeFormatIs24 {
            pattern = pattern.replacingOccurrences(of: "HH:mm", with: "hh:mm a")
        }
        
        dateFormatter.dateFormat = pattern
        return dateFormatter.string(from: date)
    }
    
    public static func formatDateTime(timestamp:Int32) -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        dateFormatter.locale = NSLocale.current
        
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateNow = Date()
        
        let yearDiff = calendar.component(.year, from: date) - calendar.component(.year, from: dateNow)
        let monthDiff = calendar.component(.month, from: date) - calendar.component(.month, from: dateNow)
        let dayDiff = calendar.component(.day, from: date) - calendar.component(.day, from: dateNow)
        let weekDiff = calendar.component(.weekOfMonth, from: date) - calendar.component(.weekOfMonth, from: dateNow)
        var pattern = ""
        
        if dayDiff == 0 && monthDiff == 0 && weekDiff == 0 && yearDiff == 0 {
                pattern = "HH:mm"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday".localized
        } else if weekDiff != 0 && yearDiff == 0 || yearDiff == 0 && monthDiff < 0
            || yearDiff == 0 && monthDiff == 0 && weekDiff == 0  && dayDiff < 0 {
            pattern = "d MMM"
        } else if yearDiff != 0  {
            pattern = "dd.MM.yyyy"
        } else {
            pattern = "HH:mm"
        }
        
        if !User.timeFormatIs24 {
            pattern = pattern.replacingOccurrences(of: "HH:mm", with: "hh:mm a")
        }
        
        dateFormatter.dateFormat = pattern
        return dateFormatter.string(from: date)
    }
    
    public static func formatDateTimeCharts(timestamp:Int64, interval : String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        
        var result : String = ""
        
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        switch(interval) {
        case ExchangeRatesConst.hour, ExchangeRatesConst.day:
            if User.timeFormatIs24 {
                dateFormatter.dateFormat = "HH:mm"
            } else {
                dateFormatter.dateFormat = "hh:mm a"
            }
            break
        case ExchangeRatesConst.week, ExchangeRatesConst.oneMonth, ExchangeRatesConst.threeMonth, ExchangeRatesConst.sixMonth:
            dateFormatter.dateFormat = "d MMM"
            break
        case ExchangeRatesConst.year:
            dateFormatter.dateFormat = "d.MM.yy"
            break
        default:
            break
        }

        result = dateFormatter.string(from: date)
        
        return result
    }

    final class Box<T> {
        let value: T

        init(_ value: T) {
            self.value = value
        }
    }

    class Atomic<T:BinaryInteger> {
        private var queue = DispatchQueue(label: "ru.paymon.Atomic.queue")
        private (set) var value: T = 0

        func increment() {
            queue.sync {
                value += 1
            }
        }

        func incrementAndGet() -> T {
            queue.sync {
                value += 1
            }
            return value
        }

        func decrementAndGet() -> T {
            queue.sync {
                value -= 1
            }
            return value
        }
    }

    class Ref<T> {
        let value:T! = nil
    }
}

class SharedDictionary<K: Hashable, V> {
    public typealias Element = (key: K, value: V)

    public var dict: [K: V] = [:]

    subscript(key: K) -> V? {
        get {
            return dict[key]
        }
        set(newValue) {
            dict[key] = newValue
        }
    }
    public var count: Int {
        get {
            return dict.count
        }
    }
    public var keys: Dictionary<K, V>.Keys {
        get {
            return dict.keys
        }
    }
    public var values: Dictionary<K, V>.Values {
        get {
            return dict.values
        }
    }
    public var isEmpty: Bool {
        get {
            return dict.isEmpty
        }
    }
    public func removeAll(keepingCapacity keepCapacity: Bool = true) {
        dict.removeAll()
    }
    public func removeValue(forKey key: K) -> V? {
        return dict.removeValue(forKey: key)
    }
    public func value(forKey key: K) -> V? {
        return dict[key]
    }
//    public mutating func remove(at index: [K : V].Index) -> SharedDictionary.Element {
//        return remove(at: index)
//    }
}

class SharedArray<Element>:CustomStringConvertible {
    var array:[Element]=[]

    init() {}
    init(Type:Element.Type) {}
    init(fromArray:[Element]) { array = fromArray }
    init(_ values:Element ...) { array = values }

    var count:Int { return array.count }
    var isEmpty:Bool {
        get {
            return count == 0
        }
    }
    subscript (index:Int) -> Element {
        get { return array[index] }
        set { array[index] = newValue }
    }

    // allow short syntax to access array content
    // example:   myArrayRef[].map({ $0 + "*" })
    subscript () -> [Element] {
        get { return array }
        set { array = newValue }
    }

    var description:String { return "\(array)" }

    func append(_ newElement: Element) { array.append(newElement) }

    func remove(at: Int) -> Element {
        return array.remove(at: at)
    }
}

enum JSONError : Error {
    case UnknownKey
}
typealias JSONObject = [String: Any]
typealias JSONArray = [Any]
precedencegroup JSONObjectPrecedence {
    associativity: left
    higherThan: BitwiseShiftPrecedence
}

infix operator ~:JSONObjectPrecedence
infix operator ~~:JSONObjectPrecedence
//extension JSONObject {
extension Dictionary where Key == String, Value == Any {
//    public subscript(key: String) -> Value?

//    public func ~(left: [String: Any], right: String) throws -> JSONObject {
//        if let value = left[right] {
//            return value
//        } else {
//            throw JSONError.UnknownKey
//        }
//    }
    static func ~(left: [Key: Value], right: String) throws -> JSONObject {
        if let value = left[right] as? JSONObject {
            return value
        } else {
            throw JSONError.UnknownKey
        }
    }

    static func ~~(left: [Key: Value], right: String) throws -> JSONArray {
        if let value = left[right] as? JSONArray {
            return value
        } else {
            throw JSONError.UnknownKey
        }
    }
}

extension Array where Element == Any {
    static func ~(left: [Element], right: Int) throws -> JSONObject {
        if let value = left[right] as? JSONObject {
            return value
        } else {
            throw JSONError.UnknownKey
        }
    }

    static func ~~(left: [Element], right: Int) throws -> JSONArray {
        if let value = left[right] as? JSONArray {
            return value
        } else {
            throw JSONError.UnknownKey
        }
    }
}

extension String {
    func nsRange(fromRange range: Range<String.Index>) -> NSRange {
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from!),
                       length: utf16.distance(from: from!, to: to!))
    }

    func range(fromRange nsRange: NSRange) -> Range<String.Index>? {
        guard
                let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
                let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
                let from = String.Index(from16, within: self),
                let to = String.Index(to16, within: self)
                else { return nil }
        return from ..< to
    }

//    subscript(_ range: CountableRange<Int>) -> String {
//        let idx1 = index(startIndex, offsetBy: range.lowerBound)
//        let idx2 = index(startIndex, offsetBy: range.upperBound)
//        return String(self[idx1..<idx2])
//    }
//    var count: Int { return characters.count }
}

extension UIColor {
    public convenience init(r:UInt8, g:UInt8, b:UInt8, a:UInt8 = 255) {
        self.init(red: CGFloat(r) / CGFloat(255), green: CGFloat(g) / CGFloat(255), blue: CGFloat(b) / CGFloat(255), alpha: CGFloat(a) / CGFloat(255))
    }
}
