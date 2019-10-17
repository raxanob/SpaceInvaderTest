/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
import UIKit
import SpriteKit

class GameOverScene: SKScene {
  
  // Private GameScene Properties
  
  var contentCreated = false
  
  // Object Lifecycle Management
  
  // Scene Setup and Content Creation
  
  override func didMove(to view: SKView) {
    
    if (!self.contentCreated) {
      self.createContent()
      self.contentCreated = true
    }
  }
  
  func createContent() {
    
    let gameOverLabel = SKLabelNode(fontNamed: "Galvji")
    gameOverLabel.fontSize = 50
    gameOverLabel.fontColor = SKColor.systemYellow
    gameOverLabel.text = "Game"
    gameOverLabel.fontName = "Silkscreen Expanded"
    gameOverLabel.position = CGPoint(x: self.size.width/2, y: 2.0 / 3.0 * self.size.height);
    
    self.addChild(gameOverLabel)
    
    let gameOverLabel2 = SKLabelNode(fontNamed: "Galvji")
    gameOverLabel2.fontSize = 50
    gameOverLabel2.fontColor = SKColor.white
    gameOverLabel2.text = "Over!"
    gameOverLabel2.fontName = "Silkscreen Expanded"
    gameOverLabel2.position = CGPoint(x: self.size.width/2, y: 2.0 / 3.5 * self.size.height);
    
    self.addChild(gameOverLabel2)
    
    let labelReturnGame = SKLabelNode(fontNamed: "Galvji")
    labelReturnGame.fontSize = 17
    labelReturnGame.fontColor = SKColor.white
    labelReturnGame.text = "Toque para jogar novamente"
    labelReturnGame.position = CGPoint(x: self.size.width/2, y: gameOverLabel.frame.origin.y - gameOverLabel.frame.size.height - 200);
    labelReturnGame.fontColor = SKColor.black

    
    self.addChild(labelReturnGame)
    
    let labelReturnMain = SKLabelNode(fontNamed: "Galvji")
    labelReturnMain.fontSize = 17
    labelReturnMain.fontColor = SKColor.white
    labelReturnMain.text = "Toque para ir para a tela inicial"
    labelReturnMain.position = CGPoint(x: self.size.width/2, y: gameOverLabel.frame.origin.y - gameOverLabel.frame.size.height - 250);
    labelReturnMain.fontColor = SKColor.black

    
    self.addChild(labelReturnMain)
    
    // black space color
    self.backgroundColor = SKColor.black
    
    let buttonReturnGame = SKSpriteNode()
    buttonReturnGame.name = "btn"
    buttonReturnGame.color = SKColor.systemPink
    buttonReturnGame.size.height = 30
    buttonReturnGame.size.width = UIScreen.main.bounds.size.width - 40
    buttonReturnGame.position = CGPoint(x: labelReturnGame.frame.midX, y: labelReturnGame.frame.midY)
    
    self.addChild(buttonReturnGame)
    
    let buttonReturnMain = SKSpriteNode()
    buttonReturnMain.name = "btn2"
    buttonReturnMain.color = SKColor.systemGreen
    buttonReturnMain.size.height = 30
    buttonReturnMain.size.width = UIScreen.main.bounds.size.width - 40
    buttonReturnMain.position = CGPoint(x: labelReturnGame.frame.midX, y: labelReturnMain.frame.midY)
    
    self.addChild(buttonReturnMain)
    
  }
  
    
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let touch = touches.first
    let positionInScene = touch!.location(in: self)
    let touchedNode = self.atPoint(positionInScene)
    
    if let name = touchedNode.name {
        if name == "btn" {

            let gameScene = GameScene(size: self.size)
            gameScene.scaleMode = .aspectFill
            
            self.view?.presentScene(gameScene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))

          }
        if name == "btn2"{
            let gameScene = MainSceneTest(size: self.size)
            gameScene.scaleMode = .aspectFill
            
            self.view?.presentScene(gameScene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))
        }
      }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)  {
    
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)  {

    
  }

}
