#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"

User Function FA050INC()

	Private cValida   
	Private cCtrBloq := 0        

	//RUBENS JUNIOR (FACILE SISTEMAS) 01/11/13
	//TITULOS MANUAIS SEREM INSERIDOS BLOQUEADOS, PARA APROVACAO
	//PARA UTILIZACAO DOS TITULOS, SERA NECESSERAIO OS APROVADORES ACESSAREM A ROTINA BIA184()
	IF((FunName() = "FINA050") .Or. (FunName() = "FINA750"))  

		// Tiago Rossini coradini - Data: 19/11/15 - OS: 1006-15 - Mikaelly Gentil - Não bloquear titulos a pagar com tipo PA/PR
		If !Alltrim(M->E2_TIPO) $ "PA/PR"
			M->E2_MSBLQL := '1'
		EndIf

	EndIf

	//Valida classe de valor e contrato para PA.
	IF ALLTRIM(M->E2_TIPO) == 'PA'

		IF EMPTY(M->E2_CLVL)
			MsgAlert("O campo Classe de Valor deverá ser preenchido.")
			Return .F.
		ENDIF

		IF EMPTY(M->E2_CCD)
			MsgAlert("O campo Centro de Custo deverá ser preenchido.")
			Return .F.
		ENDIF

		IF cEmpAnt <> '02'
		
			IF SUBSTR(M->E2_CLVL,1,1) == '8' .AND. EMPTY(M->E2_YCONTR)
				MsgAlert("O campo contrato deverá ser preenchido quando a Classe de Valor iniciar com 8.")
				Return .F.
			ENDIF
								
			// Valida Subitem de projeto
			If !U_BIAF160(M->E2_CLVL, M->E2_ITEMCTA, M->E2_YSUBITE)
			
				MsgBox("A classe de valor e o item de selecionados, exige o preenchimento do Subitem de Projeto!", "FA050INC", "STOP")
				
				Return .F.
							
			EndIf
			
			IF !EMPTY(M->E2_YCONTR)
				DbSelectArea("SC3")
				DbSetOrder(1)
				DbSeek(xFilial("SC3")+M->E2_YCONTR)
				lPassei := .F.

				WHILE !EOF() .AND. SC3->C3_NUM == M->E2_YCONTR
					IF ALLTRIM(M->E2_CLVL) == ALLTRIM(SC3->C3_YCLVL)
						lPassei := .T.
						
						IF SC3->C3_MSBLQL == '1' .AND. cCtrBloq <> 2
						    cCtrBloq := 1							
						ELSE
						  cCtrBloq := 2
						ENDIF
					ENDIF

					DbSelectArea("SC3")
					DbSkip()
				END
				
				IF cCtrBloq == 1
				   MsgAlert("[FA050INC] Este contrato está bloqueado.")
				   cCtrBloq := 0
				   Return .F.
				ENDIF

				IF !lPassei
					MsgAlert("A Classe de Valor deste PA deverá ser igual a Classe de Valor do Contrato informado.")
					Return .F.
				ENDIF

				// BUSCANDO O VALOR DO CONTRATO -- COLOCAR O CODIGO DO CONTRATO COMO PARAMETRO
				IF SUBSTR(M->E2_YCONTR,3,1) = '9'
					CSQL := "SELECT ISNULL(SUM(C3_TOTAL),0) AS CONTRATO FROM "+RETSQLNAME("SC3")+" WHERE C3_NUM = '"+M->E2_YCONTR+"' AND "
				ELSE
					CSQL := "SELECT ISNULL(SUM(C3_TOTAL),0) AS CONTRATO FROM "+RETSQLNAME("SC3")+" WHERE SUBSTRING(C3_NUM,1,5) = '"+SUBSTR(M->E2_YCONTR,1,5)+"' AND "
				ENDIF
				CSQL += "C3_YCLVL = '"+M->E2_CLVL+"' AND D_E_L_E_T_ = '' "
				IF CHKFILE("_CONTRATO")
					DBSELECTAREA("_CONTRATO")
					DBCLOSEAREA()
				ENDIF
				TCQUERY CSQL ALIAS "_CONTRATO" NEW
				IF _CONTRATO->CONTRATO = 0
					RETURN
				ENDIF

				DbSelectArea("SC3")
				DbSetOrder(1)
				DbSeek(xFilial("SC3")+M->E2_YCONTR)

				IF dDatabase < SC3->C3_DATPRI .OR. dDatabase > SC3->C3_DATPRF
					MSGBOX("Esta PA não poderá ser inclusa pois a data está fora da vigência do contrato ","STOP")
				ENDIF

				// BUSCANDO OS PA'S
				IF SUBSTR(M->E2_YCONTR,3,1) = '9'
					CSQL := "SELECT ISNULL(SUM(E2_VALOR),0) AS PA FROM "+RETSQLNAME("SE2")+" WHERE E2_YCONTR = '"+M->E2_YCONTR+"' AND E2_TIPO = 'PA' AND "
				ELSE
					CSQL := "SELECT ISNULL(SUM(E2_VALOR),0) AS PA FROM "+RETSQLNAME("SE2")+" WHERE SUBSTRING(E2_YCONTR,1,5) = '"+SUBSTR(M->E2_YCONTR,1,5)+"' AND E2_TIPO = 'PA' AND "
				ENDIF
				CSQL += "E2_CLVL = '"+M->E2_CLVL+"' AND D_E_L_E_T_ = '' "
				IF CHKFILE("_PA")
					DBSELECTAREA("_PA")
					DBCLOSEAREA()
				ENDIF
				TCQUERY CSQL ALIAS "_PA" NEW

				IF (M->E2_VALOR + _PA->PA) > _CONTRATO->CONTRATO
					MSGBOX("O valor de todos os PAs inclusos para este contrato não poderá ultrapassar o limite do contrato","STOP")
				ENDIF
			ENDIF
		ENDIF
		
		
		
	ENDIF

	//Selecionar a natureza de acordo com o campo M->E2_NATUREZ
	dbSelectArea("SED")
	dbSetOrder(1)
	dbSeek(xFilial("SED")+AllTrim(M->E2_NATUREZ))
	cValida := SED->ED_YVALEXP

	// Em 18/12/17... por Marcos Alberto Soprani... Retirado até segunda Ordem... Estou fazendo um teste de compensação entre carteiras
	If 1 == 2

		If cValida == "N"

			If Empty(M->E2_YPROCEX)
				Return .T.
			Else
				Alert ("Esta Natureza e utilizada somente para despesas referentes a Exportação")
				Return .F.
			Endif

		Else

			If Empty(M->E2_YPROCEX)
				Alert ("Para a Natureza utilizada e necessário informar um Processo de Exportação!")
				Return .F.
			Else
				Return .T.
			Endif

		EndIf

	Else

		Return .T.

	EndIf

Return