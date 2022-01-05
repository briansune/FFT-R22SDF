// =========================================================
// LOG BASE 2
// =========================================================
function integer clog2;
	input integer value;
	begin  
		value = value-1;
		for (clog2=0; value>0; clog2=clog2+1)
			value = value>>1;
		end  
endfunction
// =========================================================

// =========================================================
// LOG BASE 4
// =========================================================
function integer clog4;
	input integer value2;
	begin  
		value2 = value2-1;
		for (clog4=0; value2>0; clog4=clog4+1)
			value2 = value2>>2;
		end  
endfunction
// =========================================================