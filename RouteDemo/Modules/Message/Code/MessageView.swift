//
//  MessageView.swift
//  Message
//
//  Created by Ekko on 2023/8/7.
//

import UIKit

class MessageView: UIView {
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "message"
        label.backgroundColor = .gray
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        self.addSubview(textLabel)
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel.sizeToFit()
        textLabel.center = self.center
    }
}
