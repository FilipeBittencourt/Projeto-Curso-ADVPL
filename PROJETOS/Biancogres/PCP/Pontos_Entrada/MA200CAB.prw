#Include "TOPCONN.CH"
#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'
#Include "tbiconn.ch"
#Include 'FONT.CH'
#Include 'COLORS.CH'
#Include "FOLDER.CH"
#INCLUDE 'MATA200.CH'
#INCLUDE 'DBTREE.CH'
#include "TOTVS.CH"

/*/{Protheus.doc} MA200CAB
@author Marcos Alberto Soprani
@since 24/08/11
@version 1.0
@description Ponto de Entrada que permite a Inclusão de gets, says, etc
.            na tela de cadastro de estrutura
@type function
/*/

User Function MA200CAB()

	Local aUndo        := {}
	Local oPanel2
	Public xc_NewRev   := Space(03)
	Public xc_NDtIni   := dDataBase
	Public xc_VldNRv   := .T.
	Public obj_Tela    := PARAMIXB[3]
	Public zt_RevAtu   := ""
	Public zy_NewRev   := .F.
	Public zy_Opcao    := PARAMIXB[2]

	Public zt_PrdSim   := Space(15)

	// Alterado por Marcos Alberto Soprani em 06/08/18
	SB1->( dbSetOrder(1) )
	SB1->( dbSeek( xFilial("SB1") + cProduto ) )
	cRevisao := SB1->B1_REVATU 

	If zy_Opcao == 3                                                            // Inclusão
		***********************************************************************************

		@ 008, 300 SAY "Estrutura Similar para cópia:" SIZE 077, 007 OF PARAMIXB[3] PIXEL
		@ 006, 370 MSGET zt_PrdSim SIZE 040, 010 OF PARAMIXB[3] PIXEL PICTURE PesqPict('SG1','G1_COD') WHEN ( xc_VldNRv .and. !cRevisao $ zt_RevAtu ) F3 "SB1";
		Valid xA200CodSim(cProduto, zt_PrdSim, @aUndo)

	ElseIf zy_Opcao == 4                                                       // Alteração
		***********************************************************************************

		// Alterado por Marcos Alberto Soprani em 06/08/18
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial("SB1") + cProduto ) )
		cRevisao := SB1->B1_REVATU 

		AZ001 := " SELECT G1_TRT "
		AZ001 += "   FROM " + RetSqlName("SG1") + " "
		AZ001 += "  WHERE G1_FILIAL = '" + xFilial("SG1") + "' "
		AZ001 += "    AND G1_COD = '" + cProduto + "' "
		AZ001 += "    AND D_E_L_E_T_ = ' ' "
		AZ001 += "  GROUP BY G1_TRT "
		TcQuery AZ001 New Alias "AZ01"
		dbSelectArea("AZ01")
		dbGoTop()
		While !Eof()
			zt_RevAtu   += AZ01->G1_TRT+","
			dbSelectArea("AZ01")
			dbSkip()
		End
		AZ01->(dbCloseArea())

		@ 008, 300 SAY "Data inicial p/ nova revisão:" SIZE 077, 007 OF PARAMIXB[3] PIXEL
		@ 006, 370 MSGET xc_NDtIni SIZE 040, 010 OF PARAMIXB[3] PIXEL PICTURE PesqPict('SG1','G1_INI') WHEN ( xc_VldNRv .and. !cRevisao $ zt_RevAtu )

		@ 022, 330 SAY "Nova Revisão:" SIZE 037, 007 OF PARAMIXB[3] PIXEL
		@ 020, 370 MSGET xc_NewRev SIZE 015, 010 OF PARAMIXB[3] PIXEL PICTURE PesqPict('SG1','G1_REVINI') WHEN ( xc_VldNRv .and. !cRevisao $ zt_RevAtu ) ;
		Valid xA200CodSim(cProduto, cProduto, @aUndo)

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ xA200CodSim ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 24.08.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Rotina Original A200CodSim do fonte MATA200. Valida Estru- ¦¦¦
¦¦¦          ¦tura Similar.                                               ¦¦¦
¦¦¦          ¦ Importante ressaltar que tanto a variável cProduto quanto  ¦¦¦
¦¦¦          ¦a cCodSim são iguais o que vai mudar é exatamente o revisão ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xA200CodSim(cProduto, cCodSim, aUndo)

	Local lRet		 := .T.
	Local aAreaAnt   := GetArea()
	Local aAreaSB1   := SB1->(GetArea())
	Local aAreaSG1   := SG1->(GetArea())
	Local cNomeArq   := ''
	Private nEstru   := 0

	If xc_NewRev <> cRevisao .and. zy_Opcao <> 3
		lRet := .F.
	EndIf

	If lRet

		// Esta regra se fez necessária para que o usuário não gerasse mais de uma revisão para o mesmo dia
		//gerando problema com a questão das datas inicial e final de cada revisão
		qp_Contad := 0
		If zy_Opcao <> 3

			AT001 := " SELECT COUNT(*) CONTAD "
			AT001 += "   FROM " + RetSqlName("SG1") + " "
			AT001 += "  WHERE G1_FILIAL = '" + xFilial("SG1") + "' "
			AT001 += "    AND G1_COD = '" + cProduto + "' "
			AT001 += "    AND G1_INI = '" + dtos(xc_NDtIni) + "' "
			AT001 += "    AND D_E_L_E_T_ = ' ' "
			TCQUERY AT001 New Alias "AT01"
			dbSelectArea("AT01")
			dbGotop()
			qp_Contad := AT01->CONTAD
			AT01->(dbCloseArea())

		Else

			// Alterado por Marcos Alberto Soprani em 06/08/18
			SB1->( dbSetOrder(1) )
			SB1->( dbSeek( xFilial("SB1") + cProduto ) )
			cRevisao := SB1->B1_REVATU 

		EndIf

		If qp_Contad == 0

			If !Empty(cCodSim)

				SB1->(dbSetOrder(1))
				If !SB1->(dbSeek(xFilial('SB1') + cCodSim))
					Help(' ',1,'NOFOUNDSB1')
					lRet := .F.
				EndIf

				SG1->(dbSetOrder(1))
				If lRet .And. !SG1->((dbSeek(xFilial('SG1') + cCodSim)))
					Help(' ',1,'ESTNEXIST')
					lRet := .F.
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se o produto similar n„o contem o produto principal em sua estrutura. ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet

					cNomeArq := Estrut2(cCodSim)
					dbSelectArea('ESTRUT')
					ESTRUT->(dbGotop())
					Do While !ESTRUT->(Eof())
						If ESTRUT->COMP == cProduto
							Help(' ',1,'SIMINVALID')
							lRet := .F.
							Exit
						EndIf
						ESTRUT->(dbSkip())
					EndDo

					If lRet

						FimEstrut2(Nil,cNomeArq)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Restaura Area de trabalho.                                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						RestArea(aAreaSG1)
						RestArea(aAreaSB1)
						RestArea(aAreaAnt)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Gera Registros da Estrutura Similar                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						xMa200GrSim(cProduto, cCodSim, @aUndo)

					EndIf

				EndIf

			EndIf

		Else

			xc_NewRev   := Space(03)
			MsgALERT("Já existe uma revisão cadastrada para a data em questão!!!")

		EndIf

		xc_VldNRv := .F.

	Else

		MsgALERT("Problemas ao determinar a nova revisão. Favor verificar!!!")

	EndIf

Return lRet

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ xMa200GrSim ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 24.08.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Rotina Original Ma200GrSim do fonte MATA200. Valida Estru- ¦¦¦
¦¦¦          ¦tura Similar.                                               ¦¦¦
¦¦¦          ¦ Importante ressaltar que tanto a variável cProduto quanto  ¦¦¦
¦¦¦          ¦a cCodSim são iguais o que vai mudar é exatamente o revisão ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xMa200GrSim(cProduto, cCodSim, aUndo)

	Local lRet       := .T.
	Local aAreaAnt   := GetArea()
	Local aAreaTRE   := {}
	Local aRecnos    := {}
	Local nX         := 0
	Local i          := 0
	Local aCampos    := {}

	If !Empty(cCodSim)

		zy_NewRev   := .T.

		// Alterado por Marcos Alberto Soprani em 06/08/18
		SB1->( dbSetOrder(1) )
		SB1->( dbSeek( xFilial("SB1") + cCodSim ) )
		gr_RevPai := SB1->B1_REVATU 

		dbSelectArea('SG1')
		dbSetOrder(1)
		If dbSeek(xFilial('SG1') + cCodSim, .F.)
			Do While !Eof() .And. SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cCodSim
				// Esta regra mudou da rotina padrão para a personalização. Criação feito por Marcos Alberto em 24/08/11
				If zy_Opcao <> 3
					If SG1->G1_REVINI == gr_RevPai .and. SG1->G1_REVFIM == gr_RevPai
						aAdd(aRecnos, Recno())
					EndIf
				Else
					If dDataBase >= SG1->G1_INI .and. dDataBase <= SG1->G1_FIM
						aAdd(aRecnos, Recno())
					EndIf
				EndIf
				dbSkip()
			EndDo
		EndIf

		If Len(aRecnos) > 0
			For nX := 1 to Len(aRecnos)
				gr_Comp := Space(15)
				dbGoto(aRecnos[nX])
				gr_Comp := SG1->G1_COMP

				//-- Grava o Campo Atual
				aCampos := {}
				For i := 1 To FCount()
					aAdd(aCampos, FieldGet(i))
				Next i

				//-- Cria o Novo Registro
				If !dbSeek( xFilial("SG1") + cProduto + gr_Comp + IIF(zy_Opcao <> 3, xc_NewRev, cRevisao) )

					Begin Transaction
						RecLock('SG1', .T.)
						If aScan(aUndo, {|x| x[1]==Recno()}) == 0
							aAdd(aUndo, {Recno(), 1}) //-- 1=Reg.Incluido/2=Reg.Excluido/3=Reg.Alterado
						EndIf
						For i:=1 To FCount()
							FieldPut(i,aCampos[i])
						Next 1
						Replace G1_COD     With cProduto
						Replace G1_REVINI  With IIF(SG1->G1_REVFIM <> "ZZZ", IIF(zy_Opcao <> 3, xc_NewRev, cRevisao), "   ")
						Replace G1_TRT     With IIF(SG1->G1_REVFIM <> "ZZZ", IIF(zy_Opcao <> 3, xc_NewRev, cRevisao), "   ")
						Replace G1_REVFIM  With IIF(SG1->G1_REVFIM <> "ZZZ", IIF(zy_Opcao <> 3, xc_NewRev, cRevisao), "ZZZ")
						Replace G1_INI     With xc_NDtIni
						If zy_Opcao == 3
							Replace G1_FIM      With ctod("31/12/49")
							Replace G1_YDESCCD  With Substr( Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"),1,45)
						EndIf
						MsUnlock()
					End Transaction

				EndIf

			Next nX
		EndIf
	EndIf
	//-- Restaura a Area de Trabalho
	RestArea(aAreaAnt)

	oTree:Reset()
	Ma200Monta(oTree, obj_Tela, cProduto, cCodSim, xc_NewRev, zy_Opcao)

Return lRet
