return function(sTool) local tSet = {} -- English ( Column "ISO 639-1" )
  tSet["tool."..sTool..".name"       ] = "Material Adv"
  tSet["tool."..sTool..".desc"       ] = "Advanced control over materials"
  tSet["tool."..sTool..".left"       ] = "Apply material"
  tSet["tool."..sTool..".right"      ] = "Copy material"
  tSet["tool."..sTool..".reload"     ] = "Revert material"
  tSet["tool."..sTool..".pattern_con"] = "Quick filter:"
  tSet["tool."..sTool..".pattern"    ] = "Enter pattern to search in the list"
  tSet["tool."..sTool..".random_con" ] = "Randomize count:"
  tSet["tool."..sTool..".random"     ] = "Change this so the tool will pick random material for you"
  tSet["tool."..sTool..".type_con"   ] = "Material type:"
  tSet["tool."..sTool..".type"       ] = "Select material source list from ones displayed here"
  tSet["tool."..sTool..".type_def"   ] = "Select list..."
return tSet end
