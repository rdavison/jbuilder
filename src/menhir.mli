(** Menhir rules *)

(** Return the list of targets that are generated by this stanza. This
    list of targets is used by the code that computes the list of
    modules in the directory. *)
val targets : Jbuild.Menhir.t -> string list

(** Return the list of modules that are generated by this stanza. *)
val module_names : Jbuild.Menhir.t -> Module.Name.t list

(** Generate the rules for a [(menhir ...)] stanza. *)
val gen_rules
  :  Compilation_context.t
  -> Jbuild.Menhir.t
  -> unit