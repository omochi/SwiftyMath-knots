import SwiftyMath
import SwiftyKnots
import SwiftyHomology

// 9_42 11n37 10_152
let G = GridDiagram.load("10_152")!
let gens = GridComplex.GeneratorSet(for: G) { x in x.AlexanderDegree >= 0 }
let f = HFKCalculator(diagram: G, generators: gens)

f.run()
