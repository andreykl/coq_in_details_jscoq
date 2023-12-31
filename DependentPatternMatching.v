Module DestructuringLet.
  Inductive prod (A B : Type) : Type :=
    pair (a : A) (b : B).

  Arguments pair {A B} a b : assert.

  Definition fst {A B} (p : prod A B) : A := let 'pair a _ := p in a.

  Fail Definition eq_sym_refl {A} {x y : A} (H : x = y) : y = x := eq_refl.

  Definition eq_sym_eq_rect {A} {x y : A} (H : x = y) : y = x :=
    eq_rect _ (fun x' => x' = x) eq_refl _ H.

  Print eq_rect.

  Definition eq_sym_match {A} {x y : A} (H : x = y) : y = x :=
    match H with
    | eq_refl => eq_refl
    end.

  Lemma eq_sym_destruct {A} {x y : A} (H : x = y) : y = x.
  Proof.
    destruct H.
    reflexivity.
  Qed.

  Definition eq_sym_let {A} {x y : A} (H : x = y) : y = x :=
    let 'eq_refl := H in eq_refl.

  Definition eq_sym_let2 {A} {x y : A} (H : x = y) : y = x :=
    let e : y = x := let 'eq_refl := H in eq_refl in e.
End DestructuringLet.

Module BinaryWordV1.
  Inductive binary_word : nat -> Set :=
  | bw1 (b : bool) : binary_word 1
  | bwn {n} (b : bool) : binary_word n -> binary_word (S n).

  Fixpoint binary_word_concat {n m} (w1 : binary_word n) (w2 : binary_word m)
    : binary_word (n + m) :=
    match w1 with
    | bw1 b => bwn b w2
    | bwn b w => bwn b (binary_word_concat w w2)
    end.

  Fail Fixpoint binary_word_or {n} (w1 w2 : binary_word n) : binary_word n :=
    match w1, w2 with
    | bw1 b1, bw1 b2 => bw1 (b1 || b2)
    | bwn b1 pw1, bwn b2 pw2 => bwn (b1 || b2) (binary_word_or pw1 pw2)
    end.

  Fail Fixpoint binary_word_or {n} (w1 w2 : binary_word n) : binary_word n :=
    match w1, w2 with
    | bw1 b1, bw1 b2 => bw1 (b1 || b2)
    | bwn b1 pw1, bwn b2 pw2 => bwn (b1 || b2) (binary_word_or pw1 pw2)
    | bw, _ => bw
    end.

  Fail Fixpoint binary_word_or {n} (w1 w2 : binary_word n) : binary_word n :=
    match
      w1 in binary_word n1', w2 in binary_word n2'
      return n1' = n2' -> binary_word n1'
    with
    | bw1 b1, bw1 b2 => fun _ => bw1 (b1 || b2)
    | @bwn n1 b1 pw1, @bwn n2 b2 pw2 => fun e =>
        bwn (b1 || b2) (binary_word_or pw1 pw2)
    | bw, _ => fun _ => bw
    end eq_refl.

  Fail Fixpoint binary_word_or {n} (w1 w2 : binary_word n) : binary_word n :=
    match
      w1 in binary_word n1', w2 in binary_word n2'
      return n1' = n2' -> binary_word n1'
    with
    | bw1 b1, bw1 b2 => fun _ => bw1 (b1 || b2)
    | @bwn n1 b1 pw1, @bwn n2 b2 pw2 => fun e =>
       let pw2' : binary_word n1 := let 'eq_refl := e in pw2 in
       bwn (b1 || b2) (binary_word_or pw1 pw2')
    | bw, _ => fun _ => bw
    end eq_refl.

  Fail Fixpoint binary_word_or {n} (w1 w2 : binary_word n) : binary_word n :=
    match
      w1 in binary_word n1', w2 in binary_word n2'
      return n1' = n2' -> binary_word n1'
    with
    | bw1 b1, bw1 b2 => fun _ => bw1 (b1 || b2)
    | @bwn n1 b1 pw1, @bwn n2 b2 pw2 => fun (e : S n1 = S n2) =>
       let e' : n1 = n2 := let 'eq_refl := e in eq_refl in
       let pw2' : binary_word n1 := let 'eq_refl := e' in pw2 in
       bwn (b1 || b2) (binary_word_or pw1 pw2')
    | bw, _ => fun _ => bw
    end eq_refl.

  Fixpoint binary_word_or_pre {n} (w1 w2 : binary_word n) : binary_word n :=
    match
      w1 in binary_word n1', w2 in binary_word n2'
      return n1' = n2' -> binary_word n1'
    with
    | bw1 b1, bw1 b2 => fun _ => bw1 (b1 || b2)
    | @bwn n1 b1 pw1, @bwn n2 b2 pw2 => fun (e : S n1 = S n2) =>
       let e' : n2 = n1 := let 'eq_refl := e in eq_refl in
       let pw2' : binary_word n1 := let 'eq_refl := e' in pw2 in
       bwn (b1 || b2) (binary_word_or_pre pw1 pw2')
    | bw, _ => fun _ => bw
    end eq_refl.

  Fixpoint binary_word_or_good {n} (w1 w2 : binary_word n) : binary_word n :=
    match
      w1 in binary_word n1', w2 in binary_word n2'
      return n1' = n2' -> binary_word n1'
    with
    | bw1 b1, bw1 b2 => fun _ => bw1 (b1 || b2)
    | @bwn n1 b1 pw1, @bwn n2 b2 pw2 => fun e =>
       let pw2' : binary_word n1 := let 'eq_refl := eq_sym e in pw2 in
       bwn (b1 || b2) (binary_word_or_good pw1 pw2')
    | bw, _ => fun _ => bw
    end eq_refl.

  Lemma discriminate_bwn_SO_n {n} (w : binary_word n)
    :
    match w with
    | bw1 _ => False
    | _ => True
    end
    -> 1 = n
    -> False.
  Proof.
    remember w as w2 eqn:Heq.
    destruct w as [b | b n w]; intros H **; [subst; destruct H|].
    destruct w; discriminate.
  Qed.

  Fixpoint binary_word_or {n} (w1 w2 : binary_word n) : binary_word n :=
    match
      w1 in binary_word n1', w2 in binary_word n2'
      return n2' = n1' -> binary_word n1'
    with
    | bw1 b1, bw1 b2 => fun _ => bw1 (b1 || b2)
    | @bwn n1 b1 pw1, @bwn n2 b2 pw2 => fun e =>
       bwn (b1 || b2) (binary_word_or pw1 (let 'eq_refl := e in pw2))
    | bw1 _, bwn _ _ as bw => fun e =>
       False_rect _ (discriminate_bwn_SO_n bw I (eq_sym e))
    | bwn _ _ as bw, bw1 _ => fun e =>
       False_rect _ (discriminate_bwn_SO_n bw I e)
    end eq_refl.

  Fixpoint binary_word_or2 {n} (w1 w2 : binary_word n) : binary_word n :=
    match
      w1 in binary_word n1'
      return binary_word n1' -> n1' = n -> binary_word n1'
    with
    | bw1 b1 => fun w2 e0 =>
      match w2 in binary_word n2' return 1 = n2' -> binary_word n2' with
      | bw1 b2 => fun _ => bw1 (b1 || b2)
      | bwn b2 pw2 as bw => fun e1 =>
        False_rect _ (discriminate_bwn_SO_n bw I e1)
      end (let 'eq_refl := e0 in eq_refl)
    | @bwn n1 b1 pw1 as bw => fun w2 e0 =>
       match w2 in binary_word n2' return n2' = S n1 -> binary_word n2' with
       | bw1 b2 => fun e1 =>
         False_rect _ (discriminate_bwn_SO_n bw I e1)
       | @bwn n2 b2 pw2 as bw => fun e1 =>
         let 'eq_refl := eq_sym e1 in
         bwn (b1 || b2) (binary_word_or pw1 (let 'eq_refl := e1 in pw2))
       end (let 'eq_refl := e0 in eq_refl)
    end w2 eq_refl.
End BinaryWordV1.

Module CoqArt.
  Inductive binary_word : nat -> Set :=
  | bw0 :  binary_word 0
  | bwS (p : nat)(b:bool)(w: binary_word p) : binary_word (S p).

  Lemma discriminate_O_S {p:nat}:  0 = S p -> False.
  Proof.
    intros;discriminate.
  Qed.

  Lemma  discriminate_S_O {p:nat}:  S p = 0 -> False.
  Proof.
    intros;discriminate.
  Qed.

  Fixpoint binary_word_or (n:nat)(w1:binary_word n) {struct w1}:
    binary_word n -> binary_word n :=
    match w1 in binary_word p return binary_word p -> binary_word p with
      bw0 =>
	(fun w2:binary_word 0 =>
	   match w2 in binary_word p' return p'=0->binary_word p' with
	     bw0 =>
	       (fun h => bw0)
	   | bwS q b w2' =>
	       (fun h => False_rec (binary_word (S q)) (discriminate_S_O h))
	   end (refl_equal 0))
    | bwS q b1 w1' =>
	(fun w2:binary_word (S q) =>
	   match w2 in binary_word p' return S q=p'->binary_word p' with
	     bw0 =>
	       (fun h => False_rec (binary_word 0) (discriminate_S_O h))
	   | bwS q' b2 w2' =>
	       (fun h =>
		  bwS q'
		    (orb b1 b2)
		    (binary_word_or q'
		       (* this use of eq_rec transforms w1' into an element of (binary_word (S q'))
			  instead of (binary_word (S q)), thanks to the equality h. *)
		       (eq_rec (S q)
			  (fun v:nat => binary_word (pred v))
			  w1'
			  (S q')
			  (h:S q=S q'))
		       w2'))
	   end (refl_equal (S q)))
    end.

  Fixpoint binary_word_or' {n} (w1 w2 : binary_word n) : binary_word n :=
    match w1 in binary_word n1'
          return binary_word n1' -> n1' = n1' -> binary_word n1' with
    | bw0 => fun _ _ => bw0
    | bwS p1 b1 pw1 => fun '(bwS p2 b2 pw2) (e : S p2 = S p1) =>
        bwS _ (b1 || b2) (binary_word_or' pw1 (let 'eq_refl := e in pw2))
    end w2 eq_refl.
End CoqArt.

Inductive listn : nat -> Set :=
| niln : listn 0
| consn : forall n:nat, nat -> listn n -> listn (S n).

Definition tail n (v: listn (S n)) :=
  match v in listn (S m) return listn m with
  | niln => False_rect unit
  | consn n' a y => y
  end.

Module BinaryWord2.
  
  Inductive binary_word : nat -> Set :=
  | bw1 (b : bool) : binary_word 1
  | bwn {n} (b : bool) : binary_word (S n) -> binary_word (S (S n)).

  Fixpoint binary_word_or {n} (w1 w2 : binary_word n) : binary_word n :=
    match w1 in binary_word n1'
          return binary_word n1' -> n1' = n1' -> binary_word n1' with
    | bw1 b1 =>
        fun '(bw1 b2) _ => bw1 (b1 || b2)
    | @bwn n1 b1 pw1 =>
        fun '(@bwn n2 b2 pw2) (e : S (S n2) = S (S n1)) =>
          bwn (b1 || b2) (binary_word_or pw1 (let 'eq_refl := e in pw2))
    end w2 eq_refl.

  Definition to_S {n} (w : binary_word n) : {n' & binary_word (S n') & S n' = n} :=
    match w with
    | bw1 b' => existT2 _ _ 0 (bw1 b') eq_refl
    | @bwn n' b' w' => existT2 _ _ (S n') (bwn b' w') eq_refl
    end.

  Fixpoint binary_word_concat {n m} (w1 : binary_word n) (w2 : binary_word m)
    : binary_word (n + m) :=
    match w1 with
    | bw1 b =>
        let t3 : {m' & binary_word (S m') & S m' = m} := to_S w2 in
        let w2' := projT2 (sigT_of_sigT2 t3) in
        let 'eq_refl := projT3 t3 in bwn b w2'
    | bwn b w => bwn b (binary_word_concat w w2)
    end.

End BinaryWord2.

Module AdditionsAndSolutions.
  Import BinaryWordV1.
  
  Lemma binary_word_or_lemma : forall n (w1 w2 : binary_word n), binary_word n.
  Proof.
    fix F 2.
    intros n w1 w2.
    destruct w1 as [b1|n1 b1 pw1].
    { remember 1 as x eqn:Ex.
      remember w2 as w2' eqn:Ew2.
      destruct w2 as [b2|n2 b2 pw2].
      - apply (bw1 (b1 || b2)).
      - (* impossible case. we could just use `apply w2'` to solve the goal *)
        (* so, what we have below is just for fun *)
        injection Ex as Ex.
        subst n2.
        inversion pw2.
    }
    { remember (S n1) as x eqn:Ex.
      destruct w2 as [b2|n2 b2 pw2].
      - (* impossible case, so we just supply an appropriate value *)
        apply (bw1 true).
      - (* here we have 2 different types for terms pw1 and pw2 *)
        injection Ex as Ex.
        rewrite Ex in *.
        apply (bwn (b1 || b2) (F _ pw1 pw2)).
    }
  Qed.
    
  Lemma discriminate_bwn_SO_n' {n b pw} (w : binary_word (S n))
    : w = bwn b pw -> 1 = S n -> False.
  Proof.
    intros; destruct pw; discriminate.
  Qed.

  Fixpoint binary_word_or' {n} (w1 w2 : binary_word n) : binary_word n :=
    match
      w1 in binary_word n1', w2 in binary_word n2'
      return n2' = n1' -> binary_word n1'
    with
    | bw1 b1, bw1 b2 => fun _ => bw1 (b1 || b2)
    | bwn b1 pw1, bwn b2 pw2 => fun e =>
       bwn (b1 || b2) (binary_word_or' pw1 (let 'eq_refl := e in pw2))
    | bw1 _, bwn _ _ as bw => fun e =>
       False_rect _ (discriminate_bwn_SO_n' bw eq_refl (eq_sym e))
    | bwn _ _ as bw, bw1 _ => fun e =>
       False_rect _ (discriminate_bwn_SO_n' bw eq_refl e)
    end eq_refl.

  Fixpoint binary_word_or1 {n} (w1 w2 : binary_word n) : binary_word n :=
    match
      w1 in binary_word n1'
      return binary_word n1' -> n1' = n -> binary_word n1'
    with
    | bw1 b1 => fun w2 e0 =>
      match w2 in binary_word n2' return n = n2' -> binary_word n2' with
      | bw1 b2 => fun _ => bw1 (b1 || b2)
      | bwn b2 pw2 as bw => fun e1 =>
        False_rect _ (discriminate_bwn_SO_n bw I (eq_trans e0 e1))
      end (let 'eq_refl := e0 in eq_refl)
    | @bwn n1 b1 pw1 as bw => fun w2 e0 =>
       match w2 in binary_word n2' return n2' = n -> binary_word n2' with
       | bw1 b1 => fun e1 =>
         False_rect _ (discriminate_bwn_SO_n bw I (eq_trans e1 (eq_sym e0)))
       | @bwn n2 b2 pw2 as bw => fun e1 =>
         let e' : S n2 = S n1 := eq_trans e1 (eq_sym e0) in
         let 'eq_refl := eq_sym e' in
         bwn (b1 || b2) (binary_word_or pw1 (let 'eq_refl := e' in pw2))
       end (let 'eq_refl := e0 in eq_refl)
    end w2 eq_refl.
End AdditionsAndSolutions.
