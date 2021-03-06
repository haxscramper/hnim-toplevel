# Package

version       = "0.2.29"
author        = "haxscramper"
description   = "Toplevel package"
license       = "Apache-2.0"

import hmisc/types/colorstring
import nimproj

# {.define(shellNoDebugOutput).}
# {.define(shellNoDebugError).}
# {.define(shellNoDebugCommand).}
# {.define(shellNoDebugRuntime).}


import shell, os
var noShell: set[DebugOutputKind]

let subdirs = @[
  "hparse",
  "hmisc",
  "nimtrs",
  "hdrawing",
  "ngspice",
  "hpprint",
  "hasts",
  "nimtraits",
  "hnimast",
  "hcparse"
]


func withDocs(dirs: seq[string]): seq[string] =
  for dir in dirs:
    result.add dir
    result.add &"{dir}-doc"

func onlyDocs(dirs: seq[string]): seq[string] =
  for dir in dirs:
    result.add &"{dir}-doc"

let gitcmd = "git -c color.status=always"

task statall, "Get git statistics for all subdirs":
  for dir in subdirs.withDocs():
    withDir dir:
      let (output, error, code) = shellVerboseErr noShell:
        ($gitcmd) status -s

      let (branch, _, _) = shellVerboseErr noShell:
        git branch "--show-current"

      if output.len == 0:
        echo branch.toYellow(), " ", dir.toGreen(), " no changes"
      else:
        echo dir.toGreen()
        echo output

proc pushdir(dir: string): void =
  withDir dir:
    let (output, error, code) = shellVerboseErr noShell:
        ($gitcmd) push --all

    if code == 0:
      echo dir.toGreen(), " done"
    else:
      echo dir.toRed(), " error"
      echo error


task pushdocs, "Push all documentation changes to repositories":
  for dir in subdirs.onlyDocs():
    pushDir(dir)

task pushall, "Push all commited changes to all repositories":
  for dir in subdirs.withDocs():
    pushDir(dir)

task testall, "Run tests for all subdirectories":
  for dir in subdirs:
    withDir dir:
      let (output, error, code) = shellVerboseErr noShell:
        nimble test

      if code != 0:
        echo dir.toRed(), " failed"
      else:
        echo dir.toGreen(), " ok"

proc docDir(dir: string) =
  let topdir = cwd()
  let release = true
  withDir dir:
    let outdir = topdir / (dir & "-doc")
    let url =
      if release:
         &"https://haxscramper.github.io/{dir}-doc"
      else:
        outdir

    echo &"{dir} -> {outdir}"
    docgenBuild(
      url, outdir,
      nimdocCss = topdir / "nimdoc.css",
      build = true
    )
    echo "done".toGreen()


task docall, "Generate documentation for all subdirectories":
  for dir in subdirs:
    if not dir.startsWith("hcparse"):
      docDir(dir)


task docone, "Generate documentation for on subdirectory":
  docDir("hmisc")

task commitdocs, "Commit all documentation changes":
  for dir in subdirs.onlyDocs():
    withDir dir:
      shell:
        "git add ."
        "git commit -m \"[DOC] documentation update\""

task test, "Test task":
  discard
