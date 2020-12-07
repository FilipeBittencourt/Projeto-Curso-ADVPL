/*---------+-----------+-------+----------------------+------+------------+
|Funcao    |BIAFM001   | Autor | Marcelo Sousa        | Data | 31.07.2018 |
|          |           |       | Facile Sistemas      |      |            |
+----------+-----------+-------+----------------------+------+------------+
|Descricao |WORKFLOW UTILIZADO VIA BOTAO NO CADASTRO DE CURRÍCULO         |
|          |DENTRO DO RECRUTAMENTO PARA ENVIO DE MENSAGENS AO CANDIDATO.  |
+----------+--------------------------------------------------------------+
|Uso       |RECRUTAMENTO E SELEÇÃO                                        |
+----------+-------------------------------------------------------------*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TOPCONN.CH"

User Function BIAFM012()

	Processa({ || cMsg := Rpt() }, "Aguarde...", "Carregando dados...",.F.)

Return

Static Function Rpt()

	Local _cAlias   := GetNextAlias()
	Local nRegAtu   := 0
	Local _daduser
	Local _mNomeUsr

//	Local msVetDados := _oGetDados:aCols
//	Local msVetColun := _oGetDados:aHeader
//	Local msVetPlan  := {}
//	Local msNomeFunc := _oGetDados:OWND:cCaption
	Local zpM, pmZ

	local cCab1Fon   := 'Calibri' 
	local cCab1TamF  := 8   
	local cCab1CorF  := '#FFFFFF'
	local cCab1Fun   := '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'
	Local nConsumo	 :=	0

	local cEmpresa   := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML    := UPPER(Alltrim(FunName())) + "_" + ALLTrim( DTOS(DATE()) + "_" + StrTran( time(),':',''))
	private cDirDest := "c:\temp\"

	oExcel := ARSexcel():New()

//	msQtdLinhas := Len(_oGetDados:aCols) 
//	ProcRegua()

	oExcel:AddPlanilha("Relatorio", {20, 70, 70, 70, 70, 150, 50, 150, 60, 60}, 6)
	
	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório de Dependentes por funcionário", 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2,)  
	
	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("FILIAL"          	  , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("MATRICULA"          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("FUNCIONARIO"        , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CODIGO DEP"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("NOME DEP"           , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("NASCIMENTO DEP"     , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("IDADE"              , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("SEXO"               , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("GRAU PARENTESCO"    , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("ASSIST. MEDICA"     , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("TIPO IR"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("SALARIO FAM."       , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("LOCAL NASCIMENTO"   , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CARTORIO"           , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("REG. CARTORIO"      , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("NUM. LIVRO"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("NUM. FOLHA"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DATA ENTRADA"       , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DATA BAIXA"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CPF"                , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VERBA COOP."        , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("AUX. CRECHE"        , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VLR CRECHE"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("TIPO DEPENDENTE"    , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("PLANO SAUDE"        , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CODIGO PLS"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Definindo a query que trará os dados necessários.                       ±±
	±± para a montagem do e-mail. 											   ±±	
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	cQuery := ""
	cQuery += " SELECT RA_FILIAL AS FILIAL,	"
	cQuery += " RB_MAT AS MATRICULA, "
	cQuery += " RA_NOME AS FUNCIONARIO, "
	cQuery += " RB_COD AS CODDEP, "
	cQuery += " RB_NOME AS NOMDEP, "
	cQuery += " RB_DTNASC AS NASCIMENTO, "
	cQuery += "(YEAR(GETDATE()) - SUBSTRING(RB_DTNASC,1,4)) AS IDADE,  "
	cQuery += " RB_SEXO AS SEXO, "
	cQuery += " RB_GRAUPAR AS GRAU, "
	cQuery += " RB_YASSMED AS ASSISTMEDICA, "
	cQuery += " RB_TIPIR AS TIPOIR, "
	cQuery += " RB_TIPSF AS 'SALARIOFAMILIA', "
	cQuery += " RB_LOCNASC AS LOCALNASCIMENTO, "
	cQuery += " RB_CARTORI AS 'CARTORIO', "
	cQuery += " RB_NREGCAR AS REGCARTORIO, "
	cQuery += " RB_NUMLIVR AS NUMLIVRO, "
	cQuery += " RB_NUMFOLH AS NUMFOLHA, "
	cQuery += " RB_DTENTRA AS DATAENTRADA, "
	cQuery += " RB_DTBAIXA AS DATABAIXA, "
	cQuery += " RB_CIC AS CPF, "
	cQuery += " RB_YVBCOOP AS VERBACOOP, "
	cQuery += " RB_AUXCRE AS AUXCRECHE, "
	cQuery += " RB_VLRCRE AS VLRCRECHE, "
	cQuery += " RB_TPDEP AS TIPODEPENDENTE, "
	cQuery += " RB_PLSAUDE AS PLANOSAUDE, "
	cQuery += " RB_YCODPLS AS CODIGOPLS "
	cQuery += " FROM " + RetSqlName("SRB") + " SRB "
	cQuery += " JOIN " + RetSqlName("SRA") + " SRA ON RA_MAT = RB_MAT AND RA_FILIAL = RB_FILIAL "
	cQuery += " AND SRB.D_E_L_E_T_ = '' "
	cQuery += " AND SRA.RA_SITFOLH <> 'D' "
	
	TcQuery cQuery New Alias (_cAlias)
	
	(_cAlias)->(DBGOTOP())
	
	While (_cAlias)->(!Eof())
            
            IF (_cAlias)->PLANOSAUDE == "1"
			     
			    cPl := "SIM"
			
			ELSEIF (_cAlias)->PLANOSAUDE == "2"
			
			    cPl := "NAO"

			ENDIF	
                                                                                      
			IF (_cAlias)->TIPOIR == "1"
			     
			    cIr := "s/Lim.Idade"
			
			ELSEIF (_cAlias)->TIPOIR == "2"
			
			    cIr := "Ate 21 Anos"
	
			ELSEIF (_cAlias)->TIPOIR == "3"
			
			    cIr := "Ate 24 Anos"
	
			ELSEIF (_cAlias)->TIPOIR == "4"
			
			    cIr := "Nao é Dep"
			            
			ENDIF	
	
			IF (_cAlias)->ASSISTMEDICA == "1"
			     
			    cAssis := "SIM"
			
			ELSEIF (_cAlias)->ASSISTMEDICA == "2"
			
			    cAssis := "NAO"

			ENDIF	
			
			IF (_cAlias)->SALARIOFAMILIA == "1"
			     
			    cSal := "SEM LIMITE"
			
			ELSEIF (_cAlias)->SALARIOFAMILIA == "2"
				 
				cSal := "ATÉ OS 14"
			
			ELSEIF (_cAlias)->SALARIOFAMILIA == "3"
			
				cSal := "NÃO"
				
			ENDIF 
			
			IF (_cAlias)->GRAU == "C"
			     
			    cGrau := "CÔNJUGE"
			
			ELSEIF (_cAlias)->GRAU == "F"
			
			    cGrau := "FILHO"

			ENDIF	

			IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))))
	
			nRegAtu++
			if MOD(nRegAtu,2) > 0 
				cCorFun2 := '#DCE6F1'
			else
				cCorFun2 := '#B8CCE4'
			endif
	
			oExcel:AddLinha(14) 
			oExcel:AddCelula()
			oExcel:AddCelula( (_cAlias)->FILIAL             , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->MATRICULA          , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->FUNCIONARIO        , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->CODDEP             , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->NOMDEP             , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( STOD((_cAlias)->NASCIMENTO)   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->IDADE              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->SEXO               , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( cGrau            			    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( cAssis				        , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( cIr			                , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( cSal                          , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->LOCALNASCIMENTO    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->CARTORIO           , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->REGCARTORIO        , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->NUMLIVRO           , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->NUMFOLHA           , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( STOD((_cAlias)->DATAENTRADA)  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( STOD((_cAlias)->DATABAIXA)    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->CPF                , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->VERBACOOP          , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->AUXCRECHE          , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->VLRCRECHE          , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->TIPODEPENDENTE + " - " + cGrau     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( cPl				            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			oExcel:AddCelula( (_cAlias)->CODIGOPLS          , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
	
			(_cAlias)->(dbSkip())
	
	EndDo
	
	(_cAlias)->(dbCloseArea())

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

Return
