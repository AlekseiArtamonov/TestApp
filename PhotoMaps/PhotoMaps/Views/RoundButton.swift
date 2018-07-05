//
//  RoundButton.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/3/18.
//  Copyright © 2018 test. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 0
        layer.cornerRadius = self.frame.size.width / 2
    }
}
