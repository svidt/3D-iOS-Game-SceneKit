//
//  GameViewController.swift
//  3D iOS Game SceneKit
//
//  Created by Svidt on 20/04/2023.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    
    var gameView: SCNView!
    var gameScene: SCNScene!
    var cameraNode: SCNNode!
    var targetCreationTime: TimeInterval = 0
    var points: Int = 0
    let textGeometry: SCNText! = SCNText(string: "Score: " + "0", extrusionDepth: 0.0)
    var gameOver = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeView()
        initializeScene()
        initializeCamera()
        createScoreText()
       
        
    }

    func initializeView() {
        gameView = self.view as! SCNView
        gameView.autoenablesDefaultLighting = true
        gameView.delegate = self
    }
    
    func initializeScene(){
        gameScene = SCNScene()
        gameView.scene = gameScene
        gameView.isPlaying = true
    }
    
    func initializeCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x:0, y:6, z:12)
        gameScene.rootNode.addChildNode(cameraNode)
    }
    
    func createScoreText(){
        textGeometry.font = UIFont(name: "Arial", size: 0.5)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(x: -1, y: -1, z: 0)
        
        gameScene.rootNode.addChildNode(textNode)
    }
    
    func createCapsules(){
        let geometry: SCNGeometry = SCNCapsule(capRadius: 0.4, height: 2)
        var randomColor = UIColor.red
        let randomNumber = arc4random_uniform(4)
        if randomNumber == 0 {
            randomColor = UIColor.red
        } else if randomNumber == 1 {
            randomColor = UIColor.white
        } else if randomNumber == 2 {
            randomColor = UIColor.yellow
        } else {
            randomColor = UIColor.blue
        }
        
        geometry.materials.first?.diffuse.contents = randomColor
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        if randomColor == UIColor.red {
            geometryNode.name = "red"
        } else if randomColor == UIColor.white {
            geometryNode.name = "white"
        } else if randomColor == UIColor.yellow {
            geometryNode.name = "yellow"
        } else {
            geometryNode.name = "blue"
        }
        
        gameScene.rootNode.addChildNode(geometryNode)
        
        let randomDirection: Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        
        let force = SCNVector3(x: randomDirection, y: 20, z: 0)
        
        geometryNode.physicsBody?.applyForce(force, at: SCNVector3(x:0.05, y:0.05, z:0.05), asImpulse: true)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > targetCreationTime {
            
            if gameOver == false {
                createCapsules()
                textGeometry.string = "Score: " + "\(points)"
            } else {
                let gameOverTextGeometry: SCNText! = SCNText(string: "GAME OVER!", extrusionDepth: 0.0)
                gameOverTextGeometry.font = UIFont(name: "Arial", size: 0.8)
                gameOverTextGeometry.firstMaterial?.diffuse.contents = UIColor.red
                let gameOverTextNode = SCNNode(geometry: gameOverTextGeometry)
                gameOverTextNode.position = SCNVector3(x: -2.5, y: 5, z: 0)
                
                gameScene.rootNode.addChildNode(gameOverTextNode)
                
                textGeometry.string = "Score: " + "\(points)"
            }
            
            targetCreationTime = time + 0.4
        }
        
        cleanUp()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let location = touch.location(in: gameView)
        let hitList = gameView.hitTest(location, options: nil)
        if let hitObject = hitList.first {
            let node = hitObject.node
            
            if node.name == "blue" {
                if gameOver == false {
                    node.removeFromParentNode()
                    points = points + 1
                } else {
                    
                }
            } else {
                gameOver = true
            }
        }
    }
    
    // This function has the duty of cleaning up or removing the remaining capsules that fall below the screen to save memory.
    func cleanUp() {
        for node in gameScene.rootNode.childNodes {
            if node.presentation.position.y < 0 {
                node.removeFromParentNode()
            }
        }
    }
 

    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
}
