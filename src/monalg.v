(* --------------------------------------------------------------------
 * (c) Copyright 2014--2015 IMDEA Software Institute.
 *
 * You may distribute this file under the terms of the CeCILL-B license
 * -------------------------------------------------------------------- *)

(* -------------------------------------------------------------------- *)
Require Import ssreflect ssrfun ssrbool eqtype ssrnat seq path choice.
Require Import finset fintype finfun tuple bigop ssralg ssrint.
Require Import ssrnum xfinmap fsfun.

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Import Monoid GRing.Theory Num.Theory.

Local Open Scope fset.
Local Open Scope fmap.
Local Open Scope ring_scope.

Delimit Scope malg_scope with MP.

Local Notation simpm := Monoid.simpm.
Local Notation ilift := fintype.lift.

Local Notation efst := (@fst _ _) (only parsing).
Local Notation esnd := (@snd _ _) (only parsing).

Delimit Scope m_scope with M.

(* -------------------------------------------------------------------- *)
Reserved Notation "{ 'malg' G [ K ] }"
  (at level 0, K, G at level 2, format "{ 'malg'  G [ K ] }").
Reserved Notation "{ 'malg' K }"
  (at level 0, K at level 2, format "{ 'malg'  K }").
Reserved Notation "[ 'malg' g ]"
  (at level 0, g at level 2, format "[ 'malg'  g ]").
Reserved Notation "[ 'malg' x : aT => E ]"
  (at level 0, x ident, format "[ 'malg'  x : aT  =>  E ]").
Reserved Notation "<< z *p k >>"
  (at level 0).
Reserved Notation "<< k >>"
  (at level 0).
Reserved Notation "g @_ k"
  (at level 3, k at level 2, left associativity, format "g @_ k").
Reserved Notation "c %:MP"
  (at level 2, format "c %:MP").

(* -------------------------------------------------------------------- *)
Module MonomialDef.

Record mixin_of (V : Type) : Type := Mixin {
  one : V;
  mul : V -> V -> V;
  _   : associative mul;
  _   : left_id one mul;
  _   : right_id one mul;
  _   : forall x y, mul x y = one -> x = one /\ y = one
}.

Section ClassDef.

Record class_of T := Class
 { base : Choice.class_of T; mixin : mixin_of T }.

Structure type := Pack {sort; _ : class_of sort; _ : Type}.

Local Coercion base : class_of >-> Choice.class_of.
Local Coercion sort : type >-> Sortclass.

Variables (T : Type) (cT : type).

Definition class := let: Pack _ c _ as cT' := cT return class_of cT' in c.
Definition clone c of phant_id class c := @Pack T c T.

Let xT := let: Pack T _ _ := cT in T.
Notation xclass := (class : class_of xT).

Definition pack m :=
  fun bT b & phant_id (Choice.class bT) b => Pack (@Class T b m) T.

Definition eqType := @Equality.Pack cT xclass xT.
Definition choiceType := @Choice.Pack cT xclass xT.

End ClassDef.

Module Exports.
Coercion base : class_of >-> Choice.class_of.
Coercion mixin : class_of >-> mixin_of.
Coercion sort : type >-> Sortclass.

Coercion  eqType : type >-> Equality.type.
Canonical eqType.
Coercion  choiceType : type >-> Choice.type.
Canonical choiceType.

Bind Scope m_scope with sort.

Notation monomType := type.
Notation MonomType T m := (@pack T m _ _ id).
Notation MonomMixin := Mixin.

Notation "[ 'monomType' 'of' T 'for' cT ]" := (@clone T cT _ idfun)
  (at level 0, format "[ 'monomType'  'of'  T  'for'  cT ]") : form_scope.
Notation "[ 'monomType' 'of' T ]" := (@clone T _ _ id)
  (at level 0, format "[ 'monomType'  'of'  T ]") : form_scope.
End Exports.
End MonomialDef.

(* -------------------------------------------------------------------- *)
Import MonomialDef.Exports.

Definition mone {M} := MonomialDef.one (MonomialDef.class M).
Definition mmul {M} := MonomialDef.mul (MonomialDef.class M).

(* -------------------------------------------------------------------- *)
Module ConomialDef.

Section ClassDef.

Record class_of (M : Type) : Type := Class {
  base  : MonomialDef.class_of M;
  mixin : commutative (MonomialDef.mul base)
}.

Structure type := Pack {sort; _ : class_of sort; _ : Type}.

Local Coercion base : class_of >-> MonomialDef.class_of.
Local Coercion sort : type >-> Sortclass.

Variables (T : Type) (cT : type).

Definition class := let: Pack _ c _ as cT' := cT return class_of cT' in c.
Definition clone c of phant_id class c := @Pack T c T.

Let xT := let: Pack T _ _ := cT in T.
Notation xclass := (class : class_of xT).

Definition pack mul0 (m0 : @commutative T T mul0) :=
  fun bT b & phant_id (MonomialDef.class bT) b =>
  fun    m & phant_id m0 m => Pack (@Class T b m) T.

Definition eqType     := @Equality.Pack cT xclass xT.
Definition choiceType := @Choice.Pack cT xclass xT.
Definition monomType  := @MonomialDef.Pack cT xclass xT.

End ClassDef.

Module Exports.
Coercion base  : class_of >-> MonomialDef.class_of.
Coercion mixin : class_of >-> commutative.
Coercion sort  : type >-> Sortclass.

Coercion eqType : type >-> Equality.type.
Coercion choiceType : type >-> Choice.type.
Coercion monomType : type >-> MonomialDef.type.

Canonical eqType.
Canonical choiceType.
Canonical monomType.

Bind Scope m_scope with sort.

Notation conomType := type.
Notation ConomType T m := (@pack T _ m _ _ id _ id).
Notation ConomMixin := MonomialDef.Mixin.

Notation "[ 'conomType' 'of' T 'for' cT ]" := (@clone T cT _ idfun)
  (at level 0, format "[ 'conomType'  'of'  T  'for'  cT ]") : form_scope.
Notation "[ 'conomType' 'of' T ]" := (@clone T _ _ id)
  (at level 0, format "[ 'conomType'  'of'  T ]") : form_scope.
End Exports.

End ConomialDef.

(* -------------------------------------------------------------------- *)
Export MonomialDef.Exports.
Export ConomialDef.Exports.

Local Notation "1" := (@mone _) : m_scope.
Local Notation "*%R" := (@mmul _) : m_scope.
Local Notation "x * y" := (mmul x y) : m_scope.

(* -------------------------------------------------------------------- *)
Module MonomialTheory.
Section Monomial.
Variable M : monomType.

Lemma mulmA : associative  (@mmul M). Proof. by case M => T [? []]. Qed.
Lemma mul1m : left_id  1%M (@mmul M). Proof. by case M => T [? []]. Qed.
Lemma mulm1 : right_id 1%M (@mmul M). Proof. by case M => T [? []]. Qed.

Local Open Scope m_scope.

Lemma unitm (x y : M) : x * y = 1 -> x = 1 /\ y = 1.
Proof. by case: M x y => T [? []]. Qed.

Canonical monom_monoid := Monoid.Law mulmA mul1m mulm1.

Lemma unitmP (x y : M) : reflect (x == 1 /\ y == 1) (x * y == 1).
Proof.
apply: (iffP idP)=> [|[/eqP-> /eqP->]]; rewrite ?mulm1 //.
by move/eqP/unitm=> [-> ->]; rewrite !eqxx.
Qed.
End Monomial.

Section Conomial.
Variable M : conomType.

Local Open Scope m_scope.

Lemma mulmC : commutative (@mmul M).
Proof. by case M => T []. Qed.

Canonical conom_monoid := Monoid.Law (@mulmA M) (@mul1m M) (@mulm1 M).
Canonical conom_comoid := Monoid.ComLaw mulmC.
End Conomial.

Module Exports.
Canonical monom_monoid.
Canonical conom_monoid.
Canonical conom_comoid.
End Exports.
End MonomialTheory.

Export MonomialTheory.Exports.

(* -------------------------------------------------------------------- *)
Section MalgDef.
Variable (K : choiceType) (G : zmodType).

Inductive malg : predArgType := Malg of {fsfun K -> G / 0}.

Definition malg_val g := let: Malg g := g in g.
Definition malg_of (_ : phant K) (_ : phant G) := malg.

Coercion malg_val : malg >-> fsfun_of.

Fact malg_key : unit. Proof. by []. Qed.

Definition malg_of_fsfun   k := locked_with k Malg.
Canonical  malg_unlockable k := [unlockable fun malg_of_fsfun k].
End MalgDef.

(* -------------------------------------------------------------------- *)
Bind Scope ring_scope with malg.
Bind Scope ring_scope with malg_of.

Notation "{ 'malg' G [ K ] }" :=
  (@malg_of _ _ (Phant K) (Phant G)) : type_scope.
Notation "{ 'malg' K }" :=
  {malg int[K]} : type_scope.

(* -------------------------------------------------------------------- *)
Section MalgCanonicals.
Variable (K : choiceType) (G : zmodType).

Canonical  malgType := Eval hnf in [newType for (@malg_val K G)].
Definition malg_eqMixin := Eval hnf in [eqMixin of {malg G[K]} by <:].
Canonical  malg_eqType := Eval hnf in EqType {malg G[K]} malg_eqMixin.
Definition malg_choiceMixin := Eval hnf in [choiceMixin of {malg G[K]} by <:].
Canonical  malg_choiceType := Eval hnf in ChoiceType {malg G[K]} malg_choiceMixin.
End MalgCanonicals.

(* -------------------------------------------------------------------- *)
Section MkMalg.
Variable (K : choiceType) (G : zmodType).

Definition mkmalg (g : {fsfun K -> G / 0}) : {malg G[K]} :=
  nosimpl (Malg g).

Definition mkmalgU (k : K) (x : G) :=
  nosimpl (mkmalg [fsfun [fmap].[k <- x] / 0]).
End MkMalg.

(* -------------------------------------------------------------------- *)
Notation "[ 'malg' g ]"
  := (mkmalg [fsfun g / 0]) : ring_scope.
Notation "[ 'malg' x : aT => E ]"
  := (mkmalg [fsfun [fmap x : aT => E] / 0]) : ring_scope.
Notation "<< z *g k >>"
  := (mkmalgU k z).
Notation "<< k >>"
  := << 1 *g k >> : ring_scope.

(* -------------------------------------------------------------------- *)
Section MalgBaseOp.
Variable (K : choiceType) (G : zmodType).

Definition msupp (g : {malg G[K]}) :=
  nosimpl (domf (malg_val g)).

Definition mcoeff (x : K) (g : {malg G[K]}) :=
  nosimpl (malg_val g x).
End MalgBaseOp.

Notation "g @_ k" := (mcoeff k g).

(* -------------------------------------------------------------------- *)
Section MalgBaseOpMonom.
Variable (K : monomType) (G : zmodType).

Definition malgC (c : G) : {malg G[K]} :=
  nosimpl << c *g 1%M >>.

Lemma malgCE (c : G) : malgC c = << c *g 1%M >>.
Proof. by []. Qed.
End MalgBaseOpMonom.

Notation "c %:MP" := (@malgC _ _ c).

(* -------------------------------------------------------------------- *)
Section MalgTheory.
Variable (K : choiceType) (G : zmodType).

Lemma mkmalgK (g : {fsfun K -> G / 0}) :
  mkmalg g = g :> {fsfun _ -> _ / _}.
Proof. by []. Qed.

Lemma malgP (g1 g2 : {malg G[K]}) :
  reflect (forall k, g1@_k = g2@_k) (g1 == g2).
Proof.
apply: (iffP eqP)=> [->//|]; move: g1 g2.
case=> [g1] [g2] h; apply/eqP; rewrite -val_eqE /=.
by apply/fsfunP=> k; move/(_ k): h.
Qed.

Lemma mcoeff_fnd (g : {fmap K -> G}) k :
  (mkmalg [fsfun g / 0])@_k = odflt 0 g.[?k].
Proof. by apply/fsfun_fnd. Qed.

Lemma mcoeffE (domf : {fset K}) (E : K -> G) k :
    [malg k : domf => E (val k)]@_k
  = if k \in domf then E k else 0.
Proof. by apply/fsfunE. Qed.

Lemma mcoeff_eq0 (g : {malg G[K]}) (k : K) :
  (g@_k == 0) = (k \notin msupp g).
Proof.
case: g; elim/fsfunW=> g; rewrite mcoeff_fnd /msupp domf_fsfunE.
case: fndP=> kf /=; first have: k = val (FSetSub kf) by [].
  by move=> {2}->; rewrite val_in_FSet -topredE /= negbK.
by rewrite eqxx; apply/esym/imfsetP=> h; case: h kf=> [[y]] ? _ -> /negP.
Qed.

Lemma mcoeff_neq0 (g : {malg G[K]}) (k : K) :
  (g@_k != 0) = (k \in msupp g).
Proof. by rewrite mcoeff_eq0 negbK. Qed.

Lemma mcoeff_outdom (g : {malg G[K]}) (k : K) :
  k \notin msupp g -> g@_k = 0.
Proof. by rewrite -mcoeff_eq0=> /eqP. Qed.

CoInductive msupp_spec (g : {malg G[K]}) (k : K) : bool -> G -> Type :=
| MsuppIn  (_ : k \in    msupp g) : msupp_spec g k true  g@_k
| MsuppOut (_ : k \notin msupp g) : msupp_spec g k false 0.

Lemma msuppP (g : {malg G[K]}) (k : K) : msupp_spec g k (k \in msupp g) g@_k.
Proof.
case: (boolP (k \in msupp g)); first by apply/MsuppIn.
by move=> k_notin_g; rewrite (mcoeff_outdom k_notin_g); apply/MsuppOut.
Qed.
End MalgTheory.

(* -------------------------------------------------------------------- *)
Section MalgZMod.
Variable (K : choiceType) (G : zmodType).

Implicit Types g : {malg G[K]}.
Implicit Types k : K.

Let EN g     k := - g@_k.
Let ED g1 g2 k := g1@_k + g2@_k.

Definition fgzero : {malg G[K]} :=
  [malg [fmap]].

Definition fgopp g :=
  [malg k : msupp g => - g@_(val k)].

Definition fgadd g1 g2 :=
  [malg k : (msupp g1 `|` msupp g2) => g1@_(val k) + g2@_(val k)].

Lemma fgzeroE k : fgzero@_k = 0.
Proof. by rewrite mcoeff_fnd !(in_fsetE, not_fnd). Qed.

Lemma fgoppE g k : (fgopp g)@_k = - g@_k.
Proof. by rewrite (mcoeffE _ (EN g)); case: msuppP; rewrite ?oppr0. Qed.

Lemma fgaddE g1 g2 k : (fgadd g1 g2)@_k = g1@_k + g2@_k.
Proof.
rewrite (mcoeffE _ (ED g1 g2)); rewrite in_fsetE /ED.
by case: (msuppP g1); case: (msuppP g2); rewrite !simpm.
Qed.

Let fgE := (fgzeroE, fgoppE, fgaddE).

Lemma fgaddA : associative fgadd.
Proof. by move=> x y z; apply/eqP/malgP=> k; rewrite !fgE addrA. Qed.

Lemma fgaddC : commutative fgadd.
Proof. by move=> x y; apply/eqP/malgP=> k; rewrite !fgaddE addrC. Qed.

Lemma fgadd0g : left_id fgzero fgadd.
Proof. by move=> x; apply/eqP/malgP=> k; rewrite !fgE add0r. Qed.

Lemma fgaddg0 : right_id fgzero fgadd.
Proof. by move=> x; rewrite fgaddC fgadd0g. Qed.

Lemma fgaddNg : left_inverse fgzero fgopp fgadd.
Proof. by move=> x; apply/eqP/malgP=> k; rewrite !fgE addNr. Qed.

Lemma fgaddgN : right_inverse fgzero fgopp fgadd.
Proof. by move=> x; rewrite fgaddC fgaddNg. Qed.

Definition malg_ZmodMixin := ZmodMixin fgaddA fgaddC fgadd0g fgaddNg.
Canonical  malg_ZmodType  := Eval hnf in ZmodType {malg G[K]} malg_ZmodMixin.
End MalgZMod.

Section MAlgZModTheory.
Context {K : choiceType} {G : zmodType}.

Implicit Types g   : {malg G[K]}.
Implicit Types k   : K.
Implicit Types x y : G.

Local Notation mcoeff  := (@mcoeff  K G) (only parsing).
Local Notation msupp   := (@msupp   K G).
Local Notation mkmalgU := (@mkmalgU K G) (only parsing).

Let fgE := (fgzeroE, fgoppE, fgaddE).

(* -------------------------------------------------------------------- *)
Lemma malgD_def g1 g2 : g1 + g2 = fgadd g1 g2.
Proof. by []. Qed.

(* -------------------------------------------------------------------- *)
Lemma mcoeff_is_additive k: additive (mcoeff k).
Proof. by move=> g1 g2 /=; rewrite !fgE. Qed.

Canonical mcoeff_additive k := Additive (mcoeff_is_additive k).

Lemma mcoeff0   k   : 0@_k = 0 :> G                . Proof. exact: raddf0. Qed.
Lemma mcoeffN   k   : {morph mcoeff k: x / - x}    . Proof. exact: raddfN. Qed.
Lemma mcoeffD   k   : {morph mcoeff k: x y / x + y}. Proof. exact: raddfD. Qed.
Lemma mcoeffB   k   : {morph mcoeff k: x y / x - y}. Proof. exact: raddfB. Qed.
Lemma mcoeffMn  k n : {morph mcoeff k: x / x *+ n} . Proof. exact: raddfMn. Qed.
Lemma mcoeffMNn k n : {morph mcoeff k: x / x *- n} . Proof. exact: raddfMNn. Qed.

Lemma mcoeffU k x k' : << x *g k >>@_k' = x *+ (k == k').
Proof. by rewrite mcoeff_fnd fnd_set fnd_fmap0 eq_sym; case: eqP. Qed.

Lemma mcoeffUU k x : << x *g k >>@_k = x.
Proof. by rewrite mcoeffU eqxx. Qed.

Let mcoeffsE := (mcoeff0, mcoeffU, mcoeffB, mcoeffD, mcoeffN, mcoeffMn).

(* -------------------------------------------------------------------- *)
Lemma msupp0 : msupp 0 = fset0 :> {fset K}.
Proof.
apply/fsetP=> k; rewrite in_fset0; apply/negbTE.
by rewrite -mcoeff_eq0 mcoeff0.
Qed.

Lemma msuppU k x : msupp << x *g k >> = if x == 0 then fset0 else [fset k].
Proof.
apply/fsetP=> k'; rewrite -mcoeff_neq0 mcoeffU 2!fun_if.
rewrite in_fset0 in_fset1 [k'==_]eq_sym; case: (x =P 0).
  by move=> ->; rewrite mul0rn eqxx.
  by move=> /eqP nz_x; case: (k =P k')=> //=; rewrite eqxx.
Qed.

Lemma msuppU_le {k x} : msupp << x *g k >> `<=` [fset k].
Proof. by rewrite msuppU; case: eqP=> _; rewrite (fsub0set, fsubset_refl). Qed.

Lemma msuppN g : msupp (-g) = msupp g.
Proof. by apply/fsetP=> k; rewrite -!mcoeff_neq0 mcoeffN oppr_eq0. Qed.

Lemma msuppD_le g1 g2 : msupp (g1 + g2) `<=` msupp g1 `|` msupp g2.
Proof.
apply/fsubsetP=> k; rewrite in_fsetU -mcoeff_neq0 mcoeffD.
by case: (msuppP g1); case: (msuppP g2)=> //=; rewrite addr0 eqxx.
Qed.

Lemma msuppB_le g1 g2 : msupp (g1 - g2) `<=` msupp g1 `|` msupp g2.
Proof. by rewrite -[msupp g2]msuppN; apply/msuppD_le. Qed.

Lemma msuppD g1 g2 : [disjoint msupp g1 & msupp g2] ->
  msupp (g1 + g2) = msupp g1 `|` msupp g2.
Proof.
move=> dj_g1g2; apply/fsetP=> k; rewrite in_fsetU.
rewrite -!mcoeff_neq0 mcoeffD; case: (boolP (_ || _)); last first.
  by rewrite negb_or !negbK => /andP[/eqP-> /eqP->]; rewrite addr0 eqxx.
wlog: g1 g2 dj_g1g2 / (k \notin msupp g2) => [wlog h|].
  case/orP: {+}h; rewrite mcoeff_neq0; last rewrite addrC.
    by move/(fdisjointP dj_g1g2)/wlog; apply.
  move/(fdisjointP_sym dj_g1g2)/wlog; apply.
    by rewrite fdisjoint_sym. by rewrite orbC.
by move=> /mcoeff_outdom ->; rewrite eqxx orbF addr0.
Qed.

Lemma msuppB g1 g2 : [disjoint msupp g1 & msupp g2] ->
  msupp (g1 - g2) = msupp g1 `|` msupp g2.
Proof. by move=> dj_g1g2; rewrite msuppD msuppN. Qed.

Lemma msuppMn_le g n : msupp (g *+ n) `<=` msupp g.
Proof.
elim: n => [|n ih]; first by rewrite mulr0n msupp0 fsub0set.
rewrite mulrS (fsubset_trans (msuppD_le _ _)) //.
by rewrite fsubUset fsubset_refl.
Qed.

Lemma msuppMNm_le g n : msupp (g *- n) `<=` msupp g.
Proof. by rewrite msuppN msuppMn_le. Qed.

(* -------------------------------------------------------------------- *)
Lemma monalgU_is_additive k : additive (mkmalgU k).
Proof. by move=> x1 x2 /=; apply/eqP/malgP=> k'; rewrite !mcoeffsE mulrnBl. Qed.

Canonical monalgU_additive k := Additive (monalgU_is_additive k).

Lemma monalgU0   k   : << (0 : G) *g k >> = 0        . Proof. exact: raddf0. Qed.
Lemma monalgUN   k   : {morph mkmalgU k: x / - x}    . Proof. exact: raddfN. Qed.
Lemma monalgUD   k   : {morph mkmalgU k: x y / x + y}. Proof. exact: raddfD. Qed.
Lemma monalgUB   k   : {morph mkmalgU k: x y / x - y}. Proof. exact: raddfB. Qed.
Lemma monalgUMn  k n : {morph mkmalgU k: x / x *+ n} . Proof. exact: raddfMn. Qed.
Lemma monalgUMNn k n : {morph mkmalgU k: x / x *- n} . Proof. exact: raddfMNn. Qed.

Lemma monalgU_eq0 x k: (<< x *g k >> == 0) = (x == 0).
Proof.
apply/eqP/eqP; last by move=> ->; rewrite monalgU0.
by move/(congr1 (mcoeff k)); rewrite !mcoeffsE eqxx.
Qed.

Definition monalgUE :=
  (monalgU0, monalgUB, monalgUD, monalgUN, monalgUMn).

(* -------------------------------------------------------------------- *)
Lemma monalgEw (g : {malg G[K]}) (domg : {fset K}) : msupp g `<=` domg ->
  g = \sum_(k : domg) << g@_(val k) *g val k >>.
Proof.
move=> le_gd; apply/eqP/malgP=> k /=; case: msuppP=> [kg|k_notin_g].
  rewrite raddf_sum /= (bigD1 (fincl le_gd (FSetSub kg))) //=.
  rewrite mcoeffUU big1 ?addr0 //; case=> [k' k'_in_g] /=.
  by rewrite eqE /= mcoeffU => /negbTE ->.
rewrite raddf_sum /= big1 //; case=> [k' k'g] _ /=.
by rewrite mcoeffU; case: eqP k_notin_g=> // <- /mcoeff_outdom ->.
Qed.

Lemma monalgE (g : {malg G[K]}) :
  g = \sum_(k : msupp g) << g@_(val k) *g val k >>.
Proof. by apply/monalgEw/fsubset_refl. Qed.
End MAlgZModTheory.

(* -------------------------------------------------------------------- *)
Section MalgMonomTheory.
Context {K : monomType} {G : zmodType}.

(* -------------------------------------------------------------------- *)
Lemma msuppC (c : G) :
  msupp c%:MP = (if c == 0 then fset0 else [fset 1%M]) :> {fset K}.
Proof. by apply/msuppU. Qed.

Lemma mcoeffC (c : G) k : c%:MP@_k = c *+ (k == (1%M : K)).
Proof. by rewrite mcoeffU eq_sym. Qed.

Lemma mcoeffC0 (k : K) : 0%:MP@_k = 0 :> G.
Proof. by rewrite mcoeffC mul0rn. Qed.

Lemma msuppC0 : msupp (0 : G)%:MP = fset0 :> {fset K}.
Proof. by rewrite msuppC eqxx. Qed.

Lemma malgC0E : 0%:MP = 0 :> {malg G[K]}.
Proof. by apply/eqP/malgP=> k; rewrite mcoeffC0 mcoeff0. Qed.

Lemma malgCK : cancel (@malgC K G) (@mcoeff K G 1%M).
Proof. by move=> c; rewrite mcoeffC eqxx mulr1n. Qed.

Lemma malgC_eq (c1 c2 : G) :
  (c1%:MP == c2%:MP :> {malg G[K]}) = (c1 == c2).
Proof. by apply/eqP/eqP=> [|->//] /eqP/malgP/(_ 1%M); rewrite !mcoeffU eqxx. Qed.

(* -------------------------------------------------------------------- *)
Local Notation malgC := (@malgC K G) (only parsing).

Lemma malgC_is_additive : additive malgC.
Proof. by move=> g1 g2; apply/eqP/malgP=> k; rewrite malgCE monalgUB. Qed.

Canonical malgC_additive : {additive G -> {malg G[K]}} :=
  Additive malgC_is_additive.

Lemma malgC0     : malgC 0 = 0               . Proof. exact: raddf0. Qed.
Lemma malgCN     : {morph malgC: x / - x}    . Proof. exact: raddfN. Qed.
Lemma malgCD     : {morph malgC: x y / x + y}. Proof. exact: raddfD. Qed.
Lemma malgCB     : {morph malgC: x y / x - y}. Proof. exact: raddfB. Qed.
Lemma malgCMn  k : {morph malgC: x / x *+ k} . Proof. exact: raddfMn. Qed.
Lemma malgCMNn k : {morph malgC: x / x *- k} . Proof. exact: raddfMNn. Qed.
End MalgMonomTheory.

(* -------------------------------------------------------------------- *)
Section MAlgLMod.
Variable (K : choiceType) (R : ringType).

Implicit Types g       : {malg R[K]}.
Implicit Types c x y z : R.
Implicit Types k l     : K.

Definition fgscale c g : {malg R[K]} :=
  \sum_(k : msupp g) << c * g@_(val k) *g val k >>.

Local Notation "c *:g g" := (fgscale c g)
  (at level 40, left associativity).

Lemma fgscaleE c g k :
  (c *:g g)@_k = c * g@_k.
Proof.
rewrite {2}[g]monalgE !raddf_sum mulr_sumr.
by apply/eq_bigr=> /= i _; rewrite !mcoeffU mulrnAr.
Qed.

Lemma fgscaleA c1 c2 g :
  c1 *:g (c2 *:g g) = (c1 * c2) *:g g.
Proof. by apply/eqP/malgP=> x; rewrite !fgscaleE mulrA. Qed.

Lemma fgscale1r D: 1 *:g D = D.
Proof. by apply/eqP/malgP=> k; rewrite !fgscaleE mul1r. Qed.

Lemma fgscaleDr c g1 g2 :
  c *:g (g1 + g2) = c *:g g1 + c *:g g2.
Proof. by apply/eqP/malgP=> k; rewrite !(mcoeffD, fgscaleE) mulrDr. Qed.

Lemma fgscaleDl g c1 c2:
  (c1 + c2) *:g g = c1 *:g g + c2 *:g g.
Proof. by apply/eqP/malgP=> x; rewrite !(mcoeffD, fgscaleE) mulrDl. Qed.

Definition malg_lmodMixin :=
  LmodMixin fgscaleA fgscale1r fgscaleDr fgscaleDl.
Canonical malg_lmodType :=
  Eval hnf in LmodType R {malg R[K]} malg_lmodMixin.
End MAlgLMod.

(* -------------------------------------------------------------------- *)
Section MAlgLModTheory.
Context {K : choiceType} {R : ringType}.

Implicit Types g       : {malg R[K]}.
Implicit Types c x y z : R.
Implicit Types k l     : K.

Lemma malgZ_def c g : c *: g = fgscale c g.
Proof. by []. Qed.

(* -------------------------------------------------------------------- *)
Lemma mcoeffZ c g k : (c *: g)@_k = c * g@_k.
Proof. by apply/fgscaleE. Qed.

Canonical mcoeff_linear m : {scalar {malg R[K]}} :=
  AddLinear ((fun c => (mcoeffZ c)^~ m) : scalable_for *%R (mcoeff m)).

(* -------------------------------------------------------------------- *)
Lemma msuppZ_le c g : msupp (c *: g) `<=` msupp g.
Proof.
apply/fsubsetP=> k; rewrite -!mcoeff_neq0 mcoeffZ.
by apply/contraTneq=> ->; rewrite mulr0 negbK.
Qed.
End MAlgLModTheory.

(* -------------------------------------------------------------------- *)
Section MAlgLModTheoryIdDomain.
Context {K : choiceType} {R : idomainType}.

Implicit Types g       : {malg R[K]}.
Implicit Types c x y z : R.
Implicit Types k l     : K.

(* -------------------------------------------------------------------- *)
Lemma msuppZ c g : msupp (c *: g) = if c == 0 then fset0 else msupp g.
Proof.
case: eqP=> [->|/eqP nz_c]; first by rewrite scale0r msupp0.
by apply/fsetP=> k; rewrite -!mcoeff_neq0 mcoeffZ mulf_eq0 negb_or nz_c.
Qed.
End MAlgLModTheoryIdDomain.

(* -------------------------------------------------------------------- *)
Definition mcoeffsE :=
  (@mcoeff0, @mcoeffUU, @mcoeffU, @mcoeffB, @mcoeffD,
   @mcoeffN, @mcoeffMn, @mcoeffZ).

(* -------------------------------------------------------------------- *)
Section MAlgRingType.
Variable (K : monomType) (R : ringType).

Implicit Types g       : {malg R[K]}.
Implicit Types c x y z : R.
Implicit Types k l     : K.

Lemma mcoeffU1 k k' : (<< k >> : {malg R[K]})@_k' = (k == k')%:R.
Proof. by rewrite mcoeffU. Qed.

Lemma msuppU1 k : @msupp _ R << k >> = [fset k].
Proof. by rewrite msuppU oner_eq0. Qed.

Definition fgone : {malg R[K]} := << 1%M >>.

Local Notation "g1 *M_[ k1 , k2 ] g2" :=
  << g1@_k1%M * g2@_k2%M *g (k1 * k2)%M >>
  (at level 40, no associativity, format "g1  *M_[ k1 ,  k2 ]  g2").

Local Notation "g1 *gM_[ k2 ] g2" :=
  (\sum_(k1 : msupp g1) g1 *M_[val k1, k2] g2)
  (at level 40, no associativity, only parsing).

Local Notation "g1 *Mg_[ k1 ] g2" :=
  (\sum_(k2 : msupp g2) g1 *M_[k1, val k2] g2)
  (at level 40, no associativity, only parsing).

Local Notation fg1mull_r g1 g2 k2 :=
  (fun k1 => g1 *M_[k1, k2] g2) (only parsing).

Local Notation fg1mulr_r g1 g2 k1 :=
  (fun k2 => g1 *M_[k1, k2] g2) (only parsing).

Local Notation fg1mull := (fg1mull_r _ _ _) (only parsing).
Local Notation fg1mulr := (fg1mulr_r _ _ _) (only parsing).

Definition fgmul g1 g2 : {malg R[K]} :=
  \sum_(k1 : msupp g1) \sum_(k2 : msupp g2)
    g1 *M_[val k1, val k2] g2.

Lemma fgmull g1 g2 :
  fgmul g1 g2 = \sum_(k1 : msupp g1) \sum_(k2 : msupp g2)
    g1 *M_[val k1, val k2] g2.
Proof. by []. Qed.

Lemma fgmulr g1 g2 :
  fgmul g1 g2 = \sum_(k2 : msupp g2) \sum_(k1 : msupp g1)
    g1 *M_[val k1, val k2] g2.
Proof. by rewrite fgmull exchange_big. Qed.

Let fg1mulzg g1 g2 k1 k2 : k1 \notin msupp g1 -> 
  << g1@_k1 * g2@_k2 *g (k1 * k2)%M >> = 0.
Proof. by move/mcoeff_outdom=> ->; rewrite mul0r monalgU0. Qed.

Let fg1mulgz g1 g2 k1 k2 : k2 \notin msupp g2 -> 
  << g1@_k1 * g2@_k2 *g (k1 * k2)%M >> = 0.
Proof. by move/mcoeff_outdom=> ->; rewrite mulr0 monalgU0. Qed.

Lemma fgmullw g1 g2 (d1 d2 : {fset K}) : msupp g1 `<=` d1 -> msupp g2 `<=` d2
  -> fgmul g1 g2 = \sum_(k1 : d1) \sum_(k2 : d2) g1 *M_[val k1, val k2] g2.
Proof.
move=> le_d1 le_d2; pose F k1 := g1 *Mg_[k1] g2.
rewrite fgmull (big_fset_incl F le_d1) {}/F /=; last first.
  by move=> k _ /fg1mulzg ?; rewrite big1.
apply/eq_bigr=> k1 _; rewrite (big_fset_incl fg1mulr le_d2) //.
by move=> x _ /fg1mulgz.
Qed.

Lemma fgmulrw g1 g2 (d1 d2 : {fset K}) : msupp g1 `<=` d1 -> msupp g2 `<=` d2
  -> fgmul g1 g2 = \sum_(k2 : d2) \sum_(k1 : d1) g1 *M_[val k1, val k2] g2.
Proof. by move=> le_d1 le_d2; rewrite (fgmullw le_d1 le_d2) exchange_big. Qed.

Definition fgmullwl {g1 g2} (d1 : {fset K}) (le : msupp g1 `<=` d1) :=
  @fgmullw g1 g2 _ _ le (fsubset_refl _).

Definition fgmulrwl {g1 g2} (d2 : {fset K}) (le : msupp g2 `<=` d2) :=
  @fgmulrw g1 g2 _ _ (fsubset_refl _) le.

Lemma fgmulElw g1 g2 (d1 d2 : {fset K}) k : msupp g1 `<=` d1 -> msupp g2 `<=` d2
  -> (fgmul g1 g2)@_k = \sum_(k1 : d1) \sum_(k2 : d2)
        (g1@_(val k1) * g2@_(val k2)) *+ ((val k1 * val k2)%M == k).
Proof.
move=> le1 le2; rewrite (fgmullw le1 le2) raddf_sum /=.
apply/eq_bigr=> k1 _; rewrite raddf_sum /=; apply/eq_bigr=> k2 _.
by rewrite mcoeffsE.
Qed.

Lemma fgmulErw g1 g2 (d1 d2 : {fset K}) k : msupp g1 `<=` d1 -> msupp g2 `<=` d2
  -> (fgmul g1 g2)@_k = \sum_(k2 : d2) \sum_(k1 : d1)
        (g1@_(val k1) * g2@_(val k2)) *+ ((val k1 * val k2)%M == k).
Proof. by move=> le1 le2; rewrite (fgmulElw _ le1 le2); rewrite exchange_big. Qed.

Lemma fgmul0g g : fgmul 0 g = 0.
Proof. by rewrite fgmull msupp0 big_fset0. Qed.

Lemma fgmulg0 g : fgmul g 0 = 0.
Proof. by rewrite fgmulr msupp0 big_fset0. Qed.

Lemma fgmulUg c k g (d : {fset K}) : msupp g `<=` d ->
 fgmul << c *g k >> g =
   \sum_(k' : d) << c * g@_(val k') *g (k * val k')%M >>.
Proof.
move=> le; rewrite (fgmullw msuppU_le le) big_fset1 /=.
by apply/eq_bigr=> /= k' _; rewrite mcoeffUU.
Qed.

Lemma fgmulgU c k g (d : {fset K}) : msupp g `<=` d ->
 fgmul g << c *g k >> =
   \sum_(k' : d) << g@_(val k') * c *g (val k' * k)%M >>.
Proof.
move=> le; rewrite (fgmulrw le msuppU_le) big_fset1 /=.
by apply/eq_bigr=> /= k' _; rewrite mcoeffUU.
Qed.

Lemma fgmulUU c1 c2 k1 k2 :
  fgmul << c1 *g k1 >> << c2 *g k2 >> = << c1 * c2 *g (k1 * k2)%M >>.
Proof. by rewrite (fgmullw msuppU_le msuppU_le) !big_fset1 /= !mcoeffUU. Qed.

Lemma fgmulEl1w {g1 g2} (d1 : {fset K}) : msupp g1 `<=` d1 -> fgmul g1 g2 =
  \sum_(k1 : d1) fgmul << g1@_(val k1) *g val k1 >> g2.
Proof.
move=> le; rewrite (fgmullwl le); apply/eq_bigr=> /= k _.
by rewrite -fgmulUg // fsubset_refl.
Qed.

Lemma fgmulEr1w {g1 g2} (d2 : {fset K}) : msupp g2 `<=` d2 -> fgmul g1 g2 =
  \sum_(k2 : d2) fgmul g1 << g2@_(val k2) *g val k2 >>.
Proof.
move=> le; rewrite (fgmulrwl le); apply/eq_bigr=> /= k _.
by rewrite -fgmulgU // fsubset_refl.
Qed.

Lemma fgmullUg_is_additive c k : additive (fgmul << c *g k >>).
Proof.
move=> g1 g2 /=; rewrite (fgmulUg _ _ (msuppB_le g1 g2)).
rewrite (fgmulUg _ _ (fsubsetUl _ (msupp g2))).
rewrite (fgmulUg _ _ (fsubsetUr (msupp g1) _)).
rewrite -sumrB; apply/eq_bigr=> /= k' _.
by rewrite mcoeffB -monalgUB mulrBr.
Qed.

Lemma fgmullgU_is_additive c k : additive (fun g => fgmul^~ << c *g k >> g).
Proof.
move=> g1 g2 /=; rewrite (fgmulgU _ _ (msuppB_le g1 g2)).
rewrite (fgmulgU _ _ (fsubsetUl _ (msupp g2))).
rewrite (fgmulgU _ _ (fsubsetUr (msupp g1) _)).
rewrite -sumrB; apply/eq_bigr=> /= k' _.
by rewrite mcoeffB -monalgUB mulrBl.
Qed.

Definition fgmullUg_additive c k := Additive (fgmullUg_is_additive c k).
Definition fgmullgU_additive c k := Additive (fgmullgU_is_additive c k).

Lemma fgoneE k : fgone@_k = (k == 1%M)%:R.
Proof. by rewrite mcoeffU1 eq_sym. Qed.

Lemma fgmulA : associative fgmul.
Proof.
move=> g1 g2 g3; have FE (G : seq {fset K}) :
  { E : {fset K} | all [pred g | g `<=` E] G }.
  exists (\big[fsetU/fset0]_(g <- G) g); apply/allP=> /=.
  move=> g; elim: G=> // a G ih /=; case/orP=> [/eqP->|/ih {ih} ih].
  by rewrite big_cons fsubsetUl.
  by rewrite big_cons fsubsetU // ih orbT.
case: (FE [seq msupp g | g <- [:: g1; g2; g3; fgmul g1 g2; fgmul g2 g3]]).
move=> E /and5P []/= le1 le2 le3 le12 /andP[le23 _] {FE}.
transitivity (\sum_(k1 : E) \sum_(k2 : E) \sum_(k3 : E)
  << g1@_(val k1) * g2@_(val k2) * g3@_(val k3) *g
       (val k1 * val k2 * val k3)%M >>).
+ rewrite (fgmulEl1w (d1 := E)) //; apply/eq_bigr=> /= k1 _.
  rewrite [X in fgmul _ X](fgmullw (d1 := E) (d2 := E)) //.
  have /= raddf := raddf_sum (fgmullUg_additive g1@_(val k1) (val k1)).
  rewrite raddf; apply/eq_bigr=> /= k2 _; rewrite raddf.
  by apply/eq_bigr=> /= k3 _; rewrite fgmulUU mulrA mulmA.
rewrite [LHS](eq_bigr _ (fun _ _ => exchange_big _ _ _ _ _ _)) /=.
rewrite exchange_big /=; apply/esym; rewrite (@fgmulEr1w _ _ E) //.
apply/eq_bigr=> /= k3 _; rewrite (@fgmullw g1 _ E E) //.
have /= raddf := raddf_sum (fgmullgU_additive g3@_(val k3) (val k3)).
rewrite raddf; apply/eq_bigr=> /= k1 _; rewrite raddf.
by apply/eq_bigr=> /= k2 _; rewrite fgmulUU.
Qed.

Lemma fgmul1g : left_id fgone fgmul.
Proof.
move=> g; rewrite fgmull; apply/eqP/malgP=> k.
rewrite msuppU1 big_fset1 [X in _=X@__]monalgE !raddf_sum /=.
by apply/eq_bigr=> kg _; rewrite fgoneE eqxx mul1r mul1m.
Qed.

Lemma fgmulg1 : right_id fgone fgmul.
Proof.
move=> g; rewrite fgmulr; apply/eqP/malgP=> k.
rewrite msuppU1 big_fset1 [X in _=X@__]monalgE !raddf_sum /=.
by apply/eq_bigr=> kg _; rewrite fgoneE eqxx mulr1 mulm1.
Qed.

Lemma fgmulgDl : left_distributive fgmul +%R.
Proof.
move=> g1 g2 g; apply/esym; rewrite
  (fgmullwl (fsubsetUl _ (msupp g2)))
  (fgmullwl (fsubsetUr (msupp g1) _)).
rewrite -big_split /= (fgmullwl (msuppD_le _ _)).
apply/eq_bigr=> k1 _; rewrite -big_split /=; apply/eq_bigr.
by move=> k2 _; rewrite mcoeffD mulrDl monalgUD.
Qed.

Lemma fgmulgDr : right_distributive fgmul +%R.
Proof.
move=> g g1 g2; apply/esym; rewrite
  (fgmulrwl (fsubsetUl _ (msupp g2)))
  (fgmulrwl (fsubsetUr (msupp g1) _)).
rewrite -big_split /= (fgmulrwl (msuppD_le _ _)).
apply/eq_bigr=> k1 _; rewrite -big_split /=; apply/eq_bigr.
by move=> k2 _; rewrite mcoeffD mulrDr monalgUD.
Qed.

Lemma fgoner_eq0 : fgone != 0.
Proof. by apply/malgP=> /(_ 1%M) /eqP; rewrite !mcoeffsE oner_eq0. Qed.

Definition malg_ringMixin :=
  RingMixin fgmulA fgmul1g fgmulg1 fgmulgDl fgmulgDr fgoner_eq0.
Canonical  malg_ringType :=
  Eval hnf in RingType {malg R[K]} malg_ringMixin.
End MAlgRingType.

(* -------------------------------------------------------------------- *)
Section MAlgRingTheory.
Variable (K : monomType) (R : ringType).

Delimit Scope m_scope with M.

Implicit Types g       : {malg R[K]}.
Implicit Types c x y z : R.
Implicit Types k l     : K.

(* -------------------------------------------------------------------- *)
Lemma malgM_def g1 g2 : g1 * g2 = fgmul g1 g2.
Proof. by []. Qed.

(* -------------------------------------------------------------------- *)
Lemma malgME g1 g2 :
  g1 * g2 = \sum_(k1 : msupp g1) \sum_(k2 : msupp g2)
    << g1@_(val k1) * g2@_(val k2) *g (val k1 * val k2)%M >>.
Proof. by []. Qed.

Lemma malgMEw g1 g2 (d1 d2 : {fset K}) :
  msupp g1 `<=` d1 -> msupp g2 `<=` d2 ->
  g1 * g2 = \sum_(k1 : d1) \sum_(k2 : d2)
    << g1@_(val k1) * g2@_(val k2) *g (val k1 * val k2)%M >>.
Proof. by apply/fgmullw. Qed.

(* -------------------------------------------------------------------- *)
Lemma mcoeffMl g1 g2 k :
  (g1 * g2)@_k = \sum_(k1 : msupp g1) \sum_(k2 : msupp g2)
    (g1@_(val k1) * g2@_(val k2)) *+ (val k1 * val k2 == k)%M.
Proof. by apply/fgmulElw; apply/fsubset_refl. Qed.

Lemma mcoeffMr g1 g2 k :
  (g1 * g2)@_k = \sum_(k2 : msupp g2) \sum_(k1 : msupp g1)
    (g1@_(val k1) * g2@_(val k2)) *+ (val k1 * val k2 == k)%M.
Proof. by apply/fgmulErw; apply/fsubset_refl. Qed.

(* -------------------------------------------------------------------- *)
Lemma mcoeffMlw g1 g2 (d1 d2 : {fset K}) k :
  msupp g1 `<=` d1 -> msupp g2 `<=` d2 ->
  (g1 * g2)@_k = \sum_(k1 : d1) \sum_(k2 : d2)
    (g1@_(val k1) * g2@_(val k2)) *+ (val k1 * val k2 == k)%M.
Proof. by apply/fgmulElw. Qed.

Lemma mcoeffMrw g1 g2 (d1 d2 : {fset K}) k :
  msupp g1 `<=` d1 -> msupp g2 `<=` d2 ->
  (g1 * g2)@_k = \sum_(k2 : d2) \sum_(k1 : d1)
    (g1@_(val k1) * g2@_(val k2)) *+ (val k1 * val k2 == k)%M.
Proof. by apply/fgmulErw. Qed.

(* -------------------------------------------------------------------- *)
Lemma mcoeff1 k : 1@_k = (k == 1%M)%:R :> R.
Proof. by rewrite mcoeffC. Qed.

Lemma mul_malgC c g : c%:MP * g = c *: g.
Proof.
rewrite malgCE malgM_def malgZ_def (fgmulUg _ _ (fsubset_refl _)).
by apply/eq_bigr=> /= k _; rewrite mul1m.
Qed.

Lemma mcoeffCM c g k : (c%:MP * g)@_k = c * g@_k :> R.
Proof. by rewrite mul_malgC mcoeffZ. Qed.

(* -------------------------------------------------------------------- *)
Lemma msuppM_le g1 g2 k :
  k \in msupp (g1 * g2) ->
    exists k1 : msupp g1, exists k2 : msupp g2, k = (val k1 * val k2)%M.
Proof.
move=> k_in_g1Mg2; apply/(existsPP (fun _ => exists_eqP)).
apply/contraLR: k_in_g1Mg2=> hk; rewrite -mcoeff_eq0.
rewrite mcoeffMl big1 // => /= k1 _; rewrite big1 // => k2 _.
case: eqP=> // kE; case/negP: hk; apply/existsP.
by exists k1; apply/existsP; exists k2; rewrite kE.
Qed.

(* -------------------------------------------------------------------- *)
Lemma malgC_is_multiplicative : multiplicative (@malgC K R).
Proof.
split=> // g1 g2; apply/eqP/malgP=> k.
by rewrite mcoeffCM !mcoeffC mulrnAr.
Qed.

Canonical malgC_rmorphism : {rmorphism R -> {malg R[K]}} :=
  AddRMorphism malgC_is_multiplicative.

(* -------------------------------------------------------------------- *)
Lemma mpolyC1E : 1%:MP = 1 :> {malg R[K]}.
Proof. exact: rmorph1. Qed.

Lemma mpolyC_nat (n : nat) : (n%:R)%:MP = n%:R :> {malg R[K]}.
Proof.
by apply/eqP/malgP=> i; rewrite mcoeffC mcoeffMn mcoeffC mulrnAC.
Qed.

Lemma mpolyCM : {morph @malgC K R : p q / p * q}.
Proof. exact: rmorphM. Qed.
End MAlgRingTheory.

(* -------------------------------------------------------------------- *)
Section MalgLAlgType.
Variable (K : monomType) (R : ringType).

Implicit Types g       : {malg R[K]}.
Implicit Types c x y z : R.
Implicit Types k l     : K.

(* -------------------------------------------------------------------- *)
Lemma fgscaleAl c g1 g2 : c *: (g1 * g2) = (c *: g1) * g2.
Proof. by rewrite -!mul_malgC mulrA. Qed.

Canonical malg_lalgType :=
  Eval hnf in LalgType R {malg R[K]} fgscaleAl.
End MalgLAlgType.

(* -------------------------------------------------------------------- *)
Section MalgComRingType.
Variable (K : conomType) (R : comRingType).

Implicit Types g       : {malg R[K]}.
Implicit Types c x y z : R.
Implicit Types k l     : K.

Lemma fgmulC : @commutative {malg R[K]} _ *%R.
Proof.
move=> g1 g2; apply/eqP/malgP=> k; rewrite mcoeffMl mcoeffMr.
apply/eq_bigr=> /= k1 _; apply/eq_bigr=> /= k2 _.
by rewrite mulrC [X in X==k]mulmC.
Qed.

Canonical malg_comRingType :=
  Eval hnf in ComRingType {malg R[K]} fgmulC.
Canonical malg_algType :=
  Eval hnf in CommAlgType R {malg R[K]}.
End MalgComRingType.