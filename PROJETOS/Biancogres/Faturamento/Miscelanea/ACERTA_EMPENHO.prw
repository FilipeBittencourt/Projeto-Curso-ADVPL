#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} ACERTA_EMPENHO
@description PROGRAMA PARA ACERTAR PROBLEMAS DE ESTOQUE RELACIONADO A EMPENHOS E RESERVAS QUE OCORREM OCASIONALMENTE - PODE SER RODADO MANUALMENTE MAS TB TEM JOB DIARIAS AS 02:00AM
@author MADALENO / Revisado por Fernando Rocha
@since 25/07/2008
@version 1.0
@type function
/*/
USER FUNCTION ACERTA_EMPENHO()

	Pergunte("ACE_EMP", .F.)

	@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Refaz Empenho SB2/SBF/SB8"
	@ 8,10 TO 84,222

	@ 16,12 SAY "Esta rotina tem por finalidade: "
	@ 24,12 SAY "Refazer os saldos de empenhos nas tabelas SB2 x SBF x SB8."

	@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
	@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
	@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("ACE_EMP", .T.) //ABRE PERGUNTAS

	ACTIVATE DIALOG oDlg5 CENTERED

RETURN()

//Chama rotina que acerta o empenho
Static Function OkProc()
	Processa( {|| U_ACEMPPRC(.F.) } )
	Close(oDlg5)
Return


//Rotina que realiza o acerto do Empenho
User Function ACEMPPRC(_lAuto, _cProdDe,_cProdAte)

	Default _lAuto := .T.
	Default _cProdDe := MV_PAR01
	Default _cProdAte := MV_PAR02

	PRIVATE CSQL	:= ""
	PRIVATE ENTER	:= CHR(13)+CHR(10)
	PRIVATE CPRODUTO, CLOTE, CLOCALIZACAO, CQUANT, CQUANT2
	PRIVATE lRet	:= .F. 

	If !_lAuto
		lRet := MsgBox("Esta rotina irá refazer os empenhos de produtos PA. Deseja continuar? ","Atencao","YesNo")
	Else
		Conout("ACEMPPRC -> INICIANDO ACERTO DE EMPENHO - PRODUTO: "+_cProdDe)
		lRet := .T.
	EndIf

	If lRet

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			SELECT B2_LOCAL
			FROM  %Table:SB2%
			WHERE B2_COD >= %Exp:_cProdDe% AND B2_COD <= %Exp:_cProdAte% AND B2_COD >= 'A' AND %NOTDEL%
			GROUP BY B2_LOCAL
		EndSql

		If !(cAliasTmp)->(EOF())
			CSQL := " UPDATE "+RETSQLNAME("SDC")+" SET D_E_L_E_T_ = '*'												"+ ENTER
			CSQL += " WHERE D_E_L_E_T_ 	= '' 																		"+ ENTER
			CSQL += " AND DC_ORIGEM 	= 'SC0'																		"+ ENTER
			CSQL += " AND DC_PRODUTO BETWEEN '"+_cProdDe+"' AND '"+_cProdAte+"'										"+ ENTER
			CSQL += " AND NOT EXISTS (																				"+ ENTER
			CSQL += " 					SELECT * 																	"+ ENTER
			CSQL += " 					FROM "+RETSQLNAME("SC0")+" 													"+ ENTER
			CSQL += " 					WHERE C0_NUM 	= DC_PEDIDO 												"+ ENTER
			CSQL += "					AND C0_PRODUTO 	= DC_PRODUTO 												"+ ENTER
			CSQL += " 					AND D_E_L_E_T_ 	= '')														"+ ENTER	
			TCSQLEXEC(CSQL)
		EndIf

		While  !(cAliasTmp)->(EOF())

			//Antes de atualizar, zera todo o empenho do SB2 -- EXECUTA UMA UNICA VEZ, ANTES DA ATUALIZACAO
			CSQL := "UPDATE "+RETSQLNAME("SB2")+" SET B2_RESERVA = 0 , B2_RESERV2 = 0 " + ENTER
			CSQL += "WHERE	B2_COD  >= '"+_cProdDe+"' AND " + ENTER
			CSQL += "				B2_COD  <= '"+_cProdAte+"' AND " + ENTER
			CSQL += "				B2_LOCAL = '"+(cAliasTmp)->B2_LOCAL+"' AND 	D_E_L_E_T_ = '' " + ENTER
			TCSQLEXEC(CSQL)

			//Antes de atualizar, zera todo o empenho do SBF -- EXECUTA UMA UNICA VEZ, ANTES DA ATUALIZACAO
			CSQL := "UPDATE "+RETSQLNAME("SBF")+" SET BF_EMPENHO = 0, BF_EMPEN2 = 0 " + ENTER
			CSQL += "WHERE	BF_PRODUTO >= '"+_cProdDe+"'	AND " + ENTER
			CSQL += "				BF_PRODUTO <= '"+_cProdAte+"'	AND " + ENTER
			CSQL += "				BF_LOCAL	  = '"+(cAliasTmp)->B2_LOCAL+"'	AND " + ENTER
			CSQL += "				D_E_L_E_T_ = ''										" + ENTER
			TCSQLEXEC(CSQL)

			//Antes de atualizar, zera o empenho do SB8	-- EXECUTA UMA UNICA VEZ, ANTES DA ATUALIZACAO
			CSQL := "UPDATE "+RETSQLNAME("SB8")+" SET B8_EMPENHO = 0, B8_EMPENH2 = 0 " + ENTER
			CSQL += "WHERE	B8_PRODUTO >= '"+_cProdDe+"'	AND " + ENTER
			CSQL += "				B8_PRODUTO <= '"+_cProdAte+"'	AND " + ENTER
			CSQL += "				B8_LOCAL	  = '"+(cAliasTmp)->B2_LOCAL+"'	AND " + ENTER
			CSQL += "				D_E_L_E_T_ = ''										" + ENTER
			TCSQLEXEC(CSQL)



			//VERIFICANDO O SALDO POR PRODUTO (SB2) 
			//Seleciona o Total do Produto -- SB2
			CSQL := "SELECT DC_PRODUTO, SUM(DC_QUANT) QUANT, SUM(DC_QTSEGUM) QUANT2 " + ENTER
			CSQL += "FROM "+RETSQLNAME("SDC")+"		" + ENTER
			CSQL += "WHERE 	DC_PRODUTO >= '"+_cProdDe+"'	AND " + ENTER
			CSQL += "				DC_PRODUTO <= '"+_cProdAte+"'	AND " + ENTER
			CSQL += "				DC_LOCAL	  = '"+(cAliasTmp)->B2_LOCAL+"'	AND " + ENTER
			CSQL += "				D_E_L_E_T_ = ''										" + ENTER
			CSQL += "GROUP BY DC_PRODUTO " + ENTER
			CSQL += "ORDER BY DC_PRODUTO " + ENTER
			IF CHKFILE("_EMP3")
				DBSELECTAREA("_EMP3")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_EMP3" NEW

			CSQL := "SELECT COUNT(*) AS QUANT			" + ENTER
			CSQL += "FROM	(SELECT DC_PRODUTO PRODUTO  " + ENTER
			CSQL += "		FROM "+RETSQLNAME("SDC")+"	" + ENTER
			CSQL += "		WHERE	DC_PRODUTO >= '"+_cProdDe+"'	AND " + ENTER
			CSQL += "					DC_PRODUTO <= '"+_cProdAte+"'	AND " + ENTER
			CSQL += "				  DC_LOCAL	  = '"+(cAliasTmp)->B2_LOCAL+"'	AND " + ENTER
			CSQL += "					D_E_L_E_T_ = ''										" + ENTER
			CSQL += "		GROUP BY DC_PRODUTO) AS TTT " + ENTER
			IF CHKFILE("_EMP4")
				DBSELECTAREA("_EMP4")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_EMP4" NEW

			ProcRegua(_EMP4->QUANT)

			//Atualiza SB2
			DO WHILE ! _EMP3->(EOF())
				IncProc("Corrigindo Empenho SB2... "+(cAliasTmp)->B2_LOCAL+"/"+ALLTRIM(_EMP3->DC_PRODUTO))
				//Atualiza SB2
				CSQL := "UPDATE "+RETSQLNAME("SB2")+" SET B2_RESERVA = "+ALLTRIM(STR(_EMP3->QUANT))+" , B2_RESERV2 = "+ALLTRIM(STR(_EMP3->QUANT2))+" " + ENTER
				CSQL += "WHERE	B2_COD = '"+_EMP3->DC_PRODUTO+"' AND B2_LOCAL = '"+(cAliasTmp)->B2_LOCAL+"' AND 	D_E_L_E_T_ = '' " + ENTER
				TCSQLEXEC(CSQL)
				_EMP3->(DBSKIP())
			END DO

			//VERIFICANDO O SALDO POR LOCALIZACAO (SBF) PARA PODER ACERTA-LO

			//Seleciona o Total do Produto/Lote/Localizacao -- SBF
			CSQL := "SELECT DC_PRODUTO, DC_LOTECTL, DC_LOCALIZ, SUM(DC_QUANT) QUANT, SUM(DC_QTSEGUM) QUANT2 " + ENTER
			CSQL += "FROM "+RETSQLNAME("SDC")+"  " + ENTER
			CSQL += "WHERE	DC_PRODUTO >= '"+_cProdDe+"'	AND " + ENTER
			CSQL += "				DC_PRODUTO <= '"+_cProdAte+"'	AND " + ENTER
			CSQL += "				DC_LOCAL		= '"+(cAliasTmp)->B2_LOCAL+"'	AND " + ENTER
			CSQL += "				D_E_L_E_T_ = ''										" + ENTER
			CSQL += "GROUP BY DC_PRODUTO, DC_LOTECTL, DC_LOCALIZ " + ENTER
			CSQL += "ORDER BY DC_PRODUTO, DC_LOTECTL, DC_LOCALIZ " + ENTER
			IF CHKFILE("_EMP")
				DBSELECTAREA("_EMP")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_EMP" NEW

			//Seleciona a Quantidade de Registros
			CSQL := "SELECT COUNT(*) AS QUANT			" + ENTER
			CSQL += "FROM	(SELECT DC_PRODUTO, DC_LOTECTL, DC_LOCALIZ, SUM(DC_QUANT) QUANT, SUM(DC_QTSEGUM) QUANT2 " + ENTER
			CSQL += "		FROM "+RETSQLNAME("SDC")+"	" + ENTER
			CSQL += "		WHERE	DC_PRODUTO >= '"+_cProdDe+"'	AND " + ENTER
			CSQL += "					DC_PRODUTO <= '"+_cProdAte+"'	AND " + ENTER
			CSQL += "					DC_LOCAL		= '"+(cAliasTmp)->B2_LOCAL+"'	AND " + ENTER
			CSQL += "					D_E_L_E_T_ = ''										" + ENTER
			CSQL += "		GROUP BY DC_PRODUTO, DC_LOTECTL, DC_LOCALIZ) AS TTT " + ENTER
			IF CHKFILE("_EMP2")
				DBSELECTAREA("_EMP2")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_EMP2" NEW

			ProcRegua(_EMP2->QUANT)

			DO WHILE ! _EMP->(EOF())

				IncProc("Corrigindo Empenho SBF... "+(cAliasTmp)->B2_LOCAL+"/"+ALLTRIM(_EMP->DC_PRODUTO))

				CPRODUTO 		:= _EMP->DC_PRODUTO
				CLOTE 			:= _EMP->DC_LOTECTL
				CLOCALIZACAO 	:= _EMP->DC_LOCALIZ
				CQUANT 			:= _EMP->QUANT
				CQUANT2 		:= _EMP->QUANT2

				CSQL := "SELECT BF_PRODUTO, BF_LOTECTL, BF_LOCALIZ, BF_QUANT, BF_EMPENHO, BF_EMPEN2 " + ENTER
				CSQL += "FROM "+RETSQLNAME("SBF")+" " + ENTER
				CSQL += "WHERE	BF_PRODUTO = '"+CPRODUTO+"' AND " + ENTER
				CSQL += "		BF_LOTECTL = '"+CLOTE+"' AND " + ENTER
				CSQL += "		BF_LOCALIZ = '"+CLOCALIZACAO+"' AND " + ENTER
				CSQL += "		BF_LOCAL	 = '"+(cAliasTmp)->B2_LOCAL+"' AND " + ENTER
				CSQL += "		D_E_L_E_T_ = '' " + ENTER
				CSQL += "GROUP BY BF_PRODUTO, BF_LOTECTL, BF_LOCALIZ, BF_QUANT, BF_EMPENHO, BF_EMPEN2 " + ENTER
				CSQL += "ORDER BY BF_PRODUTO, BF_LOTECTL, BF_LOCALIZ, BF_QUANT, BF_EMPENHO, BF_EMPEN2 " + ENTER
				IF CHKFILE("_SBF")
					DBSELECTAREA("_SBF")
					DBCLOSEAREA()
				ENDIF
				TCQUERY CSQL ALIAS "_SBF" NEW

				IF _SBF->(EOF())
					MSGBOX("PRODUTO "+CPRODUTO+ " LOTE " +CLOTE+ " LOCALIZAÇÃO " +CLOCALIZACAO+ " NÃO ENCONTRADA NA TABELA SBF")
				ELSE
					IF CQUANT <> _SBF->BF_EMPENHO //.AND. CQUANT2 <> _SBF->BF_EMPEN2
						CSQL := "UPDATE "+RETSQLNAME("SBF")+" SET BF_EMPENHO = "+ALLTRIM(STR(CQUANT))+", BF_EMPEN2 = "+ALLTRIM(STR(CQUANT2))+" " + ENTER
						CSQL += "FROM "+RETSQLNAME("SBF")+" " + ENTER
						CSQL += "WHERE	BF_PRODUTO = '"+CPRODUTO+"' AND " + ENTER
						CSQL += "		BF_LOTECTL = '"+CLOTE+"' AND " + ENTER
						CSQL += "		BF_LOCALIZ = '"+CLOCALIZACAO+"' AND " + ENTER
						CSQL += "		BF_LOCAL	 = '"+(cAliasTmp)->B2_LOCAL+"' AND " + ENTER
						CSQL += "		D_E_L_E_T_ = '' " + ENTER
						TCSQLEXEC(CSQL)
					END IF
				END IF
				_EMP->(DBSKIP())
			END DO

			//VERIFICANDO O SALDO NA TABELA DE LOTE (SB8) PARA PODR ACERTA-LO
			CSQL := "SELECT DC_PRODUTO, DC_LOTECTL, SUM(DC_QUANT) QUANT, SUM(DC_QTSEGUM) QUANT2 " + ENTER
			CSQL += "FROM "+RETSQLNAME("SDC")+" " + ENTER
			CSQL += "WHERE	DC_PRODUTO >= '"+_cProdDe+"'	AND " + ENTER
			CSQL += "				DC_PRODUTO <= '"+_cProdAte+"'	AND " + ENTER
			CSQL += "				DC_LOCAL	  = '"+(cAliasTmp)->B2_LOCAL+"'	AND " + ENTER
			CSQL += "				D_E_L_E_T_ = ''										" + ENTER
			CSQL += "GROUP BY DC_PRODUTO, DC_LOTECTL " + ENTER
			CSQL += "ORDER BY DC_PRODUTO, DC_LOTECTL " + ENTER
			IF CHKFILE("_EMP")
				DBSELECTAREA("_EMP")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_EMP" NEW

			//Seleciona a Quantidade de Registros
			CSQL := "SELECT COUNT(*) AS QUANT			" + ENTER
			CSQL += "FROM	(SELECT DC_PRODUTO, DC_LOTECTL, SUM(DC_QUANT) QUANT, SUM(DC_QTSEGUM) QUANT2 " + ENTER
			CSQL += "		FROM "+RETSQLNAME("SDC")+"	" + ENTER
			CSQL += "		WHERE	DC_PRODUTO >= '"+_cProdDe+"'	AND " + ENTER
			CSQL += "					DC_PRODUTO <= '"+_cProdAte+"'	AND " + ENTER
			CSQL += "					DC_LOCAL	  = '"+(cAliasTmp)->B2_LOCAL+"'	AND " + ENTER
			CSQL += "					D_E_L_E_T_ = ''										" + ENTER
			CSQL += "		GROUP BY DC_PRODUTO, DC_LOTECTL) AS TTT " + ENTER
			IF CHKFILE("_EMP2")
				DBSELECTAREA("_EMP2")
				DBCLOSEAREA()
			ENDIF
			TCQUERY CSQL ALIAS "_EMP2" NEW

			ProcRegua(_EMP2->QUANT)

			DO WHILE ! _EMP->(EOF())

				IncProc("Corrigindo Empenho SB8... "+(cAliasTmp)->B2_LOCAL+"/"+ALLTRIM(_EMP->DC_PRODUTO))

				CPRODUTO 	:= _EMP->DC_PRODUTO
				CLOTE 		:= _EMP->DC_LOTECTL
				CQUANT 		:= _EMP->QUANT
				CQUANT2 	:= _EMP->QUANT2

				CSQL := "SELECT SUM(B8_SALDO) AS B8_SALDO, SUM(B8_SALDO2) AS B8_SALDO2, SUM(B8_EMPENHO) AS B8_EMPENHO, SUM(B8_EMPENH2) AS B8_EMPENH2 " + ENTER
				CSQL += "FROM "+RETSQLNAME("SB8")+" " + ENTER
				CSQL += "WHERE	B8_PRODUTO = '"+CPRODUTO+"' AND " + ENTER
				CSQL += "		B8_LOTECTL = '"+CLOTE+"' AND  " + ENTER
				CSQL += "		B8_SALDO > 0 AND		 " + ENTER
				CSQL += "		B8_LOCAL	 = '"+(cAliasTmp)->B2_LOCAL+"'	AND " + ENTER
				CSQL += "		D_E_L_E_T_ = '' " + ENTER
				IF CHKFILE("_AUX")
					DBSELECTAREA("_AUX")
					DBCLOSEAREA()
				ENDIF
				TCQUERY CSQL ALIAS "_AUX" NEW


				IF (CQUANT - _AUX->B8_EMPENHO) <> 0

					CSQL := "SELECT B8_SALDO, B8_SALDO2, B8_EMPENHO, B8_EMPENH2, R_E_C_N_O_ " + ENTER
					CSQL += "FROM "+RETSQLNAME("SB8")+" 			" + ENTER
					CSQL += "WHERE	B8_PRODUTO = '"+CPRODUTO+"' AND " + ENTER
					CSQL += "		B8_LOTECTL = '"+CLOTE+"'	AND " + ENTER
					CSQL += "		B8_SALDO   > 0 						AND	" + ENTER
					CSQL += "		B8_LOCAL	 = '"+(cAliasTmp)->B2_LOCAL+"'	AND " + ENTER
					CSQL += "		D_E_L_E_T_ = '' 							" + ENTER
					CSQL += "ORDER BY B8_NUMLOTE 							" + ENTER
					IF CHKFILE("_SB8")
						DBSELECTAREA("_SB8")
						DBCLOSEAREA()
					ENDIF
					TCQUERY CSQL ALIAS "_SB8" NEW

					DO WHILE ! _SB8->(EOF())
						IF CQUANT <> 0
							QUANT_DIF := ( _SB8->B8_SALDO  )
							QUANT_DIF2 := ( _SB8->B8_SALDO2  )

							CRECNO 		:= _SB8->R_E_C_N_O_


							IF QUANT_DIF <> 0

								IF QUANT_DIF >= CQUANT
									CSQL := "UPDATE "+RETSQLNAME("SB8")+" SET B8_EMPENHO = "+ALLTRIM(STR(CQUANT))+", B8_EMPENH2 = "+ALLTRIM(STR(CQUANT2))+" " + ENTER
									CSQL += "WHERE	B8_PRODUTO = '"+CPRODUTO+"' AND " + ENTER
									CSQL += "		B8_LOTECTL = '"+CLOTE+"' AND  " + ENTER
									CSQL += "		B8_LOCAL	 = '"+(cAliasTmp)->B2_LOCAL+"'	AND " + ENTER
									CSQL += "		D_E_L_E_T_ = '' " + ENTER
									CSQL += "		AND R_E_C_N_O_ = '"+ALLTRIM(STR(CRECNO))+"' " + ENTER
									TCSQLEXEC(CSQL)
									CQUANT 	:= 0
									CQUANT2 := 0
								ELSE
									CQUANT := CQUANT -QUANT_DIF
									CQUANT2 := CQUANT2 -QUANT_DIF2

									CSQL := "UPDATE "+RETSQLNAME("SB8")+" SET B8_EMPENHO = "+ALLTRIM(STR(QUANT_DIF))+", B8_EMPENH2 = "+ALLTRIM(STR(QUANT_DIF2))+" " + ENTER
									CSQL += "WHERE	B8_PRODUTO = '"+CPRODUTO+"' AND " + ENTER
									CSQL += "		B8_LOTECTL = '"+CLOTE+"' AND  " + ENTER
									CSQL += "		B8_SALDO > 0 AND		 " + ENTER
									CSQL += "		B8_LOCAL	 = '"+(cAliasTmp)->B2_LOCAL+"'	AND " + ENTER
									CSQL += "		D_E_L_E_T_ = '' " + ENTER
									CSQL += "		AND R_E_C_N_O_ = '"+ALLTRIM(STR(CRECNO))+"' " + ENTER
									TCSQLEXEC(CSQL)
								END IF
							END IF
						END IF
						_SB8->(DBSKIP())
					END DO
				END IF
				_EMP->(DBSKIP())
			END DO

			(cAliasTmp)->(dbSkip())
		End


		IF CHKFILE("_EMP")
			DBSELECTAREA("_EMP")
			DBCLOSEAREA()
		ENDIF

		IF CHKFILE("_EMP2")
			DBSELECTAREA("_EMP2")
			DBCLOSEAREA()
		ENDIF

		IF CHKFILE("_EMP3")
			DBSELECTAREA("_EMP3")
			DBCLOSEAREA()
		ENDIF

		IF CHKFILE("_EMP4")
			DBSELECTAREA("_EMP4")
			DBCLOSEAREA()
		ENDIF

		IF CHKFILE("_SBF")
			DBSELECTAREA("_SBF")
			DBCLOSEAREA()
		ENDIF

		IF CHKFILE("_SB8")
			DBSELECTAREA("_SB8")
			DBCLOSEAREA()
		ENDIF

		IF CHKFILE("_AUX")
			DBSELECTAREA("_AUX")
			DBCLOSEAREA()
		ENDIF

		If !_lAuto
			MsgAlert("Atualizacao realizada com sucesso!")
		Else
			Conout("ACEMPPRC -> ACERTO DE EMPENHO FINALIZADO COM SUCESSO - PRODUTO: "+_cProdDe)
		EndIf

		RETURN()

	Else

		RETURN()

	EndIf

/*/{Protheus.doc} FROPACEM
@description ROTINA PARA FAZER O ACERTA EMPENHO VIA JOB AUTOMATICA TODO DIA DE MADRUGADA - Fernando/Facile em 11/05/2015
@author ferna
@since 11/05/2015
@version 1.0
@type function
/*/
User Function FROPACEM() 

	Local xv_Emps    := U_BAGtEmpr("01_05")
	Local nI

	For nI := 1 to Len(xv_Emps)
		//Inicializa o ambiente
		RPCSetType(3)
		WfPrepEnv(xv_Emps[nI,1], xv_Emps[nI,2]) 

		//Processa Acerto de Empenho de alguns produtos conforme query
		Processa({|| PrcAcerta()})

		//Procesa exclusao de Reservas sem arquivo SDC (erro identificado uma vez somente)
		Processa({|| PrcResSdc()})

		RpcClearEnv()
	Next nI

Return  

Static Function PrcAcerta()
	Local cAliasAux
	Local cSQL

	cAliasAux := GetNextAlias()
	BeginSql Alias cAliasAux   
		%NOPARSER%

		with tab_emp as
		(
		SELECT
		B1_COD
		,E1 = (SELECT SUM(B2_RESERVA) FROM %TABLE:SB2% SB2 WHERE B2_COD = B1_COD and B2_LOCAL = BZ_LOCPAD and SB2.D_E_L_E_T_='')
		,E2 = (SELECT SUM(BF_EMPENHO) FROM %TABLE:SBF% SBF WHERE BF_PRODUTO = B1_COD and BF_LOCAL = BZ_LOCPAD AND SBF.D_E_L_E_T_ ='')
		,E3 = (SELECT SUM(B8_EMPENHO) FROM %TABLE:SB8% SB8 WHERE B8_PRODUTO = B1_COD and B8_LOCAL = BZ_LOCPAD AND SB8.D_E_L_E_T_ = '')
		,E4 = (SELECT SUM(DC_QUANT) FROM %TABLE:SDC% SDC WHERE DC_PRODUTO = B1_COD and DC_LOCAL = BZ_LOCPAD AND SDC.D_E_L_E_T_ = '')
		from %TABLE:SB1% SB1 
		join %TABLE:SBZ% SBZ on BZ_FILIAL = '  ' and BZ_COD = B1_COD
		where B1_TIPO = 'PA'
		and SB1.D_E_L_E_T_ = ''
		and SBZ.D_E_L_E_T_ = ''
		)

		select * from tab_emp
		where
		round((E1 + E2 + E3 + E4)/4,2) <> round(E1,2)
		order by B1_COD

	EndSql

	(cAliasAux)->(DbGoTop())
	While !(cAliasAux)->(Eof())

		U_ACEMPPRC(.T., (cAliasAux)->B1_COD,(cAliasAux)->B1_COD)

		(cAliasAux)->(DbSkip())
	EndDo
	(cAliasAux)->(DbCloseArea())

Return

Static Function PrcResSdc()
	Local cAliasAux
	Local cSQL

	cAliasAux := GetNextAlias()
	BeginSql Alias cAliasAux   
		%NOPARSER%

		select C0_NUM, C0_PRODUTO
		from %Table:SC0% SC0
		join %Table:SB1% SB1 on B1_FILIAL = '  ' and B1_COD = C0_PRODUTO 
		where
		B1_LOCALIZ = 'S'
		and SC0.D_E_L_E_T_=''
		and SB1.D_E_L_E_T_=''
		and not exists (select 1 from %Table:SDC% SDC where DC_ORIGEM = 'SC0' and DC_PEDIDO = C0_NUM  and DC_PRODUTO = C0_PRODUTO and SDC.D_E_L_E_T_='')

	EndSql

	(cAliasAux)->(DbGoTop())
	While !(cAliasAux)->(Eof())

		//Procura a Reserva e Exclui a Mesma
		SC0->(DbSetOrder(1))	
		If SC0->(DbSeek(XFilial("SC0")+(cAliasAux)->C0_NUM+(cAliasAux)->C0_PRODUTO))

			__CREST := SC0->(C0_FILIAL+C0_NUM+C0_PRODUTO)

			U_GravaPZ2(SC0->(RecNo()),"SC0",SC0->(C0_FILIAL+C0_NUM+C0_PRODUTO),"NO_SDC",AllTrim(FunName()),"SDC","SISTEMA")

			a430Reserv({3,SC0->C0_TIPO,SC0->C0_DOCRES,SC0->C0_SOLICIT,SC0->C0_FILRES},;
			SC0->C0_NUM,;
			SC0->C0_PRODUTO,;
			SC0->C0_LOCAL,;
			SC0->C0_QUANT,;
			{	SC0->C0_NUMLOTE,;
			SC0->C0_LOTECTL,;
			SC0->C0_LOCALIZ,;
			SC0->C0_NUMSERI})

			U_BIAEnvMail(, "micheli.zanoni@biancogres.com.br;suporte.ti@biancogres.com.br","RESERVA SEM EMPENHO EXCLUIDA", "ERRO - RESERVA: "+__CREST+" - Empresa: "+AllTrim(CEMPANT)+" Excluída por falta do arquivo SDC - Verificar.", '', '', , '')

		EndIf

		(cAliasAux)->(DbSkip())
	EndDo
	(cAliasAux)->(DbCloseArea())

Return
