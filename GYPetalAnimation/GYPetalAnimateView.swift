//
//  GYPetalAnimateView.swift
//  GYPetalAnimation
//
//  Created by GY on 2019/7/4.
//  Copyright © 2019 GY. All rights reserved.
//

import UIKit

class GYPetalAnimateView: UIView {
    
    /// 花瓣数量
    var petalCount: Int = 6
    /// 花瓣最大半径
    var petalMaxRadius: CGFloat = 80
    /// 花瓣最小半径
    var petalMinRadius: CGFloat = 24
    /// 动画总时间
    var animationDuration: Double = 10.5
    /// 第一朵花瓣的颜色
    /// 设定好第一朵花瓣和最后一朵花瓣的颜色后，如果花瓣数量大于2，那么中间花瓣的颜色将根据这两个颜色苹果进行平均过渡
    var firstPetalColor: (red: Float, green: Float, blue: Float, alpha: Float) = (0.17, 0.59, 0.60, 1)
    /// 最后一朵花瓣的颜色
    var lastPetalColor: (red: Float, green: Float, blue: Float, alpha: Float) = (0.31, 0.85, 0.62, 1)
    
    lazy private var containerLayer: CAReplicatorLayer = {
        
        let layer = CAReplicatorLayer()
        layer.instanceCount = petalCount
        layer.instanceColor = UIColor(red: CGFloat(firstPetalColor.red),
            green: CGFloat(firstPetalColor.green),
            blue: CGFloat(firstPetalColor.blue),
            alpha: CGFloat(firstPetalColor.alpha)
            ).cgColor
        layer.instanceRedOffset = (lastPetalColor.red - firstPetalColor.red) / Float(petalCount)
        layer.instanceGreenOffset = (lastPetalColor.green - firstPetalColor.green) / Float(petalCount)
        layer.instanceBlueOffset = (lastPetalColor.blue - firstPetalColor.blue) / Float(petalCount)
        layer.instanceTransform = CATransform3DMakeRotation(-CGFloat.pi * 2 / CGFloat(petalCount), 0, 0, 1)
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerLayer.frame = self.bounds
    }
    
    /// 设置视图背景色, 将花瓣容器Layer添加到视图的Layer中
    private func setupView() {
        backgroundColor = UIColor.black
        layer.addSublayer(containerLayer)
    }
    
    /// 创建花瓣图层
    /// - Parameters:
    ///     - center: 花瓣中心点
    ///     - radius: 花瓣半径
    /// - Returns: 花瓣图层
    private func createPetal(center: CGPoint, reduis: CGFloat) -> CAShapeLayer {
        
        let petal = CAShapeLayer()
        petal.fillColor = UIColor.white.cgColor
        let path = UIBezierPath(arcCenter: center, radius: reduis, startAngle: 0.0, endAngle: CGFloat(2 * Float.pi), clockwise: true)
        petal.path = path.cgPath
        // 混合模式
        petal.compositingFilter = "screenBlendMode"
        petal.frame = CGRect.init(x: 0, y: 0, width: containerLayer.bounds.width, height: containerLayer.bounds.height)
        return petal
    }
    
    /// 开始动画
    /// 花瓣开始展开和收回
    func animate() {
        containerLayer.transform = CATransform3DIdentity
        containerLayer.sublayers?.forEach({
             $0.removeFromSuperlayer()
        })
        
        let petalLayer = createPetal(center: CGPoint.init(x: containerLayer.bounds.width / 2, y: containerLayer.bounds.height / 2), reduis: petalMinRadius)
        containerLayer.addSublayer(petalLayer)
        
        let moveAnimation = CAKeyframeAnimation(keyPath: "position.x")
        moveAnimation.values = [petalLayer.position.x,
                petalLayer.position.x - petalMaxRadius,
                petalLayer.position.x - petalMaxRadius,
                petalLayer.position.x]
        moveAnimation.keyTimes = [0.1, 0.4, 0.5, 0.95]
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1, petalMaxRadius/petalMinRadius, petalMaxRadius/petalMinRadius, 1]
        scaleAnimation.keyTimes = [0.1, 0.4, 0.5, 0.95]
        
        let petalAnimationGroup = CAAnimationGroup()
        petalAnimationGroup.duration = animationDuration
        petalAnimationGroup.repeatCount = .infinity
        petalAnimationGroup.animations = [moveAnimation,scaleAnimation]
        
        petalLayer.add(petalAnimationGroup, forKey: nil)
        
        // 旋转
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotateAnimation.duration = animationDuration
        rotateAnimation.repeatCount = .infinity
        rotateAnimation.values = [
                -CGFloat.pi * 2 / CGFloat(petalCount),
                -CGFloat.pi * 2 / CGFloat(petalCount),
                 CGFloat.pi * 2 / CGFloat(petalCount),
                 CGFloat.pi * 2 / CGFloat(petalCount),
                -CGFloat.pi * 2 / CGFloat(petalCount)]
        rotateAnimation.keyTimes = [0, 0.1, 0.4, 0.5, 0.95]
        containerLayer.add(rotateAnimation, forKey: nil)
        
        // 添加虚影
        let shadowLayer = createPetal(center: CGPoint.init(x: containerLayer.bounds.width / 2 - petalMaxRadius, y: containerLayer.bounds.height / 2), reduis: petalMaxRadius)
        containerLayer.addSublayer(shadowLayer)
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.0, 0.3, 0.0]
        opacityAnimation.keyTimes = [0.45, 0.5, 0.8]
        
        let shadowScaleAnimation = CAKeyframeAnimation(keyPath: "position.scale")
        shadowScaleAnimation.values = [1.0, 1.0, 0.78]
        shadowScaleAnimation.keyTimes = [0.0, 0.5, 0.8]
        
        let shadowAnimationGroup = CAAnimationGroup()
        shadowAnimationGroup.duration = animationDuration
        shadowAnimationGroup.repeatCount = .infinity
        shadowAnimationGroup.animations = [opacityAnimation, shadowScaleAnimation]
        shadowLayer.add(shadowAnimationGroup, forKey: nil)
        
    }
    
    // 停止动画 移除控件
    func stopAnimate() {
        containerLayer.sublayers?.forEach({
            $0.removeAllAnimations()
        })
    }
}
