//  PXChartBackgroundView.swift
//  PXLineChart_Swift
//  Created by Xin Peng on 2017/6/15.
//  Copyright © 2017年 EB. All rights reserved.

import UIKit
class PXChartBackgroundView: UIView {
    fileprivate var xAxisView: PXXview?
    fileprivate var yAxisView: PXYview?
    var delegate: PXLineChartViewDataSource?
    var axisAttributes: AxisAttributes?

    convenience init(_ xAxisView: PXXview, _ yAxisView: PXYview) {
        self.init()
        self.xAxisView = xAxisView
        self.yAxisView = yAxisView
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        isOpaque = false
    }

    override func draw(_ rect: CGRect) {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        drawLineAndPointsInRect(rect: rect)
    }

    func drawLineAndPointsInRect(rect: CGRect) {
        guard let yCon = delegate?.numberOfElementsCountWithAxisType(.AxisTypeY) else {
            return
        }
        var isPointHide = false
        if let wrapedpointHide = axisAttributes?.pointHide {
            isPointHide = wrapedpointHide
        }
        var isGridHide = false
        if let wrapedgridHide = axisAttributes?.gridHide {
            isGridHide = wrapedgridHide
        }
        if !isGridHide {
            let gridCon = yCon
            let isfirstYAsOrigin = false
            for i in 0..<gridCon {
                if let yElementlab = delegate?.elementWithAxisType(.AxisTypeY, i) {
                    var guidHeight: Float = 0
                    if i < gridCon - 1 {
                        let ylaterElementlab: UILabel = (delegate?.elementWithAxisType(.AxisTypeY, i+1))!
                        let pointY = yAxisView?.pointOfYcoordinate(ylaterElementlab.text!)
                        guidHeight = (yAxisView?.guidHeight(yElementlab.text, laterYxisValue: ylaterElementlab.text))!
                        let newRect = CGRect(x: 0, y: pointY ?? 0, width: self.frame.width, height: CGFloat(guidHeight))
                        var fillcolor = UIColor(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1)
                        if let customFillColor = axisAttributes?.gridColor {
                            fillcolor = customFillColor
                        }
                        if isfirstYAsOrigin {
                            if (i % 2 != 0) {
                                UIColor.clear.setFill()
                            } else {
                                fillcolor.setFill()
                            }
                        } else {
                            if (i % 2 == 0) {
                                UIColor.clear.setFill()
                            } else {
                                fillcolor.setFill()
                            }
                        }
                        let rectPath = UIBezierPath(rect: newRect)
                        rectPath.fill()
                    }
                }
            }

            guard let lines = delegate?.numberOfChartlines() else {
                return
            }
            for i in 0..<lines {
                let ctx = UIGraphicsGetCurrentContext()!
                let path = UIBezierPath()
                ctx.setLineWidth(2.5)
                if let points = delegate?.plotsOflineIndex(i),points.count > 0 {
                    let startPointItem = points.first!
                    let startX = xAxisView?.pointOfXcoordinate(startPointItem.px_pointXvalue()) ?? 0
                    let startY = yAxisView?.pointOfYcoordinate(startPointItem.px_pointYvalue()) ?? 0
                    let strokeColor = startPointItem.px_chartLineColor()
                    var start = CGPoint()
                    start = CGPoint(x: startX, y: startY)
                    path.move(to: start)
                    var endXPoint = CGPoint()
                    for j in 0..<points.count {
                        let pointitem = points[j]
                        let pointXvalue = pointitem.px_pointXvalue()
                        let pointYvalue = pointitem.px_pointYvalue()
                        let pointCenterX: CGFloat = xAxisView!.pointOfXcoordinate(pointXvalue)
                        let pointCenterY: CGFloat = yAxisView!.pointOfYcoordinate(pointYvalue)
                        
                        var pointButton: UIButton?
                        if !isPointHide {
                            pointButton = UIButton()
                            pointButton!.tag = j
                            let pointColor = pointitem.px_chartPointColor()
                            pointButton!.backgroundColor = pointColor
                            let pSize = pointitem.px_pointSize()
                            pointButton!.frame = CGRect(x: 0, y: 0, width: pSize.width, height: pSize.height)
                            pointButton!.center = CGPoint(x: pointCenterX, y: pointCenterY)
                            pointButton!.layer.masksToBounds = true
                            pointButton!.isUserInteractionEnabled = true
                            pointButton!.layer.cornerRadius = min(pSize.width, pSize.height)/2
                            pointButton?.action(.touchUpInside, operation: { [unowned self] (sender) in
                                self.pointDidSelect(i, subIndex: j)
                            })
                            addSubview(pointButton!)
                        }
                        let pFont = axisAttributes?.pointFont ?? UIFont.systemFont(ofSize: 12)
                        let attr = [NSAttributedString.Key.font: pFont]
                        let  buttonSize = (pointYvalue as NSString).size(withAttributes: attr)
                        let titlebutton = UIButton()
                        titlebutton.setTitle(pointYvalue, for: .normal)
                        let titleColor = pointitem.px_pointValueColor()
                        titlebutton.setTitleColor(titleColor, for: .normal)
                        titlebutton.titleLabel?.font = pFont
                        titlebutton.backgroundColor = UIColor.clear
                        titlebutton.tag = j
                        titlebutton.isUserInteractionEnabled = true
                        let yFactor = pointButton != nil ? pointButton!.frame.height/2 : 0
                        titlebutton.frame = CGRect(x: pointCenterX - buttonSize.width/2, y: pointCenterY-yFactor-5-buttonSize.height, width: buttonSize.width, height: buttonSize.height)
                        titlebutton.action(.touchUpInside, operation: { [unowned self] (sender) in
                            self.pointDidSelect(i, subIndex: j)
                        })
                        addSubview(titlebutton)
                        path.addLine(to: CGPoint(x: pointCenterX, y: pointCenterY))
                        endXPoint = CGPoint(x: pointCenterX, y: yAxisView!.pointOfYcoordinate("0"))
                    }
                    path.addLine(to: endXPoint)
                    let fillcolor = startPointItem.px_chartFillColor()
                    fillcolor.set()
                    ctx.addPath(path.cgPath)
                    ctx.fillPath()

                    strokeColor.set()
                    ctx.addPath(path.cgPath)
                    ctx.strokePath()
                }
            }
        }
    }

    func pointDidSelect(_ superIndex: Int, subIndex: Int) {
        delegate?.elementDidClickedWithPointSuperIndex(superIndex, subIndex)
    }
    func refresh() {
        setNeedsDisplay()
    }
}

extension UIButton {
    private struct PX_AssociatedKeys {
        static var operationKey  = "operationKey"
    }

    func action(_ withEvent: UIControl.Event, operation: ((UIButton) -> Void)) {
    }

    @objc func callAction(_ sender: UIButton) {
        let operation: ((UIButton) -> Void)? = objc_getAssociatedObject(self, &PX_AssociatedKeys.operationKey) as? ((UIButton) -> Void)
        if operation != nil {
            operation?(sender)
        }
    }
}
