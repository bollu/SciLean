import SciLean.Core

namespace SciLean

class SetElem (Cont : Type u) (Idx : Type v) (Elem : outParam (Type w)) where
  setElem : (const : Cont) → (idx : Idx) → (elem : Elem) → Cont

export SetElem (setElem)

-- class ModifyElem (Cont : Type u) (Idx : Type v) (Elem : outParam (Type w)) where
--   modifyElem : (x : Cont) → (i : Idx) → (f : Elem → Elem) → Cont

-- export ModifyElem (modifyElem)

class IntroElem (Cont : Type u) (Idx : Type v) (Elem : outParam (Type w)) where
  introElem : (f : Idx → Elem) → Cont

export IntroElem (introElem)

class PushElem (Cont : Nat → Type u) (Elem : outParam (Type w)) where
  pushElem (k : Nat) (elem : Elem) : Cont n → Cont (n + k)

export PushElem (pushElem)

class DropElem (Cont : Nat → Type u) (Elem : outParam (Type w)) where
  dropElem (k : Nat) : Cont (n + k) → Cont n

export DropElem (dropElem)

class ReserveElem (Cont : Nat → Type u) (Elem : outParam (Type w)) where
  reserveElem (k : Nat) : Cont n → Cont n

export ReserveElem (reserveElem)

/-- This class says that `Cont` behaves like an array with `Elem` values indexed by `Idx`

Examples for `Idx = Fin n` and `Elem = ℝ` are: `ArrayN ℝ n` or `ℝ^{n}`

For `array : Cont` you can:
  1. get values: `getElem array x : Elem` for `x : Idx`
  2. set values: `setElem array x y : Cont` for `x : Idx` and `y : Elem`
  3. make new a array: `introElem f : Cont` for `f : Idx → Elem`

Alternative notation:
  1. `array[x]`
  2. in `do` block: `array[x] := y`, `array[x] += y`, ...
  3. `λ [x] => f x` this notation works only if the type `Cont` can be infered from the context
     Common use: `let array : Cont := λ [x] => f x` where the type asscription `: Cont` is important.
-/
class GenericArray (Cont : Type u) (Idx : Type v |> outParam) (Elem : Type w |> outParam) 
  extends GetElem Cont Idx Elem (λ _ _ => True), 
          SetElem Cont Idx Elem,
          IntroElem Cont Idx Elem
  where
  ext : ∀ f g : Cont, (∀ x : Idx, f[x] = g[x]) ↔ f = g
  getElem_setElem_eq  : ∀ (x : Idx) (y : Elem) (f : Cont), (setElem f x y)[x] = y
  getElem_setElem_neq : ∀ (i j : Idx) (val : Elem) (arr : Cont), i ≠ j → (setElem arr i val)[j] = arr[j]
  getElem_introElem : ∀ f i, (introElem f)[i] = f i

attribute [simp] GenericArray.getElem_setElem_eq GenericArray.getElem_introElem
attribute [default_instance] GenericArray.toGetElem GenericArray.toSetElem GenericArray.toIntroElem

class GenericLinearArray (Cont : Nat → Type u) (Elem : Type w |> outParam) 
  extends PushElem Cont Elem, 
          DropElem Cont Elem, 
          ReserveElem Cont Elem
  where
  toGenericArray : ∀ n, GenericArray (Cont n) (Fin n) Elem

  pushElem_getElem : ∀ n k val (i : Fin (n+k)) (x : Cont n), n ≤ i.1 → 
    have : ∀ n', GetElem (Cont n') (Fin n') Elem (λ _ _ => True) := λ n' => (toGenericArray n').toGetElem
    (pushElem k val x)[i] = val

  dropElem_getElem : ∀ n k (i : Fin n) (x : Cont (n+k)), 
    have : ∀ n', GetElem (Cont n') (Fin n') Elem (λ _ _ => True) := λ n' => (toGenericArray n').toGetElem
    (dropElem k x)[i] = x[(⟨i.1, sorry_proof⟩ : Fin (n+k))]

  reserveElem_id : ∀ (x : Cont n) (k), reserveElem k x = x
  

instance {T} {Y : outParam Type} [inst : GenericLinearArray T Y] (n) : GenericArray (T n) (Fin n) Y := inst.toGenericArray n

namespace GenericArray

variable {Cont : Type} {Idx : Type |> outParam} {Elem : Type |> outParam}

-- TODO: Make an inplace modification
-- Maybe turn this into a class and this is a default implementation
@[inline]
def modifyElem [GetElem Cont Idx Elem λ _ _ => True] [SetElem Cont Idx Elem] 
  (arr : Cont) (i : Idx) (f : Elem → Elem) : Cont := 
  setElem arr i (f (arr[i]))

@[simp]
theorem getElem_modifyElem_eq [GenericArray Cont Idx Elem] (cont : Cont) (idx : Idx) (f : Elem → Elem)
  : (modifyElem cont idx f)[idx] = f cont[idx] := by simp[modifyElem]; done

@[simp]
theorem getElem_modifyElem_neq [inst : GenericArray Cont Idx Elem] (arr : Cont) (i j : Idx) (f : Elem → Elem)
  : i ≠ j → (modifyElem arr i f)[j] = arr[j] := by simp[modifyElem]; apply GenericArray.getElem_setElem_neq; done

-- Maybe turn this into a class and this is a default implementation
-- For certain types there might be a faster implementation
def mapIdx [GenericArray Cont Idx Elem] [Enumtype Idx] (f : Idx → Elem → Elem) (arr : Cont) : Cont := Id.run do
  let mut arr := arr
  for (i,_) in Enumtype.fullRange Idx do
    -- This notation should correctly handle aliasing 
    -- It should expand to `f := modifyElem f x (g x) True.intro`
    -- This prevent from making copy of `f[x]`
    arr := modifyElem arr i (f i)
  arr

@[simp]
theorem getElem_mapIdx [GenericArray Cont Idx Elem] [Enumtype Idx] (f : Idx → Elem → Elem) (arr : Cont) (i : Idx)
  : (mapIdx f arr)[i] = f i arr[i] := sorry_proof

def map [GenericArray Cont Idx Elem] [Enumtype Idx] (f : Elem → Elem) (arr : Cont) : Cont := 
  mapIdx (λ _ => f) arr

@[simp]
theorem getElem_map [GenericArray Cont Idx Elem] [Enumtype Idx] (f : Elem → Elem) (arr : Cont) (i : Idx)
  : (map f arr)[i] = f arr[i] := sorry_proof


instance [GenericArray Cont Idx Elem] [ToString Elem] [Enumtype Idx] : ToString (Cont) := ⟨λ a => 
  match Iterable.first (ι:=Idx) with
  | some fst => Id.run do
    let mut s : String := s!"'[{a[fst]}"
    for (i,li) in Enumtype.fullRange Idx do
      if li.1 = 0 then continue else
      s := s ++ s!", {a[i]}"
    s ++ "]"
  | none => "'[]"⟩

section Operations

  variable [GenericArray Cont Idx Elem] [Enumtype Idx] 

  instance [Add Elem] : Add Cont := ⟨λ f g => mapIdx (λ x fx => fx + g[x]) f⟩
  instance [Sub Elem] : Sub Cont := ⟨λ f g => mapIdx (λ x fx => fx - g[x]) f⟩
  instance [Mul Elem] : Mul Cont := ⟨λ f g => mapIdx (λ x fx => fx * g[x]) f⟩
  instance [Div Elem] : Div Cont := ⟨λ f g => mapIdx (λ x fx => fx / g[x]) f⟩

  instance {R} [HMul R Elem Elem] : HMul R Cont Cont := ⟨λ r f => map (λ fx => r*(fx : Elem)) f⟩

  instance [Neg Elem] : Neg Cont := ⟨λ f => map (λ fx => -(fx : Elem)) f⟩
  instance [Inv Elem] : Inv Cont := ⟨λ f => map (λ fx => (fx : Elem)⁻¹) f⟩

  instance [One Elem]  : One Cont  := ⟨introElem λ _ : Idx => 1⟩
  instance [Zero Elem] : Zero Cont := ⟨introElem λ _ : Idx => 0⟩

  instance [LT Elem] : LT Cont := ⟨λ f g => ∀ x, f[x] < g[x]⟩ 
  instance [LE Elem] : LE Cont := ⟨λ f g => ∀ x, f[x] ≤ g[x]⟩

  instance [DecidableEq Elem] : DecidableEq Cont := 
    λ f g => Id.run do
      let mut eq : Bool := true
      for (x,_) in Enumtype.fullRange Idx do
        if f[x] ≠ g[x] then
          eq := false
          break
      if eq then isTrue sorry else isFalse sorry

  instance [LT Elem] [∀ x y : Elem, Decidable (x < y)] (f g : Cont) : Decidable (f < g) := Id.run do
    let mut lt : Bool := true
    for (x,_) in Enumtype.fullRange Idx do
      if ¬(f[x] < g[x]) then
        lt := false
        break
    if lt then isTrue sorry else isFalse sorry

  instance [LE Elem] [∀ x y : Elem, Decidable (x ≤ y)] (f g : Cont) : Decidable (f ≤ g) := Id.run do
    let mut le : Bool := true
    for (x,_) in Enumtype.fullRange Idx do
      if ¬(f[x] ≤ g[x]) then
        le := false
        break
    if le then isTrue sorry else isFalse sorry

end Operations

end GenericArray


namespace GenericArray

  variable {Cont : Nat → Type} {Elem : Type |> outParam}
  variable [GenericLinearArray Cont Elem]

  def empty : Cont 0 := introElem λ i => 
    absurd (a := ∃ n : Nat, n < 0) 
           (Exists.intro i.1 i.2) 
           (by intro h; have h' := h.choose_spec; cases h'; done)

  def split {n m : Nat} (x : Cont (n+m)) : Cont n × Cont m :=
    (introElem λ i => x[⟨i.1,sorry_proof⟩],
     introElem λ i => x[⟨i.1+n,sorry_proof⟩])

  def append {n m : Nat} (x : Cont n) (y : Cont m) : Cont (n+m) :=
    introElem λ i =>
      if i.1 < n
      then x[⟨i.1,sorry_proof⟩]
      else y[⟨i.1-n, sorry_proof⟩]

end GenericArray
