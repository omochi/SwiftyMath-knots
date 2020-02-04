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
        
        let H = Array(gens).parallelFlatMap { (i, gens) -> [(Int, Int, Int)] in
            self.graph(generators: gens, differential: d)
                .vertices
                .map{
                    $0.MaslovDegree
                }
                .countMultiplicities()
                .map{
                    (k, n) in (k, i, n)
                }
        }

        print(H)
    }
    
    private func graph<S: Sequence>(generators: S, differential d: ChainMap1<GridComplex.BaseModule, GridComplex.BaseModule>) -> SimpleDirectedGraph<GridComplex.Generator> where S.Element == GridComplex.Generator {
        
        typealias Generator = GridComplex.Generator
        typealias Graph = SimpleDirectedGraph<Generator>
        
        var graph = Graph()
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
                guard let y = graph.targets[x]?.anyElement else {
                    continue
                }
                
                for a in graph.cotargets[y] ?? [] where a != x {
                    for b in graph.targets[x] ?? [] where b != y {
                        if graph.targets[a]?.contains(b) ?? false {
                            graph.disconnect(a, b)
                        } else {
                            graph.connect(a, b)
                        }
                    }
                }
                
                graph.remove(x)
                graph.remove(y)
                codomain.remove(y)
            }
            
            gens[k] = nil
            gens[k - 1] = codomain
        }
        
        return graph
    }
}

extension LinearCombination where A == GridComplex.InflatedGenerator {
    static func wrap(_ x: GridComplex.Generator) -> Self {
        .wrap(TensorGenerator(.identity, x))
    }
}
