#include "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM440SC9I	บAutor  ณFernando Rocha      บ Data ณ 02/10/2014  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApos gravar SC9											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BIANCOGRES												  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function M440SC9I
Local aArea := GetArea() 
Local cQuery         

//Ranisses em 27/01/16 
If cEmpAnt <> "02" 	

	//Edita Registro
	RecLock("SC9",.F.)

	If (!AllTrim(FunName()) == "BIAEC001")

		//Caso exista bloqueio de contrato, realiza o bloqueio no SC9
		If Type("nTpBlq") <> "U" .And. Substr(nTpBlq,1,2) == '06'  
	  
			If nTpBlq <> '065'  
	
				SC9->C9_YDTBLCT := dDataBase
				SC9->C9_YTPBLCT	:= nTpBlq			
				
				//Informa Bloqueio na Tela de Libera็ใo de PV
				If SC9->C9_CLIENTE == "010064"	
					cSql := "UPDATE SZN070 SET ZN_BLQPDCT = 'S', ZN_MSEXP = '' WHERE ZN_PEDIDO IN (SELECT C5_NUM FROM SC5070 WHERE C5_YPEDORI = '"+SC9->C9_PEDIDO+"' AND D_E_L_E_T_ = '') AND D_E_L_E_T_ = '' "
					If (TCSQLExec(cSql) < 0)
					    MsgStop("TCSQLError() " + TCSQLError())
					EndIf  
				Else
					//Informa Bloqueio na Tela de Libera็ใo de PV
					SZN->(DbSetOrder(1))
					If SZN->(DbSeek(XFilial("SZN")+SC9->C9_PEDIDO)) .And. SZN->ZN_BLQPDCT <> "S"
						RecLock("SZN",.F.)		
						SZN->ZN_BLQPDCT := 'S'
						SZN->(MsUnlock())			
					EndIf
				EndIf
					
			Else
	
				SC9->C9_YDTBLCT := dDataBase
				SC9->C9_YTPBLCT	:= nTpBlq  
				SC9->C9_YDTLICT	:= dDataBase
	
			EndIf
			
		EndIf
	

	EndIf

	//Grava o nome dos Produtos na tabela de Liberacao
	SC9->C9_YNOMPRD := Substr(SB1->B1_DESC,1,50)
	SC9->C9_QTDLIB2 := ConvUM(SC9->C9_PRODUTO,SC9->C9_QTDLIB,0,2)	
	
	//Grava Altera็ใo
	SC9->(MsUnlock())	

	//Ticket 22041 -> para disparar o processo de RA pra empenhos automaticos
	U_BIA859(SC9->C9_CLIENTE,SC9->C9_LOJA)

EndIf

          
//Fernando/Facile em 28/04/2015 - sempre gravar log de inclusao do SC9 - avaliando para relatorio
If Type("CUSERNAME") <> "U"
	U_GravaPZ2(SC9->(RecNo()),"SC9",SC9->C9_BLEST+SC9->C9_BLCRED,"M440SC9I",AllTrim(FunName()),"C9I", CUSERNAME)
EndIf

//Mantem a data da libera็ใo original
IF (AllTrim(FunName()) == "BIAEC001") .And. Type("__BECDTLORI") == "D" .And. !Empty(__BECDTLORI)
 
	U_GravaPZ2(SC9->(RecNo()),"SC9",DTOC(SC9->C9_DATALIB),"M440SC9I",AllTrim(FunName()),"ADL", CUSERNAME)
	
	RecLock("SC9",.F.)
	SC9->C9_DATALIB := __BECDTLORI 
	SC9->(MsUnlock())

EndIf

//Mantem a data da libera็ใo original - ROTINA DE REAJUSTE DE TABELA DE PREวO
IF Type("__RJDTEPORI") == "D" .And. !Empty(__RJDTEPORI)
 
	U_GravaPZ2(SC9->(RecNo()),"SC9",DTOC(SC9->C9_DATALIB),"M440SC9I",AllTrim(FunName()),"ADR", CUSERNAME)
	
	RecLock("SC9",.F.)
	SC9->C9_DATALIB := __RJDTEPORI 
	SC9->(MsUnlock())

	__RJDTEPORI := Nil

EndIf



//Grava Status do RA
IF (AllTrim(FunName()) == "BIAEC001") .And. Type("__nRAStatus") == "C" .And. !Empty(__nRAStatus)
 
	U_GravaPZ2(SC9->(RecNo()),"SC9",SC9->C9_YRASTAT,"M440SC9I",AllTrim(FunName()),"RAS", CUSERNAME)
	
	RecLock("SC9",.F.)
	SC9->C9_YRASTAT := __nRAStatus
	SC9->(MsUnlock())
	
EndIf

//Grava Libera็ใo de Contrato
IF (AllTrim(FunName()) == "BIAEC001") .And. Type("__YTPBLCT") == "C" .And. !Empty(__YTPBLCT)

	RecLock("SC9",.F.)
	SC9->C9_YTPBLCT := __YTPBLCT
	SC9->C9_YDTBLCT := __YDTBLCT
	SC9->C9_YDTLICT := __YDTLICT
	SC9->(MsUnlock())
	
EndIf

//Fernando/Facile em 25/08/2016 - Projeto rodape Vitcer - gravar o lote do pedido base no rodape da vitcer
SC5->(DbSetOrder(1))
If SC5->(DbSeek(SC9->(C9_FILIAL+C9_PEDIDO))) .And. SC5->C5_CLIENTE == "008615"  .And. !Empty(SC5->C5_YPEDBAS) 

	cQuery := ""
	
	cQuery += " update SC6140 "
	cQuery += " set C6_LOTECTL = '"+SC9->C9_LOTECTL+"', C6_MSEXP = '' "
	cQuery += " from SC5140 SC5 " 
	cQuery += " join SC6140 SC6 on C6_FILIAL = C5_FILIAL and C6_NUM = C5_NUM "
	cQuery += " where C5_FILIAL = '01' " 
	cQuery += " and C5_YEORIBS = '"+AllTrim(CEMPANT)+AllTrim(CFILANT)+"' " 
	cQuery += " and C5_YPEDBAS = '"+SC5->C5_NUM+"' "
	cQuery += " and C6_ITEM = '"+SC9->C9_ITEM+"' "
	cQuery += " and SC5.D_E_L_E_T_='' and SC6.D_E_L_E_T_ = '' "
	
	TCSQLExec(cQuery)

EndIf

RestArea(aArea)
Return()
