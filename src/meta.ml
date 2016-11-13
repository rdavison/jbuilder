open Import

type t =
  { name    : string
  ; entries : entry list
  }

and entry =
  | Comment of string
  | Var     of var
  | Package of t

and var = string * predicate list * action * string

and action = Set | Add

and predicate =
  | P of string
  | A of string

module Parse = struct
  let error = Loc.fail_lex

  let next = Meta_lexer.token

  let package_name lb =
    match next lb with
    | String s ->
      if String.contains s '.' then
        error lb "'.' not allowed in sub-package names";
      s
    | _ -> error lb "package name expected"

  let string lb =
    match next lb with
    | String s -> s
    | _ -> error lb "string expected"

  let lparen lb =
    match next lb with
    | Lparen -> ()
    | _ -> error lb "'(' expected"

  let action lb =
    match next lb with
    | Equal      -> Set
    | Plus_equal -> Add
    | _          -> error lb "'=' or '+=' expected"

  let rec predicates_and_action lb acc =
    match next lb with
    | Rparen -> (List.rev acc, action lb)
    | Name n -> after_predicate lb (P n :: acc)
    | Minus  ->
      let n =
        match next lb with
        | Name p -> p
        | _      -> error lb "name expected"
      in
      after_predicate lb (A n :: acc)
    | _          -> error lb "name, '-' or ')' expected"

  and after_predicate lb acc =
    match next lb with
    | Rparen -> (List.rev acc, action lb)
    | Comma  -> predicates_and_action lb acc
    | _      -> error lb "')' or ',' expected"

  let rec entries lb depth acc =
    match next lb with
    | Rparen ->
      if depth > 0 then
        List.rev acc
      else
        error lb "closing parenthesis without matching opening one"
    | Eof ->
      if depth = 0 then
        List.rev acc
      else
        error lb "%d closing parentheses missing" depth
    | Name "package" ->
      let name = package_name lb in
      lparen lb;
      let sub_entries = entries lb (depth + 1) [] in
      entries lb depth (Package { name; entries = sub_entries } :: acc)
    | Name var ->
      let preds, action =
        match next lb with
        | Equal      -> ([], Set)
        | Plus_equal -> ([], Add)
        | Lparen     -> predicates_and_action lb []
        | _          -> error lb "'=', '+=' or '(' expected"
      in
      let value = string lb in
      entries lb depth (Var (var, preds, action, value) :: acc)
    | _ ->
      error lb "'package' or variable name expected"
end

let load fn =
  with_lexbuf_from_file fn ~f:(fun lb ->
      Parse.entries lb 0 [])

let flatten t =
  let rec loop path acc_vars acc_pkgs entries =
    match entries with
    | [] -> (List.rev acc_vars, acc_pkgs)
    | entry :: rest ->
      match entry with
      | Comment _ ->
        loop path acc_vars acc_pkgs rest
      | Var v ->
        loop path (v :: acc_vars) acc_pkgs rest
      | Package { name; entries } ->
        let sub_path = sprintf "%s.%s" path name in
        let sub_vars, acc_pkgs = loop sub_path [] acc_pkgs entries in
        let acc_pkgs = (sub_path, sub_vars) :: acc_pkgs in
        loop path acc_vars acc_pkgs rest
  in
  let vars, pkgs = loop t.name [] [] t.entries in
  (t.name, vars) :: pkgs