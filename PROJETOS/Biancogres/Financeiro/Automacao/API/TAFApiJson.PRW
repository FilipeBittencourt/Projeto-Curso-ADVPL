#include "TOTVS.CH"

/*/{Protheus.doc} TAFApiJson
@description Classe para geracao e tratamentos de JSON
@since 01/10/2018
@version 1.0
@type class
/*/

Class TAFApiJson from LongClassName

	Method New() Constructor

	Method GerarJson(oObjeto)
	Method GetJsonObj(oObjeto)
	Method GetNameAPI(aLstFields, cFieldName)

EndClass


Method New() Class TAFApiJson

Return()


Method GerarJson(oObjeto) Class TAFApiJson

	Local cJson 	:= ""
	Local oJObj	

	oJObj := ::GetJsonObj(oObjeto)	

	cJson := FwJsonSerialize( oJObj, .F., .T.)

Return(cJson)


Method GetJsonObj(oObjeto) Class TAFApiJson

	Local ix, iy
	Local oJsonObj		:= JsonObject():New()
	Local aData 		:= ClassDataArr(oObjeto, .T.)
	Local nPLstField	:= aScan(aData,{|x| AllTrim(Upper(x[1])) == "ALSTFIELDS"})
	Local aLstFields
	Local _oJAuxArray
	Local _oJAuxObj

	If ( nPLstField > 0 )

		aLstFields := aData[nPLstField][2]

	EndIf

	For ix := 1 To Len(aData)

		If AllTrim(Upper(aData[ix][1])) == "ALSTFIELDS"
			loop
		EndIf

		If ValType(aData[ix][2]) <> "U"

			If (ValType(aData[ix][2]) == "A")

				_oJAuxArray := {}

				For iy := 1 To Len(aData[ix][2])

					_oJAuxObj := ::GetJsonObj(aData[ix][2][iy])

					AAdd(_oJAuxArray, _oJAuxObj)

				Next iy	

				oJsonObj[::GetNameAPI(aLstFields,aData[ix][1])] := _oJAuxArray		

			ElseIf (ValType(aData[ix][2]) == "O")

				oJsonObj[::GetNameAPI(aLstFields,aData[ix][1])] := ::GetJsonObj(aData[ix][2])

			Else

				oJsonObj[::GetNameAPI(aLstFields,aData[ix][1])] := aData[ix][2] 

			EndIf

		EndIf		

	Next ix	

Return(oJsonObj)


Method GetNameAPI(aLstFields, cFieldName) Class TAFApiJson

	If ( aLstFields == Nil )

		Return cFieldName

	Else

		Return aLstFields:GetAPIName(cFieldName)

	EndIf

Return ("")