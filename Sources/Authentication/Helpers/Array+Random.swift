extension Array where Element == UInt8 {
    static func random(count: Int) -> [Element] {
        var array: [Element] = .init(repeating: 0, count: count)
        for index in 0..<count {
            array[index] = Element.random(in: .min ... .max)
        }
        return array
    }
}
