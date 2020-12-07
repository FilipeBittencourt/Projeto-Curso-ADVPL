#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ BIA824				  บAUTOR  ณ Ranisses A. Corona บ DATA ณ  09/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ Faz acerto nos titulos de impostos																บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ Fiscal                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION BIA824()

Pergunte("BIA824", .F.)

@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Acerto nos Tํtulos de Impostos"
@ 8,10 TO 84,222

@ 16,12 SAY "Esta rotina tem por finalidade: "
@ 24,12 SAY "Realizar acerto nos tํtulos de impostos, que foram excluidos de forma indevida pelo sistema."

@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("BIA824", .T.) //ABRE PERGUNTAS

ACTIVATE DIALOG oDlg5 CENTERED

RETURN()


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณChama rotina que acerta o empenho       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function OkProc()
Processa( {|| RunProc() } )
Close(oDlg5)
Return


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRotina que realiza o acerto do Empenho  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Static Function RunProc()
Private CSQL		 := ""
Private ENTER		 := CHR(13)
Private lRet		 := .F.
Private nParc		 := ""
Private nNewParc := ""
Private nValor	 := "" 
Private lFlag		 := .F.

lRet := MsgBox("Deseja realmente verificar todos os Titulos a Pagar com Impostos? ","Atencao","YesNo")

If lRet
	
	//Selecionando todos os registros do Contas a Pagar com Impostos
	CSQL := ""
	CSQL += "SELECT	E2_PARCINS, E2_VRETINS, E2_PARCIR, E2_IRRF, E2_PARCISS, E2_ISS, E2_PARCPIS, E2_VRETPIS, E2_PARCCOF, E2_VRETCOF, E2_PARCSLL, E2_VRETCSL,	" + ENTER
	CSQL += "				E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, E2_VRETIRF, E2_IRRF, E2_EMISSAO, E2_EMIS1, D_E_L_E_T_, R_E_C_N_O_					" + ENTER
	CSQL += "FROM "+RetSqlName("SE2")+" 																			" + ENTER
	CSQL += "WHERE 	E2_FILIAL = '"+xFilial("SE2")+"' AND D_E_L_E_T_ = '' AND	" + ENTER
	If MV_PAR01 == 1			//PIS
		CSQL += "		E2_PARCPIS <> ''	" + ENTER
	ElseIf MV_PAR01 == 2	//COFINS
		CSQL += "		E2_PARCCOF <> '' 	" + ENTER
	ElseIf MV_PAR01 == 3	//CSLL
		CSQL += "		E2_PARCSLL <> ''	" + ENTER
	ElseIf MV_PAR01 == 4	//IRRF
		CSQL += "		E2_PARCIR <> '' 	" + ENTER
	EndIf
		//CSQL += "				AND E2_NUM = '000559' AND E2_FORNECE = '001179'					" + ENTER
	CSQL += "ORDER BY R_E_C_N_O_																							" + ENTER
	IF CHKFILE("_TRB1")
		DBSELECTAREA("_TRB1")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_TRB1" NEW
	
	//Selecionando todos os registros do Contas a Pagar com Impostos - Qtd Registros
	CSQL := ""
	CSQL += "SELECT	COUNT(*) QUANT																						" + ENTER
	CSQL += "FROM "+RetSqlName("SE2")+" 																			" + ENTER
	CSQL += "WHERE 	E2_FILIAL = '"+xFilial("SE2")+"' AND D_E_L_E_T_ = '' AND	" + ENTER
	If MV_PAR01 == 1			//PIS
		CSQL += "		E2_PARCPIS <> ''	" + ENTER
	ElseIf MV_PAR01 == 2	//COFINS
		CSQL += "		E2_PARCCOF <> '' 	" + ENTER
	ElseIf MV_PAR01 == 3	//CSLL
		CSQL += "		E2_PARCSLL <> ''	" + ENTER
	ElseIf MV_PAR01 == 4	//IRRF
		CSQL += "		E2_PARCIR <> '' 	" + ENTER
	EndIf
		//CSQL += "				AND E2_NUM = '000559' AND E2_FORNECE = '001179'					" + ENTER
	IF CHKFILE("_QTD1")
		DBSELECTAREA("_QTD1")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_QTD1" NEW
	
	ProcRegua(_QTD1->QUANT)
	
	//Verifica cada Titulo selecionado acima
	DO WHILE ! _TRB1->(EOF())
		
		//Define a variavel do Imposto de acordo com o paramentro.
		If MV_PAR01 == 1  		//PIS
			nParc  := _TRB1->E2_PARCPIS
			nValor := _TRB1->E2_VRETPIS
		ElseIf MV_PAR01 == 2 //COFINS
			nParc  := _TRB1->E2_PARCCOF
			nValor := _TRB1->E2_VRETCOF
		ElseIf MV_PAR01 == 3 //CSLL
			nParc  := _TRB1->E2_PARCSLL
			nValor := _TRB1->E2_VRETCSL
		ElseIf MV_PAR01 == 4 //IRRF
			nParc  := _TRB1->E2_PARCIR
			nValor := _TRB1->E2_IRRF
		EndIf
		
		IncProc("Verificando Tํtulo..."+ALLTRIM(_TRB1->E2_PREFIXO)+"-"+ALLTRIM(_TRB1->E2_NUM)+"-"+ALLTRIM(_TRB1->E2_PARCELA) )
		
		//Procura Titulo de Imposto QUE ESTA DELETADO
		CSQL := ""
		CSQL += "SELECT COUNT(*) AS QUANT " + ENTER
		CSQL += "FROM "+RetSqlName("SE2")+" 										" + ENTER
		CSQL += "	WHERE E2_PREFIXO	= '"+_TRB1->E2_PREFIXO+"'		" + ENTER
		CSQL += "		AND E2_NUM 			= '"+_TRB1->E2_NUM+"' 			" + ENTER
		CSQL += "		AND E2_EMIS1		= '"+_TRB1->E2_EMIS1+"'			" + ENTER
		CSQL += "		AND E2_PARCELA 	= '"+nParc+"'								" + ENTER
		CSQL += "		AND E2_VALOR		= "+Str(nValor)+"						" + ENTER
		CSQL += "		AND E2_TIPO 		= 'TX'											" + ENTER
		CSQL += "		AND E2_FORNECE 	= 'UNIAO'										" + ENTER
		CSQL += "		AND D_E_L_E_T_	= '*'
		IF CHKFILE("_QTD2")
			DBSELECTAREA("_QTD2")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_QTD2" NEW
		
		//Procura Titulo do Imposto QUE NAO ESTA DELETADO
		CSQL := ""
		CSQL += "SELECT COUNT(*) AS QUANT " + ENTER
		CSQL += "FROM "+RetSqlName("SE2")+" 										" + ENTER
		CSQL += "	WHERE E2_PREFIXO	= '"+_TRB1->E2_PREFIXO+"'		" + ENTER
		CSQL += "		AND E2_NUM 			= '"+_TRB1->E2_NUM+"' 			" + ENTER
		CSQL += "		AND E2_EMIS1		= '"+_TRB1->E2_EMIS1+"'			" + ENTER
		CSQL += "		AND E2_PARCELA 	= '"+nParc+"'								" + ENTER
		CSQL += "		AND E2_VALOR		= "+Str(nValor)+"						" + ENTER
		CSQL += "		AND E2_TIPO 		= 'TX'											" + ENTER
		CSQL += "		AND E2_FORNECE 	= 'UNIAO'										" + ENTER
		CSQL += "		AND D_E_L_E_T_	= ''
		IF CHKFILE("_QTD3")
			DBSELECTAREA("_QTD3")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_QTD3" NEW
		
		
		If _QTD2->QUANT == 1 .And. _QTD3->QUANT == 0
			
			//Procura quantos titulos existem com a mesma chave
			CSQL := ""
			CSQL += "SELECT COUNT(*) AS QUANT " + ENTER
			CSQL += "FROM "+RetSqlName("SE2")+" 										" + ENTER
			CSQL += "	WHERE E2_PREFIXO	= '"+_TRB1->E2_PREFIXO+"'		" + ENTER
			CSQL += "		AND E2_NUM 			= '"+_TRB1->E2_NUM+"' 			" + ENTER
			CSQL += "		AND E2_PARCELA 	= '"+nParc+"'								" + ENTER
			CSQL += "		AND E2_TIPO 		= 'TX'											" + ENTER
			CSQL += "		AND E2_FORNECE 	= 'UNIAO'										" + ENTER
			IF CHKFILE("_QTD4")
				DBSELECTAREA("_QTD4")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_QTD4" NEW
			
			//Seleciona o registro que foi apagado indevidamente
			CSQL := ""
			CSQL += "SELECT E2_PREFIXO, E2_NUM, E2_TIPO, E2_PARCELA, E2_FORNECE, E2_LOJA, E2_EMISSAO, E2_EMIS1, E2_VALOR, E2_NATUREZ, D_E_L_E_T_, R_E_C_N_O_ " + ENTER
			CSQL += "FROM "+RetSqlName("SE2")+" 										" + ENTER
			CSQL += "	WHERE E2_PREFIXO	= '"+_TRB1->E2_PREFIXO+"'		" + ENTER
			CSQL += "		AND E2_NUM 			= '"+_TRB1->E2_NUM+"' 			" + ENTER
			CSQL += "		AND E2_PARCELA 	= '"+nParc+"'								" + ENTER
			CSQL += "		AND E2_VALOR		= "+Str(nValor)+"						" + ENTER
			CSQL += "		AND E2_TIPO 		= 'TX'											" + ENTER
			CSQL += "		AND E2_FORNECE 	= 'UNIAO'										" + ENTER
			CSQL += "		AND D_E_L_E_T_	= '*'												" + ENTER
			IF CHKFILE("_TRB2")
				DBSELECTAREA("_TRB2")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_TRB2" NEW
			
			//Verifica se sera necessario realizar o acerto
			If _QTD4->QUANT == 1
				
				MsgAlert("VOLTA REGISTRO DELETADO!..."+ALLTRIM(_TRB1->E2_PREFIXO)+"-"+ALLTRIM(_TRB1->E2_NUM)+"-"+ALLTRIM(_TRB1->E2_PARCELA)+"-"+ALLTRIM(_TRB1->E2_FORNECE))
				
				//Volta registro que esta deletado.
				CSQL := ""
				CSQL := "UPDATE "+RetSqlName("SE2")+" SET D_E_L_E_T_ = '', R_E_C_D_E_L_ = '0' " + ENTER
				//CSQL += "SELECT *																			" + ENTER
				//CSQL += "FROM "+RetSqlName("SE2")+" 									" + ENTER
				CSQL += "WHERE R_E_C_N_O_  = '"+ALLTRIM(STR(_TRB2->R_E_C_N_O_))+"'	" + ENTER
				TcSQLExec(CSQL)
				
			Else
					
				//Selecionando o registro que NAO ESTA DELETADO
				CSQL := ""
				CSQL += "SELECT E2_PREFIXO, E2_NUM, E2_TIPO, E2_PARCELA, E2_FORNECE, E2_LOJA, E2_EMISSAO, E2_EMIS1, E2_VALOR, E2_NATUREZ, E2_TITPAI, D_E_L_E_T_, R_E_C_N_O_ " + ENTER
				CSQL += "FROM "+RetSqlName("SE2")+" 										" + ENTER
				CSQL += "	WHERE E2_PREFIXO	= '"+_TRB1->E2_PREFIXO+"'		" + ENTER
				CSQL += "		AND E2_NUM 			= '"+_TRB1->E2_NUM+"' 			" + ENTER
				CSQL += "		AND E2_PARCELA 	= '"+nParc+"'								" + ENTER
				CSQL += "		AND E2_TIPO 		= 'TX'											" + ENTER
				CSQL += "		AND E2_FORNECE 	= 'UNIAO'										" + ENTER
				CSQL += "		AND D_E_L_E_T_	= ''												" + ENTER
				IF CHKFILE("_TRB3")
					DBSELECTAREA("_TRB3")
					DBCLOSEAREA()
				ENDIF
				TCQUERY CSQL ALIAS "_TRB3" NEW
				
				//Selecionando a maior parcela do imposto para acertar
				CSQL := ""
				CSQL += "SELECT MAX(E2_PARCELA) as PARC	" + ENTER
				CSQL += "FROM "+RetSqlName("SE2")+" 		" + ENTER
				CSQL += "WHERE E2_PREFIXO		= '"+_TRB1->E2_PREFIXO+"'	" + ENTER
				CSQL += "		AND E2_NUM 			= '"+_TRB1->E2_NUM+"'			" + ENTER
				CSQL += "		AND E2_TIPO			= 'TX' 			" + ENTER
				CSQL += "		AND E2_FORNECE 	= 'UNIAO'		" + ENTER
				CSQL += "		AND D_E_L_E_T_	= ''				" + ENTER
				IF CHKFILE("_TRB4")
					DBSELECTAREA("_TRB4")
					DBCLOSEAREA()
				ENDIF
				TCQUERY CSQL ALIAS "_TRB4" NEW
				
				//Grava nova parcela
				nNewParc := Soma1(_TRB4->PARC)
			
				If !_TRB3->(EOF())
					
					lFlag := .T.
					
					//Acerta Parcela no Titulo do Imposto
					CSQL := ""
					CSQL += "UPDATE "+RetSqlName("SE2")+" SET E2_PARCELA = '"+nNewParc+"'	" + ENTER
					//CSQL += "SELECT *																			" + ENTER
					//CSQL += "FROM "+RetSqlName("SE2")+" 									" + ENTER
					CSQL += "WHERE R_E_C_N_O_  = '"+ALLTRIM(STR(_TRB3->R_E_C_N_O_))+"'	" + ENTER
					TcSQLExec(CSQL)
					
					//Acerta Parcela no Titulo Pai
					CSQL := ""
					If Alltrim(_TRB3->E2_NATUREZ) == "PIS"
						MsgAlert("ACERTO PIS")
						CSQL += "UPDATE "+RetSqlName("SE2")+" SET E2_PARCPIS = '"+nNewParc+"'	" + ENTER
					ElseIf Alltrim(_TRB3->E2_NATUREZ) == "COFINS"
						MsgAlert("ACERTO COFINS")
						CSQL += "UPDATE "+RetSqlName("SE2")+" SET E2_PARCCOF = '"+nNewParc+"'	" + ENTER
					ElseIf Alltrim(_TRB3->E2_NATUREZ) == "CSLL"
						MsgAlert("ACERTO CSLL")
						CSQL += "UPDATE "+RetSqlName("SE2")+" SET E2_PARCSLL = '"+nNewParc+"'	" + ENTER
					Else
						MsgAlert("ACERTO IRRF")
						CSQL += "UPDATE "+RetSqlName("SE2")+" SET E2_PARCIR  = '"+nNewParc+"'	" + ENTER
					EndIf
					//CSQL += "SELECT *																			" + ENTER
					//CSQL += "FROM "+RetSqlName("SE2")+" 									" + ENTER
					CSQL += "WHERE E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA = '"+_TRB3->E2_TITPAI+"' AND D_E_L_E_T_ 	= '' " + ENTER
					TcSQLExec(CSQL)

				EndIf
			
				//Volta registro que esta deletado.
				CSQL := ""
				CSQL := "UPDATE "+RetSqlName("SE2")+" SET D_E_L_E_T_ = '', R_E_C_D_E_L_ = '0' " + ENTER
				//CSQL += "SELECT *																			" + ENTER
				//CSQL += "FROM "+RetSqlName("SE2")+" 									" + ENTER
				CSQL += "WHERE R_E_C_N_O_  = '"+ALLTRIM(STR(_TRB2->R_E_C_N_O_))+"'	" + ENTER
				TcSQLExec(CSQL)
				
				If lFlag
					MsgAlert("REGISTRO COM DUPLICIDADE!..."+ALLTRIM(_TRB1->E2_PREFIXO)+"-"+ALLTRIM(_TRB1->E2_NUM)+"-"+ALLTRIM(_TRB1->E2_PARCELA)+"-"+ALLTRIM(_TRB1->E2_FORNECE))
				Else
					MsgAlert("VOLTA REGISTRO DELETADO!..."+ALLTRIM(_TRB1->E2_PREFIXO)+"-"+ALLTRIM(_TRB1->E2_NUM)+"-"+ALLTRIM(_TRB1->E2_PARCELA)+"-"+ALLTRIM(_TRB1->E2_FORNECE))		
        EndIf
											
			EndIf
			
		EndIf
		
		_TRB1->(DBSKIP())
	END DO
	
EndIf

Return()
