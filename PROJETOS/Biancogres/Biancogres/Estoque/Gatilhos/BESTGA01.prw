#include "protheus.ch"
#include "topconn.ch"
                    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BESTGA01	ºAutor  ³Fernando Rocha      º Data ³ 10/11/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho para calculo da quantidade do D3 apos digitar Peca º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BESTGA01()
Local _aAreaB1 := SB1->(GetArea())
Local _cProd
Local _nQTPC
Local _nQuant

If !( AllTrim(FunName()) $ "MATA241###MATA261" )
	Return 0
EndIf

_cProd 	:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "D3_COD"})]
_nQTPC 	:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "D3_YQTDPC"})]

If Empty(_cProd)
	MsgAlert("Informe primeiro o produto!")
	Return 0
EndIf

SB1->(DbSetOrder(1))
If ( SB1->(DbSeek(xFilial("SB1")+_cProd)) .And. SB1->B1_TIPO == "PA" ) 
	If ( SB1->B1_UM <> "PC" )
		_nQuant := ROUND(_nQTPC/SB1->B1_YPECA*SB1->B1_CONV,2)
	Else
		_nQuant := _nQTPC
	EndIf
Else
	_nQuant := 0
EndIf  

_nQuant := Round(_nQuant,2)

RestArea(_aAreaB1)

Return(_nQuant)
