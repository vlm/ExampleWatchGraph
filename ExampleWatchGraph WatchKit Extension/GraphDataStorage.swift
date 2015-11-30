//
//  GraphDataStorage.swift
//  ExampleWatchGraph
//
//  Created by Lev Walkin on 11/30/15.
//  Copyright © 2015 Lev Walkin. All rights reserved.
//

import Foundation

/*
 * The class holds on to the measurement points, normalizes
 * them by finding maximums, and dispences back in the floating
 * point domain to provide source for drawing.
 */
class GraphData {
    /*
     * Target output's properties for the graph.
     * timeSpan - amount of time a point appears on a graph before moving off screen;
     * readjustmentDuration - amount of time the graph adjusts (squeezes or expands)
     * when a new maximum is discovered.
     */
    private var timeSpan : Double
    private let readjustmentDuration : Double = 1.0
    
    /*
     * Graph data itself.
     */
    private var data : [(NSTimeInterval, Int)] = []
    
    /*
     * Derived properties for the graph.
     */
    private var maxValue : Int = 0
    private var lastMaxUpdate : NSTimeInterval = 0
    private var curMaxTarget : (NSTimeInterval, Int) = (0, 0)
    private var nextMaxTarget : Int?
    
    init(graphTimeSpan seconds: Double) {
        timeSpan = seconds
    }
    
    /*
     * Add a new point to the graph.
     * addPoint does maintenance by removing old data.
     */
    func addPoint(timeStamp ts: NSTimeInterval, value: Int) {
        data.append((ts, value))
        removeOldPoints(ts)
        updateMaximum(currentTime: ts, value: value)
    }
    
    /*
     * Return a list of (x, y) : (Double, Double) values, where all values
     * are generally normalized to conform to [0..1] range.
     * The values are allowed to temporarily exceed the range from time to time,
     * but that's expected from the graph that resizes gradually in real time to
     * fit within [0..1] range.
     */
    func normalValues(currentTime curTS: NSTimeInterval) -> [(Double, Double)] {
        let valueNormFactor = getNormalizingFactor(currentTime: curTS)
        var arr : [(Double, Double)] = []
        for (ts, v) in data {
            let normElement = (x_of(currentTime: curTS, locationTime: ts), Double(v) / valueNormFactor)
            arr.append(normElement)
        }
        return arr
    }
    
    /*
     * Get the X coordinate (usually, but not always within [0..1]) of the time point.
     */
    private func x_of(currentTime ts: NSTimeInterval, locationTime: NSTimeInterval) -> Double {
        let leftTS = ts - timeSpan
        // Everything that is more than graphTimeSpan in the past goes to negative.
        return ((locationTime - leftTS) / timeSpan)
    }
    
    /*
     * Get a factor that makes data mostly fit within [0..1] range.
     */
    private func getNormalizingFactor(currentTime curTS: NSTimeInterval) -> Double {
        var valueNormFactor : Double
        updateMaximum(currentTime: curTS, value: 0)
        if(curMaxTarget.0 < curTS) {
            valueNormFactor = Double(maxValue)
        } else {
            valueNormFactor = Double(curMaxTarget.1)
                - easing(curTS, t2: curMaxTarget.0) * Double(curMaxTarget.1 - maxValue)
        }
        return valueNormFactor
    }
    
    /*
     * Easing is a shape of the way the graph does real time auto-resizing
     * to fit the space.
     */
    private func easing(now : NSTimeInterval, t2 : NSTimeInterval) -> Double {
        let p = ((t2 - now)/readjustmentDuration)
        return sin((p - 1.0) * M_PI_2)+1.0
    }
    
    /*
     * Remove points that fell off the left edge.
     * We don't remove points which just fell of the edge, because
     * some drawing artifacts will appear jumpy. So we
     * remove points that are -10% of the time width of the graph.
     */
    private func removeOldPoints(ts: NSTimeInterval) {
        let tenPercent : Double = -0.1
        while(x_of(currentTime: ts, locationTime: data[0].0) < tenPercent) {
            data.removeAtIndex(0)
        }
    }
    
    private func updateMaximum(currentTime ts: NSTimeInterval, value : Int) {
        if(maxValue == 0) {
            maxValue = max(1, value)
            curMaxTarget = (ts+0.1, maxValue)
            nextMaxTarget = nil
            lastMaxUpdate = ts
        }
        
        if(lastMaxUpdate < ts - timeSpan && nextMaxTarget == nil && data.count > 0) {
            let (_, m) = data.maxElement({ (a, b) -> Bool in a.1 < b.1 })!
            nextMaxTarget = m
        }
        
        if(curMaxTarget.0 < ts) {
            maxValue = curMaxTarget.1
            if(nextMaxTarget == nil) {
                if(value > maxValue) {
                    curMaxTarget = (ts+readjustmentDuration, value)
                    lastMaxUpdate = ts
                }
            } else {
                lastMaxUpdate = ts
                curMaxTarget = (ts+readjustmentDuration, max(value, nextMaxTarget!))
                nextMaxTarget = nil
            }
        } else {
            if(value > curMaxTarget.1 && (nextMaxTarget == nil || nextMaxTarget! < value)) {
                nextMaxTarget = value
                lastMaxUpdate = ts
            }
        }
        
    }
}
