//
//  GraphPainter.swift
//  ExampleWatchGraph
//
//  Created by Lev Walkin on 11/30/15.
//  Copyright © 2015 Lev Walkin. All rights reserved.
//

import WatchKit
import Foundation


/*
 * Come up with data and draw it.
 * Subclassed from NSObject to allow timers to function.
 */
class GraphPainter : NSObject {
    
    /*
     * Constants for interface smoothness.
     */
    let graphSeconds : Double = 5.0
    let graphFramesPerSecond = 30.0
    let measurementsPerSecond = 3.0

    /*
     * Interface.
     */
    let scale : CGFloat
    let graphImage: WKInterfaceImage!
    let imgSize : CGSize

    /*
     * Display and data generator timers.
     */
    var dataTimer : NSTimer?
    var drawTimer : NSTimer?

    /*
     * Accumulated data.
     */
    let graphData : GraphData

    init(fromImage image: WKInterfaceImage, imageSize size: CGSize, interfaceScale factor: CGFloat) {
        graphImage = image
        imgSize = size
        scale = factor
        
        graphData = GraphData(graphTimeSpan: graphSeconds)
        super.init()
    }
    
    func appendGraphPoint(value: Int) {
        let ts = NSDate.timeIntervalSinceReferenceDate()
        graphData.addPoint(timeStamp: ts, value: value)
    }
    
    /* Come up with data */
    func dataTimerFired() {
        let value = Int(arc4random_uniform(100))
        appendGraphPoint(value)
    }
    
    private func initAxisLineContext(context: CGContextRef, color: UIColor) {
        // Setup for the thin underline appearance
        CGContextSetShouldAntialias(context, false)
        CGContextSetLineWidth(context, 1/scale) // Exactly 1 device pixel.
        CGContextSetStrokeColorWithColor(context, color.CGColor)
    }
    
    private func initGraphLineContext(context: CGContextRef, color: UIColor) {
        // Setup for the graph path appearance
        CGContextSetShouldAntialias(context, true)
        CGContextSetLineWidth(context, 2.0)
        CGContextSetLineJoin(context, CGLineJoin.Round)
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
    }
    
    /*
     * Redraw the full scene.
     */
    func drawTimerFired() {
        UIGraphicsBeginImageContextWithOptions(imgSize, true, scale)
        let context = UIGraphicsGetCurrentContext()!
        
        let curTS = NSDate.timeIntervalSinceReferenceDate()
        let ybase = CGFloat(ceil(0.75 * Double(imgSize.height)))
        let data = graphData.normalValues(currentTime: curTS)
        
        /*
         * Thin gray underline at 0-point of the graph.
         */
        initAxisLineContext(context, color: UIColor.grayColor())
        CGContextBeginPath (context);
        CGContextMoveToPoint(context, 0, ybase)
        CGContextAddLineToPoint(context, imgSize.width, ybase)
        CGContextStrokePath(context);
        
        /*
         * Draw the graph line itself.
         */
        initGraphLineContext(context, color: UIColor.redColor())
        CGContextBeginPath (context);
        var n = 0
        for (x_norm, y_norm) in data {
            let x = CGFloat(x_norm * Double(imgSize.width))
            let y = ybase + CGFloat(y_norm * Double(-imgSize.height/2))
            if(n++ == 0) {
                CGContextMoveToPoint(context, x, y)
            } else {
                CGContextAddLineToPoint(context, x, y)
            }
        }
        CGContextStrokePath(context);

        // Capture the image data as UIImage,
        // then display it back on a image element
        // (invokes conversion to and from PNG).
        // See https://www.youtube.com/watch?v=ue7QScZz8WM for
        // a PNG related trace.
        let uimg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        graphImage.setImage(uimg)
    }
    
    /*
     * Start timers to draw data 30fps and add new data.
     */
    func start() {
        drawTimer = NSTimer.scheduledTimerWithTimeInterval(1/graphFramesPerSecond,
            target: self, selector: "drawTimerFired", userInfo: nil, repeats: true)
        dataTimer = NSTimer.scheduledTimerWithTimeInterval(1/measurementsPerSecond,
            target: self, selector: "dataTimerFired", userInfo: nil, repeats: true)
    }
    
    func stop() {
        drawTimer!.invalidate()
        dataTimer!.invalidate()
    }
}