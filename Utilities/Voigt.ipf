#pragma ModuleName = Voigt
#pragma IgorVersion = 6.2
#pragma rtGlobals = 1

Static Constant C1 = 0.53460
Static Constant C2 = 0.21660

Function Voigt1D(w, x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ IndependentVariable x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = f0
	//CurveFitDialog/ w[1] = scale
	//CurveFitDialog/ w[2] = x0
	//CurveFitDialog/ w[3] = width
	//CurveFitDialog/ w[4] = shape

	Return w[0] + w[1] * Voigt((x - w[2]) / w[3], w[4])
End

Function Voigt2D(w, x, y) : FitFunc
	Wave w
	Variable x, y

	//CurveFitDialog/ Independent Variables 2
	//CurveFitDialog/ x
	//CurveFitDialog/ y
	//CurveFitDialog/ Coefficients 8
	//CurveFitDialog/ w[0] = f0
	//CurveFitDialog/ w[1] = scale
	//CurveFitDialog/ w[2] = x0
	//CurveFitDialog/ w[3] = y0
	//CurveFitDialog/ w[4] = width
	//CurveFitDialog/ w[5] = shape
	//CurveFitDialog/ w[6] = ratio
	//CurveFitDialog/ w[7] = phase

	Return Ellipticize(EllipticVoigt, w, x - w[2], y - w[3], w[6], w[7])
End

Static Function EllipticVoigt(w, r)
	Wave w
	Variable r

	Return w[0] + w[1] * Voigt(r / w[4], w[5])
End

Function Voigt_Amplitude(scale, shape)
  Variable scale, shape

  Return scale * exp(shape^2) * erfc(shape)
End

Function Voigt1D_Amplitude(w)
	Wave w

	Return Voigt_Amplitude(w[1], w[4])
End

Function Voigt2D_Amplitude(w)
	Wave w

	Return Voigt_Amplitude(w[1], w[5])
End

Function Voigt_FWHM(width, shape)
	Variable width, shape

	Variable g = Voigt_GaussianFWHM(width)
	Variable l = Voigt_LorentzianFWHM(width, shape)

	Return C1 * l + sqrt(C2 * l^2 + g)
End

Function Voigt1D_FWHM(w)
	Wave w

	Return Voigt_FWHM(w[3], w[4])
End

Function Voigt2D_FWHM(w)
	Wave w

	Return Voigt_FWHM(w[4], w[5])
End

Function Voigt_GaussianFWHM(width)
	Variable width

	Return 2*ln(2) * width
End

Function Voigt1D_GaussianFWHM(w)
	Wave w

	Return Voigt_GaussianFWHM(w[3])
End

Function Voigt2D_GaussianFWHM(w)
	Wave w

	Return Voigt_GaussianFWHM(w[4])
End

Function Voigt_LorentzianFWHM(width, shape)
	Variable width, shape

	Return shape * Voigt_GaussianFWHM(width)
End

Function Voigt1D_LorentzianFWHM(w)
	Wave w

	Return Voigt_LorentzianFWHM(w[3], w[4])
End

Function Voigt2D_LorentzianFWHM(w)
	Wave w

	Return Voigt_LorentzianFWHM(w[4], w[5])
End

Function Voigt_Area(scale, width)
	Variable scale, width

	Return sqrt(pi) * scale * width
End

Function Voigt1D_Area(w)
	Wave w

	Return Voigt_Area(w[1], w[3])
End
