//
//  File.swift
//  SwiftyKnots-Sample
//
//  Created by Taketo Sano on 2020/02/04.
//

public struct SimpleDirectedGraph<Id: Hashable> {
    public struct Vertex {
        var index: Int
        var isValid: Bool
        var inputs: Set<Int>
        var outputs: Set<Int>
        var data: Id
    }

    public var vertexArray: [Vertex] = []
    public var vertexMap: [Id: Int] = [:]
    
    public func vertex(forID id: Id) -> UnsafeMutablePointer<Vertex> {
        return vertex(atIndex: vertexMap[id]!)
    }
    
    public func vertex(atIndex index: Int) -> UnsafeMutablePointer<Vertex> {
        let p = vertexArray.withUnsafeBufferPointer { (bp: UnsafeBufferPointer<Vertex>) in
            bp.baseAddress! + index
        }
        return UnsafeMutablePointer(mutating: p)
    }
    
    public init() {
    }
    
    public mutating func add(_ id: Id) {
        let vertex = Vertex(index: vertexArray.count,
                            isValid: true,
                            inputs: [],
                            outputs: [],
                            data: id)
        vertexArray.append(vertex)
        vertexMap[id] = vertex.index
    }
    
    public mutating func add<S: Sequence>(_ seq: S) where S.Element == Id {
        for x in seq {
            add(x)
        }
    }
    
    public mutating func remove(_ v: Id) {
        let v = self.vertex(forID: v)
        remove(v)
    }
    
    public mutating func remove(_ v: UnsafeMutablePointer<Vertex>) {
        for w in v.pointee.outputs {
            let wv = self.vertex(atIndex: w)
            wv.pointee.inputs.remove(v.pointee.index)
        }
        
        for u in v.pointee.inputs {
            let uv = self.vertex(atIndex: u)
            uv.pointee.outputs.remove(v.pointee.index)
        }
        
        v.pointee.isValid = false
    }
    
    public mutating func connect(_ v: Id, _ w: Id) {
        assert(v != w)
        
        let vv = self.vertex(forID: v)
        let wv = self.vertex(forID: w)

        connect(vv, wv)
    }
    
    public mutating func connect(_ v: UnsafeMutablePointer<Vertex>, _ w: UnsafeMutablePointer<Vertex>) {
        v.pointee.outputs.insert(w.pointee.index)
        w.pointee.inputs.insert(v.pointee.index)
    }
    
    public mutating func disconnect(_ v: Id, _ w: Id) {
        let vv = self.vertex(forID: v)
        let wv = self.vertex(forID: w)
    
        disconnect(vv, wv)
    }
    
    public mutating func disconnect(_ v: UnsafeMutablePointer<Vertex>, _ w: UnsafeMutablePointer<Vertex>) {
           v.pointee.outputs.remove(w.pointee.index)
           w.pointee.inputs.remove(v.pointee.index)
       }
}
