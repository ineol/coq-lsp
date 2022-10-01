(************************************************************************)
(*         *   The Coq Proof Assistant / The Coq Development Team       *)
(*  v      *   INRIA, CNRS and contributors - Copyright 1999-2018       *)
(* <O___,, *       (see CREDITS file for the list of authors)           *)
(*   \VV/  **************************************************************)
(*    //   *    This file is distributed under the terms of the         *)
(*         *     GNU Lesser General Public License Version 2.1          *)
(*         *     (see LICENSE file for the text of the license)         *)
(************************************************************************)

(************************************************************************)
(* Coq Language Server Protocol                                         *)
(* Copyright (C) 2019 MINES ParisTech -- Dual License LGPL 2.1 / GPL3+  *)
(* Copyright (C) 2019-2022 Emilio J. Gallego Arias, INRIA               *)
(* Copyright (C) 2022-2022 Shachar Itzhaky, Technion                    *)
(************************************************************************)

(* Some issues due to different API in clients... *)
module type Point = sig
  type t

  val in_range : ?loc:Loc.t -> t -> bool
  val gt_range : ?loc:Loc.t -> t -> bool
end

module LineCol : Point with type t = int * int
module Offset : Point with type t = int

type approx =
  | Exact
  | PickPrev

module type S = sig
  module P : Point

  val goals :
    doc:Doc.t -> point:P.t -> approx:approx -> Coq.Goals.reified_pp option
end

module LC : S with module P := LineCol
module O : S with module P := Offset
