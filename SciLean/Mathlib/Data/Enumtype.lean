import SciLean.Mathlib.Data.Iterable


-- Enumerable type
class Enumtype (α : Type u) extends Iterable α where
  numOf : Nat
  fromFin : Fin numOf → α
  toFin : α → Fin numOf

  --- Data compatibility with Iterable
  first_fromFin :
    match numOf with
      | 0 => True
      | n+1 => first = fromFin ⟨0,sorry⟩
  next_fromFin : 
    match numOf with
      | 0 => True
      | n+1 => ∀ (i : Fin n), 
        next (fromFin ⟨i.1,sorry⟩) = fromFin (⟨(i.1+1),sorry⟩)
        ∧ 
        next (fromFin ⟨n,sorry⟩) = none
  next_toFin : ∀ (a : α),
    match (next a) with
      | none => True
      | some nxt => Iterable.next (toFin a) = some (toFin nxt)

export Enumtype (numOf fromFin toFin)

namespace Enumtype

  instance [Enumtype ι] : Iterable.UpperBound ι :=
  {
    upperBound := numOf ι
    valid := sorry
  }

  instance : Enumtype Empty :=
  {
    numOf := 0
    fromFin := λ a => absurd (a := a.1<0) a.2 sorry
    toFin := λ a => (by induction a; done)

    first_fromFin := sorry
    next_fromFin  := sorry
    next_toFin    := sorry
  }

  instance : Enumtype Unit :=
  {
    numOf   := 1
    fromFin := λ _ => Unit.unit
    toFin   := λ _ => 0
    
    first_fromFin := sorry
    next_fromFin  := sorry
    next_toFin    := sorry
  }

  @[simp]       
  theorem numof_unit : numOf Unit = 1 := by simp[numOf]; done 

  instance : Enumtype (Fin n) :=
  {
    numOf := n
    fromFin := id
    toFin := id

    first_fromFin := sorry
    next_fromFin  := sorry
    next_toFin    := sorry
  }

  @[simp]       
  theorem numof_fin {n} : numOf (Fin n) = n := by simp[numOf]; done 

  --- Row-major 
  instance [Enumtype α] [Enumtype β] : Enumtype (α × β) :=
  {
     numOf := numOf α * numOf β
     fromFin := λ i => (fromFin ⟨i.1 / numOf β, sorry⟩, fromFin ⟨i.1 % numOf β, sorry⟩)
     toFin   := λ (a,b) => ⟨(toFin b).1 + (numOf β) * (toFin a).1, sorry⟩

     first_fromFin := sorry
     next_fromFin  := sorry
     next_toFin    := sorry
  }

  --- Col-major
  instance [Enumtype α] [Enumtype β] : Enumtype (α ×ₗ β) :=
  {
     numOf := numOf α * numOf β
     fromFin := λ i => (fromFin ⟨i.1 % numOf α, sorry⟩, fromFin ⟨i.1 / numOf α, sorry⟩)
     toFin   := λ (a,b) => ⟨(toFin a).1 + (numOf α) * (toFin b).1, sorry⟩

     first_fromFin := sorry
     next_fromFin  := sorry
     next_toFin    := sorry
  }

  instance [Enumtype α] [Enumtype β] : Enumtype (α ⊕ β) := 
  {
    numOf := numOf α + numOf β
    fromFin := λ i => 
      if i < numOf α 
      then Sum.inl $ fromFin ⟨i.1, sorry⟩ 
      else Sum.inr $ fromFin ⟨i.1 - numOf α, sorry⟩
    toFin := λ ab => 
      match ab with
      | Sum.inl a => ⟨(toFin a).1, sorry⟩
      | Sum.inr b => ⟨(toFin b).1 + numOf α, sorry⟩

    first_fromFin := sorry
    next_fromFin  := sorry
    next_toFin    := sorry
  }

  -- TODO: Add LinRange as for Iterable

  -- This is closed range! Includes last element!
  def Range (α : Type u) [Enumtype α] := Option (α × α)
  def range {α} [Enumtype α] (s e : α) : Range α := some (s,e)

  def Range.length {α} [Enumtype α] (r : Range α) : ℕ :=
    match r with
    | none => 0
    | some (s,e) => 
      let is := toFin s
      let ie := toFin e
      ie.1 - is.1 + 1

  --- Should we have `×` or `×ₗ` there? Maybe define `*ₗ` notation.
  instance [Enumtype ι] [Enumtype κ] : HMul (Range ι) (Range κ) (Range (ι × κ)) :=
    ⟨λ I J =>
       match I, J with
         | (some (is,ie)), (some (js,je)) => some ((is,js), (ie,je))
         | _, _ => none⟩

  -- TODO: Define `*ₗ` multiplication `HColMul`
  -- instance [Enumtype ι] [Enumtype κ] : HColMul (Range ι) (Range κ) (Range (ι ×ₗ κ)) := ⟨λ I J => (I*J : Range (ι × κ))⟩

  instance (α : Type u) [Enumtype α] [ToString α] : ToString (Range α) := 
    ⟨λ r => 
      match r with
        | none => "[]"
        | some (s,e) => s!"[{s}:{e}]"⟩

  -- TODO: Change to LinRange once defined
  def fullRange (α : Type u) [Enumtype α] : Range α :=
      match (numOf α) with
        | 0 => none
        | n+1 => some (fromFin ⟨0, sorry⟩, fromFin ⟨n, sorry⟩)


  -- TODO: Somehow add this to the ForIn
  -- Having a proof about the compatibility of the index and linear index would be nice.
  structure ValidLinIndex {ι} [Enumtype ι] (i : ι) (li : Nat) : Type where
    valid : li = (toFin i).1


  instance {m} [Monad m] {n}
           : ForIn m (Range (Fin n)) (Fin n × (Fin (numOf (Fin n)))) :=
  {
    forIn := λ r init f => 
               match r with
                 | none => pure init
                 | some (s,e) => do
                   let mut val := init
                   for i in [s.1:e.1+1] do
                     match (← f (⟨i,sorry⟩, ⟨i,sorry⟩) val) with
                       | ForInStep.done d => return d
                       | ForInStep.yield d => val ← pure d
                   pure val
  }


  instance {m} [Monad m] [Enumtype ι]
           : ForIn m (Range ι) (ι × Fin (numOf ι)) :=
  {
    forIn := λ r init f => 
      match r with
      | none => pure init
      | some (s,e) => do
        let n := r.length
        let mut idx := s
        let mut val := init
        for i in [0:n] do
          match (← f (idx, ⟨i,sorry⟩) val), Iterable.next idx with 
          | ForInStep.done d, _ => return d
          | ForInStep.yield d, none => do
            val ← pure d
          | ForInStep.yield d, some idx' => do
            idx := idx'
            val ← pure d
        pure val
  }


  -- Row-major ordering, i.e. the inner loop runs over κ
  instance {m} [Monad m] [Enumtype ι] [Enumtype κ]
           [ForIn m (Range ι) (ι × Nat)]
           [ForIn m (Range κ) (κ × Nat)]
           : ForIn m (Range (ι × κ)) ((ι × κ) × (Fin (numOf (ι × κ)))) :=
  {
    forIn := λ r init f =>
               match r with 
                 | none => pure init
                 | some ((is,js),(ie,je)) => do
                   let mut val := init
                   for (i,li) in (range is ie) do
                     let offset := (numOf κ) * li
                     for (j,lj) in (range js je) do
                       match (← f ((i,j), ⟨lj + offset, sorry⟩) val) with
                         | ForInStep.done d => return d
                         | ForInStep.yield d => val ← pure d
                   pure val
  }


  -- Colum-major ordering, i.e. the inner loop runs over ι
  instance {m} [Monad m] [Enumtype ι] [Enumtype κ]
           [ForIn m (Range ι) (ι × Nat)]
           [ForIn m (Range κ) (κ × Nat)]
           : ForIn m (Range (ι ×ₗ κ)) ((ι ×ₗ κ) × (Fin (numOf (ι ×ₗ κ)))) :=
  {
    forIn := λ r init f => 
               match r with 
                 | none => pure init
                 | some ((is,js),(ie,je)) => do
                   let mut val := init
                   for (j,lj) in (range js je) do
                     let offset := (numOf ι) * lj
                     for (i,li) in (range is ie) do
                       match (← f ((i,j), ⟨li + offset, sorry⟩) val) with
                         | ForInStep.done d => return d
                         | ForInStep.yield d => val ← pure d
                   pure val
  }

  -- It is important to fetch a new instance of `UpperBoundUnsafe` at call site.
  -- That way we are likely to fetch an instance of `UpperBound` if available
  def sum {α} [Zero α] [Add α] {ι} [Enumtype ι] (f : ι → α) : α := ((do
    let mut r : α := 0 
    for i in Iterable.fullRange ι do
      r := r + (f i)
    r) : Id α)

  -- TODO: add priority b:term:66
  --       This way `∑ i, f i + c = (∑ i, f i) + c` i.e. sum gets stopped by `+` and `-`
  --       The paper 'I♥LA: compilable markdown for linear algebra' https://doi.org/10.1145/3478513.3480506  
  --           claims on page 5 that conservative sum is more common then greedy


  open Lean.TSyntax.Compat in
  macro "∑" xs:Lean.explicitBinders ", " b:term:66 : term => Lean.expandExplicitBinders `Enumtype.sum xs b

  -- section Examples

  --   def ri : Enumtype.Range (Fin 10) := some (5,9)
  --   def rj : Enumtype.Range (Fin 10) := some (0,4)
  --   def r  := ri * rj
  --   def rCol : Enumtype.Range (Fin 10 ×ₗ Fin 10) := ri * rj

  --   def test1 : IO Unit := 
  --   do
  --     IO.println "Row Major ordering:"
  --     for (index,linearindex) in r do 
  --       IO.println s!"index = {index}  |  linearindex = {linearindex} "
  --     IO.println ""
  --     IO.println "Col Major ordering:"
  --     for (index,linearindex) in rCol do 
  --       IO.println s!"index = {index}  |  linearindex = {linearindex} "

  --   #eval test1
  
  -- end Examples
