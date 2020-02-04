//
//  File.swift
//  SwiftyKnots-Sample
//
//  Created by Taketo Sano on 2020/02/04.
//

public struct SimpleDirectedGraph<Id: Hashable> {
    public private(set) var vertices:  Set<Id>
    public private(set) var targets:   [Id : Set<Id>]
    public private(set) var cotargets: [Id : Set<Id>]
    
    public init() {
        self.vertices = []
        self.targets = [:]
        self.cotargets = [:]
    }
    
    public mutating func add(_ id: Id) {
        vertices.insert(id)
    }
    
    public mutating func add<S: Sequence>(_ seq: S) where S.Element == Id {
        vertices.formUnion(seq)
    }
    
    public mutating func remove(_ v: Id) {
        for w in targets[v] ?? [] {
            cotargets[w]?.remove(v)
        }
        for u in cotargets[v] ?? [] {
            targets[u]?.remove(v)
        }
        vertices.remove(v)
        targets[v] = nil
        cotargets[v] = nil
    }
    
    public mutating func connect(_ v: Id, _ w: Id) {
        assert(v != w)
        if targets[v] == nil {
            targets[v] = [w]
        } else {
            targets[v]!.insert(w)
        }

        if cotargets[w] == nil {
            cotargets[w] = [v]
        } else {
            cotargets[w]!.insert(v)
        }
    }
    
    public mutating func disconnect(_ v: Id, _ w: Id) {
        targets[v]?.remove(w)
        cotargets[w]?.remove(v)
    }
}
