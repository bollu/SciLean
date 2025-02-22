import SciLean.Core.Mor
import SciLean.Core.Fun

namespace SciLean


-- Negation --
--------------

function_properties Neg.neg {X : Type} (x : X) : X
argument x [Vec X]
  isLin      := sorry,
  isSmooth, diff_simp, fwdDiff_simp
argument x [SemiHilbert X]
  hasAdjoint := sorry,
  adj_simp   := - x' by sorry,
  hasAdjDiff := by constructor; infer_instance; simp; infer_instance; done,
  adjDiff_simp := - dx' by simp[adjointDifferential]; done
argument x [AddGroup X] [Nonempty X]
  isInv := sorry,
  inv_simp := - x' by sorry


-- Multiplication --
--------------------

function_properties HMul.hMul {X : Type} (x : ℝ) (y : X) : X
argument x [Vec X] 
  isLin      := sorry,
  isSmooth, diff_simp, fwdDiff_simp
argument x [Hilbert X]
  hasAdjoint := sorry,
  adj_simp   := ⟪x', y⟫ by sorry,
  hasAdjDiff := by constructor; infer_instance; simp; infer_instance; done,
  adjDiff_simp := ⟪dx', y⟫ by simp[adjointDifferential]; unfold hold; simp; done

argument y [Vec X]
  isLin      := sorry,
  isSmooth, diff_simp, fwdDiff_simp
argument y [SemiHilbert X]
  hasAdjoint := sorry,
  adj_simp   := x * y' by sorry,
  hasAdjDiff := by constructor; infer_instance; simp; infer_instance; done,
  adjDiff_simp := x * dy' by simp[adjointDifferential]; done
argument y [Vec X] [Nonempty X] [Fact (x ≠ 0)]
  isInv    := sorry,
  inv_simp := 1/x * y' by sorry

function_properties HMul.hMul (x : ℝ) (y : ℝ)  : ℝ
argument x [Fact (y ≠ 0)]
  isInv    := sorry,
  inv_simp := x' * (1/y) by sorry

-- @[simp, simp_diff]
-- theorem HMul.hMul.arg_xy.fwdDiff_simp  {X : Type} [Vec X]  {α}
--   : (fwdDiff λ ((x,y) : (ℝ×X)) => x * y) = λ ((x,y),dxy) => (x*y, λ a => (dxy a).1 * y + x * (dxy a).2) :=
-- by  simp[fwdDiff]; done

-- Division --
--------------

-- ???BIG QUESTION???
-- Can we really state smoothenss in `x as??
--    IsSmooth (λ (x y : ℝ) => x / y)
-- 
-- or do we only have?
--    ∀ y, IsSmooth (λ x : ℝ => x / y

-- If only the second is true
-- instance HDiv.hDiv.arg_x.isSmooth (y : ℝ) : IsSmooth (λ (x : ℝ) => x / y) := by sorry
-- @[simp] theorem HDiv.hDiv.arg_x.diff_simp (y : ℝ) : ∂ (λ (x : ℝ) => x / y) = λ x dx => dx / y := by sorry

function_properties HDiv.hDiv (x y : ℝ) : ℝ
argument x
  isLin     := by sorry,
  isSmooth, diff_simp, fwdDiff_simp,
  hasAdjoint := sorry,
  adj_simp := x' / y by sorry,
  hasAdjDiff := by constructor; infer_instance; simp; infer_instance; done,
  adjDiff_simp := dx' / y by simp[adjointDifferential]; unfold hold; simp; done

--- We can't say much in `y as we do not have `IsSmoothAt


-- Addition --
--------------

function_properties HAdd.hAdd {X : Type} (x y : X) : X
argument x [Vec X]
  isSmooth  := sorry, 
  diff_simp := dx by sorry
argument x [SemiHilbert X]
  hasAdjDiff := by constructor; infer_instance; simp; infer_instance; done,
  adjDiff_simp := dx' by simp[adjointDifferential]; unfold hold; simp; done
argument x [AddGroup X] [Nonempty X]
  isInv := sorry,
  inv_simp := x' - y by sorry

argument y [Vec X]
  isSmooth  := sorry,
  diff_simp := dy by sorry
argument y [SemiHilbert X]
  hasAdjDiff   := by constructor; infer_instance; simp; infer_instance; done,
  adjDiff_simp := dy' by simp[adjointDifferential]; done
argument y [AddGroup X] [Nonempty X]
  isInv    := sorry,
  inv_simp := y' - x by sorry


instance HAdd.hAdd.arg_xy.isLin {X} [Vec X] 
  : IsLin (λ ((x, y) : (X × X)) => x + y) := sorry

instance HAdd.hAdd.arg_xy.hasAdjoint {X} [SemiHilbert X] 
  : HasAdjoint (λ ((x, y) : (X × X)) => x + y) := sorry

@[simp, simp_diff] theorem HAdd.hAdd.arg_xy.adj_simp {X} [SemiHilbert X] 
  : (Function.uncurry HAdd.hAdd)† = λ xy' : X => (xy', xy') := sorry

-- @[simp, simp_diff]
-- theorem HAdd.hAdd.arg_xy.fwdDiff_simp  {X : Type} [Vec X] {α}
--   : (fwdDiff λ ((x,y) : (X×X)) => x + y) = λ ((x,y),dxy) => (x+y, λ a => (dxy a).1 + (dxy a).2) :=
-- by simp[fwdDiff]; done


-- Subtraction --
-----------------

function_properties HSub.hSub {X : Type} (x y : X) : X
argument x [Vec X] 
  isSmooth  := sorry, 
  diff_simp := dx by sorry
argument x [SemiHilbert X]
  hasAdjDiff := by constructor; infer_instance; simp; infer_instance; done,
  adjDiff_simp := dx' by simp[adjointDifferential]; unfold hold; simp; done
argument x [AddGroup X] [Nonempty X]
  isInv := sorry,
  inv_simp := x' + y by sorry
 
argument y [Vec X] 
  isSmooth  := sorry,
  diff_simp := - dy by sorry
argument y [SemiHilbert X]
  hasAdjDiff := by constructor; infer_instance; simp; infer_instance; done,
  adjDiff_simp := - dy' by simp[adjointDifferential]; done
argument y [AddGroup X] [Nonempty X]
  isInv := sorry,
  inv_simp := x - y' by sorry


instance HSub.hSub.arg_xy.isLin {X} [Vec X] 
  : IsLin (λ ((x, y) : (X × X)) => x - y) := sorry

instance HSub.hSub.arg_xy.hasAdjoint {X} [SemiHilbert X] 
  : HasAdjoint (λ ((x, y) : (X × X)) => x - y) := sorry

@[simp, simp_diff] theorem HSub.hSub.arg_xy.adj_simp {X} [SemiHilbert X] 
  : (Function.uncurry HSub.hSub)† = λ xy' : X => (xy', - xy') := sorry

-- @[simp, simp_diff]
-- theorem HSub.hSub.arg_xy.fwdDiff_simp  {X : Type} [Vec X] {α}
--   : (fwdDiff λ ((x,y) : (X×X)) => x - y) = λ ((x,y),dxy) => (x-y, λ a => (dxy a).1-(dxy a).2) :=
-- by simp[fwdDiff]; done


-- Inner product --
-------------------

function_properties Inner.inner {X} [Hilbert X] (x y : X) : ℝ
argument x
  isLin        := sorry,
  isSmooth, diff_simp, fwdDiff_simp,
  hasAdjoint   := sorry,
  adj_simp     := x' * y by sorry,
  hasAdjDiff   := by constructor; infer_instance; simp; infer_instance; done,
  adjDiff_simp := dx' * y by simp[adjointDifferential]; unfold hold; simp; done
argument y
  isLin        := sorry,
  isSmooth, diff_simp, fwdDiff_simp,
  hasAdjoint   := sorry,
  adj_simp     := y' * x by sorry,
  hasAdjDiff   := by constructor; infer_instance; simp; infer_instance; done,
  adjDiff_simp := dy' * x by simp[adjointDifferential]; done

@[simp, simp_diff]
theorem SemiInner.semiInner.on_reals (x y : ℝ) : ⟪x,y⟫ = x * y := by simp[Inner.inner]; done

-- @[simp, simp_diff]
-- theorem SemiInner.semiInner.arg_xy.fwdDiff_simp  {X : Type} [Hilbert X] {α}
--   : (fwdDiff λ (xy : (X×X)) => ⟪xy.1,xy.2⟫) = λ ((x,y),dxy) => (⟪x,y⟫, λ a => ⟪(dxy a).1,y⟫ + ⟪x,(dxy a).2⟫) :=
-- by simp[fwdDiff];; done


-- Squared Norm --
------------------

function_properties Inner.normSqr {X} [Hilbert X] (x : X) : ℝ
argument x
  isSmooth,
  diff_simp    := 2 * ⟪dx, x⟫ by simp[normSqr]; admit,
  -- fwdDiff_simp := λ a => (∥x∥², 2 * ⟪dx a, x⟫) by simp[fwdDiff]; done,
  hasAdjDiff,
  adjDiff_simp := ((2:ℝ) * dx') * x by simp[normSqr]; done 
