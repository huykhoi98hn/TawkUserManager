//
//  UIScrollView+Extensions.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 15/05/2022.
//

import UIKit

extension UIScrollView {
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.height + contentInset.bottom)
        setContentOffset(bottomOffset, animated: true)
    }
}
