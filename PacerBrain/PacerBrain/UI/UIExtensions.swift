//
//  UIExtensions.swift
//  PacerBrain
//
//  Created by Nicholas Dorn on 5/27/25.
//

import SwiftUI

/// A shared formatter (cache it for performance)
private let minuteSecondFormatter: DateComponentsFormatter = {
    let fmt = DateComponentsFormatter()
    fmt.allowedUnits = [.minute, .second]
    fmt.zeroFormattingBehavior = .pad       // “01:05” instead of “1:5”
    fmt.unitsStyle = .positional            // yields “MM:SS”
    return fmt
}()

extension TimeInterval {
    /// Formats self as “MM:SS”
    var minuteSecondString: String {
        minuteSecondFormatter.string(from: self) ?? "0:00"
    }
}
