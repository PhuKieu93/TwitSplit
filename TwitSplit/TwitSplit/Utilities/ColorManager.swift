//
//  ColorManager.swift
//  TwitSplit
//
//  Created by Kieu Minh Phu on 4/4/18.
//  Copyright © 2018 Kieu Minh Phu. All rights reserved.
//

import UIKit

struct Green {
    let fern = TwitColor.colorFromRGB(rgbValue: 0x6ABB72)
    let mountainMeadow = TwitColor.colorFromRGB(rgbValue: 0x3ABB9D)
    let chateauGreen = TwitColor.colorFromRGB(rgbValue: 0x4DA664)
    let blueStone = TwitColor.colorFromRGB(rgbValue: 0x026759)
    let grayNurse = TwitColor.colorFromRGB(rgbValue: 0xEBEEEB)
    let deYork = TwitColor.colorFromRGB(rgbValue: 0x90CE97)
    let algaeGreen = TwitColor.colorFromRGB(rgbValue: 0x99DEC3)
    let skeptic = TwitColor.colorFromRGB(rgbValue: 0xCBEAD9)
}

struct Blue {
    let havelockBlue = TwitColor.colorFromRGB(rgbValue: 0x4A90E2)
    let pictonBlue = TwitColor.colorFromRGB(rgbValue: 0x5CADCF)
    let mariner = TwitColor.colorFromRGB(rgbValue: 0x3585C5)
    let curiousBlue = TwitColor.colorFromRGB(rgbValue: 0x4590B6)
    let denim = TwitColor.colorFromRGB(rgbValue: 0x2F6CAD)
    let chambray = TwitColor.colorFromRGB(rgbValue: 0x485675)
    let blueWhale = TwitColor.colorFromRGB(rgbValue: 0x29334D)
}

struct Violet {
    let wisteria = TwitColor.colorFromRGB(rgbValue: 0x9069B5)
    let blueGem = TwitColor.colorFromRGB(rgbValue: 0x533D7F)
}

struct Yellow {
    let energy = TwitColor.colorFromRGB(rgbValue: 0xF2D46F)
    let turbo = TwitColor.colorFromRGB(rgbValue: 0xF7C23E)
}

struct Orange {
    let neonCarrot = TwitColor.colorFromRGB(rgbValue: 0xF79E3D)
    let sun = TwitColor.colorFromRGB(rgbValue: 0xEE7841)
    let buttercup = TwitColor.colorFromRGB(rgbValue: 0xF5A623)
}

struct Red {
    let venetianRed = TwitColor.colorFromRGB(rgbValue: 0xC80815)
    let terraCotta = TwitColor.colorFromRGB(rgbValue: 0xE66B5B)
    let valencia = TwitColor.colorFromRGB(rgbValue: 0xCC4846)
    let cinnabar = TwitColor.colorFromRGB(rgbValue: 0xDC5047)
    let wellRead = TwitColor.colorFromRGB(rgbValue: 0xB33234)
}

struct Gray {
    let primary_gray = TwitColor.colorFromRGB(rgbValue: 0x818181)
    let almondFrost = TwitColor.colorFromRGB(rgbValue: 0xA28F85)
    let dustyGray = TwitColor.colorFromRGB(rgbValue: 0x989898)
    let whiteSmoke = TwitColor.colorFromRGB(rgbValue: 0xEFEFEF)
    let iron = TwitColor.colorFromRGB(rgbValue: 0xD1D5D8)
    let ironGray = TwitColor.colorFromRGB(rgbValue: 0x75706B)
    let abbey = TwitColor.colorFromRGB(rgbValue: 0x575858)
    let alto = TwitColor.colorFromRGB(rgbValue: 0xD8D8D8)
    let gallery = TwitColor.colorFromRGB(rgbValue: 0xEBEBEB)
    let alabaster = TwitColor.colorFromRGB(rgbValue: 0xFAFAFA)
}

struct Black {
    let semiBlack = TwitColor.colorFromRGB(rgbValue: 0x4A4A4A)
}

// MARK: Color
struct TwitColor {
    
    static var green = Green()
    static var blue = Blue()
    static var violet = Violet()
    static var yellow = Yellow()
    static var orange = Orange()
    static var red = Red()
    static var gray = Gray()
    static var black = Black()
    
    static func colorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
