(************************************************************************)
(* Coq Language Server Protocol                                         *)
(* Copyright 2019 MINES ParisTech -- LGPL 2.1+                          *)
(* Copyright 2019-2023 Inria -- LGPL 2.1+                               *)
(* Written by: Emilio J. Gallego Arias                                  *)
(************************************************************************)

module Lang = JLang

(** {1 document/definition} *)
module LocationLink = struct
  type t =
    { originSelectionRange : Lang.Range.t option [@default None]
    ; targetUri : Lang.LUri.File.t
    ; targetRange : Lang.Range.t
    ; targetSelectionRange : Lang.Range.t
    }
  [@@deriving yojson]
end

(** {1 DocumentSymbols} *)
module DocumentSymbol = struct
  type t =
    { name : string
    ; detail : string option [@default None]
    ; kind : int
    ; tags : int list option [@default None]
    ; deprecated : bool option [@default None]
    ; range : Lang.Range.t
    ; selectionRange : Lang.Range.t
    ; children : t list option [@default None]
    }
  [@@deriving yojson]
end

(** Not used as of today, superseded by DocumentSymbol *)
module Location = struct
  type t =
    { uri : Lang.LUri.File.t
    ; range : Lang.Range.t
    }
  [@@deriving yojson]
end

(** Not used as of today, superseded by DocumentSymbol *)
module SymInfo = struct
  type t =
    { name : string
    ; kind : int
    ; location : Location.t
    }
  [@@deriving yojson]
end

(** {1 Hover} *)

module HoverContents = struct
  type t =
    { kind : string
    ; value : string
    }
  [@@deriving yojson]
end

module HoverInfo = struct
  type t =
    { contents : HoverContents.t
    ; range : Lang.Range.t option [@default None]
    }
  [@@deriving yojson]
end

(** {1 Completion} *)

module LabelDetails = struct
  type t = { detail : string } [@@deriving yojson]
end

module TextEditReplace = struct
  type t =
    { insert : Lang.Range.t
    ; replace : Lang.Range.t
    ; newText : string
    }
  [@@deriving yojson]
end

module CompletionData = struct
  type t =
    { label : string
    ; insertText : string option [@default None]
    ; labelDetails : LabelDetails.t option [@default None]
    ; textEdit : TextEditReplace.t option [@default None]
    ; commitCharacters : string list option [@default None]
    }
  [@@deriving yojson]
end

(** Code Lenses *)
module Command = struct
  type t =
    { title : string
    ; command : string
    ; arguments : Yojson.Safe.t list option [@default None]
    }
  [@@deriving yojson]
end

module CodeLens = struct
  type t =
    { range : Lang.Range.t
    ; command : Command.t option [@default None]
    ; data : Yojson.Safe.t option [@default None]
    }
  [@@deriving yojson]
end

(** SelectionRange *)
module SelectionRange = struct
  type t =
    { range : Lang.Range.t
    ; parent : t option [@default None]
    }
  [@@deriving yojson]
end

(** Pull Diagnostics *)
module DocumentDiagnosticParams = struct
  type t =
    { textDocument : string
    ; indentifier : string option [@default None]
    ; previousResultId : string option [@default None]
    ; workDoneToken : Base.ProgressToken.t option [@default None]
    ; partialResultToken : Base.ProgressToken.t option [@default None]
    }
  [@@deriving of_yojson]
end

module FullDocumentDiagnosticReport = struct
  type t =
    { kind : string
    ; resultId : string option [@default None]
    ; items : JLang.Diagnostic.t list
    }
  [@@deriving to_yojson]
end

module UnchangedDocumentDiagnosticReport = struct
  type t =
    { kind : string
    ; resultId : string option [@default None]
    }
  [@@deriving to_yojson]
end

module DocumentDiagnosticReportPartialResult = struct
  type t =
    { relatedDocuments :
        (JLang.LUri.File.t * FullDocumentDiagnosticReport.t) list
    }
  [@@deriving to_yojson]
end

(* Utility functions to translate between coordinate systems *)

let lsp_point_to_doc_point ~(doc : Fleche.Doc.t) point =
  let line, char = point in
  let line_count = Array.length doc.contents.lines in
  (* lines cannot be empty *)
  let line = min (line_count - 1) line in
  let s = Array.get doc.contents.lines line in
  let char = Coq.Utf8.get_unicode_offset_from_utf16_pos s char in
  (line, char)

let doc_point_to_lsp_point ~(doc : Fleche.Doc.t) (point: Lang.Point.t) =
  let s = Array.get doc.contents.lines point.line in
  let char = Coq.Utf8.get_utf16_offset_from_unicode_offset s point.character in
  { point with character = char }

let doc_range_to_lsp_range ~(doc : Fleche.Doc.t) (range: Lang.Range.t) =
  ({ start = doc_point_to_lsp_point ~doc range.start;
   end_ = doc_point_to_lsp_point ~doc range.end_ }: Lang.Range.t)
