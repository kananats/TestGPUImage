//
//  Home.swift
//  MovieMaker
//
//  Created by s.kananat on 2018/11/14.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import UIKit
import AVFoundation

final class Home: UIViewController {
        
    // Temporary
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.addTarget { [weak self] _ in
            let vc = Canvas.ViewController()
            self?.present(vc, animated: true)
        }
        
        return button
    }()
    
    /// One-time layout initialization
    private lazy var makeLayout: () = {
        self.view.addSubview(self.button)
    }()
}

// Inheritance
extension Home {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = self.makeLayout
        
        self.updateLayout()
    }
}

// Private
extension Home {
    
    /// Update layout constraints
    func updateLayout() {
        self.button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
