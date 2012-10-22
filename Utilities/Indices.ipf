#pragma ModuleName = Indices
#pragma IgorVersion = 6.2
#pragma rtGlobals = 1

Threadsafe Function nx(w)
	Wave w
	Return DimSize(w, 0)
End

Threadsafe Function ny(w)
	Wave w
	Return DimSize(w, 1)
End

Threadsafe Function nz(w)
	Wave w
	Return DimSize(w, 2)
End

Threadsafe Function nt(w)
	Wave w
	Return DimSize(w, 3)
End

Threadsafe Function p2x(w, p)
	Wave w
	Variable p

	Return DimLeft(w, 0, offset=p)
End

Threadsafe Function q2y(w, q)
	Wave w
	Variable q

	Return DimLeft(w, 1, offset=q)
End

Threadsafe Function r2z(w, r)
	Wave w
	Variable r

	Return DimLeft(w, 2, offset=r)
End

Threadsafe Function s2t(w, s)
	Wave w
	Variable s

	Return DimLeft(w, 3, offset=s)
End

Threadsafe Function x2p(w, x)
	Wave w
	Variable x

	Return (x - DimOffset(w, 0)) / DimDelta(w, 0)
End

Threadsafe Function y2q(w, y)
	Wave w
	Variable y

	Return (y - DimOffset(w, 1)) / DimDelta(w, 1)
End

Threadsafe Function z2r(w, z)
	Wave w
	Variable z

	Return (z - DimOffset(w, 2)) / DimDelta(w, 2)
End

Threadsafe Function t2s(w, t)
	Wave w
	Variable t

	Return (t - DimOffset(w, 3)) / DimDelta(w, 3)
End

Threadsafe Function DimLeft(w, d, [offset])
	Wave w
	Variable d
	Variable offset

	If (ParamIsDefault(offset))
		offset = 0
	EndIf

	Return DimOffset(w, d) + offset * DimDelta(w, d)
End

Threadsafe Function DimRight(w, d, [offset])
	Wave w
	Variable d
	Variable offset

	If (ParamIsDefault(offset))
		offset = -1
	EndIf

	Return DimLeft(w, d, offset=DimSize(w, d) + offset)
End


Threadsafe Function leftY(w)
	Wave w

	Return DimOffset(w, 1)
End

Threadsafe Function rightY(w)
	Wave w

	Return DimRight(w, 1, offset=0)
End

Threadsafe Function deltaY(w)
	Wave w

	Return DimDelta(w, 1)
End

Threadsafe Function leftZ(w)
	Wave w

	Return DimOffset(w, 2)
End

Threadsafe Function rightZ(w)
	Wave w

	Return DimRight(w, 2, offset=0)
End

Threadsafe Function deltaZ(w)
	Wave w

	Return DimDelta(w, 2)
End

Threadsafe Function leftT(w)
	Wave w

	Return DimOffset(w, 3)
End

Threadsafe Function rightT(w)
	Wave w

	Return DimRight(w, 3, offset=0)
End

Threadsafe Function deltaT(w)
	Wave w

	Return DimDelta(w, 3)
End

Threadsafe Function i2p(w, i)
	Wave w
	Variable i

	Return mod(i, nX(w))
End

Threadsafe Function i2q(w, i)
	Wave w
	Variable i

	Return floor(mod(i, nX(w)*nY(w)) / nX(w))
End

Threadsafe Function i2r(w, i)
	Wave w
	Variable i

	Return floor(mod(i, nX(w)*nY(w)*nZ(w)) / (nX(w)*nY(w)))
End

Threadsafe Function i2s(w, i)
	Wave w
	Variable i

	Return floor(i / nX(w)*nY(w)*nZ(w))
End

Threadsafe Function i2x(w, i)
	Wave w
	Variable i

	Return p2x(w, i2p(w, i))
End

Threadsafe Function i2y(w, i)
	Wave w
	Variable i

	Return q2y(w, i2q(w, i))
End

Threadsafe Function i2z(w, i)
	Wave w
	Variable i

	Return r2z(w, i2r(w, i))
End

Threadsafe Function i2t(w, i)
	Wave w
	Variable i

	Return s2t(w, i2s(w, i))
End

Threadsafe Function pq2i(w, p, q)
	Wave w
	Variable p, q

	Return pqrs2i(w, p, q, 0, 0)
End

Threadsafe Function pqr2i(w, p, q, r)
	Wave w
	Variable p, q, r

	Return pqrs2i(w, p, q, r, 0)
End

Threadsafe Function pqrs2i(w, p, q, r, s)
	Wave w
	Variable p, q, r, s

	Return p + DimSize(w, 0) * (q + DimSize(w, 1) * (r + DimSize(w, 2) * s))
End

Threadsafe Function NearestX(w, x)
	Wave w
	Variable x

	Return p2x(w, Round(x2p(w, x)))
End

Threadsafe Function NearestY(w, y)
	Wave w
	Variable y

	Return q2y(w, Round(y2q(w, y)))
End

Threadsafe Function NearestZ(w, z)
	Wave w
	Variable z

	Return r2z(w, Round(z2r(w, z)))
End

Threadsafe Function NearestT(w, t)
	Wave w
	Variable t

	Return s2t(w, Round(t2s(w, t)))
End
