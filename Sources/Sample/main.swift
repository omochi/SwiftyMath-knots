import SwiftyMath
import SwiftyKnots
import SwiftyHomology

let G = GridDiagram.load("10_152")!
let gens = GridComplex.GeneratorSet(for: G) { x in x.AlexanderDegree >= 0 }
let f = HFKCalculator(diagram: G, generators: gens)

f.run()
