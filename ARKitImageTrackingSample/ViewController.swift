//
//  ViewController.swift
//  ARKitImageTrackingSample
//
//  Created by 陰山賢太 on 2019/05/21.
//  Copyright © 2019 Kageken. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!

    let img = UIImage(named: "R18mark")
    
    //AR Resourcesに目的の画像が埋め込まれている
    let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages!

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    var arNode = SCNNode()
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let imageAnchor = anchor as? ARImageAnchor {
            //目的の画像に青い面を被せる
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = img
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            arNode.addChildNode(planeNode)
        }
     
        return arNode
    }

    var currentPos: SCNVector3?
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let nPos = node.worldPosition // node position
        let nRot = node.eulerAngles
        let cPos = (sceneView.pointOfView?.worldPosition)! // camera position
        let worldPosStr = "node position: (\(nPos.x.prec2)m \(nPos.y.prec2)m \(nPos.z.prec2)m)"
        let rotStr = "rotation: (\(nRot.x.rad2deg.prec2)° \(nRot.y.rad2deg.prec2)° \(nRot.z.rad2deg.prec2)°)"
        let cameraPosStr = "camera position: (\(cPos.x.prec2)m \(cPos.y.prec2)m \(cPos.z.prec2)m)"
        let distanceStr = "distance from camera: \(calcScenePositionDistance(cPos, nPos).prec2)m"
        DispatchQueue.main.async {
            self.textView.text = "\(worldPosStr)\n\(rotStr)\n\(cameraPosStr)\n\(distanceStr)"
        }
        currentPos = nPos
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

    //MARK: - action
    var firstPos: SCNVector3?
    var secondPos: SCNVector3?
    @IBAction func tappedButton(_ sender: Any) {
        if currentPos != nil {
            if firstPos == nil {
                firstPos = currentPos
                self.button.setTitle("Set Destination", for: .normal)
            } else if secondPos == nil {
                secondPos = currentPos
                let dist = calcScenePositionDistance(firstPos!, secondPos!)
                self.button.setTitle("move \(dist)m", for: .normal)
            } else {
                firstPos = nil
                secondPos = nil
                button.setTitle("Set Start Position", for: .normal)
            }
        }
    }
    
    //MARK: - positionの計算
    private func calcScenePositionDistance(_ posA: SCNVector3, _ posB: SCNVector3) -> Float {
        return GLKVector3Distance(SCNVector3ToGLKVector3(posA), SCNVector3ToGLKVector3(posB))
    }

    //MARK: - setup
    private func setup() {
        self.textView.text = "node position:\nrotation:\ncamera position:\ndistance from camera:"
        self.button.setTitle("Set Start Position", for: .normal)
    }
}

extension Float {
    var prec2: String {
        return String(format: "%.2f", self)
    }
    var rad2deg: Float {
        return self * 64.6972
    }
}
