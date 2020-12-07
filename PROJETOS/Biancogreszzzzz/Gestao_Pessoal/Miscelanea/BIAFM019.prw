#include 'protheus.ch'
#include 'parmtype.ch'

User Function BIAFM019()

	Local I

	FOR I := 1 TO LEN(aPD)

		IF aPD[I][7] <> "I" .AND. M->RG_RESCDIS <> "0" .AND. cVerbaRot == "002"

			FDELPD(aPD[I][1])

		Elseif cVerbaRot == "003"

			fDelPd("425")
			fDelPd("399")

		Endif

	NEXT 

Return 