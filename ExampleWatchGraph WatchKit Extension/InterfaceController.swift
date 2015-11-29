//
//  InterfaceController.swift
//  ExampleWatchGraph WatchKit Extension
//
//  Created by Lev Walkin on 11/29/15.
//  Copyright © 2015 Lev Walkin. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {
    @IBOutlet var graphContainerImage: WKInterfaceImage!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        let graphSize = computeGraphSize()
        graphContainerImage.setWidth(graphSize.width)
        graphContainerImage.setHeight(graphSize.height)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Prepare off-screen buffer sized according to our graph,
        // but take the device scale factor into account.
        let imgSize = upscaleToDevice(computeGraphSize())
         // imgSize.width -= 1 // See below wrt. anti-aliasing.
        UIGraphicsBeginImageContext(imgSize)
        
        // Initialize drawing context and draw a line
        let context = UIGraphicsGetCurrentContext()!
        // If we set everything up correctly, the line should look
        // crisp without anti-aliasing. Any off-by-pixel errors will
        // produce a weird-looking fuzzy line, which won't look
        // right at all. Try (imgSize.width-=1) to entertain.
        CGContextSetShouldAntialias(context, false)
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
        // Draw a simple diagonal line across the graph.
        CGContextBeginPath (context);
        CGContextMoveToPoint(context, 0, 0)
        CGContextAddLineToPoint(context, imgSize.width, imgSize.height)
        CGContextStrokePath(context);

        // Save the image to PNG, then load it back as
        // a UIImage object.
        let cimg = CGBitmapContextCreateImage(context);
        let uimg = UIImage(CGImage: cimg!)
        // End the graphics context
        UIGraphicsEndImageContext()
        
        // Show graph on Watch interface
        graphContainerImage.setImage(uimg)

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    /*
     * A graph size is partly computed, partly invented.
     * The width of the graph is a tad smaller than the width
     * of the screen. For some reason it appears that the interface
     * image can only be 2 pixels smaller than the screen width.
     * The height is different.
     * Since we can't obtain the image size later for the purpose of
     * off-screen CoreGraphic drawing, we should know
     * the image height upfront. So we just come up with a value
     * and fix it here. Makes sense to keep number whole to avoid
     * aliasing artifacts during drawing.
     */
    private func computeGraphSize() -> CGSize {
        let currentDevice = WKInterfaceDevice.currentDevice()
        return CGSize(
            width: currentDevice.screenBounds.width - 2,
            height: floor(currentDevice.screenBounds.width/3))
    }
    
    /*
     * Logical pixels are bigger than the device pixels. In order
     * to create a high resolution graph, the underlying image should
     * be created in a device resolution. When we manipulate
     * the graph image data (rather than UI Labels and Images),
     * we use a much bigger canvas. Expected scale-up factor: 2.0.
     */
    private func upscaleToDevice(sz: CGSize) -> CGSize {
        let currentDevice = WKInterfaceDevice.currentDevice()
        let scale = currentDevice.screenScale   // Expected value: 2.0
        return CGSize(width: scale * sz.width, height: scale * sz.height)
    }

}
