// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function darken_bottom_row(_self)
{
	_self.darken_alpha += 0.02;
	if (_self.darken_alpha > 1) {
	    _self.darken_alpha = 1;
	}
}