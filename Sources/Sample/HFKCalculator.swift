//
//  HFKCalculator.swift
//  SwiftyKnots-Sample
//
//  Created by Taketo Sano on 2020/02/04.
//

import SwiftyMath
import SwiftyHomology
import SwiftyKnots
import Dispatch

public final class HFKCalculator {
    public let gridDiagram: GridDiagram
    public let generators: GridComplex.GeneratorSet
    
    public convenience init(diagram G: GridDiagram) {
        let gens = GridComplex.GeneratorSet(for: G) { x in x.AlexanderDegree >= 0 }
        self.init(diagram: G, generators: gens)
    }
    
    public init(diagram G: GridDiagram, generators: GridComplex.GeneratorSet) {
        self.gridDiagram = G
        self.generators = generators
    }
    
    public func run() {
        let gens = generators.group{ $0.AlexanderDegree }
        let d = GridComplex(
            type: .tilde,
            diagram: gridDiagram,
            generators: generators
        ).differential
        
        var H: [(Int, Int, Int)] = []
        
        for (i, gens) in gens {
            let h: [(Int, Int, Int)] = self.graph(generators: gens, differential: d)
                .vertexArray
                .filter { $0.isValid }
                .map { $0.data }
                .map ({
                    $0.MaslovDegree
                })
                .countMultiplicities()
                .map ({
                    (k, n) in (k, i, n)
                })
            H.append(contentsOf: h)
        }

        print(H)
    }
    
    private func graph<S: Sequence>(generators: S, differential d: ChainMap1<GridComplex.BaseModule, GridComplex.BaseModule>) -> SimpleDirectedGraph<GridComplex.Generator> where S.Element == GridComplex.Generator {
        
        typealias Generator = GridComplex.Generator
        typealias Graph = SimpleDirectedGraph<Generator>
        
        var graph = Graph()
        
        self.graphInout(
            generators: generators,
            differential: d,
            graph: &graph
        )

        return graph
    }
    
    private func graphInout<S: Sequence>(
        generators: S,
        differential d: ChainMap1<GridComplex.BaseModule, GridComplex.BaseModule>,
        graph: inout SimpleDirectedGraph<GridComplex.Generator>)
        where S.Element == GridComplex.Generator
    {
        typealias Generator = GridComplex.Generator
        typealias Graph = SimpleDirectedGraph<Generator>
        
        var gens = generators.group{ $0.MaslovDegree }.mapValues{ Set($0) }
        let mRange = gens.keys.range!
        
        for k in mRange.reversed() {
            let domain   = gens[k] ?? []
            var codomain = gens[k - 1] ?? []
            
            if k == mRange.upperBound {
                graph.add(domain)
            }
            graph.add(codomain)
            
            // connect vertices [k] -> [k-1]
            for x in domain {
                let dx = d[k].applied(to: .wrap(x))
                let ys = dx.generators.map{ $0.factors.1 }
                
                for y in ys where codomain.contains(y) {
                    graph.connect(x, y)
                }
            }
            
            // reduce vertices:
            //
            //      a   x             a'
            //      |\ /|\             \
            //      | X | \    ==>       \
            //      |/ \|  \               \
            //      y   b   b'          b   b'

            for x in domain {
                let xv = graph.vertex(forID: x)
                
                guard let yi = xv.pointee.outputs.anyElement else {
                    continue
                }
                
                let yv = graph.vertex(atIndex: yi)
                
                for ai in yv.pointee.inputs {
                    let av = graph.vertex(atIndex: ai)
                    guard av.pointee.index != xv.pointee.index else { continue }
                    
                    for bi in xv.pointee.outputs {
                        let bv = graph.vertex(atIndex: bi)
                        guard bv.pointee.index != yv.pointee.index else { continue }
                        
                        if av.pointee.outputs.contains(bi) {
                            graph.disconnect(av, bv)
                        } else {
                            graph.connect(av, bv)
                        }
                    }
                }
            
                graph.remove(xv)
                graph.remove(yv)
                codomain.remove(yv.pointee.data)
            }
            
            gens[k] = nil
            gens[k - 1] = codomain
        }
    }
}

extension LinearCombination where A == GridComplex.InflatedGenerator {
    static func wrap(_ x: GridComplex.Generator) -> Self {
        .wrap(TensorGenerator(.identity, x))
    }
}
