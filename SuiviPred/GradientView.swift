//
//  GradientView.swift
//  SuiviPred
//
//  Created by Jeremie Chaine on 04/06/2017.
//  Copyright © 2017 Jeremie Chaine. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    @IBInspectable var firstColor : UIColor = UIColor.clear {
        didSet{
            updateView()
        }
    }
    
    @IBInspectable var secondColor : UIColor = UIColor.clear {
        didSet{
            updateView()
        }
    }
    
    override class var layerClass: AnyClass{
        get {
            return CAGradientLayer.self
        }
    }
    
    func updateView(){
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor.cgColor, secondColor.cgColor]
        layer.locations = [0.0625]
    }

}
