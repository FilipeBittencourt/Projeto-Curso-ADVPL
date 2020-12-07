#include "TOTVS.ch"
#include "Topconn.ch"

/*/{Protheus.doc} MA030TOK
ealiza validações no cadastro no de Clientes
@type function
@author Bruno Madaleno /  Ranisses A. Corona
@since 02/08/2006
/*/
Static _cMCodCli_
User Function MA030TOK()

	Local lRET 		:= .T.
	Local CMENSAGEM := ""
	Local CTIPO 	:= ""
	Local cEmpresa 	:= ""
	Local cCliente 	:= ""
	Local cLoja 	:= ""
	Local cAliasTmp
	Local  i
	Local nI		:= 0
	Local cVend		:= ''
	Local cVendLib	:= ''
	Local nComi		:= ''
	Local cCliVend  := ''
	Local cMsgVend  := 'O cliente cadastrado é um representante.'+CRLF
	Local cMsgCons  := 'O cliente cadastrado é um consumidor final.'+CRLF
	Local lMsgVend  := .F.
	Local lMsgCons  := .F.
	Local nClExST	:= "005693_002940_010825_010864_017151_010064_006338_008960" //Clientes com exceção para cálculo de ST - Ticket 16079
	Local nUFSTCD	:= "SP_"+GetMV("MV_YUFSTCD") //UF onde o cliente tem que ser SOLIDARIO - Ticket 14718
	Local lPassei
	Local lVendCPF	:= .F.

	Local aListaVen := {;
		'M->A1_VEND', 'M->A1_YVENDB2', 'M->A1_YVENDB3', ; //Bianco
	'M->A1_YVENDI', 'M->A1_YVENDI2', 'M->A1_YVENDI3', ; //Incesa
	'M->A1_YVENBE1', 'M->A1_YVENBE2', 'M->A1_YVENBE3', ; //BellaCasa
	'M->A1_YVENML1', 'M->A1_YVENML2', 'M->A1_YVENML3', ; //Mundialli
	'M->A1_YVENVT1', 'M->A1_YVENVT2', 'M->A1_YVENVT3',; //Vitcer
	'M->A1_YVENPEG',; //Pegasus
	'M->A1_YVENVI1'; //VINILICO
	}

	Local aListaCom := {;
		'M->A1_COMIS', 'M->A1_YCOMB2', 'M->A1_YCOMB3', ; //Bianco
	'M->A1_YCOMISI', 'M->A1_YCOMI2', 'M->A1_YCOMI3', ;//Incesa
	'M->A1_YCOMBE1', 'M->A1_YCOMBE2', 'M->A1_YCOMBE3', ;//BellaCasa
	'M->A1_YCOMML1', 'M->A1_YCOMML2', 'M->A1_YCOMML3', ;//Mundialli
	'M->A1_YCOMVT1', 'M->A1_YCOMVT2', 'M->A1_YCOMVT3', ;//Vitcer
	'M->A1_YCOMPEG',; //Pegasus
	'M->A1_YCOMVI1',; //VINILICO
	}

	Local aListaVend := {;
		'999999/002886/888888/999996/999997',;//bianco
	'999999/002886/888888/999996/999997',;//bianco
	'999999/002886/888888/999996/999997',;//bianco
	'000258/002886',;//incesa
	'000258/002886',;//incesa
	'000258/002886',;//incesa
	'000258/002886/999999/002886/888888/999996/999997',; //BellaCasa
	'000258/002886/999999/002886/888888/999996/999997',; //BellaCasa
	'000258/002886/999999/002886/888888/999996/999997',; //BellaCasa
	'000258/002886/999999/002886/888888/999996/999997',;	//Mundialli
	'000258/002886/999999/002886/888888/999996/999997',;	//Mundialli
	'000258/002886/999999/002886/888888/999996/999997',;	//Mundialli
	'000258/002886/999999/002886/888888/999996/999997',;	////Vitcer
	'000258/002886/999999/002886/888888/999996/999997',;	////Vitcer
	'000258/002886/999999/002886/888888/999996/999997',;	////Vitcer
	'000258/002886/999999/002886/888888/999996/999997',;	////Pegasus
	'000258/002886/999999/002886/888888/999996/999997';	//VINILICO
	}

	//Public 	cError := .F. 		//TESTE BIZAGI
	//Public  cCliBZ := ""        //Codigo do Cliente para o Sistema BIZAGI

	_cMCodCli_ := M->A1_COD
	
	If FUNNAME() == "RPC"
		CONOUT("->"+FUNNAME() )
		CONOUT('MA030TOK: Comissão Bianco  		- ' 	+ Str(M->A1_COMIS))
		CONOUT('MA030TOK: Comissão Incesa  		- ' 	+ Str(M->A1_YCOMISI))
		CONOUT('MA030TOK: Comissão BellaCasa  	- ' 	+ Str(M->A1_YCOMBE1))
		CONOUT('MA030TOK: Comissão Mundialli  	- ' 	+ Str(M->A1_YCOMML1))
		CONOUT('MA030TOK: Comissão VitCer  		- ' 	+ Str(M->A1_YCOMVT1))
	EndIf

	// Tiago Rossini Coradini
	// Data: 06/11/2014
	// Validação do cgc por tipo de pessoa
	// tratamento adiconado ao ponto de entrada para evitar duplicidade de registros entre as empresas
	If !M->A1_EST == "EX" .AND. !M->A1_TIPO == "X"  //OS 3056-15 - RANISSES EM 03/08/15
		If !A030CGC(M->A1_PESSOA, M->A1_CGC)
			Return(.F.)
		EndIf
	EndIf

	IF CEMPANT <> "02"

		//Valida o campo Muncipio de Cobrança para não permitir numero, somente texto - 4567-15 - A informação estava vindo errada do Bizagi.
		If Substr(Alltrim(M->A1_MUNC),1,1) $ "0/1/2/3/4/5/6/7/8/9"
			Aviso("MA030TOK","O Municipio de Cobrança está incorreto no cadastro. Favor verificar antes de continuar.",{'Ok'})
			AutoGrLog("O Municipio de Cobrança está incorreto no cadastro. Favor verificar antes de continuar.")
			//cError := .T.
			Return(.F.)
		EndIf

		//Solicitacao realizado pelo Sr. Vagner = OS 1653-12
		/* Ticket 26346 - Solicitação do Wellison do Financeiro para garantir padrão 'S' nos campos A1_YGERFAT e A1_YFGNRE
		If Alltrim(M->A1_YGERFAT) == "S" .And. M->A1_YTPSEG == "E"
			Aviso("MA030TOK","Não é permitido gerar faturas para os clientes do segmento de Engenharia. Favor conferir os campos GERAR FATURA e TP SEGMENTO, antes de continuar.",{'Ok'})
			AutoGrLog("Não é permitido gerar faturas para os clientes do segmento de Engenharia. Favor conferir os campos GERAR FATURA e TP SEGMENTO, antes de continuar.")
			Return(.F.)
		EndIf
		*/

		If !Empty(Alltrim(M->A1_YREGESP))
			MsgAlert("Este Cliente possui Regime Especial e não serão as geradas as Guias de GNRE!","MA030TOK")
			AutoGrLog("Este Cliente possui Regime Especial e não serão as geradas as Guias de GNRE!")
		EndIf

		If 	!M->A1_COD $ nClExST //Ticket 16079
			If 	(M->A1_TIPO == "S"  .and. !M->A1_EST $ nUFSTCD ) .Or. (M->A1_TIPO == "R"  .and.  M->A1_EST $ nUFSTCD )
				Aviso("MA030TOK","Tipo do Cliente incompativel com o Estado!",{'Ok'})
				AutoGrLog("Tipo do Cliente incompativel com o Estado!")
				//cError := .T.
				Return(.F.)
			EndIf
		EndIF

		//Solicitado pelo Vagner no dia 26/08/10
		If 	M->A1_YDTPRO <> 3 .and. M->A1_SATIV1 == '000099'
			Aviso("MA030TOK","Número de dias para protesto está incorreto. Favor preencher com 3 dias!",{"OK"})
			AutoGrLog("Número de dias para protesto está incorreto. Favor preencher com 3 dias!")
			//cError := .T.
			Return(.F.)
		EndIf

		lPassei := .F.

		//caso o cliente for vendedor
		SA3->(SA3->(DbSetOrder(3)))//Filial+CGC
		If (SA3->(DbSeek(xFilial("SA3")+M->A1_CGC)))
			cCliVend := SA3->A3_COD
		EndIf

		For nI := 1 to Len(aListaVen)

			cVend 		:= &(aListaVen[nI])
			nComi 		:= &(aListaCom[nI])
			cVendLib	:= aListaVend[nI]

			If  (AllTrim(cVend) <> "" .AND. nComi == 0 .AND. !cVend $ cVendLib .AND. AllTrim(cVend) <> AllTrim(cCliVend) .And. M->A1_TIPO <> 'F' )

				SA3->(SA3->(DbSetOrder(1)))
				If (SA3->(DbSeek(xFilial("SA3")+cVend)))

					cAliasTmp := GetNextAlias()
					BeginSql Alias cAliasTmp
					%NoParser%

					SELECT 1 FROM SRA010 WHERE RA_CIC = %Exp:AllTrim(SA3->A3_CGC)% AND RA_SITFOLH <> 'D' AND D_E_L_E_T_= ''
					UNION ALL
					SELECT 1 FROM SRA070 WHERE RA_CIC = %Exp:AllTrim(SA3->A3_CGC)% AND RA_SITFOLH <> 'D' AND D_E_L_E_T_= ''

					EndSql

					If (cAliasTmp)->(Eof())
						lPassei := .T.
					else
						lVendCPF := .T.
					EndIf

					(cAliasTmp)->(DbCloseArea())

				Else
					lPassei := .T.
				EndIf
			EndIf

			If (AllTrim(cVend) <> "" .And. nComi == 0 .And. AllTrim(cVend) == AllTrim(cCliVend))
				cMsgVend += 'O vendedor com código: '+cVend+' foi informado com comissão zero.'+CRLF
				lMsgVend := .T.
			EndIf

			If (AllTrim(cVend) <> "" .And. nComi == 0 .And. M->A1_TIPO == 'F')
				cMsgCons += 'O vendedor com código: '+cVend+' foi informado com comissão zero.'+CRLF
				lMsgCons := .T.
			EndIf

		Next

		If !(Isblind())

			If (lMsgVend)
				cMsgVend += 'Deseja continuar com gravação/edição do registro?'+CRLF
				If !MsgYesNo(cMsgVend, "MA030TOK")
					//cError := .T.
					Return(.F.)
				EndIf
			EndIf

			If (lMsgCons) .And. !(lMsgVend)
				cMsgCons += 'Deseja continuar com gravação/edição do registro?'+CRLF
				If !MsgYesNo(cMsgCons, "MA030TOK")
					//cError := .T.
					Return(.F.)
				EndIf
			EndIf

		EndIf

		IF lPassei

			Aviso("MA030TOK","Caso o Representante seja informado, a comissão deverá ser diferente de zero",{"OK"})
			AutoGrLog("Caso o Representante seja informado, a comissão deverá ser diferente de zero")
			//cError := .T.
			Return(.F.)

		ELSEIF lVendCPF

			MsgAlert("Existem Representantes informados que são Funcionários - Vai permitir Comissão ZERO", "MA030TOK - ATENÇÃO")
			AutoGrLog("Existem Representantes informados que são Funcionários - Vai permitir Comissão ZERO")

		ENDIF

		FOR i = 1 to 17

			CC_VEND  := ''
			CC_COMIS := ''
			CC_COM   := 0

			DO CASE
				//Biancogres
			CASE i = 1
				CC_VEND  := M->A1_VEND
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_COMIS)),",",".")
				CC_COM   := M->A1_COMIS
			CASE i = 2
				CC_VEND  := M->A1_YVENDB2
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMB2)),",",".")
				CC_COM   := M->A1_YCOMB2
			CASE i = 3
				CC_VEND  := M->A1_YVENDB3
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMB3)),",",".")
				CC_COM   := M->A1_YCOMB3

				//Incesa
			CASE i = 4
				CC_VEND  := M->A1_YVENDI
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMISI)),",",".")
				CC_COM   := M->A1_YCOMISI
			CASE i = 5
				CC_VEND  := M->A1_YVENDI2
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMI2)),",",".")
				CC_COM   := M->A1_YCOMI2
			CASE i = 6
				CC_VEND  := M->A1_YVENDI3
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMI3)),",",".")
				CC_COM   := M->A1_YCOMI3

				//Bellacasa
			CASE i = 7
				CC_VEND  := M->A1_YVENBE1
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMBE1)),",",".")
				CC_COM   := M->A1_YCOMBE1
			CASE i = 8
				CC_VEND  := M->A1_YVENBE2
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMBE2)),",",".")
				CC_COM   := M->A1_YCOMBE2
			CASE i = 9
				CC_VEND  := M->A1_YVENBE3
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMBE3)),",",".")
				CC_COM   := M->A1_YCOMBE3

				//Mundialli
			CASE i = 10
				CC_VEND  := M->A1_YVENML1
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMML1)),",",".")
				CC_COM   := M->A1_YCOMML1
			CASE i = 11
				CC_VEND  := M->A1_YVENML2
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMML2)),",",".")
				CC_COM   := M->A1_YCOMML2
			CASE i = 12
				CC_VEND  := M->A1_YVENML3
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMML3)),",",".")
				CC_COM   := M->A1_YCOMML3

				//Vitcer
			CASE i = 13
				CC_VEND  := M->A1_YVENVT1
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMVT1)),",",".")
				CC_COM   := M->A1_YCOMVT1
			CASE i = 14
				CC_VEND  := M->A1_YVENVT2
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMVT2)),",",".")
				CC_COM   := M->A1_YCOMVT2
			CASE i = 15
				CC_VEND  := M->A1_YVENVT3
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMVT3)),",",".")
				CC_COM   := M->A1_YCOMVT3

				//pegasus
			CASE i = 16
				CC_VEND  := M->A1_YVENPEG
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMPEG)),",",".")
				CC_COM   := M->A1_YCOMPEG

			CASE i = 17
				CC_VEND  := M->A1_YVENVI1
				CC_COMIS := STRTRAN(ALLTRIM(STR(M->A1_YCOMVI1)),",",".")
				CC_COM   := M->A1_YCOMVI1

			ENDCASE

			//Comissão Biancogres
			IF i == 1 .OR. i == 2 .OR. i == 3

				CSQL1 := "SELECT A3_COMIS FROM SA3010 WHERE A3_COD = '"+CC_VEND+"' AND D_E_L_E_T_ = '' "

				cAliasTmp := GetNextAlias()
				TCQUERY CSQL1 ALIAS (cAliasTmp) NEW
				IF (cAliasTmp)->A3_COMIS < CC_COM
					Aviso("MA030TOK","VALOR DA COMISSAO BIANCOGRES MAIOR QUE O CADASTRADO NO REPRESENTANTE",{"OK"})
					AutoGrLog("VALOR DA COMISSAO BIANCOGRES MAIOR QUE O CADASTRADO NO REPRESENTANTE")
					//cError := .T.
					Return(.F.)
				ENDIF

				(cAliasTmp)->(DbCloseArea())

			ENDIF

			//Comissao Incesa
			IF i == 4 .OR. i == 5 .OR. i == 6

				CSQL1 := "SELECT A3_YCOMISI FROM SA3010 WHERE A3_COD = '"+CC_VEND+"' AND D_E_L_E_T_ = '' "

				cAliasTmp := GetNextAlias()
				TCQUERY CSQL1 ALIAS (cAliasTmp) NEW
				IF (cAliasTmp)->A3_YCOMISI < CC_COM
					Aviso("MA030TOK","VALOR DA COMISSAO INCESA MAIOR QUE O CADASTRADO NO REPRESENTANTE",{"OK"})
					AutoGrLog("VALOR DA COMISSAO INCESA MAIOR QUE O CADASTRADO NO REPRESENTANTE")
					//cError := .T.
					Return(.F.)
				ENDIF

				(cAliasTmp)->(DbCloseArea())

			ENDIF

			//Comissao Bellacasa
			IF i == 7 .OR. i == 8 .OR. i == 9

				CSQL1 := "SELECT A3_YCOMIBE FROM SA3010 WHERE A3_COD = '"+CC_VEND+"' AND D_E_L_E_T_ = '' "

				cAliasTmp := GetNextAlias()
				TCQUERY CSQL1 ALIAS (cAliasTmp) NEW
				IF (cAliasTmp)->A3_YCOMIBE < CC_COM
					Aviso("MA030TOK","VALOR DA COMISSAO BELLACASA MAIOR QUE O CADASTRADO NO REPRESENTANTE",{"OK"})
					AutoGrLog("VALOR DA COMISSAO BELLACASA MAIOR QUE O CADASTRADO NO REPRESENTANTE")
					//cError := .T.
					Return(.F.)
				ENDIF

				(cAliasTmp)->(DbCloseArea())

			ENDIF

			//Comissao Mundialli
			IF i == 10 .OR. i == 11 .OR. i == 12

				CSQL1 := "SELECT A3_YCOMIML FROM SA3010 WHERE A3_COD = '"+CC_VEND+"' AND D_E_L_E_T_ = '' "

				cAliasTmp := GetNextAlias()
				TCQUERY CSQL1 ALIAS (cAliasTmp) NEW

				IF (cAliasTmp)->A3_YCOMIML < CC_COM
					Aviso("MA030TOK","VALOR DA COMISSAO MUNDIALLI MAIOR QUE O CADASTRADO NO REPRESENTANTE",{"OK"})
					AutoGrLog("VALOR DA COMISSAO MUNDIALLI MAIOR QUE O CADASTRADO NO REPRESENTANTE")
					//cError := .T.
					Return(.F.)
				ENDIF

				(cAliasTmp)->(DbCloseArea())

			ENDIF

			//Comissao Vitcer
			IF i == 13 .OR. i == 14 .OR. i == 15

				CSQL1 := "SELECT A3_YCOMIVT FROM SA3010 WHERE A3_COD = '"+CC_VEND+"' AND D_E_L_E_T_ = '' "

				cAliasTmp := GetNextAlias()
				TCQUERY CSQL1 ALIAS (cAliasTmp) NEW

				IF (cAliasTmp)->A3_YCOMIVT < CC_COM
					Aviso("MA030TOK","VALOR DA COMISSAO VITCER MAIOR QUE O CADASTRADO NO REPRESENTANTE",{"OK"})
					AutoGrLog("VALOR DA COMISSAO VITCER MAIOR QUE O CADASTRADO NO REPRESENTANTE")
					//cError := .T.
					Return(.F.)
				ENDIF

				(cAliasTmp)->(DbCloseArea())

			ENDIF

			//Comissao Pegasus
			If i == 16

				CSQL1 := "SELECT A3_YCOMPEG FROM SA3010 WHERE A3_COD = '"+CC_VEND+"' AND D_E_L_E_T_ = '' "

				cAliasTmp := GetNextAlias()
				TCQUERY CSQL1 ALIAS (cAliasTmp) NEW

				If (cAliasTmp)->A3_YCOMPEG < CC_COM
					Aviso("MA030TOK","VALOR DA COMISSAO PEGASUS MAIOR QUE O CADASTRADO NO REPRESENTANTE",{"OK"})
					AutoGrLog("VALOR DA COMISSAO PEGASUS MAIOR QUE O CADASTRADO NO REPRESENTANTE")
					//cError := .T.
					Return(.F.)
				EndIf

				(cAliasTmp)->(DbCloseArea())

			EndIf

			If i == 17

				CSQL1 := "SELECT A3_YCOMVIN FROM SA3010 WHERE A3_COD = '"+CC_VEND+"' AND D_E_L_E_T_ = '' "

				cAliasTmp := GetNextAlias()
				TCQUERY CSQL1 ALIAS (cAliasTmp) NEW

				If (cAliasTmp)->A3_YCOMVIN < CC_COM
					Aviso("MA030TOK","VALOR DA COMISSAO VINILICO MAIOR QUE O CADASTRADO NO REPRESENTANTE",{"OK"})
					AutoGrLog("VALOR DA COMISSAO VINILICO MAIOR QUE O CADASTRADO NO REPRESENTANTE")
					//cError := .T.
					Return(.F.)
				EndIf

				(cAliasTmp)->(DbCloseArea())

			EndIf
		Next

		If (AllTrim(M->A1_CALCSUF) <> 'N')
			If (GetInfCli(M->A1_COD)[1] <> AllTrim(M->A1_CALCSUF))
				U_BIAWSUF1(M->A1_CGC)
			EndIf
		EndIf

		IF ALTERA
			
			U_BIA863() // GRAVA INFORMAÇÕES ADICIONAIS NO CLIENTE
			
			/*
			CONOUT('Get A1_COD=>'+M->A1_COD)
			CONOUT('Get cCliBZ=>'+cCliBZ)
			cCliBZ := M->A1_COD //Codigo do Cliente para o Sistema BIZAGI
			CONOUT('Gravando cCliBZ=>'+cCliBZ)
			cError := .F.
			Return(lRET)
			*/
			
		ENDIF


		If Alltrim(CMODULO) <> "FIN"
		
			IF M->A1_TIPO = "F"
				CTIPO := "CONSUMIDOR FINAL"
			ELSEIF	M->A1_TIPO = "L"
				CTIPO := "PRODUTOR RURAL"
			ELSEIF	M->A1_TIPO = "R"
				CTIPO := "REVENDEDOR"
			ELSEIF	M->A1_TIPO = "S"
				CTIPO := "SOLIDÁRIO"
			ELSEIF	M->A1_TIPO = "X"
				CTIPO := "EXPORTAÇÃO"
			ELSE
				CTIPO := "USUARIO"
			ENDIF
	
			CMENSAGEM := "ATENÇÃO.... " + CHR(13) + CHR(10)
			CMENSAGEM += "O TIPO DE CLIENTE É: " +CTIPO
	
			IF EMPTY(M->A1_GRPTRIB)
				CMENSAGEM += " E O GRUPO DE CLIENTE ESTA VAZIO"
			ELSE
				CMENSAGEM += " E O GRUPO DE CLIENTE É: " + M->A1_GRPTRIB
			ENDIF
			CMENSAGEM += CHR(13) + CHR(10) + "DESEJA CONFIRMAR O CADASTRO?"
	
			Conout("2 ->"+funname() )
	
			If !(Isblind())
	
				IF M->A1_EST == "MG"
					IF MsgYesNo(CMENSAGEM,"MA030TOK")
						lRET := .T.
					ELSE
						lRET := .F.
						Aviso("MA030TOK", CMENSAGEM, {"OK"})
						AutoGrLog(CMENSAGEM)
						Return(lRET)
					ENDIF
				ENDIF
			
			EndIf
		
		EndIf
		
		//VERIFICANDO SE O CLIENTE JA FOI CADASTRADO OU NA BIANCO OU NA INCESA
		IF INCLUI

			// VERIFICANDO O CLIENTE NA BIANCOGRES
			CSQL := ""
			CSQL += "SELECT COUNT(A1_COD) AS QUANT FROM SA1010 "
			CSQL += "WHERE 	A1_COD = '" +M->A1_COD+"' AND "
			CSQL += "		A1_LOJA = '" +M->A1_LOJA+"' AND "
			CSQL += "		D_E_L_E_T_ = ' ' "

			cAliasTmp := GetNextAlias()
			TCQUERY cSQL ALIAS (cAliasTmp) NEW

			IF (cAliasTmp)->QUANT <> 0
				Aviso("ATENÇÃO","CODIGO "+M->A1_COD+" JÁ CADASTRADO NA BIANCOGRES",{"OK"})
				AutoGrLog("CODIGO "+M->A1_COD+" JÁ CADASTRADO NA BIANCOGRES")
				lRET := .F.
				//cError := .T.
				(cAliasTmp)->(DbCloseArea())
				Return(lRET)
			ENDIF
			(cAliasTmp)->(DbCloseArea())

			CSQL := ""
			CSQL += "SELECT COUNT(A1_COD) AS QUANT FROM SA1050 "
			CSQL += "WHERE 	A1_COD = '" +M->A1_COD+"' AND "
			CSQL += "		A1_LOJA = '" +M->A1_LOJA+"' AND "
			CSQL += "		D_E_L_E_T_ = ' ' "

			cAliasTmp := GetNextAlias()
			TCQUERY cSQL ALIAS (cAliasTmp) NEW

			IF (cAliasTmp)->QUANT <> 0
				Aviso("ATENÇÃO","CODIGO " +M->A1_COD+ " JÁ CADASTRADO NA INCESA",{"OK"})
				AutoGrLog("CODIGO " +M->A1_COD+ " JÁ CADASTRADO NA INCESA")
				lRET := .F.
				//cError := .T.
				(cAliasTmp)->(DbCloseArea())
				Return(lRET)
			ENDIF
			(cAliasTmp)->(DbCloseArea())

		ENDIF
	ENDIF

	// Validação necessária para não permitir contas contabeis erradas
	If cEmpAnt <> "02" .And. Substr(Alltrim(M->A1_CONTA),9,6) <> Alltrim(M->A1_COD)
		M->A1_CONTA := Substr(M->A1_CONTA,1,8)+ALLTRIM(M->A1_COD)
		MsgAlert("Atenção, Conta contabil incorretamente, favor verificar!","MA030TOK")
		AutoGrLog("Atenção, Conta contabil incorretamente, favor verificar!")
		Return(.F.)
	Endif

	// Verifica se já existe o CGC do cliente em alguma empresa do grupo
	If M->A1_TIPO <> "X" .And. U_BIAF009(M->A1_CGC, @cEmpresa, @cCliente, @cLoja)
		MsgAlert("Atenção, O CGC/CPF: "+ AllTrim(M->A1_CGC) +" já esta associado ao cliente: "+ cCliente +" - Loja: "+ cLoja +" da empresa: "+ cEmpresa,"MA030TOK")
		AutoGrLog("Atenção, O CGC/CPF: "+ AllTrim(M->A1_CGC) +" já esta associado ao cliente: "+ cCliente +" - Loja: "+ cLoja +" da empresa: "+ cEmpresa)
		Return(.F.)
	EndIf

	If lRET
		U_BIA863()
	EndIf

	If lRET

		/*
		CONOUT('Gravando Codigo variavel')
		ConfirmSX8()
		CONOUT('Gravando A1_COD=>'+M->A1_COD)
		CONOUT('Gravando 1 cCliBZ=>'+cCliBZ)
		cCliBZ := M->A1_COD //Codigo do Cliente para o Sistema BIZAGI
		CONOUT('Gravando 2 cCliBZ=>'+cCliBZ)
		*/

	EndIf

Return(lRET)

Static Function GetInfCli(cCodCli)
	Local aAreaSA1 	:= SA1->(GetArea())
	Local aRet		:= {""}

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))//
	If (SA1->(DbSeek(xFilial("SA1")+cCodCli)))
		aRet := {AllTrim(SA1->A1_CALCSUF)}
	EndIf
	SA1->(DbCloseArea())

	SA1->(RestArea(aAreaSA1))
Return aRet

User Function GetMCodA1()
Return(_cMCodCli_)