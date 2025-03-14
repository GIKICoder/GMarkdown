//
//  LaTeXRenderOperation.swift
//  iOSLaTeX
//
//  Created by Shuaib Jewon on 7/24/18.
//

import Foundation
import UIKit

internal class LaTeXRenderOperation: AsyncOperation {
    private var laTeX: String!
    private weak var laTeXRenderer: LaTeXRenderer!
    
    var renderedLaTeX: UIImage?
    var error: String?
    
    init(_ laTeX: String, withRenderer laTeXRenderer: LaTeXRenderer) {
        self.laTeX = laTeX
        self.laTeXRenderer = laTeXRenderer
    }
    
    override func start() {
        guard !self.isCancelled else {
            self.finish(true)
            return
        }
        
        self.executing(true)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }
            
            while(!strongSelf.laTeXRenderer.isReady) { /* wait */ }
            
            strongSelf.renderLaTeX()
        }
    }
    
    func renderLaTeX(){
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.laTeXRenderer.startRendering(strongSelf.laTeX, completion: { (renderedLaTeX, error) in
                strongSelf.renderedLaTeX = renderedLaTeX
                strongSelf.error = error
                
                /*
                 * TODO: Why is this delay needed here to avoid wrong cropping size?
                 */
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                    strongSelf.finish(true)
                })
            })
        }
    }
}

internal class AsyncOperation: Operation {
    override var isAsynchronous: Bool { return true }
    
    override var isExecuting: Bool {  return _executing }
    override var isFinished: Bool { return _finished }
    
    private var _executing = false {
        willSet { willChangeValue(forKey: "isExecuting") }
        didSet { didChangeValue(forKey: "isExecuting") }
    }
    
    private var _finished = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet { didChangeValue(forKey: "isFinished") }
    }
    
    func executing(_ executing: Bool) { _executing = executing }
    func finish(_ finished: Bool) { _finished = finished }
}
