import SciLean.Core.Mor
import SciLean.Core.Fun

namespace SciLean


-- Composition --
-----------------

function_properties Function.comp {X Y Z : Type} (f : Y → Z) (g : X → Y) (x : X) : Z
argument f [Vec Z]
  isLin      := by simp[Function.comp]; infer_instance,
  isSmooth   := by simp[Function.comp]; infer_instance,
  diff_simp  := df (g x) by simp[Function.comp]; done
argument g [Vec Y] [Vec Z]
  isLin     [IsLin f]    := by simp[Function.comp]; infer_instance,
  isSmooth  [IsSmooth f] := by simp[Function.comp]; infer_instance,
  diff_simp [IsSmooth f] := ∂ f (g x) (dg x) by simp[Function.comp]; done
argument x
  [Vec X] [Vec Y] [Vec Z]
  [IsLin f] [IsLin g]
  isLin     := by simp[Function.comp]; infer_instance
argument x
  [Vec X] [Vec Y] [Vec Z]
  [IsSmooth f] [IsSmooth g] 
  isSmooth  := by simp[Function.comp]; infer_instance,
  diff_simp := ∂ f (g x) (∂ g x dx) by simp[Function.comp]; done
argument x
  [SemiHilbert X] [SemiHilbert Y] [SemiHilbert Z]
  [HasAdjoint f] [HasAdjoint g]
  hasAdjoint := by simp[Function.comp]; infer_instance,
  adj_simp   := (g† ∘ f†) x' by simp[Function.comp]; done
argument x
  [SemiHilbert X] [SemiHilbert Y] [SemiHilbert Z]
  [HasAdjDiff f] [HasAdjDiff g]
  hasAdjDiff   := by simp[Function.comp]; infer_instance; done,
  adjDiff_simp := ((∂† g x) ∘ (∂† f (g x))) dx'  by simp[Function.comp]; done
  


-- function_properties Function.uncurry {X Y Z : Type} (f : X → Y → Z) (p : X×Y) : Z
-- argument f [Vec Z]
--   isLin      := by simp[Function.uncurry]; infer_instance,
--   isSmooth, diff_simp
-- argument p [Vec X] [Vec Y] [Vec Z]
-- argument g [Vec Y] [Vec Z]
--   isLin     [IsLin f]    := by simp[Function.comp]; infer_instance,
--   isSmooth  [IsSmooth f] := by simp[Function.comp]; infer_instance,
--   diff_simp [IsSmooth f] := ∂ f (g x) (dg x) by simp[Function.comp]; done
-- argument x
--   [Vec X] [Vec Y] [Vec Z]
--   [IsLin f] [IsLin g]
--   isLin     := by simp[Function.comp]; infer_instance
-- argument x
--   [Vec X] [Vec Y] [Vec Z]
--   [IsSmooth f] [IsSmooth g] 
--   isSmooth  := by simp[Function.comp]; infer_instance,
--   diff_simp := ∂ f (g x) (∂ g x dx) by simp[Function.comp]; done
-- argument x
--   [SemiHilbert X] [SemiHilbert Y] [SemiHilbert Z]
--   [HasAdjoint f] [HasAdjoint g]
--   hasAdjoint := by simp[Function.comp]; infer_instance,
--   adj_simp   := (g† ∘ f†) x' by simp[Function.comp]; done
-- argument x
--   [SemiHilbert X] [SemiHilbert Y] [SemiHilbert Z]
--   [HasAdjDiff f] [HasAdjDiff g]
--   hasAdjDiff   := by simp[Function.comp]; infer_instance; done,
--   adjDiff_simp := ((∂† g x) ∘ (∂† f (g x))) dx'  by simp[Function.comp]; done
  
