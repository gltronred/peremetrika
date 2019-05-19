#!/bin/bash

xq '.["fcd-export"].timestep | map({ time: .["@time"], vehicles: (if .vehicle then [.vehicle] | flatten | map ({ x: .["@x"], y: .["@y"], angle: .["@angle"], type: .["@type"]}) else [] end) })'

