/// @description
//draw_text_color(100, 100, "FFYL: " + string(fight_for_your_life), c_white, c_white, c_white, c_white, 1);

draw_text(0, 0, "Glow shader demo.\nWritten by @blokatt (06/06/19)\n" +
                "FPS: " + string(fps_real) +
                "\nGlow intensity (Q/W): " + string(uOuterIntensity) +
                "\nInner glow intensity (A/S): " + string(uInnerIntensity) + 
                "\nInner glow falloff (X/C): " + string(uInnerLengthMultiplier));
