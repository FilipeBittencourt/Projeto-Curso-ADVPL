#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BF01GPOL	ºAutor  ³Fernando Rocha      º Data ³ 03/03/2016  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gatilho busca politica para a tela de Proposta  Engenharia º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES 												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BF01GPOL()

Local nDTOT

Private _cCliente		:= M->Z68_CODCLI+M->Z68_LOJCLI
Private _cVendedor		:= M->Z68_CODVEN
Private _cProduto 		:= Gdfieldget("Z69_CODPRO" ,N)
Private _nQtdDig 		:= Gdfieldget("Z69_QTDVEN" ,N)
Private _cLinha			:= M->Z68_LINHA
Private _cCodCli 		:= M->Z68_CODCLI
Private _cLojCli		:= M->Z68_LOJCLI

//campos de desconto para alterar
Private _nPDESP			:= aScan(aHeader,{|x| AllTrim(x[2]) == "Z69_DESP"})
Private _nDESP			:= Acols[N][_nPDESP]

nDTOT := U_BF01GPXX(_cCliente, _cVendedor, _cProduto, _nQtdDig, _cLinha, _cCodCli, _cLojCli, _nDESP)

Return(nDTOT)


User Function BF01GPXX(_cCliente, _cVendedor, _cProduto, _nQtdDig, _cLinha, _cCodCli, _cLojCli, _nDESP, _lUpdACols)
Local aArea := GetArea()
Local aAreaA1 := SA1->(GetArea())    
Local nDTOT

Default _lUpdACols := .T.
                                                                     
Private _cSegmento := ""

//Verificando Segmento do Cliente
_cSegmento := U_fSegCliente(_cLinha, _cCodCli, _cLojCli) 

//Validacao de campos
If Empty(_cCliente) .Or. Empty(_cVendedor) .Or. Empty(_cProduto)
	MsgAlert("É obrigatório informar:  CLIENTE, VENDEDOR e PRODUTO - antes de digitar a quantidade vendida.","ATENÇÃO! POLITICA DE DESCONTO -> BF01GPOL")
	RestArea(aAreaA1)
	RestArea(aArea)
	return(0)
EndIf  
      
nDTOT := GAProc(_cCliente, _cVendedor, _cProduto, _nDESP, _cCodCli, _cLojCli, _nQtdDig, _lUpdACols)
               
RestArea(aAreaA1)
RestArea(aArea)

return(nDTOT)     

Static Function GAProc(_cCliente, _cVendedor, _cProduto, _nDESP, _cCodCli, _cLojCli, _nQtdDig, _lUpdACols) 
Local oDesconto
Local nDTOT
Local aAreaB1 := SB1->(GetArea())

Default _lUpdACols := .T.

oDesconto := TBiaPoliticaDesconto():New() 
         
oDesconto:_cCliente 	:= _cCliente
oDesconto:_cVendedor 	:= _cVendedor
oDesconto:_cProduto 	:= _cProduto
oDesconto:DESP			:= _nDESP

SB1->(DbSetOrder(1))
SB1->(DbSeek(XFilial("SB1")+_cProduto))

_aPal	:= CalcPalete(_cProduto, _nQtdDig)
oDesconto:_lPaletizado	:= ( _aPal[2] == _nQtdDig )

_aImposto		:= U_fGetImp({"IT_ALIQICM","IT_ALIQPIS","IT_ALIQCOF"}, _cCodCli, _cLojCli, _cProduto,, 0, 0, 0)

oDesconto:_nPICMS 		:= _aImposto[1]
oDesconto:_nPPIS		:= _aImposto[2]
oDesconto:_nPCOF		:= _aImposto[3]

_cComis1		:= Posicione("SA1",1,xFilial("SA1")+_cCodCli+_cLojCli,"A1_COMIS")
oDesconto:_nAComis		:= U_fCalComi(_cComis1,oDesconto:_cProduto)

oDesconto:DNV			:= Gdfieldget("Z69_DNV" ,N)

If oDesconto:GetPolitica()

	//Fernando em 22/11 - qualquer outro campo que for digitado que influencie na politica zerar a norma
	If ( !(ALLTRIM(__READVAR) $ 'M->Z69_DNV###M->Z69_DESP'))
		GdFieldPut("Z69_DNV", 0	,N)
		oDesconto:DNV := 0	
		oDesconto:Calculate()
	EndIf
	
	If ( ALLTRIM(__READVAR) == 'M->Z69_DNV' .And. oDesconto:DNV_MAX > 0 .And. Gdfieldget("Z69_DNV" ,N) > oDesconto:DNV_MAX )
		
		GdFieldPut("Z69_DNV", 0	,N)
		oDesconto:DNV := 0
		MsgAlert("Desconto de Norma - Máximo permitido é: "+AllTrim(Str(oDesconto:DNV_MAX))+"","ATENÇÃO! POLITICA DE DESCONTO -> BF01GPOL")		
		oDesconto:Calculate()
	
	ElseIf ( ALLTRIM(__READVAR) == 'M->Z69_DNV' .And. oDesconto:DNV_MAX == 0 )
	
		GdFieldPut("Z69_DNV", 0	,N)
		oDesconto:DNV := 0
		MsgAlert("Não existe NORMA cadastrada para esta venda.","ATENÇÃO! POLITICA DE DESCONTO -> BPOLGA01")		
		oDesconto:Calculate()
		
	EndIf

	nDTOT := oDesconto:DTOT
	
	If ( _lUpdACols )
	
		GdFieldPut("Z69_DCAT"	, oDesconto:DCAT 	,N)
		GdFieldPut("Z69_DPAL"	, oDesconto:DPAL 	,N) 
		GdFieldPut("Z69_DGER"	, oDesconto:DGER 	,N)
		GdFieldPut("Z69_DNV"	, oDesconto:DNV 	,N)
		GdFieldPut("Z69_DREG"	, oDesconto:DREG 	,N)
		
	EndIf

EndIf

RestArea(aAreaB1)
return(nDTOT) 

//calcular quantidade em palete fechado para atender pedido - produto posicionado - para reserva de OP
Static Function CalcPalete(cProduto, nQtdM2)
Local aAreaB1 := SB1->(GetArea())
Local nQtdCX
Local nDivPA := SB1->B1_YDIVPA
Local nQtdPalet, nInteiro, nDecimal 

SB1->(DbSetOrder(1))
SB1->(DbSeek(XFilial("SB1")+cProduto))

//Define quantidade na 2 Unidade de Medida
If SB1->B1_TIPCONV == "D"
	nQtdCX		:= (nQtdM2 / SB1->B1_CONV)
Else
	nQtdCX		:= (nQtdM2 * SB1->B1_CONV)
EndIf

nQtdPalet	:= nQtdCX / nDivPA

nInteiro	:= INT(nQtdPalet)
nDecimal	:= (nQtdPalet - INT(nQtdPalet))

If nDecimal <> 0

	//Define as novas quantidades
	nQtdPalet	:= nInteiro + 1
	nQtdCX		:= nQtdPalet * nDivPA
	
	If SB1->B1_TIPCONV == "D"
		nQtdM2	:= (nQtdCX * SB1->B1_CONV)
	Else
		nQtdM2	:= (nQtdCX / SB1->B1_CONV)
	EndIf
	
EndIf

RestArea(aAreaB1)
Return({nQtdPalet,nQtdM2})
