#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"

User Function FAXML02()

	/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	Autor     := FERNANDO ROCHA
	Autor(Rev):= Marcos Alberto Soprani
	Programa  := BIA290
	Empresa   := Biancogres Cer‚mica S/A
	Data      := 14/11/11
	Data(Rev) := 21/03/12
	Uso       := Compras
	AplicaÁ„o := Importacao de XML nota fiscal de Entrada.
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

	Local aCampos			:= {}
	Local cCondicao		:= ""
	Local _stru, cArq, cIND1, cIND2, cIND3
	Local aArea      	:= GetArea()
	Local cCbPer

	//Privates da Rotina
	//PATH ROOT DOS ARQUIVOS XML NFE - CAMINHO SERVIDOR
	Private cPath 	 			:= "\P10\XML_NFE\" + cEmpAnt+cFilAnt + "\RECEBIDOS\"
	Private cPathImp 			:= "\P10\XML_NFE\" + cEmpAnt+cFilAnt + "\IMPORTADOS\"
	Private cPathCTe 			:= "\P10\XML_NFE\" + cEmpAnt+cFilAnt + "\CTE\"

	Private cPerg 				:= "FAXML02"
	Private aRotina	 			:= {}
	Private cCadastro			:= "Contratos X Vendedor - C·lculo de Comiss„o"
	Private xMarkAll	 		:= .F.
	Private _cAliasXML 		:= "TRBCOM"
	private x_cMarca 			:= GetMark()
	//Criar o grupo de perguntas do FILTRO
	ValPerg()

	//Bloco do processamento do filtro
	Private __BFILTRO := {|| U_FAXMLFIL() }
	Private bzGrava   := {|| (_cAliasXML)->MARCA := x_cMarca }

	// Criado por Marcos Alberto para tratamento de verificaÁ„o quanto a duplicidade de associaÁıes de v·rios CTR a uma mesmo NFE - em 22/03/12
	Public xtVetNfO := {}

	//Botoes do browse
	AADD(aRotina,{"Pesquisar"    		,"U_FAXMLPES"    			,0,1})
	AADD(aRotina,{"Proc.Import."  	,"U_FAXMLIMP"  	  		,0,4})
	AADD(aRotina,{"Filtrar"		  		,"U_FAXMLFIL(.T.)" 		,0,4})

	//Criar arquivo de trabalho
	_stru:={}
	AADD(_stru,{"MARCA"    		 	,"C", Len(x_cMarca)             ,0  })
	AADD(_stru,{"NOTA"     			,"C", TamSx3("F1_DOC")			[1] ,0	})
	AADD(_stru,{"SERIE"       	,"C", TamSx3("F1_SERIE")		[1] ,0	})
	AADD(_stru,{"CODIGO"      	,"C", TamSx3("A1_COD")			[1] ,0	})
	AADD(_stru,{"LOJA"        	,"C", TamSx3("A1_LOJA")  		[1] ,0	})
	AADD(_stru,{"FORNECEDOR" 		,"C", TamSx3("A1_NOME")			[1] ,0	})
	AADD(_stru,{"EMISSAO"     	,"C", 8                         ,0	})
	AADD(_stru,{"VALORTOTAL"		,"N", TamSx3("F1_VALBRUT")	[1] ,TamSx3("F1_VALBRUT")[2]})
	AADD(_stru,{"ARQXML"   	  	,"C", 200											  ,0	})
	cArq:=Criatrab(_stru,.T.)
	If Select(_cAliasXML) > 0; (_cAliasXML)->(DbCloseArea()); EndIf
	DBUSEAREA(.t.,,carq,_cAliasXML)

	//Criar indice no arquivo de trabalho
	cIND1 := DbCreateIndex(__cUserID+"TCOM.cdx","EMISSAO+NOTA",)
	(_cAliasXML)->(DbCommit())
	cIND2 := DbCreateIndex(__cUserID+"TCO2.cdx","FORNECEDOR+EMISSAO")
	(_cAliasXML)->(DbCommit())
	cIND3 := DbCreateIndex(__cUserID+"TCO3.cdx","NOTA")
	(_cAliasXML)->(DbCommit())

	DbSetIndex(__cUserID+"TCOM.cdx")
	(_cAliasXML)->(DbSetOrder(1))

	//Consulta SQL e preenchimento do arquivo de trabalho para browse
	Eval(__BFILTRO)

	//Campos para exibicao no browse
	AADD(aCampos,	{"MARCA"		 			,			,""								,"" 	 						})
	AADD(aCampos,	{"NOTA"     	 		,"C"	,"N. Nota"				,"@!"  						})
	AADD(aCampos,	{"SERIE"       		,"C"	,"Serie"					,"@!"	 						})
	AADD(aCampos,	{"CODIGO"      		,"C"	,"Cod. Forn."			,"@!"	 						})
	AADD(aCampos,	{"LOJA"        		,"C"	,"Loja"  					,"@!"							})
	AADD(aCampos,	{"FORNECEDOR"			,"C"	,"Nome"						,"@!" 	 					})
	AADD(aCampos,	{"EMISSAO"     		,"c"	,"Dt Emissao"			,"@!"							})
	AADD(aCampos,	{"VALORTOTAL"	 		,"N"	,"Valor Total"		,"@E 999,999.99" 	})
	AADD(aCampos,	{"ARQXML"     		,"C"	,"Arquivo XML"		,"@!"							})

	//Chama o Markbrowse
	(_cAliasXML)->(DbSetOrder(1))
	(_cAliasXML)->(DbGoTop())

	SetKey( VK_F12 , __BFILTRO )

	MarkBrow(_cAliasXML, "MARCA", ,aCampos, .F., @x_cMarca, "U_bMarkAll()", , , , "U_bMark()")

	SET KEY VK_F12 TO

	(_cAliasXML)->(DbCloseArea())
	Ferase(__cUserID+"TCOM.cdx")
	Ferase(__cUserID+"TCO2.cdx")
	Ferase(__cUserID+"TCO3.cdx")

Return

/*___________________________________________________________________________
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶FunÁ„o    ¶ bMark     ¶ Autor ¶ Fernando             ¶ Data ¶   /  /   ¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶          ¶ Grava marca no campo                                       ¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
ØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØ*/
User Function bMark()

	If (_cAliasXML)->MARCA == x_cMarca
		RecLock(_cAliasXML, .F. )
		Replace MARCA With Space(Len((_cAliasXML)->MARCA))
		MsUnLock()
	Else
		IF ((_cAliasXML)->CODIGO <> "XXXXXX")
			RecLock(_cAliasXML, .F. )
			Replace MARCA With x_cMarca
			MsUnLock()
		ENDIF
	EndIf

	MARKBREFRESH()

Return

/*___________________________________________________________________________
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶FunÁ„o    ¶ bMarkAll  ¶ Autor ¶ Fernando             ¶ Data ¶   /  /   ¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶          ¶ Grava marca no campo                                       ¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
ØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØ*/
User Function bMarkAll()

	MsgSTOP("Funcionalidade IndisponÌvel!!!","AtenÁ„o (bMarkAll)")

	MARKBREFRESH()

Return

/*___________________________________________________________________________
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶FunÁ„o    ¶ FAXMLFIL  ¶ Autor ¶ Fernando             ¶ Data ¶   /  /   ¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶          ¶ PROCESSAR LEITURA DOS ARQUIVOS XML NA PASTA E FILTRO       ¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
ØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØ*/
User Function FAXMLFIL(lScreen)

	Default lScreen := .F.

	If !Pergunte(cPerg , .T. )
		Return
	EndIf

	U_BIAMsgRun("Consultando dados...",, {|| BCN9Proc()  })

	IF lScreen
		(_cAliasXML)->(dbGotop())
		MARKBREFRESH()
	ENDIF

RETURN

/*___________________________________________________________________________
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶FunÁ„o    ¶ BCN9Proc  ¶ Autor ¶ Fernando             ¶ Data ¶   /  /   ¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
ØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØ*/
Static Function BCN9Proc()

	Local cARQ
	Local cWhere
	Local _nx

	_aArqXML	:= directory(cPath+"\*.xml")

	//LIMPA TODOS OS DADOS DO ARQUIVO
	(_cAliasXML)->(DbGoTop())
	While !(_cAliasXML)->(Eof())
		RecLock(_cAliasXML, .F. )
		(_cAliasXML)->(DbDelete())
		(_cAliasXML)->(MsUnLock())

		(_cAliasXML)->(DbSkip())
	End

	//PREENCHE ARQUIVO DE ACORDO COM ARQUIVOS XML NA PASTA E FILTROS
	FOR _nx := 1 to (len(_aArqXML))
		//msgalert(_aArqXML[_nx,1],"arquivo")
		_aRetXML := U_FAXML01((cEmpAnt+cFilAnt),_aArqXML[_nx,1],.T.)

		If valtype(_aRetXML) == "A" .and. len(_aRetXML) > 0

			_cCodFor	:= Posicione("SA2",3,xFilial("SA2")+_aRetXML[2],"A2_COD")
			_cLojFor	:= Posicione("SA2",3,xFilial("SA2")+_aRetXML[2],"A2_LOJA")
			_cNomeFor	:= Posicione("SA2",3,xFilial("SA2")+_aRetXML[2],"A2_NOME")
			_cNumeroNF  := _aRetXML[3]
			_dEmissaoNF := _aRetXML[5]

			If ((EMPTY(MV_PAR01) .AND. EMPTY(MV_PAR02)) .OR. (MV_PAR01 == _cCodFor .AND. MV_PAR02 == _cLojFor)) .AND.;
			((_cNumeroNF >= MV_PAR03) .AND. (_cNumeroNF <= MV_PAR04)) .AND.;
			((_dEmissaoNF >= MV_PAR05) .AND. (_dEmissaoNF <= MV_PAR06))

				RecLock(_cAliasXML,.T.)
				(_cAliasXML)->NOTA 				:= _aRetXML[3]
				(_cAliasXML)->SERIE		  	:= _aRetXML[4]
				(_cAliasXML)->CODIGO			:= IF(EMPTY(_cCodFor) ,"XXXXXX",_cCodFor)
				(_cAliasXML)->LOJA				:= IF(EMPTY(_cLojFor) ,"XX",_cLojFor)
				(_cAliasXML)->FORNECEDOR	:= IF(EMPTY(_cNomeFor),"FORNECEDOR NAO LOCALIZADO",_cNomeFor) 	//_aRetXML[?]
				(_cAliasXML)->EMISSAO			:= dtos(_aRetXML[5])
				(_cAliasXML)->VALORTOTAL	:= _aRetXML[6]
				(_cAliasXML)->ARQXML 			:= _aArqXML[_nx,1]
				(_cAliasXML)->(MsUnlock())

			EndIf

		Else

			// Faz Backup dos arquivos que n„o pertencem a NFe normais e grava em CTe. Por Marcos Alberto em 30/03/12
			dt_cFile  := cPath + _aArqXML[_nx,1]
			xt_cFil1 := cPathCTe + _aArqXML[_nx,1]
			FRename(dt_cFile, xt_cFil1)

			MsgAlert("Arquivo: "+AllTrim(_aArqXML[_nx,1])+" na pasta de importaÁ„o com ERRO!","Importa XML")

		EndIf

	NEXT _nx

	(_cAliasXML)->(DbGoTop())

Return

/*___________________________________________________________________________
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶FunÁ„o    ¶ FAXMLPES  ¶ Autor ¶ Marcos Alberto S     ¶ Data ¶ 19/03/12 ¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶          ¶ Pesquisa registro dentro do Browser                        ¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
ØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØ*/
User Function FAXMLPES()

	Local oDlgPesq
	Local oButton1
	Local oGet1
	Local cGet1 := Space(100)
	Local oRadMenu1
	Local nRadMenu1 := 3
	Local oSay1

	DEFINE MSDIALOG oDlgPesq TITLE "Pesquisar" FROM 000, 000  TO 130, 450 COLORS 0, 16777215 PIXEL

	@ 009, 015 SAY oSay1 PROMPT "Pesquisar:" SIZE 027, 007 OF oDlgPesq COLORS 0, 16777215 PIXEL
	@ 006, 041 MSGET oGet1 VAR cGet1 SIZE 170, 010 OF oDlgPesq COLORS 0, 16777215 PIXEL
	@ 028, 017 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Emissao+Nota","Nome Fornecedor","Nota" SIZE 092, 026 OF oDlgPesq COLOR 0, 16777215 PIXEL
	@ 027, 173 BUTTON oButton1 PROMPT "Pesquisar" SIZE 037, 027 OF oDlgPesq ACTION oDlgPesq:End() PIXEL
	ACTIVATE MSDIALOG oDlgPesq

	If nRadMenu1 == 1
		cIND1 := DbCreateIndex(__cUserID+"TCOM.cdx","EMISSAO+NOTA",)
		(_cAliasXML)->(DbCommit())

	ElseIf	nRadMenu1 == 2
		cIND2 := DbCreateIndex(__cUserID+"TCO2.cdx","FORNECEDOR+EMISSAO")
		(_cAliasXML)->(DbCommit())

	ElseIf	nRadMenu1 == 3
		cIND3 := DbCreateIndex(__cUserID+"TCO3.cdx","NOTA")
		(_cAliasXML)->(DbCommit())

	EndIf

	If !dbSeek(Alltrim(cGet1))
		dbGoTop()
	EndIf
	MarkbRefresh()

Return

/*___________________________________________________________________________
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶FunÁ„o    ¶ FAXMLIMP  ¶ Autor ¶ Henry / Facile       ¶ Data ¶ 21/11/11 ¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶          ¶ Processa importacao do arquivo XML chamando funcao externa.¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
ØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØ*/
User Function FAXMLIMP()

	Local lRet
	Local GrdAre := GetArea()

	U_BIAMsgRun("Processando importacao XML...",, {|| lRet := Proces()  })

	RestArea(GrdAre)

Return(lRet)

/*___________________________________________________________________________
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶FunÁ„o    ¶ Proces    ¶ Autor ¶ Fernando             ¶ Data ¶   /  /   ¶¶¶
¶¶+-----------------------------------------------------------------------+¶¶
¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
ØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØ*/
Static Function Proces()

	(_cAliasXML)->(DbGoTop())
	While .Not. (_cAliasXML)->(Eof())
		//Verificar se a faixa esta preenchida - obrigatorio
		IF (_cAliasXML)->MARCA == x_cMarca

			__cARQ := AllTrim((_cAliasXML)->ARQXML)

			__AAREA := (_cAliasXML)->(GetArea())
			_lRet := U_FAXML03(__cARQ)
			RestArea(__AAREA)

			//MsgAlert("Arquivo a ser importado: " + (_cAliasXML)->ARQXML,"Arquivo importado")
			If _lRet

				//arquivo atual para leitura
				_cFile  := cPath+"\"+__cARQ
				//Nome para novo arquivo e pasta de destino para backup
				_cFile1 := cPathImp+"\"+__cARQ
				//Move arquivo para pasta determinada historico\entradas
				FRename(_cFile, _cFile1)

				//Apagar registro posicionado
				RecLock(_cAliasXML, .F. )
				(_cAliasXML)->(dbDelete())
				MsUnLock()

			Endif
		ENDIF
		(_cAliasXML)->(DbSkip())
	EndDo

	dbSelectArea(_cAliasXML)
	dbGoTop()

	MarkBrow(_cAliasXML, "MARCA",,,,@x_cMarca)

	MarkbRefresh()

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±≥ValPerg - Funcao para criar o grupo de perguntas SX1 se nao existir    ≥±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Static Function ValPerg()

	Local i,j,nX
	Local aTRegs := {}
	Local aHelpPor := {}
	Local aHelpEng := {}
	Local aHelpSpa := {}

	cPerg := PADR(cPerg,10)

	//DECLARACAO DAS PERGUNTAS NA ORDEM QUE DESEJA CRIAR
	aAdd(aTRegs,{"Fornecedor?"			,"C",06,0,0,"G","","","","","","","SA2","Codigo do Fornecedor."})
	aAdd(aTRegs,{"Loja?"				,"C",02,0,0,"G","","","","","","","","Loja do cliente."})
	aAdd(aTRegs,{"Numero NF De?"		,"C",06,0,0,"G","","","","","","","","Filtrar intervalo de numero de notas fiscais recebidas."})
	aAdd(aTRegs,{"Numero NF Ate?"		,"C",06,0,0,"G","","","","","","","","Filtrar intervalo de numero de notas fiscais recebidas."})
	aAdd(aTRegs,{"Data Emissao De?"		,"D",08,0,0,"G","","","","","","","","Filtrar intervalo de data de emissao de notas fiscais recebidas."})
	aAdd(aTRegs,{"Data Emissao Ate?"	,"D",08,0,0,"G","","","","","","","","Filtrar intervalo de data de emissao de notas fiscais recebidas."})

	//Criar aRegs na ordem do vetor Temporario
	aRegs := {}
	For I := 1 To Len(aTRegs)
		aAdd(aRegs,{cPerg, StrZero(I,2), aTRegs[I][1], aTRegs[I][1], aTRegs[I][1],;
		"mv_ch"+Alltrim(Str(I)), aTRegs[I][2],aTRegs[I][3],aTRegs[I][4],aTRegs[I][5],;
		aTRegs[I][6],aTRegs[I][7],"mv_par"+StrZero(I,2),aTRegs[I][8],"","","","",;
		aTRegs[I][9],"","","","",aTRegs[I][10],"","","","",aTRegs[I][11],"","","",;
		"",aTRegs[I][12],"","","",aTRegs[I][13],""})
	Next I

	//Grava no SX1 se ja nao existir
	dbSelectArea("SX1")
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Else
			RecLock("SX1",.F.)
			For j:=3 to FCount()
				If j <= Len(aRegs[i])
					If SubStr(FieldName(j),1,6) <> "X1_CNT"
						FieldPut(j,aRegs[i,j])
					EndIf
				Endif
			Next
			MsUnlock()
		EndIf

		//HELP DAS PERGUNTAS
		aHelpPor := {}
		__aRet := STRTOKARR(aTRegs[I][14],"#")
		FOR nX := 1 To Len(__aRet)
			AADD(aHelpPor,__aRet[nX])
		NEXT nX
		PutSX1Help("P."+AllTrim(cPerg)+aRegs[i,2]+".",aHelpPor,aHelpEng,aHelpSpa)

	Next

Return
