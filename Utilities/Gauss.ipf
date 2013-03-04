#pragma ModuleName = Gauss
#pragma IgorVersion = 6.2
#pragma rtGlobals = 3

Threadsafe Function Gauss2D_xWidth(w)
	Wave w
	
	Return sqrt( ((1 + alpha(w))*w[3]^2 + (1 - alpha(w))*w[5]^2) / 2)
End

Threadsafe Function Gauss2D_yWidth(w)
	Wave w
	
	Return sqrt( ((1 - alpha(w))*w[3]^2 + (1 + alpha(w))*w[5]^2) / 2)
End


Threadsafe Function Gauss2D_theta(w)
	Wave w
	
	Return atan(tan2th(w)) / 2
End

Threadsafe Static Function alpha(w)
	Wave w
	
	Return sqrt(1 + tan2th(w)^2)
End

Threadsafe Static Function tan2th(w)
	Wave w
	
	Return 2*w[6] / (w[3]/w[5] - w[5]/w[3])
End
