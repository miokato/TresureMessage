//
//  ViewController.swift
//  TresureMessage
//
//  Created by mio kato on 2018/11/10.
//  Copyright © 2018 mio kato. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, UITextFieldDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var messageText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageText.delegate = self
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.scene = SCNScene()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // Tapしたときに位置を取得してAnchorを追加
    @objc func tapped(sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: sceneView) // location: CGPoint
        let hitTest = sceneView.hitTest(location, types: .existingPlaneUsingExtent) // hitTest: [ARHitTestResult]
        if !hitTest.isEmpty {
            let anchor = ARAnchor(transform: hitTest.first!.worldTransform) // simd_float4x4
            sceneView.session.add(anchor: anchor)
        }
    }
    
    // 平面が見つかった時に呼ばれる
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // ARPlaneAnchorだったら何もしない
        guard !(anchor is ARPlaneAnchor) else { return }
        
        // UITextFieldの処理はメインスレッドで動かさないと例外が発生する・・
        DispatchQueue.main.async {
            let textGeometry = SCNText(string: self.messageText.text, extrusionDepth: 0.03)
            textGeometry.font = UIFont(name: "HiraKakuProN-W6", size: 0.5)
            let textNode = SCNNode(geometry: textGeometry)
            textNode.scale = SCNVector3Make(0.1, 0.1, 0.1)
            let (min, max) = (textNode.boundingBox)
            let w = Float(max.x - min.x)
            let h = Float(max.y - min.y)
            textNode.pivot = SCNMatrix4MakeTranslation(w/2 + min.x, h/2 + min.y, 0)
            
            node.addChildNode(textNode)
            self.messageText.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
