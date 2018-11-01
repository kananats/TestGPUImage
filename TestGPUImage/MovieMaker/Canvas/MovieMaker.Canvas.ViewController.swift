//
//  MovieMaker.Canvas.ViewController.swift
//  TestGPUImage
//
//  Created by s.kananat on 2018/11/01.
//  Copyright © 2018 s.kananat. All rights reserved.
//

import Foundation
import UIKit

extension MovieMaker.Canvas {
    final class ViewController: UIViewController {
        private lazy var button: UIButton = {
            let button = UIButton()
            button.setTitle("Record", for: .normal)
            button.addTarget { [weak self] _ in
                let vc = MovieMaker.Record.ViewController()
                self?.present(vc, animated: true)
            }
            
            return button
        }()
    }
}

extension MovieMaker.Canvas.ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.button)
        self.button.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
