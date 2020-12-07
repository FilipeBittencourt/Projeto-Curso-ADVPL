#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} F200VAR
@author Microsiga Vitoria
@since 23/03/06
@version 1.0
@description Utilizado para correção de algumas variaveis do CNAB a Receber 
@history 21/11/2018, Ranisses A. Corona, Ajustes no posicionamento das tabelas abertas
@type function
/*/

User Function F200VAR()
Local aAreaSE1	:= SE1->(GetArea())
Local aAreaSE5	:= SE5->(GetArea())
Local cArq		:= ""
Local cInd		:= 0
Local cReg		:= 0

//Armazena area de Trabalho
cArq := Alias()
cInd := IndexOrd()
cReg := Recno()
	
//Executa as funcoes
U_fAceJur()
U_fAceVal()
U_fAceDDA()

// Alteração efetuada em 12/07/11 por Marcos Alberto atendendo a solicitação do Sr. Vagner Salles para tratamento da data da Baixa diferente da variável dDataBase
If dBaixa <> dDataBase
	MsgINFO("O Título " + ParamIXB[1][1] + " está com a Data de Baixa diferente da Data Base. Este é apenas um alerta, pois a data será ajustada. Favor verificar!!!")
	Paramixb[1][2] := dDataBase
	dBaixa         := dDatabase
EndIf

RestArea(aAreaSE1)
RestArea(aAreaSE5)

//Volta area de Trabalho
DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return

//---------------------------------------------------------------------
User Function fAceJur()

If nJuros == 0
	If nValCc >0
		nJuros := nValCc
		nValCc := 0
	EndIf
EndIf

Return

//---------------------------------------------------------------------
User Function fAceVal()
Local lFina200	:= Iif( !Alltrim(FunName()) == "FINR650" , .T. , .F. ) 
Local nTipo		:= ""
Local nNsNum	:= ""
Local cNosNum	:= Iif( lFina200 , cNsNum , cNossoNum )

//Tipo do Titulo
If Alltrim(cTipo) == "01"
	nTipo := "NF"
ElseIf Alltrim(cTipo) == "06
	nTipo := "FT"
EndIf

//Busca o Numero
cAliasTmp := GetNextAlias()
BeginSql Alias cAliasTmp
	SELECT MAX(E1_PREFIXO+E1_NUM+E1_PARCELA) NUMERO
	FROM  %Table:SE1%
	WHERE 	E1_PREFIXO 	= %Exp:SUBSTR(cNumTit,1,1)% 	AND 
			E1_PARCELA	= %Exp:SUBSTR(cNumTit,10,1)% 	AND                                      
			E1_TIPO 	= %Exp:nTipo% 					AND
			(E1_NUM = %Exp:SUBSTR(cNumTit,4,6)% OR E1_NUM = %Exp:"000"+SUBSTR(cNumTit,4,6)%) AND 
			%NOTDEL%
EndSql
nNsNum	:= (cAliasTmp)->NUMERO
(cAliasTmp)->(dbCloseArea())

If Empty(cNosNum)                  
	//MsgBox("Nosso Número não encontrado no retorno bancário. O sistema irá realizar a pequisa através do PREFIXO+NUMERO+PARCELA.","FA200VAR","ALERT")
	If lFina200	//verificar a necessida do return
		Return
	EndIf
Else
	//POSICIONA ATRAVES DO NOSSO NUMERO
	SE1->(dbOrderNickName("YNOSSONUM")) 
	If SE1->(dbSeek(xFilial("SE1")+cNosNum,.T.))
		lRet := .T.
	Else
		//POSICIONA ATRAVES DO PREFIXO+NUMERO+PARCELA+TIPO
		SE1->(dbSetOrder(1))
		If SE1->(dbSeek(xFilial("SE1")+nNsNum+nTipo,.T.))   
			lRet := .T.
		Else
			lRet := .F.
			//MsgBox("O sistema não conseguiu encontrar o Título "+nNsNum+". Favor verificar.","FA200VAR","ALERT")
			If lFina200 //verificar a necessida do return		
				Return
			EndIf
		EndIf
	Endif
Endif

//Carrega o valor de Outros Creditos
If lFina200
	nOutCred := (Val(Substr(Paramixb[1][16],280,13)))/100 //Valor de Outros Creditos, definida pelo tipo de Ocorrencia
Else
	nOutCred := (Val(Substr(Paramixb[1][14],280,13)))/100 //Valor de Outros Creditos, definida pelo tipo de Ocorrencia
EndIf

If nValRec > SE1->E1_VALOR .And. Alltrim(SE1->E1_NATUREZ) == "1230" .And. (SE1->E1_PORTADO == "001"  .or. Alltrim(cOcorr) == "05" )
	If (nValRec - SE1->E1_VALOR - nJuros - nValCc - nOutCred) > 0 .And. !SE1->(EOF())
		RecLock("SE1",.F.)
		SE1->E1_YTXCOBR := nValRec - SE1->E1_VALOR - nJuros - nValCc - nOutCred 
		MsUnLock()
	EndIf
	nJuros := nJuros + nValCc
	nMulta := nMulta + SE1->E1_YTXCOBR
	If nValCc > 0
		nValCc := 0
	EndIf
EndIf

If nDescont > 0 .And. SE1->E1_PORTADO == "001"  .and. Alltrim(SE1->E1_NATUREZ) == "1230"
	nDescont := 0
EndIf

//Backup do Nosso Numero
If SE1->E1_PORTADO == "001" .And. Alltrim(cOcorr) == "03" .And. lFina200 
	If !Empty(Alltrim(SE1->E1_NUMBCO))
		RecLock("SE1",.F.)
		SE1->E1_YNUMBCO := SE1->E1_NUMBCO
		MsUnLock()
	EndIf
EndIf

//Grava o Nosso Numero no Título --corrigir problema nos títulos do Bradesco.
If !Empty(cNosNum) .And. Empty(Alltrim(SE1->E1_NUMBCO)) .And. lRet .And. lFina200
	RecLock("SE1",.F.) 
	SE1->E1_NUMBCO := cNosNum
	MsUnLock()
EndIF

//Grava BANCO/AG/CONTA caso esteja vazio - Liquidação sem Registro - Resolve o problema de posicionamento do Banco - 0712-14
If Empty(Alltrim(SE1->E1_PORTADO))  .And. Empty(Alltrim(SE1->E1_AGEDEP)) .And. Empty(Alltrim(SE1->E1_CONTA)) .And. Alltrim(cOcorr) == "05" .And. lFina200
	RecLock("SE1",.F.) 
	SE1->E1_PORTADO	:= MV_PAR06
	SE1->E1_AGEDEP  := MV_PAR07
	SE1->E1_CONTA	:= MV_PAR08
	MsUnLock()
EndIF

//Somente para BB
If SE1->E1_PORTADO == "001" .Or. Alltrim(cOcorr) == "05" 
	
	If lFina200
		nVlTarif := (Val(Substr(Paramixb[1][16],182,07)))/100 //Valor da Tarifa de Cobranca
		nOutDesp := (Val(Substr(Paramixb[1][16],189,13)))/100 //Valor de Outras Despesas, definida pelo tipo de Ocorrencia
	Else
		nVlTarif := (Val(Substr(Paramixb[1][14],182,07)))/100 //Valor da Tarifa de Cobranca  
		nOutDesp := (Val(Substr(Paramixb[1][14],189,13)))/100 //Valor de Outras Despesas, definida pelo tipo de Ocorrencia	
	EndIf

	//Registo Entrada Confirmada
	If Alltrim(cOcorr) == "02" .And. nVlTarif > 0
		nDespes			:= nVlTarif		
		Paramixb[1][05]	:= nVlTarif	

	//Registo Liquidação sem Registro
	ElseIf Alltrim(cOcorr) == "05" .And. nVlTarif > 0 

		If Alltrim(SE1->E1_TIPO) == "FT" 	
			cTipo			:= "06"
			Paramixb[1][01]	:= "06"
		Else
			cTipo			:= "01"
			Paramixb[1][01]	:= "01"
		EndIf

		cNumTit			:= SE1->E1_PREFIXO+SUBSTR(SE1->E1_NUM,4,6)+Alltrim(SE1->E1_PARCELA)
		Paramixb[1][03]	:= SE1->E1_PREFIXO+SUBSTR(SE1->E1_NUM,4,6)+Alltrim(SE1->E1_PARCELA)

		nDespes			:= nVlTarif		
		Paramixb[1][05]	:= nVlTarif	

		//nDespes			:= nVlTarif		
		//Paramixb[1][05]	:= nVlTarif	

	
	//Registo Depesa de Protesto
	ElseIf Alltrim(cOcorr) == "96" .And. nOutDesp > 0
		nDespes			:= nOutDesp		
		Paramixb[1][05]	:= nOutDesp	
		
	//Registro Depesa de Cartorio
	ElseIf Alltrim(cOcorr) == "98" .And. nOutDesp > 0
		nDespes			:= nOutDesp		
		Paramixb[1][05]	:= nOutDesp	
	
	//Liquidacao Depesa de Cartorio
	ElseIf Alltrim(cOcorr) == "15" .And. nOutCred > 0
		nDespes 		:= 0
		Paramixb[1][05]	:= 0
	
		nValRec 		:= nValRec - nOutCred
		Paramixb[1][08]	:= nValRec
	
		nValCc 			:= nOutCred 
		Paramixb[1][12]	:= nOutCred

	//Liquidacao  Normal em 03/02/14
	ElseIf Alltrim(cOcorr) == "06" .And. nOutCred > 0 .And. Alltrim(SE1->E1_NATUREZ) <> "1230"
		nDespes 		:= 0
		Paramixb[1][05]	:= 0

		nJuros			:= nJuros + nOutCred 
		Paramixb[1][09]	:= Paramixb[1][09] + nOutCred

		nOutCred		:= 0
		Paramixb[1][09]	:= 0

	//Se for Liquidacao Normal, zera a variavel de outros creditos
	ElseIf 	( Alltrim(cOcorr) == "06" .And. nOutCred > 0 .And. Alltrim(SE1->E1_NATUREZ) == "1230" ) .Or. ;	//
			( Alltrim(cOcorr) == "06" .And. nOutCred > 0 .And. Paramixb[1][15] == "04" ) 					//Tratamento de cheque
		nJuros 			:= nJuros + nOutCred
		nOutCred 		:= 0

		nDespes 		:= 0
		Paramixb[1][05]	:= 0

	EndIf

//Somente para BRADESCO
ElseIf SE1->E1_PORTADO == "237" 
	
	If lFina200 
		nVlTarif := (Val(Substr(Paramixb[1][16],176,13)))/100 //Valor de Tarifas
		nOutDesp := (Val(Substr(Paramixb[1][16],189,13)))/100 //Valor de Outras Despesas, definida pelo tipo de Ocorrencia
	Else
		nVlTarif := (Val(Substr(Paramixb[1][14],176,13)))/100 //Valor de Tarifas
		nOutDesp := (Val(Substr(Paramixb[1][14],189,13)))/100 //Valor de Outras Despesas, definida pelo tipo de Ocorrencia
	EndIf
	
	//Registo Entrada Confirmada
	If Alltrim(cOcorr) == "02" .And. nVlTarif > 0
		nDespes	:= nVlTarif
		Paramixb[1][05]	:= nVlTarif	
	
	//Registo Despesa de Protesto
	ElseIf Alltrim(cOcorr) == "28" .And. nVlTarif > 0
					
		// Tiago Rossini Coradini  - 23/02/2016 - OS: 4461-15 e 4663-15 - Clebes Jose - Ajuste na cobrança de tarifas de cartorio
		nDespes += nVlTarif
		Paramixb[1][05]	+= nVlTarif
	
	/*//Registro Depesa de Cartorio
	ElseIf Alltrim(cOcorr) == "98" .And. nOutDesp > 0
		nDespes 		:= nOutDesp
		Paramixb[1][05]	:= nOutDesp
	
	//Liquidacao Depesa de Cartorio
	ElseIf Alltrim(cOcorr) == "15" .And. nOutCred > 0
		nDespes 		:= 0
		Paramixb[1][05]	:= 0
	
		nValCc 			:= nOutCred 
		Paramixb[1][12]	:= nOutCred*/
		
	EndIf

EndIf

RETURN

//---------------------------------------------------------------------
//Rotina para informar no titulo se o cliente esta cadastrado como DDA
User Function fAceDDA()

//PARAMIXB[1][14] -> MOTIVO     = 02 - Entrada Confirmada
//PARAMIXB[1][15] -> OCORRENCIA = 76 - Cliente DDA

If SE1->E1_PORTADO == "237" .And. ALLTRIM(PARAMIXB[1][14]) == "02" .And. SUBSTRING(PARAMIXB[1][15],1,2) == "76"
	RecLock("SE1",.F.)
	SE1->E1_YDDA := "S"
	MsUnLock()
EndIf

Return