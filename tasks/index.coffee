import * as t from "@dashkite/genie"
import preset from "@dashkite/genie-presets"
import FS from "fs/promises"
import Path from "path"
import { deployStack } from "./stack"

preset t

t.define "prepare-table", ->
  path = Path.resolve __dirname, "template.yaml"
  await deployStack "graphite-test-table", await FS.readFile path, "utf8"
