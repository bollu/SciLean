
/- 

  In this file we provide some goodies for Prod 

  Namely 
    1. index access: 
       `(42, 1.0, "hello")[2] == "hello"`
    2. index set:
       `(42,3.14159,"hello").set 2 "world" = (42,3.14159,"world")`
    3. curry function:
       `hcurry 3 (λ ((i,j,k) : Nat×Nat×Nat) => i + j) = (λ i j k => i + j)`
    4. uncurry function
       `huncurry 3 (λ i j k : Nat => i + j) = λ (i,j,k) => i + j`
 -/ 

----------------------------------------------------------------------

class Prod.Size (α : Type) where
  size : Nat

class Prod.SizeFlat (α : Type) where
  sizeFlat : Nat

instance (priority := low) (α) : Prod.Size α where
  size := 1

instance (priority := low) (α) : Prod.SizeFlat α where
  sizeFlat := 1

instance (α β) [sb : Prod.Size β] : Prod.Size (α×β) where
  size := 1 + sb.size

instance (α β) [sa : Prod.SizeFlat α] [sb : Prod.SizeFlat β] : Prod.SizeFlat (α×β) where
  sizeFlat := sa.sizeFlat + sb.sizeFlat

@[reducible]
def Prod.size {α β : Type} [Prod.Size β] (_ : α × β) : Nat := Prod.Size.size (α × β)

@[reducible]
def Prod.sizeFlat {α β : Type} [Prod.SizeFlat α] [Prod.SizeFlat β] (_ : α × β) : Nat := Prod.SizeFlat.sizeFlat (α × β)


----------------------------------------------------------------------

class Prod.Get (X : Type) (i : Nat) where
  {type : Type}
  get : X → type

attribute [reducible] Prod.Get.type Prod.Get.get

@[reducible]
instance (priority := low) : Prod.Get X 0 := ⟨λ x => x⟩

@[reducible]
instance : Prod.Get (X×Y) 0 := ⟨λ x => x.fst⟩ -- `λ (x,y) => x` causes some trouble while infering IsSmooth

@[reducible]
instance [pg : Prod.Get Y n] : Prod.Get (X×Y) (n+1) := ⟨λ x => pg.get x.snd⟩ -- `λ (x,y) => pg.get y` causes some trouble while infering IsSmooth

abbrev Prod.get {X Y} (i : Nat) [pg : Prod.Get (X×Y) i] (x : X×Y) := pg.get x

----------------------------------------------------------------------

class Prod.Set (X : Type) (i : Nat) where
  {T : Type}
  seti : X → T → X

attribute [reducible] Prod.Set.T Prod.Set.seti

@[reducible]
instance (priority := low) : Prod.Set X 0 := ⟨λ x x₀ => x₀⟩

@[reducible]
instance : Prod.Set (X×Y) 0 := ⟨λ (x,y) x₀ => (x₀,y)⟩

@[reducible]
instance [pg : Prod.Set Y n] : Prod.Set (X×Y) (n+1) := ⟨λ (x,y) y₀ => (x, pg.seti y y₀)⟩

abbrev Prod.set {X Y} (i : Nat) [pg : Prod.Set (X×Y) i] (x : X×Y) (xi) := pg.seti x xi

----------------------------------------------------------------------

class Prod.Uncurry (n : Nat) (F : Type) where
  {Y : Type}
  {Xs : Type}
  uncurry : F → Xs → Y

attribute [reducible] Prod.Uncurry.Y Prod.Uncurry.Xs Prod.Uncurry.uncurry

@[reducible]
instance (priority := low) {X Y : Type} : Prod.Uncurry 1 (X→Y) where
  uncurry := λ (f : X → Y) (x : X) => f x

@[reducible]
instance {X Y : Type} [c : Prod.Uncurry n Y] : Prod.Uncurry (n+1) (X→Y) where
  Xs := X×c.Xs
  Y := c.Y
  uncurry := λ (f : X → Y) ((x,xs) : X×c.Xs) => c.uncurry (f x) xs

abbrev huncurry (n : Nat) (f : F) [Prod.Uncurry n F] := Prod.Uncurry.uncurry (n:=n) f

----------------------------------------------------------------------

class Prod.Curry (n : Nat) (Xs : Type) (Y : Type) where
  {F : Type}
  curry : (Xs → Y) → F

attribute [reducible] Prod.Uncurry.Y Prod.Uncurry.Xs Prod.Uncurry.uncurry

@[reducible]
instance (priority := low) : Prod.Curry 1 X Y where
  curry := λ (f : X → Y) => f

@[reducible]
instance {X Y Z : Type} [c : Prod.Curry n Y Z] : Prod.Curry (n+1) (X×Y) Z where
  curry := λ (f : X×Y → Z) => (λ (x : X) => c.curry (λ y => f (x,y)))

abbrev hcurry {Xs Y : Type} (n : Nat) (f : Xs → Y) [Prod.Curry n Xs Y] := Prod.Curry.curry (n:=n) f

----------------------------------------------------------------------

example : (42,3.14159,"hello").get 0 = 42 := by rfl
example : (42,3.14159,"hello").get 1 = 3.14159 := by rfl
example : (42,3.14159,"hello").get 2 = "hello" := by rfl
example : ("hello", (42, 3.14159), "world").get 1 = (42,3.14159) := by rfl


-- Product is right associative and we respect it
example : (42,3.14159,"hello").size = 3 := by rfl
example : (42,(3.14159,"hello")).size = 3 := by rfl
example : ((42,3.14159),"hello").size = 2 := by rfl
example : ((42,3.14159),"hello").sizeFlat = 3 := by rfl
example : ((42,3.14159),("hello","world")).size = 3 := by rfl
example : ((42,3.14159),("hello","world")).sizeFlat = 4 := by rfl

example : (42,3.14159,"hello").set 2 "world" = (42,3.14159,"world") := by rfl

example : huncurry 3 (λ i j k : Nat => i + j) = λ (i,j,k) => i + j := by rfl
example : huncurry 2 (λ i j k : Nat => i + j) = λ (i,j) k => i + j := by rfl

example : hcurry 3 (λ ((i,j,k) : Nat×Nat×Nat) => i + j) = (λ i j k => i + j) := by rfl
example : hcurry 2 (λ ((i,j,k) : Nat×Nat×Nat) => i + j) = (λ i (j,k) => i + j) := by rfl





