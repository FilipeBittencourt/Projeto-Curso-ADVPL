#include "PROTHEUS.CH"        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FROPGA01	ºAutor  ³Fernando Rocha      º Data ³ 18/02/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho para trazer automatico o codigo de  				  º±±
±±º          ³ acordo com o tipo do motivo.	                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES - cadastro de motivos de alteracao de reserva   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FROPGA01() 
Local _cAliasTmp
Local _cTipo

Private _cCodigo	:= ""
Private _cRet		:= ""
Private aAreaPZ4  := PZ4->(Getarea()) 
   	  
   	_cTipo := M->PZ4_TIPO
   	
	_cAliasTmp := GetNextAlias()
	BeginSql Alias _cAliasTmp
		%noparser%
		SELECT COD = CASE WHEN (SELECT COUNT(*) FROM %Table:PZ4% WHERE PZ4_TIPO = %EXP:_cTipo% AND D_E_L_E_T_=' ') > 0
			  THEN (SELECT ISNULL(RIGHT('000'+cast(convert(int, MAX(PZ4_CODIGO) )+1 as varchar(3)),3),'001') FROM %Table:PZ4% WHERE PZ4_TIPO = %EXP:_cTipo% AND D_E_L_E_T_=' ')
			  ELSE '001'
			  END
	EndSql
	
	(_cAliasTmp)->(DbGoTop())
	_cCodigo := (_cAliasTmp)->COD
	(_cAliasTmp)->(DbCloseArea())
	
	If Alltrim(_cCodigo) = ""
		_cCodigo := "001"
	EndIf
 
RestArea(aAreaPZ4)	
return(_cCodigo)

