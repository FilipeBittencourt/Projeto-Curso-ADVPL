#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FROPGA03	ºAutor  ³Fernando Rocha      º Data ³ 31/03/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho para liberacao de quantidade no MATA440	          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES 												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#DEFINE TIT_MSG "SISTEMA - RESERVA DE ESTOQUE/OP"

User Function FROPGA03()
Local aArea := GetArea()
Local _lPswOk := .T.
                                                                                 
Local _cItem 	:= Gdfieldget("C6_ITEM",n)
Local _cProd 	:= Gdfieldget("C6_PRODUTO",n)
Local _cLocal 	:= Gdfieldget("C6_LOCAL",n)
Local _nQtdDig 	:= Round( Gdfieldget("C6_QTDLIB",n) ,2)
Local _cLote	:= Gdfieldget("C6_LOTECTL",n)

Local _cPedido := M->C5_NUM
Local _cGerente := U_FRGERADM(_cPedido)                 

If M->C5_TIPO == 'N' .And. ( AllTrim(cEmpAnt) $ "01_05_13_14" ) .And. M->C5_YLINHA <> "4" .And. !(_cLocal == AllTrim(GetNewPar("FA_LOCAMO","05")))

	_aRet := U_FR2CHKPT(_cProd, _cLote, _nQtdDig,,_cPedido,_cItem)  
	
	//se vai gerar ponta - aciona autorizacao de superior
	If _lPswOk .And. _aRet[1] == "P" 
		
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(XFilial("SB1")+_cProd))	
	
		_aRetAut := U_FROPTE10(AllTrim(SB1->B1_DESC),_cLote,Transform(_nQtdDig,"@E 999,999.99"),Transform(_aRet[2],"@E 999,999.99"),Transform(_aRet[2]+_nQtdDig,"@E 999,999.99"),_cGerente)
		_lPswOk := _aRetAut[1]		
		
		If _lPswOk 
			
			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(XFilial("SC6")+_cPedido+_cItem))
				U_GravaPZ2(SC6->(RecNo()),"SC6",_aRetAut[4],_aRetAut[3],AllTrim(FunName()),"AGP", _aRetAut[2] )
			EndIf
			
		EndIf
		
	EndIf
	
	If !_lPswOk
		_nQtdDig := 0
	Else
		Gdfieldput("C6_YMOTFRA"	,"998",N) //Marcando como gerado ponta para relatorio
	EndIf 

EndIf

RestArea(aArea)
return(_nQtdDig)
