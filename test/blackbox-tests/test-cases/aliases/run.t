  $ $JBUILDER clean -j1 --display short --root .
  $ $JBUILDER build -j1 --display short --root . @just-in-src
  running in src
  $ $JBUILDER clean -j1 --display short --root .
  $ $JBUILDER build -j1 --display short --root . @everywhere
  running in src/foo/bar
  running in src/foo/baz
  running in src
  $ $JBUILDER clean -j1 --display short --root .
  $ $JBUILDER build -j1 --display short --root . @x
  running in src/foo/bar
  running in src/foo/baz
  running in src
  $ $JBUILDER build -j1 --display short --root . @plop
  From the command line:
  Error: Alias plop is empty.
  It is not defined in . or any of its descendants.
  [1]
  $ $JBUILDER build -j1 --display short --root . @truc/x
  From the command line:
  Error: Don't know about directory truc!
  [1]
