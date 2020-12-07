#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TGDField
@author Tiago Rossini Coradini
@since 04/04/2017
@version 2.0
@description Classe para manipulação de campos em objetos GetDados e MsNewGetDados 
@type class
/*/

Class TGDField

	Data Fields
	
	Method New() Constructor	
	Method AddField(cFieldName)
	Method FieldName(cFieldName)
	Method Clear()
	Method GetHeader()

EndClass


Method New() Class TGDField
		
	::Fields := HashTable():New()

Return()


Method AddField(cFieldName) Class TGDField
Local aArea := SX3->(GetArea())
Local oField := TGDFieldProperties():New()
	
	If !Empty(cFieldName)

		DbSelectArea("SX3")
  	DbSetOrder(2)
  	If DbSeek(cFieldName)
			
			oField:cName := SX3->X3_CAMPO
			oField:cTitle := SX3->X3_TITULO
			oField:cPict := SX3->X3_PICTURE
			oField:nSize := SX3->X3_TAMANHO
			oField:nDecimal := SX3->X3_DECIMAL
			oField:cValid := SX3->X3_VALID
			oField:cUsed := SX3->X3_USADO
			oField:cType := SX3->X3_TIPO
			oField:cF3 := SX3->X3_F3
			oField:cContext := SX3->X3_CONTEXT
			oField:cCbox := SX3->X3_CBOX
			oField:cRelation := SX3->X3_RELACAO			
			oField:cWhen := SX3->X3_WHEN
			oField:cVisual := SX3->X3_VISUAL
			oField:cVldUser := SX3->X3_VLDUSER
			oField:cPictVar := SX3->X3_PICTVAR
			oField:lObrigat := Subs(Bin2Str(SX3->X3_OBRIGAT),1,1) == "x"
					
		Else
		
			oField:cName := cFieldName
			
  	EndIf
  	
  EndIf
	
	::Fields:Add(cFieldName, oField)	

	RestArea(aArea)
		
Return()


Method FieldName(cFieldName) Class TGDField

Return(::Fields:GetItem(cFieldName))


Method Clear() Class TGDField
	
	::Fields:Clear()
	
Return()


Method GetHeader() Class TGDField
Local nCount
Local aHeader := {}
	
	For nCount := 1 To ::Fields:GetCount()
		
		aAdd(aHeader, {::Fields:GetValue(nCount):cTitle, ::Fields:GetValue(nCount):cName, ::Fields:GetValue(nCount):cPict, ::Fields:GetValue(nCount):nSize,; 
									::Fields:GetValue(nCount):nDecimal, ::Fields:GetValue(nCount):cValid, ::Fields:GetValue(nCount):cUsed, ::Fields:GetValue(nCount):cType,;
									::Fields:GetValue(nCount):cF3, ::Fields:GetValue(nCount):cContext, ::Fields:GetValue(nCount):cCbox, ::Fields:GetValue(nCount):cRelation,;
									::Fields:GetValue(nCount):cWhen, ::Fields:GetValue(nCount):cVisual, ::Fields:GetValue(nCount):cVldUser, ::Fields:GetValue(nCount):cPictVar,;
									::Fields:GetValue(nCount):lObrigat})			
	Next

Return(aHeader)