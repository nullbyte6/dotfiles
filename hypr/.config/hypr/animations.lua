hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("overshot",     { type = "bezier", points = { {0.13, 0.99}, {0.29, 1.1} } })
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1},    {0.32, 1}   } })
hl.curve("shot",         { type = "bezier", points = { {0.2, 1.0},   {0.2, 1.0}  } })
hl.curve("swipe",        { type = "bezier", points = { {0.6, 0.0},   {0.2, 1.05} } })
hl.curve("linear",       { type = "bezier", points = { {0, 0},       {1, 1}      } })
hl.curve("progressive",  { type = "bezier", points = { {1.0, 0.0},   {0.6, 1.0}  } })

hl.animation({ leaf = "windowsIn",  enabled = true, speed = 3,    bezier = "swipe",  style = "popin 20%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3,    bezier = "swipe",  style = "popin 20%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4,    bezier = "shot",   style = "slide" })
hl.animation({ leaf = "layers",     enabled = true, speed = 3.81, bezier = "swipe" })
hl.animation({ leaf = "layersIn",   enabled = true, speed = 3.2,  bezier = "swipe",  style = "slide bottom" })
hl.animation({ leaf = "layersOut",  enabled = true, speed = 3.2,  bezier = "swipe",  style = "slide" })
hl.animation({ leaf = "fade",       enabled = true, speed = 2.5,  bezier = "linear" })
hl.animation({ leaf = "border",     enabled = true, speed = 4,    bezier = "linear" })
