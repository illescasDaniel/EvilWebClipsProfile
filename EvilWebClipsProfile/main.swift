//
//  main.swift
//  EvilWebClipsProfile
//
//  Created by Daniel Illescas Romero on 21/09/2017.
//  Copyright © 2017 Daniel Illescas Romero. All rights reserved.
//

import AppKit

let myProfile = EvilWebClipsProfile(profileName: "pass2WithIcon",
                                    url: "https://www.google.com",
                                    alias: "Daniel",
                                    clipsCount: 2,
                                    password: "1234",
                                    iconPath: "/Users/Daniel/Downloads/Icons/1465621530_laptop.png")

myProfile.save(to: "/Users/Daniel/Desktop")
