//
//  DocumentPlugin.swift
//  Runner
//
//  Created by Perol Notsf on 2023/7/28.
//

import Foundation
import FlutterMacOS

struct DocumentPlugin {
    static func bind(controller : FlutterViewController){
        let channel = FlutterMethodChannel(name: "com.perol.dev/save",
                                           binaryMessenger: controller.engine.binaryMessenger)
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "save"  {
                let args = call.arguments as? [String:Any]
                let data  = args?["data"] as! FlutterStandardTypedData
                let name = args?["name"] as! String
                let sData = Data(data.data)
                let album = name.contains("sanity") ? "pxez_sanity" : "pxez"
                // Always save to Downloads on macOS to avoid Photos TCC crashes
                saveToDownloads(sData, name: name, in: album)
                result(true)
                return
            } else if call.method == "permissionStatus" {
                // On macOS we save to Downloads only, no Photos permission needed.
                result(true)
                return
            } else if call.method == "requestPermission" {
                // No-op on macOS (Downloads only)
                result(true)
                return
            }
            result(false)
        })
    }
    
    static func saveToDownloads(_ data: Data, name: String, in dir: String) {
        let downloads = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
        var targetDir = downloads.appendingPathComponent(dir, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: targetDir, withIntermediateDirectories: true)
        } catch {
            // ignore
        }
        // Support nested subfolders in name (e.g. "user_id/filename.jpg")
        let parts = name.split(separator: "/").map { String($0) }
        var folder = targetDir
        if parts.count > 1 {
            for i in 0..<(parts.count - 1) {
                folder = folder.appendingPathComponent(parts[i], isDirectory: true)
            }
            do { try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true) } catch {}
        }
        let fileUrl = folder.appendingPathComponent(parts.last ?? name)
        do { try data.write(to: fileUrl) } catch {}
    }

}
