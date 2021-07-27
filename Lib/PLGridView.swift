//
//  PLGridView.swift
//  PLKit
//
//  Created by Plumk on 2020/11/21.
//  Copyright © 2020 Plumk. All rights reserved.
//

import UIKit


/// 根据方向 需要指定宽或高 否则不显示
class PLGridView: UIView {

    /// 布局方向
    var axis = NSLayoutConstraint.Axis.horizontal {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /// 横向代表多少列 纵向代表多少行
    var crossAxisCount: Int = 1 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /// 当前方向间距
    var mainAxisSpacing: CGFloat = 0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /// 反方向间距 横向则是纵向间距 纵向则是横向间距
    var crossAxisSpacing: CGFloat = 0 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    /// 宽高比率 横向 height / width 纵向 width / height
    var aspectRatio: CGFloat = 1 {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }
    
    var views = [UIView]() {
        didSet {
            self.reloadViews(self.views, oldViews: oldValue)
            self.setNeedsUpdateConstraints()
        }
    }
    
    private var innerContentSize: CGSize = .zero
    
    override var frame: CGRect {
        didSet {
            if !frame.size.equalTo(oldValue.size) {
                self.setNeedsUpdateConstraints()
            }
        }
    }
    
    init(_ views: [UIView]? = nil, axis: NSLayoutConstraint.Axis? = nil, crossAxisCount: Int? = nil, mainAxisSpacing: CGFloat? = nil, crossAxisSpacing: CGFloat? = nil) {
        super.init(frame: .zero)
        
        if let x = views {
            self.views = x
        }
        
        if let x = axis {
            self.axis = x
        }
        
        if let x = crossAxisCount {
            self.crossAxisCount = x
        }
        
        if let x = mainAxisSpacing {
            self.mainAxisSpacing = x
        }
        
        if let x = crossAxisSpacing {
            self.crossAxisSpacing = x
        }
        
        self.commInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commInit()
    }
    
    
    private func commInit() {
        self.clipsToBounds = true
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentHuggingPriority(.required, for: .vertical)
        
        self.reloadViews(self.views, oldViews: nil)
        
    }
    
    private func reloadViews(_ views: [UIView]?, oldViews: [UIView]?) {
        oldViews?.forEach({ $0.removeFromSuperview() })
        
        if let views = views {
            for view in views {
                view.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(view)
            }
        }
    }
     
    /// 移除旧的约束
    private func removeOldConstraints() {
        
        for view in self.views {
            view.constraints.forEach({
                if $0.isKind(of: PLConstraint.self) {
                    view.removeConstraint($0)
                }
            })
        }
        self.constraints.forEach({
            if $0.isKind(of: PLConstraint.self) {
                self.removeConstraint($0)
            }
        })
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        self.removeOldConstraints()
        
        switch self.axis {
        case .horizontal:
            self.horizontalLayout()
            
        case .vertical:
            self.verticalLayout()
            
        @unknown default:
            break
        }
    }
    
    private func horizontalLayout() {
        
        var constraints = [NSLayoutConstraint]()
        
        for (idx, view) in self.views.enumerated() {
            
            let preRow = max(0, idx - 1) / self.crossAxisCount
            let row = idx / self.crossAxisCount
            let nextRow = (idx + 1) / self.crossAxisCount
            if idx == 0 {
                constraints.append(PLConstraint.make(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
                constraints.append(PLConstraint.make(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
                constraints.append(PLConstraint.make(item: view, attribute: .height, relatedBy: .equal, toItem: view, attribute: .width, multiplier: self.aspectRatio, constant: 0))
            } else {
                
                let preView = self.views[idx - 1]

                constraints.append(PLConstraint.make(item: view, attribute: .width, relatedBy: .equal, toItem: preView, attribute: .width, multiplier: 1, constant: 0))
                constraints.append(PLConstraint.make(item: view, attribute: .height, relatedBy: .equal, toItem: preView, attribute: .height, multiplier: 1, constant: 0))

                if row != preRow {
                    constraints.append(PLConstraint.make(item: view, attribute: .top, relatedBy: .equal, toItem: preView, attribute: .bottom, multiplier: 1, constant: self.crossAxisSpacing))
                    constraints.append(PLConstraint.make(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
                } else {
                    constraints.append(PLConstraint.make(item: view, attribute: .top, relatedBy: .equal, toItem: preView, attribute: .top, multiplier: 1, constant: 0))
                    constraints.append(PLConstraint.make(item: view, attribute: .leading, relatedBy: .equal, toItem: preView, attribute: .trailing, multiplier: 1, constant: self.mainAxisSpacing))
                }
            }
            
            
            if nextRow != row {
                constraints.append(PLConstraint.make(item: view, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant:0))
            }
            
        }
        
        constraints.append(PLConstraint.make(item: self, attribute: .bottom, relatedBy: .equal, toItem: views.last, attribute: .bottom, multiplier: 1, constant: 0, priority: .defaultLow))
        self.addConstraints(constraints)
    }
    
    private func verticalLayout() {
        var constraints = [NSLayoutConstraint]()
        
        for (idx, view) in self.views.enumerated() {
            
            let preColumn = max(0, idx - 1) / self.crossAxisCount
            let column = idx / self.crossAxisCount
            let nextColumn = (idx + 1) / self.crossAxisCount
            if idx == 0 {
                constraints.append(PLConstraint.make(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
                constraints.append(PLConstraint.make(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
                constraints.append(PLConstraint.make(item: view, attribute: .width, relatedBy: .equal, toItem: view, attribute: .height, multiplier: self.aspectRatio, constant: 0))
            } else {
                
                let preView = self.views[idx - 1]

                constraints.append(PLConstraint.make(item: view, attribute: .width, relatedBy: .equal, toItem: preView, attribute: .width, multiplier: 1, constant: 0))
                constraints.append(PLConstraint.make(item: view, attribute: .height, relatedBy: .equal, toItem: preView, attribute: .height, multiplier: 1, constant: 0))

                if column != preColumn {
                    constraints.append(PLConstraint.make(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
                    constraints.append(PLConstraint.make(item: view, attribute: .leading, relatedBy: .equal, toItem: preView, attribute: .trailing, multiplier: 1, constant: self.crossAxisSpacing))
                } else {
                    constraints.append(PLConstraint.make(item: view, attribute: .top, relatedBy: .equal, toItem: preView, attribute: .bottom, multiplier: 1, constant: self.mainAxisSpacing))
                    constraints.append(PLConstraint.make(item: view, attribute: .leading, relatedBy: .equal, toItem: preView, attribute: .leading, multiplier: 1, constant: 0))
                }
            }
            
            
            if nextColumn != column {
                constraints.append(PLConstraint.make(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant:0))
            }
            
        }
        
        constraints.append(PLConstraint.make(item: self, attribute: .trailing, relatedBy: .equal, toItem: views.last, attribute: .trailing, multiplier: 1, constant: 0, priority: .defaultLow))
        self.addConstraints(constraints)
    }
}
