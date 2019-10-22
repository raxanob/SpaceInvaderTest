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

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  // Private GameScene Properties
      
    var ship: SKSpriteNode = SKSpriteNode(imageNamed: "nave.png")
    
    let heart0: SKSpriteNode = SKSpriteNode(imageNamed: "coracao.png")
    
    let heart1: SKSpriteNode = SKSpriteNode(imageNamed: "coracao.png")
    
    let heart2: SKSpriteNode = SKSpriteNode(imageNamed: "coracao.png")
    
    var shipFireTimer: Timer?
    
    var contentCreated = false
      
      // 1
    var invaderMovementDirection: InvaderMovementDirection = .right
      // 2
    var timeOfLastMove: CFTimeInterval = 0.0
      // 3
    var timePerMove: CFTimeInterval = 0.5
      
    var tapQueue = [Int]()
    var contactQueue = [SKPhysicsContact]()
      
    var shipHealth: Float = 1.0
        
    let kMinInvaderBottomHeight: Float = 40.0
    var gameEnding: Bool = false
  
  enum InvaderType {
    case a
    case b
    case c
    
    static var size: CGSize {
      return CGSize(width: 24, height: 16)
    }
    
    static var name: String {
      return "invader"
    }
  }
  
  enum InvaderMovementDirection {
    case right
    case left
    case downThenRight
    case downThenLeft
    case none
  }
  
  enum BulletType {
    case shipFired
    case invaderFired
  }
  
  let kInvaderGridSpacing = CGSize(width: 12, height: 12)
  let kInvaderRowCount = 6
  let kInvaderColCount = 6
  
  let kShipSize = CGSize(width: 30, height: 16)
  let kShipName = "nave"
  
  let kHealthHudName = "healthHud"
  
  let kShipFiredBulletName = "shipFiredBullet"
  let kInvaderFiredBulletName = "invaderFiredBullet"
  let kBulletSize = CGSize(width:4, height: 8)
  
  let kInvaderCategory: UInt32 = 0x1 << 0
  let kShipFiredBulletCategory: UInt32 = 0x1 << 1
  let kShipCategory: UInt32 = 0x1 << 2
  let kSceneEdgeCategory: UInt32 = 0x1 << 3
  let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4
  
  // Object Lifecycle Management
  
  // Scene Setup and Content Creation
  
  override func didMove(to view: SKView) {
    
    if (!self.contentCreated) {
      self.createContent()
      self.contentCreated = true
      physicsWorld.contactDelegate = self
    }
  }
  
  func createContent() {
    physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    physicsBody!.categoryBitMask = kSceneEdgeCategory
    
    shipFireTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {_ in
        self.fireShipBullets()
    }
    
    setupInvaders()
    setupShip()
    setupHud()
    
    // black space color
    self.backgroundColor = SKColor.black
  }
  
  func loadInvaderTextures(ofType invaderType: InvaderType) -> [SKTexture] {
    
    var prefix: String
    
    switch(invaderType) {
    case .a:
        prefix = "Rosa"
    case .b:
        prefix = "Verde"
    case .c:
        prefix = "Rosa"
    }
    
    // 1
    return [SKTexture(imageNamed: String(format: "%@_00.png", prefix)),
            SKTexture(imageNamed: String(format: "%@_01.png", prefix))]
  }

  func makeInvader(ofType invaderType: InvaderType) -> SKNode {
    let invaderTextures = loadInvaderTextures(ofType: invaderType)
    
    // 2
    let invader = SKSpriteNode(texture: invaderTextures[0])
    invader.name = InvaderType.name
    
    // 3
    invader.run(SKAction.repeatForever(SKAction.animate(with: invaderTextures, timePerFrame: timePerMove)))
    
    // invaders' bitmasks setup
    invader.physicsBody = SKPhysicsBody(rectangleOf: invader.frame.size)
    invader.physicsBody!.isDynamic = false
    invader.physicsBody!.categoryBitMask = kInvaderCategory
    invader.physicsBody!.contactTestBitMask = 0x0
    invader.physicsBody!.collisionBitMask = 0x0
    
    return invader
  }
  
  func setupInvaders() {
    // 1
    let baseOrigin = CGPoint(x: size.width / 3, y: size.height / 2)
    
    for row in 0..<kInvaderRowCount {
      // 2
      var invaderType: InvaderType
      
      if row % 2 == 0 {
        invaderType = .a
      } else {
        invaderType = .b
      }
      
      // 3
      let invaderPositionY = CGFloat(row) * (InvaderType.size.height * 2) + baseOrigin.y
      
      var invaderPosition = CGPoint(x: baseOrigin.x, y: invaderPositionY)
      
      // 4
      for _ in 1..<kInvaderRowCount {
        // 5
        let invader = makeInvader(ofType: invaderType)
        invader.position = invaderPosition
        
        addChild(invader)
        
        invaderPosition = CGPoint(
          x: invaderPosition.x + InvaderType.size.width + kInvaderGridSpacing.width,
          y: invaderPositionY
        )
      }
    }
  }
  
  func setupShip() {
    // 1
    ship = makeShip() as! SKSpriteNode
    
    // 2
    ship.position = CGPoint(x: size.width / 2.0, y: kShipSize.height / 2.0)
    addChild(ship)
  }
  
  func makeShip() -> SKNode {
    ship = SKSpriteNode(imageNamed: "nave.png")
    ship.name = kShipName
    
    // 1
    ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)

    // 2
    ship.physicsBody!.isDynamic = true

    // 3
    ship.physicsBody!.affectedByGravity = false

    // 4
    ship.physicsBody!.mass = 0.02
    
    // 1
    ship.physicsBody!.categoryBitMask = kShipCategory
    // 2
    ship.physicsBody!.contactTestBitMask = 0x0
    // 3
    ship.physicsBody!.collisionBitMask = kSceneEdgeCategory
    
    return ship
  }
  
  func setupHud() {
    
    // 4
    let healthLabel = SKLabelNode(fontNamed: "slkscre")
    healthLabel.name = kHealthHudName
    healthLabel.fontSize = 20
    
    // 5
    healthLabel.fontColor = #colorLiteral(red: 1, green: 0.737254902, blue: 0.8431372549, alpha: 1)
    healthLabel.text = String(format: "Vida: ", shipHealth * 100.0)
    
    // 6
    healthLabel.position = CGPoint(
      x: frame.size.width - 100,
      y: size.height - (40 + healthLabel.frame.size.height/2)
    )
    addChild(healthLabel)
    
    // heart 0
    heart0.position = CGPoint(
        x: frame.size.width - 60,
        y: size.height - (33 + healthLabel.frame.size.height/2)
    )
    heart0.size = CGSize(width: 15, height: 15)
    addChild(heart0)
    
    // heart 1
    heart1.position = CGPoint(
        x: frame.size.width - 40,
        y: size.height - (33 + healthLabel.frame.size.height/2)
    )
    heart1.size = CGSize(width: 15, height: 15)
    addChild(heart1)
    
    // heart 2
    heart2.position = CGPoint(
        x: frame.size.width - 20,
        y: size.height - (33 + healthLabel.frame.size.height/2)
    )
    heart2.size = CGSize(width: 15, height: 15)
    addChild(heart2)

  }

  func adjustShipHealth(by healthAdjustment: Float) {
    // 1
    shipHealth = max(shipHealth + healthAdjustment, 0)
    
    if heart2.size == CGSize(width: 15, height: 15) {
        heart2.removeFromParent()
        heart2.size = CGSize(width: 0, height: 0)
    } else {
        heart1.removeFromParent()
    }
  }
  
  func makeBullet(ofType bulletType: BulletType) -> SKNode {
    var bullet: SKNode
    
    switch bulletType {
    
    case .shipFired:
      bullet = SKSpriteNode(color: SKColor.green, size: kBulletSize)
      bullet.name = kShipFiredBulletName
      
      bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
      bullet.physicsBody!.isDynamic = true
      bullet.physicsBody!.affectedByGravity = false
      bullet.physicsBody!.categoryBitMask = kShipFiredBulletCategory
      bullet.physicsBody!.contactTestBitMask = kInvaderCategory
      bullet.physicsBody!.collisionBitMask = 0x0
    
    case .invaderFired:
      bullet = SKSpriteNode(color: SKColor.magenta, size: kBulletSize)
      bullet.name = kInvaderFiredBulletName
      
      bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
      bullet.physicsBody!.isDynamic = true
      bullet.physicsBody!.affectedByGravity = false
      bullet.physicsBody!.categoryBitMask = kInvaderFiredBulletCategory
      bullet.physicsBody!.contactTestBitMask = kShipCategory
      bullet.physicsBody!.collisionBitMask = 0x0
      break
    }
    
    return bullet
  }
  
  // Scene Update
  
  func moveInvaders(forUpdate currentTime: CFTimeInterval) {
    // 1
    if (currentTime - timeOfLastMove < timePerMove) {
      return
    }
    
    determineInvaderMovementDirection()
    
    // 2
    enumerateChildNodes(withName: InvaderType.name) { node, stop in
      switch self.invaderMovementDirection {
      case .right:
        node.position = CGPoint(x: node.position.x + 10, y: node.position.y)
      case .left:
        node.position = CGPoint(x: node.position.x - 10, y: node.position.y)
      case .downThenLeft, .downThenRight:
        node.position = CGPoint(x: node.position.x, y: node.position.y - 10)
      case .none:
        break
      }
      
      // 3
      self.timeOfLastMove = currentTime
    }
  }
  
  func adjustInvaderMovement(to timePerMove: CFTimeInterval) {
    // 1
    if self.timePerMove <= 0 {
      return
    }
    
    // 2
    let ratio: CGFloat = CGFloat(self.timePerMove / timePerMove)
    self.timePerMove = timePerMove
    
    // 3
    enumerateChildNodes(withName: InvaderType.name) { node, stop in
      node.speed = node.speed * ratio
    }
  }
    
  
  func fireInvaderBullets(forUpdate currentTime: CFTimeInterval) {
    let existingBullet = childNode(withName: kInvaderFiredBulletName)
    
    // 1
    if existingBullet == nil {
      var allInvaders = [SKNode]()
      
      // 2
      enumerateChildNodes(withName: InvaderType.name) { node, stop in
        allInvaders.append(node)
      }
      
      if allInvaders.count > 0 {
        // 3
        let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
        
        let invader = allInvaders[allInvadersIndex]
        
        // 4
        let bullet = makeBullet(ofType: .invaderFired)
        bullet.position = CGPoint(
          x: invader.position.x,
          y: invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2
        )
        
        // 5
        let bulletDestination = CGPoint(x: invader.position.x, y: -(bullet.frame.size.height / 2))
        
        // 6
        fireBullet(
          bullet: bullet, 
          toDestination: bulletDestination, 
          withDuration: 2.0,
          andSoundFileName: "InvaderBullet.wav"
        )
      }
    }
  }
  
  func processContacts(forUpdate currentTime: CFTimeInterval) {
    for contact in contactQueue {
      handle(contact)
      
      if let index = contactQueue.firstIndex(of: contact) {
        contactQueue.remove(at: index)
      }
    }
  }
  
  override func update(_ currentTime: TimeInterval) {
    if isGameOver() {
      endGame()
    }
    
    moveInvaders(forUpdate: currentTime)
    fireInvaderBullets(forUpdate: currentTime)
    processContacts(forUpdate: currentTime)
  }
  
  
  // Invader Movement Helpers
  
  func determineInvaderMovementDirection() {
    // 1
    var proposedMovementDirection: InvaderMovementDirection = invaderMovementDirection
    
    // 2
    enumerateChildNodes(withName: InvaderType.name) { node, stop in
      
      switch self.invaderMovementDirection {
      case .right:
        //3
        if (node.frame.maxX >= node.scene!.size.width - 1.0) {
          proposedMovementDirection = .downThenLeft
          
          // Add the following line
          self.adjustInvaderMovement(to: self.timePerMove * 0.8)
          
          stop.pointee = true
        }
      case .left:
        //4
        if (node.frame.minX <= 1.0) {
          proposedMovementDirection = .downThenRight
          
          // Add the following line
          self.adjustInvaderMovement(to: self.timePerMove * 0.8)
          
          stop.pointee = true
        }
        
      case .downThenLeft:
        proposedMovementDirection = .left
        
        stop.pointee = true
        
      case .downThenRight:
        proposedMovementDirection = .right
        
        stop.pointee = true
        
      default:
        break
      }
      
    }
    
    //7
    if (proposedMovementDirection != invaderMovementDirection) {
      invaderMovementDirection = proposedMovementDirection
    }
  }
  
  // Bullet Helpers
  
  func fireBullet(bullet: SKNode, toDestination destination: CGPoint, withDuration duration: CFTimeInterval, andSoundFileName soundName: String) {
    // 1
    let bulletAction = SKAction.sequence([
      SKAction.move(to: destination, duration: duration),
      SKAction.wait(forDuration: 3.0 / 60.0),
      SKAction.removeFromParent()
      ])
    
    // 2
    let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
    
    // 3
    bullet.run(SKAction.group([bulletAction, soundAction]))
    
    // 4
    addChild(bullet)
  }

  func fireShipBullets() {
    let existingBullet = childNode(withName: kShipFiredBulletName)
    
    // 1
    if existingBullet == nil {
        if let ship = childNode(withName: kShipName){
        let bullet = makeBullet(ofType: .shipFired)
        // 2
        bullet.position = CGPoint(
          x: ship.position.x,
          y: ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2
        )
        // 3
        let bulletDestination = CGPoint(
          x: ship.position.x,
          y: frame.size.height + bullet.frame.size.height / 2
        )
        // 4
        fireBullet(
          bullet: bullet,
          toDestination: bulletDestination,
          withDuration: 1.0,
          andSoundFileName: "ShipBullet.wav"
        )
        } else {
            GameOverScene()
            print("tela de game over")
        }
    }
  }
    func touchDown(atPoint: CGPoint) {
      
      ship.position.x = atPoint.x
      }
  
    func touchMoved(toPoint: CGPoint) {
      ship.position.x = toPoint.x
      print(toPoint.y)
      
    }
  
    func touchUp (atPoint: CGPoint) {
      ship.position.x = atPoint.x
    }
  
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          for t in touches { touchDown(atPoint: t.location(in:self))
          }
    }
  
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      for t in touches { touchMoved(toPoint: t.location(in: self))}
    }
    
  // User Tap Helpers
  
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchUp(atPoint: t.location(in: self))}
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchUp(atPoint: t.location(in: self))}
    }
  
  // HUD Helpers
  
  // Physics Contact Helpers
  
  func didBegin(_ contact: SKPhysicsContact) {
    contactQueue.append(contact)
  }
  
  func handle(_ contact: SKPhysicsContact) {
    // Ensure you haven't already handled this contact and removed its nodes
    if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
      return
    }
    
    let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
    
    if nodeNames.contains(kShipName) && nodeNames.contains(kInvaderFiredBulletName) {
      // Invader bullet hit a ship
      run(SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false))
      
      // 1
      adjustShipHealth(by: -0.334)
      
      if shipHealth <= 0.0 {
        // 2
        contact.bodyA.node!.removeFromParent()
        contact.bodyB.node!.removeFromParent()
      } else {
        // 3
        ship = childNode(withName: kShipName) as! SKSpriteNode; do {
          ship.alpha = CGFloat(shipHealth)
          
          if contact.bodyA.node == ship {
            contact.bodyB.node!.removeFromParent()
            
          } else {
            contact.bodyA.node!.removeFromParent()
          }
        }
      }
      
    } else if nodeNames.contains(InvaderType.name) && nodeNames.contains(kShipFiredBulletName) {
      // Ship bullet hit an invader
      run(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))
      contact.bodyA.node!.removeFromParent()
      contact.bodyB.node!.removeFromParent()
      
    }
  }
  
  // Game End Helpers
  
  func isGameOver() -> Bool {
    // 1
    let invader = childNode(withName: InvaderType.name)
    
    // 2
    var invaderTooLow = false
    
    enumerateChildNodes(withName: InvaderType.name) { node, stop in
      
      if (Float(node.frame.minY) <= self.kMinInvaderBottomHeight)   {
        invaderTooLow = true
        stop.pointee = true
      }
    }
    
    // 3
    let ship = childNode(withName: kShipName)
    
    // 4
    return invader == nil || invaderTooLow || ship == nil
  }

  func endGame() {
    // 1
    if !gameEnding {
      
      gameEnding = true
      
      // 2
      let gameOverScene: GameOverScene = GameOverScene(size: size)
      
      view?.presentScene(gameOverScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
    }
  }
  
}
