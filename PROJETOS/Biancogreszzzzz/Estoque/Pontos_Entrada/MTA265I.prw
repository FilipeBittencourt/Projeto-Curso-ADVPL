#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA265I	ºAutor  ³Fernando Rocha      º Data ³ 24/09/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE - Apos a gravacao da distribuicao de produtos			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MTA265I()

Private _nLinha 	:= ParamIxb[1]// Atualização de arquivos ou campos do usuário após a Inclusão da Distribuição do Produto
Private _nQuant 	:= aCols[_nLinha][aScan(aHeader,{|x| AllTrim(x[2]) == "DB_QUANT"})]
Private _cLocaliz	:= aCols[_nLinha][aScan(aHeader,{|x| AllTrim(x[2]) == "DB_LOCALIZ"})]
Private _cNumSeri	:= aCols[_nLinha][aScan(aHeader,{|x| AllTrim(x[2]) == "DB_NUMSERI"})]
Private _cDocNum 	:= M->DA_DOC
Private _cNumSeq 	:= M->DA_NUMSEQ
Private _cProduto	:= M->DA_PRODUTO
Private _cLote		:= M->DA_LOTECTL
Private _cLocal		:= M->DA_LOCAL
      
//Funcao de processamente de Reservas
//Projeto reserva de OP - Fernando/Facile - em 09/10/2014

//If !Upper(AllTrim(getenvserver())) == "FACILE-DES-RESERVA" 
If AllTrim(CEMPANT) $ "13" //simulacao - manter a distribuicao/reserva automatica somente para incesa e mundi - bianco vai fazer pela rotina nova

	U_FRRT04PP(_nLinha,_nQuant,_cLocaliz,_cNumSeri,_cDocNum,_cNumSeq,_cProduto,_cLote,_cLocal)

EndIf

Return