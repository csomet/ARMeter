//
//  ViewController.swift
//  ARMeter
//
//  Created by Carlos Herrera Somet on 1/5/18.
//  Copyright © 2018 Carlos H Somet. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var nodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
  
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func setText(text: String, at position: SCNVector3){
        
        //clear previous text
        textNode.removeFromParentNode()
        
        let text3D = SCNText(string: text, extrusionDepth: 0.9)
        text3D.firstMaterial?.diffuse.contents = UIColor.blue
        textNode = SCNNode(geometry: text3D)
        textNode.position = position
        //reduce size 1% of original
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
    
    func calculate() {
        
        let start = nodes[0]
        let end   = nodes[1]
     
        //Pitagoras Ecuation. We need calculate a,b,c (3D) points.
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        //Ecuation:
        let distance = (sqrt(pow(a,2) + pow(b, 2) + pow(c, 2))) * 100
        
        setText(text: String(abs(distance)), at: end.position)

    }
    
    func addDot(at hitResult: ARHitTestResult){
        
        let spehere = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        spehere.materials = [material]
        
        let node = SCNNode(geometry: spehere)
        
        node.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
    
        sceneView.scene.rootNode.addChildNode(node)
        
        nodes.append(node)
        
        if nodes.count >= 2 {
            calculate()
        }
    }
    
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        for node in nodes {
            node.removeFromParentNode()
        }
        
        textNode.removeFromParentNode()
        nodes = [SCNNode]()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if nodes.count >= 2 {
            for node in nodes {
                node.removeFromParentNode()
            }
            
            nodes = [SCNNode]()
        }
        
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResult = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResult.first {
                addDot(at: hitResult)
            }
        }
    }
    
    
}
