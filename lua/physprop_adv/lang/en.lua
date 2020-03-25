﻿return function(sTool) local tSet = {} -- English ( Column "ISO 639-1" )
  tSet["tool."..sTool..".name"              ] = "Physics Properties Adv"
  tSet["tool."..sTool..".desc"              ] = "Advanced and extended version of the original physics properties tool"
  tSet["tool."..sTool..".left"              ] = "Apply the selected physical property"
  tSet["tool."..sTool..".right"             ] = "Cache the selected physical property"
  tSet["tool."..sTool..".right_use"         ] = "Cache the applied physical property"
  tSet["tool."..sTool..".reload"            ] = "Reset original physical property"
  tSet["tool."..sTool..".left_use"          ] = "Apply cached physical property"
  tSet["tool."..sTool..".material_type"     ] = "Select material type from the ones listed here"
  tSet["tool."..sTool..".material_type_def" ] = "Select type..."
  tSet["tool."..sTool..".material_name"     ] = "Select material name from the ones listed here"
  tSet["tool."..sTool..".material_name_def" ] = "Select name..."
  tSet["tool."..sTool..".gravity_toggle_con"] = "Enable gravity"
  tSet["tool."..sTool..".gravity_toggle"    ] = "When checked enables the gravity for an entity"
  tSet["tool."..sTool..".material_draw_con" ] = "Enable material draw"
  tSet["tool."..sTool..".material_draw"     ] = "Show trace entity surface material"
return tSet end