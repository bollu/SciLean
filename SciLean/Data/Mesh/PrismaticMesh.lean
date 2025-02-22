import SciLean.Data.Mesh.PrismaticSet

namespace SciLean

  structure MeshPos (S : PrismaticSet) where
    prism : Prism
    elem : S.Elem prism
    pos : ℝ^{prism.dim}


  -- Mesh embeded in a vector space X
  -- It should extend PrismaticSet, but there is some problem with 
  structure PrismaticMesh (X : Type) [Vec X] extends PrismaticSet where
    toPos : (MeshPos toPrismaticSet) → X

    -- Continuity across faces
    toPos_face (Q P : Prism) (ι : Inclusion Q P) (e : Elem P) (x : ℝ^{Q.dim}) (h : Q.InPrism x)
      : toPos ⟨P, e, ι.faceInclusion x⟩ = toPos ⟨Q, face ι e, x⟩
    
  namespace PrismaticMesh

  class ClosestPoint {X} [Vec X] (M : PrismaticMesh X) where
    closestPoint : X → (MeshPos M.toPrismaticSet)
    -- Point on the mesh is the closes point
    closestPoint_toPos (p : MeshPos M.toPrismaticSet) : closestPoint (M.toPos p) = p

  abbrev closestPoint {X} [Vec X] (M : PrismaticMesh X) [ClosestPoint M] (x : X) := ClosestPoint.closestPoint (M:=M) x
  
  open Prism in
  def size {X} [Hilbert X] {M : PrismaticMesh X} {P} (e : M.Elem P) : ℝ := 
    match P with
    | ⟨.point, _⟩ => 1
    | ⟨.cone .point, _⟩ => 
      let p0 := M.toPos ⟨_, M.face segment.point0 e, 0⟩
      let p1 := M.toPos ⟨_, M.face segment.point1 e, 0⟩
      ∥p1-p0∥
    | ⟨.cone (.cone .point), _⟩ =>
      let p0 := M.toPos ⟨_, M.face triangle.point0 e, 0⟩
      let p1 := M.toPos ⟨_, M.face triangle.point1 e, 0⟩
      let p2 := M.toPos ⟨_, M.face triangle.point2 e, 0⟩
      let (a,b,c) := sort3 ∥p0-p1∥ ∥p0-p2∥ ∥p1-p2∥
      -- see '§2. How to compute ∆' in https://people.eecs.berkeley.edu/~wkahan/Triangle.pdf
      (Math.sqrt (a+(b+c))*(c-(a-b))*(c+(a-b))*(a+(b-c)))/4
    | _ => panic! "Size of prism {P} is not implemented!"
  
  def prod {X Y} [Vec X] [Vec Y] (M : PrismaticMesh X) (N : PrismaticMesh Y) : PrismaticMesh (X×Y) :=
    PrismaticMesh.mk (M.toPrismaticSet.prod N.toPrismaticSet)
      (toPos := λ p => 
        let dim₁ := p.elem.dec.fst.dim
        let dim₂ := p.elem.dec.snd.dim
        let x₁ : ℝ^{dim₁} := λ [i] => p.pos[⟨i.1, sorry_proof⟩]
        let x₂ : ℝ^{dim₂} := λ [i] => p.pos[⟨i.1 + dim₁, sorry_proof⟩]
        let p₁ : MeshPos M.toPrismaticSet := ⟨p.elem.dec.fst, p.elem.fst, x₁⟩
        let p₂ : MeshPos N.toPrismaticSet := ⟨p.elem.dec.snd, p.elem.snd, x₂⟩
        let pos₁ := M.toPos p₁
        let pos₂ := N.toPos p₂
        (pos₁, pos₂))

      (toPos_face := sorry_proof)

  instance {X Y} [Vec X] [Vec Y] 
    (M : PrismaticMesh X) [M.ClosestPoint]
    (N : PrismaticMesh Y) [N.ClosestPoint]
    : PrismaticMesh.ClosestPoint (M.prod N) where
      closestPoint := λ (x,y) => 
        let p₁ := M.closestPoint x        
        let p₂ := N.closestPoint y
        let P := p₁.prism * p₂.prism
        let decP := P.decomposeBy p₁.prism
        ⟨P, 
        ⟨decP, cast sorry_proof p₁.elem, cast sorry_proof p₂.elem⟩, 
        λ [i] => if i.1 < p₁.prism.dim 
                 then p₁.pos[⟨i.1, sorry_proof⟩]
                 else p₂.pos[⟨i.1 - p₁.prism.dim, sorry_proof⟩]⟩
      closestPoint_toPos := sorry_proof
