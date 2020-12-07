#include "rwmake.ch"
#include "TOTVS.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} fVerificaCredito
@description Valida situacao do Credito do Cliente
@author Bruno Madaleno
@since 15/08/08
@version 1.0
@return Retorna a Varivel publica nTpBlq
@type function
/*/

//DEFINE TIPO DE BLOQUEIO DO CREDITO, PARA EXIBIR O MOTIVO NA TELA - FACILITAR A ANALISE INDEPENDENTE DA TI
//VAZIO -> LIBERADO PARA NF
//00    -> LIBERADO PARA RA
//01 FALTA SALDO DE LIMITE DE CREDITO
//02 FALTA SALDO DE RA
//03 RISCO E
//04 VENCIMENTO LIMITE DE CREDITO
//05 TITULO EM ATRASO
//06 CREDITO CONTRATO
//07 PEDIDO DE ENGENHARIA


User Function fVerificaCredito(cTipo,cNum,cCli,cLoj,cLm,cTotPed,cTotLib,lMsg,lCredEng,lNoMsg)
	Local nTipo		:= cTipo	//1->Controla Credito de NF,FT / 2->Controla Crédito de RA
	Local nNum  	:= cNum
	Local nCli		:= cCli
	Local nLoja		:= cLoj
	Local lLm		:= cLm
	Local nTotPed	:= cTotPed
	Local nTotLib	:= cTotLib
	Local llMsg		:= lMsg
	Local nRet		:= "00"
	Local nRsc		:= 0
	Local Enter		:= CHR(13)+CHR(10)

	Local lAtiva	:= .F.

	//Variaveis de Posicionamento
	//--------------------------------
	Local aArea		:= GetArea()
	Local aAreaSC9	:= SC9->(GetArea())
	//--------------------------------

	Default lNoMsg := .F. //Nao exibir nenhuma mensagem

	If lNoMsg
		lMsg := .F.
	EndIf

	//Posiciona no Pedido de Venda
	SC5->(DbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5")+cNum))
		//Testa Bloqueio dos Pedidos de Engenharia
		If lCredEng .And. SC5->C5_YTPCRED == "5" .And. SC5->C5_YCRDENG == "03"
			nRet 	:= "01"  	//Bloqueio 
			nTpBlq 	:= "07"     //Pedido de Engenharia Bloqueado

			If !lNoMsg
				MsgBox("Pedido de Engenharia aguardando liberação do Setor de Crédito e Cobrança!","fVerificaCredito","STOP")
			EndIf

			Return(nRet)
		EndIf
	EndIf

	//Posiciona no Cadastro de Cliente
	SA1->(DbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+nCli+nLoja))

	//Verifica se existe pedido na tabela de Liberacao de Pedidos
	cSql := "SELECT COUNT(*) AS COUNT 									" + Enter
	cSql += "FROM "+RetSqlName("SZN")+" SZN	WITH (NOLOCK)				" + Enter
	cSql += "WHERE	SZN.ZN_FILIAL	= '"+xFilial("SZN")+"'			AND	" + Enter
	cSql += "		SZN.ZN_PEDIDO	= '"+nNum+"'					AND	" + Enter
	cSql += "		SZN.ZN_DATAINI	<= '"+Dtos(dDataBase)+"'		AND	" + Enter
	cSql += "		SZN.ZN_DATALIM	>= '"+Dtos(dDataBase)+"'		AND	" + Enter
	cSql += "		SZN.ZN_VALOR	>= '"+Alltrim(Str(nTotPed))+"'	AND	" + Enter
	cSql += "		SZN.D_E_L_E_T_	= ''								" + Enter
	If chkfile("_SZN")
		dbSelectArea("_SZN")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "_SZN" NEW

	//Caso o pedido não esteja liberado, submete as regras de credito
	If _SZN->COUNT == 0

		//1-Controla Crédito NF/FT
		If nTipo == "1"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa verificacao para Pedidos Normais ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  SA1->A1_YBLQDIR == "S"
				nRet	:= "01"
				nTpBlq	:= "03"

				If !lNoMsg
					MsgBox("Cliente Bloqueado pela Diretoria!","fVerificaCredito","STOP")
				EndIf

				Return(nRet)
			EndIf

			If Alltrim(SA1->A1_RISCO) == "E"
				nRet 	:= "01"  	//Quando for Risco "E" bloqueia
				nTpBlq 	:= "03"     //RISCO E

				If !lNoMsg			
					MsgBox("Cliente Possui Risco E!","fVerificaCredito","STOP")
				EndIf

				Return(nRet)

				//ALTERAÇÃO CONFORME OS 1910-16 - 10/05/16
				//Executa as verificações abaixo para os RISCOS A,B,C,D
			Else						
				//**1-Limite Credito Zerado
				If SA1->A1_LC <= 0
					nRet 	:= "01"  	//Bloqueio de Credito por Valor
					nTpBlq 	:= "01"		//CREDITO LM

					If !lNoMsg				
						MsgBox("Cliente Possui Limite Credito Zerado/Negativo!","fVerificaCredito","STOP")
					EndIf

					Return(nRet)
				EndIf

				//**2-Data Limite Credito Vencida
				If SA1->A1_VENCLC < dDataBase
					nRet 	:= "04"  //Bloqueia por Vencto do Limite de Credito
					nTpBlq 	:= "04"	 //VENCIMENTO LC

					If !lNoMsg
						MsgBox("Cliente com Data do Limite de Crédito Vencida!","fVerificaCredito","STOP")
					EndIf

					Return(nRet)
				EndIf

				//**3-Saldo Limite Credito
				//QryPedCons(cCliente, cLoja, cTpLc, cGrupo, cPedido, lFilLibMan)
				CSQL := U_QryPedCons(SA1->A1_COD,SA1->A1_LOJA, SA1->A1_YTIPOLC, SA1->A1_GRPVEN, cNum, .T.)			
				If chkfile("PEDIDO")
					dbSelectArea("PEDIDO")
					dbCloseArea()
				EndIf
				TCQUERY CSQL ALIAS "PEDIDO" NEW			
				//QryTitAber(cCliente, cLoja, cTpLc, cGrupo, lFilLibMan)
				cSql := U_QryTitAber(SA1->A1_COD,SA1->A1_LOJA, SA1->A1_YTIPOLC, SA1->A1_GRPVEN, .T. )			
				If chkfile("TITULO")
					DbSelectArea("TITULO")
					DbCloseArea()
				EndIf
				TCQUERY cSql NEW ALIAS "TITULO"			
				//Saldo do Limite Credito somando Biancogres e Incesa
				nSaldo		:= SA1->A1_LC - (TITULO->SALDO + PEDIDO->SALDO + nTotLib + nTotPed)			
				//Verifica se o Saldo esta dentro do Limite
				If nSaldo < 0
					nRet 	:= "01"  	//Bloqueio de Credito por Valor
					nTpBlq 	:= "01"		//CREDITO LM				

					If !lNoMsg
						MsgBox("Cliente ultrapassou o Limite de Crédito!","fVerificaCredito","STOP")
					EndIf

					Return(nRet)
				EndIf

				//**4-Verifica Titulos em Atraso para os Risco B,C,D
				If Alltrim(SA1->A1_RISCO) <> "A"
					//Define os dias em atraso de acordo com o Risco
					If Alltrim(SA1->A1_RISCO) == "E"
						nRsc := 0
					ElseIf Alltrim(SA1->A1_RISCO) == "A"
						nRsc := 999999
					Else
						nRsc := GetMv("MV_RISCO"+Alltrim(SA1->A1_RISCO))
					EndIf

					//Verifica se o Cliente esta com Titulos em Atraso³
					//cSql := U_QryTitAtra(SA1->A1_COD,SA1->A1_LOJA, SA1->A1_YTIPOLC, SA1->A1_GRPVEN, cValToChar(nRsc) )
					cSql := U_QryTitAtra(SA1->A1_COD,SA1->A1_LOJA, SA1->A1_YTIPOLC, SA1->A1_GRPVEN, Alltrim(Str(nRsc)) )			
					If chkfile("RAN")
						DbSelectArea("RAN")
						RAN->(DbCloseArea())
					EndIf
					TCQUERY cSql ALIAS "RAN" NEW

					DbSelectArea("RAN")
					DbGoTop()

					If RAN->(!Eof())
						nRet 	:= "01"
						nTpBlq 	:= "05"	//TITULOS EM ATRASO
						RAN->(DbCloseArea())

						If !lNoMsg
							MsgBox("Cliente Possui Títulos em Atraso!","fVerificaCredito","STOP")
						EndIf

						Return(nRet)
					EndIf
					RAN->(DbCloseArea())
				Else
					//**5-Libera pedidos Risco A, com saldo LC e vencimento LC ativo
					nRet 	:= "00"  	//Quando for Risco "A" libera
					nTpBlq 	:= "00"		//LIBERADO			
					Return(nRet)			
				EndIf

			EndIf

			//2-Controla Crédito RA
		Else

			If lAtiva

				//Tratar Novo Processo de RA

			Else

				//+ SALDO DE RA EM ABERTO
				CSQL := "SELECT ISNULL(SUM(E1_SALDO),0) AS TOTAL " + Enter
				If lLm .And. !cEmpAnt == "07"  /////////////////////////////////
					CSQL += "FROM SE1070 SE1 WITH (NOLOCK), "+RETSQLNAME("SA1")+" SA1  WITH (NOLOCK) " + Enter
				Else
					CSQL += "FROM "+RETSQLNAME("SE1")+" SE1 WITH (NOLOCK), "+RETSQLNAME("SA1")+" SA1  WITH (NOLOCK) " + Enter
				EndIf
				cSql += " WHERE	SE1.E1_FILIAL	= '"+xFilial("SE1")+"'	AND " + Enter
				cSql += "		SE1.E1_CLIENTE	= SA1.A1_COD			AND	" + Enter
				cSql += " 		SE1.E1_LOJA		= SA1.A1_LOJA			AND	" + Enter
				IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. ALLTRIM(SA1->A1_YTIPOLC) == "G"
					CSQL += "		SA1.A1_GRPVEN	= '"+SA1->A1_GRPVEN+"'	AND SA1.A1_YTIPOLC = 'G' AND 	" + ENTER
				ELSE
					CSQL += "		SA1.A1_COD		= '"+nCli+"'	AND	 SA1.A1_LOJA = '"+nLoja+"' AND " + ENTER
				END IF
				CSQL += "		SE1.E1_TIPO		= 'RA'	AND		" + Enter
				CSQL += "		SE1.E1_SALDO	> 0		AND		" + Enter
				CSQL += "		SE1.D_E_L_E_T_	= '' 	AND		" + Enter
				CSQL += "		SA1.D_E_L_E_T_	= ''			" + Enter
				If chkfile("_RA")
					dbSelectArea("_RA")
					dbCloseArea()
				EndIf
				TCQUERY CSQL ALIAS "_RA" NEW
				TOTAL_RA := _RA->TOTAL
				_RA->(dbCloseArea())

				//- FATURAMENTO DE RA EM ABERTO - AGUARDANDO COMPENSAÇÃO
				CSQL := "SELECT ISNULL(SUM(E1_SALDO),0) SALDO	" + Enter
				If lLm .And. !cEmpAnt == "07"
					CSQL += "FROM SE1070 SE1 WITH (NOLOCK), SF2070 SF2 WITH (NOLOCK), "+RETSQLNAME("SE4")+" SE4, "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK) " + Enter
				Else
					CSQL += "FROM "+RETSQLNAME("SE1")+" SE1 WITH (NOLOCK), "+RETSQLNAME("SF2")+" SF2 WITH (NOLOCK), "+RETSQLNAME("SE4")+" SE4, "+RETSQLNAME("SA1")+" SA1 WITH (NOLOCK)  " + Enter
				EndIf
				cSql += " WHERE	SE1.E1_FILIAL	= '"+xFilial("SE1")+"'	AND " + Enter
				cSql += "		SE1.E1_CLIENTE	= SA1.A1_COD			AND	" + Enter
				cSql += " 		SE1.E1_LOJA		= SA1.A1_LOJA			AND	" + Enter
				IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. ALLTRIM(SA1->A1_YTIPOLC) == "G"
					CSQL += "		SA1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1.A1_YTIPOLC = 'G' AND " + ENTER
				ELSE
					CSQL += "		SA1.A1_COD		= '"+nCli+"'	AND	 SA1.A1_LOJA = '"+nLoja+"' AND " + ENTER
				END IF
				CSQL += "		SE1.E1_SALDO	> 0 				AND	" + Enter
				CSQL += "		SF2.F2_SERIE    = SE1.E1_PREFIXO	AND	" + Enter
				CSQL += "		SF2.F2_DOC		= SE1.E1_NUM		AND " + Enter
				CSQL += "		SF2.F2_CLIENTE	= SE1.E1_CLIENTE	AND " + Enter
				CSQL += "		SF2.F2_LOJA		= SE1.E1_LOJA		AND " + Enter
				CSQL += "		SF2.F2_COND 	= E4_CODIGO 		AND " + Enter
				CSQL += "		SF2.F2_TIPO		= 'N'				AND " + Enter
				CSQL += "       SE4.E4_DESCRI	LIKE '%ANTE%'		AND " + Enter
				CSQL += "		SE1.D_E_L_E_T_	= '' AND	" + Enter
				CSQL += "      	SF2.D_E_L_E_T_	= '' AND	" + Enter
				CSQL += "      	SE4.D_E_L_E_T_	= '' AND	" + Enter
				CSQL += "		SA1.D_E_L_E_T_	= ''		" + Enter
				If chkfile("_PEDFAT")
					dbSelectArea("_PEDFAT")
					dbCloseArea()
				EndIf
				TCQUERY CSQL ALIAS "_PEDFAT" NEW
				TOTAL_ABERTO := _PEDFAT->SALDO
				_PEDFAT->(dbCloseArea())

				//PROJETO2014
				If GETMV("MV_YVLDRA") .Or. Alltrim(Funname()) $ ("MATA410_MATA416") //MESMO COM O PARAMETRO DESATIVADO, FORÇA NA INCLUSÃO/EFETIVAÇÃO

					//- PEDIDOS DE VENDA DE RA QUE ESTÃO EM ABERTO
					CSQL := "SELECT ISNULL(SUM(ROUND((ROUND(C6_VALOR-(C6_QTDENT*C6_PRCVEN),2)/C6_VALOR*100)*C6_YVLIMP/100,2)),0) SALDO_PEDIDO	" + Enter
					If lLm .And. !cEmpAnt == "07"  /////////////////////////////////
						CSQL += "FROM SC5070 SC5 WITH (NOLOCK), SC6070 SC6 WITH (NOLOCK), SF4070 SF4, "+RetSqlName("SE4")+" SE4, "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) " + Enter
					Else
						CSQL += "FROM "+RetSqlName("SC5")+" SC5 WITH (NOLOCK), "+RetSqlName("SC6")+" SC6 WITH (NOLOCK), "+RetSqlName("SF4")+" SF4, "+RetSqlName("SE4")+" SE4, "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) " + Enter
					EndIf
					CSQL += "WHERE	SC5.C5_FILIAL	= '"+xFilial("SC5")+"' AND " + Enter
					CSQL += "		SC6.C6_FILIAL	= '"+xFilial("SC6")+"' AND " + Enter
					CSQL += "		SF4.F4_FILIAL	= '"+xFilial("SF4")+"' AND " + Enter
					CSQL += "		SE4.E4_FILIAL	= '"+xFilial("SE4")+"' AND " + Enter
					CSQL += "		SC5.C5_NUM		= SC6.C6_NUM AND  " + Enter
					CSQL += "  		SC5.C5_CLIENTE	= SC6.C6_CLI AND  " + Enter
					CSQL += "		SC5.C5_LOJACLI	= SC6.C6_LOJA AND  " + Enter
					CSQL += "		SC5.C5_CONDPAG  = SE4.E4_CODIGO AND  " + Enter
					CSQL += "		SC6.C6_TES		= SF4.F4_CODIGO AND  " + Enter
					CSQL += "		SC5.C5_TIPO		= 'N'			AND	 " + Enter
					CSQL += "		SC6.C6_QTDVEN-C6_QTDENT > 0 	AND  " + Enter
					CSQL += "		SC6.C6_VALOR    > 0         	AND  " + Enter
					CSQL += "		SC6.C6_BLQ		<>	'R' 		AND  " + Enter
					CSQL += "		SF4.F4_DUPLIC	=	'S' 		AND  " + Enter
					CSQL += "		SE4.E4_DESCRI LIKE '%ANTE%' 	AND  " + Enter
					CSQL += "	    SC5.C5_NUM		<> '"+nNum+"'	AND  " + Enter  //MENOS PEDIDO ATUAL
					CSQL += "		SA1.A1_COD 	= C5_CLIENTE AND " + Enter
					CSQL += "		SA1.A1_LOJA = C5_LOJACLI AND " + Enter
					IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. ALLTRIM(SA1->A1_YTIPOLC) == "G"
						CSQL += "		SA1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1.A1_YTIPOLC = 'G' AND " + ENTER
					ELSE
						CSQL += "		SA1.A1_COD		= '"+nCli+"'	AND	 SA1.A1_LOJA = '"+nLoja+"' AND " + ENTER
					ENDIF
					CSQL += "		SC5.D_E_L_E_T_  = '' AND  " + Enter
					CSQL += "		SC6.D_E_L_E_T_  = '' AND  " + Enter
					CSQL += "		SF4.D_E_L_E_T_  = '' AND  " + Enter
					CSQL += "		SE4.D_E_L_E_T_  = '' AND 	  " + Enter
					CSQL += "		SA1.D_E_L_E_T_  = ''  " + Enter
					If chkfile("_PEDIDO")
						dbSelectArea("_PEDIDO")
						dbCloseArea()
					EndIf
					TCQUERY CSQL ALIAS "_PEDIDO" NEW
					TOTAL_ABERTO += _PEDIDO->SALDO_PEDIDO
					_PEDIDO->(dbCloseArea())

					//- VALOR PEDIDO ATUAL
					If lLm .And. !cEmpAnt == "07"
						TOTAL_ABERTO += 0 //o saldo já foi verificado na empresa LM
					Else
						TOTAL_ABERTO += nTotPed
					EndIf

				Else

					//- PEDIDOS EM ABERTO DE RA JÁ LIBERADDOS - AGREG
					CSQL := "SELECT ISNULL(SUM(ROUND(C9_QTDLIB/C6_QTDVEN*C6_YVLIMP,2)),0) SALDO		" + Enter
					If lLm .And. !cEmpAnt == "07"  /////////////////////////////////
						CSQL += "FROM SC9070 SC9 WITH (NOLOCK) INNER JOIN SC6070 SC6 WITH (NOLOCK) ON	" + Enter
						CSQL += "		C9_PEDIDO	= C6_NUM	AND		" + Enter
						CSQL += "		C9_CLIENTE	= C6_CLI	AND		" + Enter
						CSQL += "		C9_LOJA		= C6_LOJA	AND		" + Enter
						CSQL += "		C9_ITEM		= C6_ITEM			" + Enter
						CSQL += "		INNER JOIN SC5070 SC5 WITH (NOLOCK) ON		" + Enter
						CSQL += "		C9_PEDIDO	= C5_NUM		AND	" + Enter
						CSQL += "		C9_CLIENTE	= C5_CLIENTE	AND	" + Enter
						CSQL += "		C9_LOJA		= C5_LOJACLI		" + Enter
						CSQL += "		INNER JOIN "+RetSqlName("SE4")+"  SE4 ON		" + Enter
						CSQL += "		C5_CONDPAG  = E4_CODIGO			" + Enter
						CSQL += "		INNER JOIN SF4070 SF4 ON		" + Enter
						CSQL += "		C6_TES      = F4_CODIGO			" + Enter
						CSQL += "		INNER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON	" + Enter
						CSQL += "		C5_CLIENTE	= A1_COD		AND	" + Enter
						CSQL += "		C5_LOJACLI	= A1_LOJA			" + Enter
					Else
						CSQL += "FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK) INNER JOIN "+RetSqlName("SC6")+" SC6 WITH (NOLOCK) ON	" + Enter
						CSQL += "		C9_PEDIDO	= C6_NUM	AND	" + Enter
						CSQL += "		C9_CLIENTE	= C6_CLI	AND	" + Enter
						CSQL += "		C9_LOJA		= C6_LOJA	AND	" + Enter
						CSQL += "		C9_ITEM		= C6_ITEM		" + Enter
						CSQL += "		INNER JOIN "+RetSqlName("SC5")+" SC5 WITH (NOLOCK) ON	" + Enter
						CSQL += "		C9_PEDIDO	= C5_NUM		AND			" + Enter
						CSQL += "		C9_CLIENTE	= C5_CLIENTE	AND 		" + Enter
						CSQL += "		C9_LOJA		= C5_LOJACLI				" + Enter
						CSQL += "		INNER JOIN "+RetSqlName("SE4")+" SE4 ON	" + Enter
						CSQL += "		C5_CONDPAG  = E4_CODIGO					" + Enter
						CSQL += "		INNER JOIN "+RetSqlName("SF4")+" SF4 ON	" + Enter
						CSQL += "		C6_TES      = F4_CODIGO					" + Enter
						CSQL += "		INNER JOIN "+RetSqlName("SA1")+" SA1 WITH (NOLOCK) ON	" + Enter
						CSQL += "		C5_CLIENTE	= A1_COD		AND			" + Enter
						CSQL += "		C5_LOJACLI	= A1_LOJA			 		" + Enter
					EndIf
					CSQL += "WHERE	C9_FILIAL	= '"+xFilial("SC9")+"'	AND	" + Enter
					CSQL += "		C6_FILIAL	= '"+xFilial("SC6")+"'  AND " + Enter
					CSQL += "		E4_FILIAL	= '"+xFilial("SE4")+"'  AND	" + Enter
					CSQL += "		A1_FILIAL	= '"+xFilial("SA1")+"'  AND	" + Enter
					CSQL += "		C9_AGREG	<> ''			AND	" + Enter
					CSQL += "		C9_NFISCAL	= ''			AND	" + Enter
					CSQL += "		C9_BLCRED	= ''			AND	" + Enter
					CSQL += "		C9_BLEST	= ''			AND	" + Enter
					CSQL += "		E4_DESCRI LIKE '%ANTE%'		AND	" + Enter
					CSQL += "		F4_DUPLIC   = 'S'			AND	" + Enter
					IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. ALLTRIM(SA1->A1_YTIPOLC) == "G"
						CSQL += "		A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND A1_YTIPOLC = 'G' AND 	" + ENTER
					ELSE
						CSQL += "		A1_COD = '"+nCli+"' AND A1_LOJA = '"+nLoja+"'	AND " + ENTER
					END IF
					CSQL += "		SC9.D_E_L_E_T_	= ''  	AND 	" + Enter
					CSQL += "		SC6.D_E_L_E_T_	= ''	AND 	" + Enter
					CSQL += "		SC5.D_E_L_E_T_	= ''	AND  	" + Enter
					CSQL += "		SE4.D_E_L_E_T_  = ''	AND		" + Enter
					CSQL += "		SF4.D_E_L_E_T_  = ''	AND		" + Enter
					CSQL += "		SA1.D_E_L_E_T_  = ''			" + Enter
					If chkfile("PEDIDO")
						dbSelectArea("PEDIDO")
						dbCloseArea()
					EndIf
					TCQUERY CSQL ALIAS "PEDIDO" NEW
					TOTAL_ABERTO += PEDIDO->SALDO
					PEDIDO->(dbCloseArea())

					TOTAL_ABERTO += nTotLib //Validação do RA para processo BIANCOGRES/INCESA -> LM

				EndIf

				//Verificar se o Saldo de RA e suficiente para atender ao Pedido
				If TOTAL_ABERTO > TOTAL_RA
					If TOTAL_ABERTO - TOTAL_RA > GetMv("MV_YDESCRA") 	//Se a diferenca entre o Pedido e RA for maior que o parametro Bloqueia.
						If GETMV("MV_YVLDRA") .Or. ( !GETMV("MV_YVLDRA") .And. (Alltrim(Funname())== "BIAEC001" .Or. Alltrim(Funname())== "MATA460A") )
							//If GETMV("MV_YVLDRA") .Or. ( !GETMV("MV_YVLDRA") .And. (Alltrim(Funname())== "BIAEC001"  ) )
							nRet   :=  '01'
							If llMsg
								MSGBOX("Total de Pedidos em Aberto (R$ " +ALLTRIM(TRANSFORM(TOTAL_ABERTO,"@E 999,999,999.99"))+"), é maior que o Total de RA (R$ " +ALLTRIM(TRANSFORM(TOTAL_RA,"@E 999,999,999.99"))+"). ","fVerificaCredito","STOP")
							EndIf
						Else
							nRet   :=  '00'
							//nRaStat := "2" //Aguardando Lancamento Ra // DESATIVADO EM 20/10/14 RANISSES
							If llMsg
								nMsg := "Total de Pedidos em Aberto (R$ " +ALLTRIM(TRANSFORM(TOTAL_ABERTO,"@E 999,999,999.99"))+"), é maior que o Total de RA (R$ " +ALLTRIM(TRANSFORM(TOTAL_RA,"@E 999,999,999.99"))+"). " + Enter
								nMsg += " " + Enter
								nMsg += "O Pedido será gravado, porém para realizar a montagem de Carga ou Faturamento é necessário realizar a inclusão de RA." + Enter
								MSGBOX(nMsg,"fVerificaCredito","INFO")
							EndIf
						EndIf
					Else
						nRet   :=  '00'
					EndIf
				Else
					nRet   :=  '00'
					//nRaStat := "1" //Liberado com Saldo // DESATIVADO EM 20/10/14 RANISSES
				EndIf

			EndIf

		EndIf

		//Se o pedido estiver cadastrado na tebela SZN - Liberacao Pedidos, libera automaticamente
	Else
		nRet   :=  '00'
	EndIf

	If chkfile("_PED_PEN")
		dbSelectArea("_PED_PEN")
		dbCloseArea()
	EndIf
	If chkfile("_SE1")
		DbSelectArea("_SE1")
		DbCloseArea()
	EndIf
	If chkfile("_SZN")
		dbSelectArea("_SZN")
		dbCloseArea()
	EndIf

	RestArea(aAreaSC9)
	RestArea(aArea)

Return nRet