// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function darken_bottom_row(_self)
{
	var dAlpha = _self.darken_alpha;
	var gOffset = abs(_self.global_y_offset);
	var maxOffset = 64;
	
	var darken_percent = gOffset/maxOffset;
	
	
	if (darken_percent > 1) {
	    darken_percent = 1;
	}
	
	_self.darken_alpha = darken_percent;
}