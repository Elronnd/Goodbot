# Package
version       = "0.0.1"
author        = "Elijah Stone"
description   = "An IRC bot that isn\'t shit"
license       = "BSD 3-clause"
srcDir        = "src"
bin           = @["goodbot"]
skipExt       = @["nim"]


# Deps
requires "nim >= 0.17.0", "irc#head"
