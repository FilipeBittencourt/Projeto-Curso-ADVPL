#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบPrograma  ณ PON_FUNC บAutor  ณ MADALENO           บ Data ณ  07/01/10   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.     ณ ROTINA PARA ENVIAR A LISTA DE FUNCIONARIOS QUE NAO BATEREU บฑฑฒ
ฒฑฑบ          ณ O PONTO ELETRONICO.                                        บฑฑฒ
ฒฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑฒ
ฒฑฑบUso       ณ AP8 - R4                                                   บฑฑฒ
ฒฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION PON_FUNC(aEmpJob)

	Local J
	IF TYPE("DDATABASE") <> "D"
		PREPARE ENVIRONMENT EMPRESA aEmpJob[1] FILIAL aEmpJob[2] MODULO "FAT" 
	END IF

	//PRIVATE DIA_SEMANA 	:= CDOW( (DDATABASE-4) )  // Saturday, Sunday 
	PRIVATE DATA_QUERY	:= DTOS(DDATABASE-1)
	PRIVATE DATA_REF		:= (DDATABASE-1)
	PRIVATE CSQL 				:= ""
	PRIVATE ENTER				:= CHR(13)+CHR(10)
	PRIVATE A_REGISTROS	:= {}
	PRIVATE S_SUPER 		:= ""

	ConOut("HORA: "+TIME()+" - INICIANDO WORKFLOW DO PONTO DA EMPRESA "+aEmpJob[1])

	// SELECIONANDO OS FUNCIONARIOS QUE NรO BATERAM O PONTO.
	CSQL := "SELECT * FROM " + ENTER
	CSQL += "	( " + ENTER
	CSQL += "	SELECT	'0 MARCAวรO' AS TIPO, RA_CLVL, RA_MAT, RA_NOME, RA_TNOTRAB, RA_YSEMAIL, " + ENTER
	CSQL += "			FERIAS = CASE WHEN  -- TRATAMENTO PARA QUALQUER TIPO DE AFASTAMENTO FERIAS OU DOENวA " + ENTER
	CSQL += "								(SELECT COUNT(R8_MAT) FROM "+RETSQLNAME("SR8")+" " + ENTER
	CSQL += "								WHERE 	R8_MAT = SRA.RA_MAT AND  " + ENTER
	CSQL += "										((R8_DATAINI <= '"+DATA_QUERY+"' AND R8_DATAFIM >= '"+DATA_QUERY+"') OR R8_DATAFIM = '') AND  " + ENTER
	CSQL += "										D_E_L_E_T_ = '') " + ENTER
	CSQL += "								= 0 THEN 'NORMAL' ELSE 'FERIAS' END " + ENTER
	CSQL += "			  " + ENTER
	CSQL += "	FROM "+RETSQLNAME("SRA")+" SRA " + ENTER
	CSQL += "	WHERE	SRA.RA_DEMISSA = '' AND " + ENTER
	CSQL += "	SRA.RA_CATFUNC IN ('M','E') AND " + ENTER 
	CSQL += "	SRA.RA_TNOTRAB <> '044'     AND " + ENTER
	CSQL += "	SRA.D_E_L_E_T_ = '' " + ENTER
	CSQL += "			 " + ENTER
	CSQL += "			AND SRA.RA_MAT IN -- RETIRANDO OS FUNCIONARIOS QUE BATE CARTรO " + ENTER
	CSQL += "							(SELECT SPF.PF_MAT " + ENTER
	CSQL += "							FROM "+RETSQLNAME("SPF")+" SPF,  " + ENTER
	CSQL += "											(SELECT SPF1.PF_MAT, MAX(SPF1.PF_DATA) AS PF_DATA " + ENTER
	CSQL += "											FROM "+RETSQLNAME("SPF")+" SPF1 " + ENTER
	CSQL += "											WHERE	SPF1.D_E_L_E_T_ = '' " + ENTER
	CSQL += "											GROUP BY SPF1.PF_MAT) SPF_AUX " + ENTER
	CSQL += " " + ENTER
	CSQL += "							WHERE	SPF.PF_MAT + SPF.PF_DATA = SPF_AUX.PF_MAT + SPF_AUX.PF_DATA AND  " + ENTER
	CSQL += "									SPF.PF_REGRAPA <> '99' AND " + ENTER
	CSQL += "									SPF.D_E_L_E_T_ = '') " + ENTER
	CSQL += " " + ENTER
	CSQL += "			AND SRA.RA_MAT NOT IN -- VERIFICANDO AS PESSOAS QUE NรO BATERAM O CARTรO  NO DIA. " + ENTER
	CSQL += "							(SELECT ZR_MAT FROM "+RETSQLNAME("SZR")+" " + ENTER
	CSQL += "							WHERE	ZR_DATA = '"+DATA_QUERY+"' AND -- DEVERม SER O DIA ATUAL - 1 " + ENTER
	CSQL += "									D_E_L_E_T_ = '') " + ENTER
	CSQL += " " + ENTER
	CSQL += "	-- PARA BUSCAR SOMENTE 1 MARCACAO " + ENTER
	CSQL += "	UNION " + ENTER
	CSQL += "	SELECT '1 MARCAวรO' AS TIPO, RA_CLVL, RA_MAT, RA_NOME, RA_TNOTRAB, RA_YSEMAIL, 'NORMAL' AS FERIAS " + ENTER
	CSQL += "	FROM "+RETSQLNAME("SZR")+" SZR, "+RETSQLNAME("SRA")+" SRA " + ENTER
	CSQL += "	WHERE	SZR.ZR_DATA  = '"+DATA_QUERY+"' AND  " + ENTER
	CSQL += "			SRA.RA_MAT     = SZR.ZR_MAT AND  " + ENTER
	CSQL += "			SZR.ZR_QUANT   = '1' AND " + ENTER     
	CSQL += "	    SRA.RA_TNOTRAB <> '044' AND " + ENTER
	CSQL += "			SZR.D_E_L_E_T_ = '' AND " + ENTER
	CSQL += "			SRA.D_E_L_E_T_ = '' " + ENTER

	CSQL += "	) AS TESS " + ENTER
	CSQL += "WHERE	FERIAS = 'NORMAL'  " + ENTER
	CSQL += "ORDER BY RA_YSEMAIL, RA_CLVL, TIPO, RA_NOME " + ENTER

	IF CHKFILE("_TRAB")
		DBSELECTAREA("_TRAB")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_TRAB" NEW

	// 007 041 042 052 055 058 059 060 061
	// VERIFICANDO SE E DIA DE TRABALHO.
	DO WHILE ! _TRAB->(EOF())
		IF DIA_TRABALHO() == .T.
			AADD(A_REGISTROS,{ ALLTRIM(_TRAB->TIPO) , ALLTRIM(_TRAB->RA_CLVL) , ALLTRIM(_TRAB->RA_MAT) , ALLTRIM(_TRAB->RA_NOME) , ALLTRIM(_TRAB->RA_TNOTRAB), ALLTRIM(_TRAB->RA_YSEMAIL) } )
		ELSE
			A := "Nao Trabalha Nesse Dia"
		END IF
		_TRAB->(DBSKIP())
	END DO

	A := 1


	// ROTINA PARA SEPARAR OS REGISTROS POR SUPERVISORES E DEPOIS ENVIAR EMAIL PARA CADA SUPERVISOR.
	A_REG_EMAIL := {}
	IF LEN(A_REGISTROS) >= 1
		S_SUPER := ALLTRIM(A_REGISTROS[1] [6])
	END IF

	FOR J:=1 TO LEN(A_REGISTROS)

		IF S_SUPER <> A_REGISTROS[J] [6]
			S_SUPER := ALLTRIM(A_REGISTROS[J] [6])
			P_ENVIA_EMAIL(A_REG_EMAIL) // ROTINA PARA ENVIAR O EMAIL.
			A_REG_EMAIL := {}
			AADD(A_REG_EMAIL ,A_REGISTROS[J])
		ELSE
			AADD(A_REG_EMAIL ,A_REGISTROS[J])
		END IF

	NEXT

	ConOut("HORA: "+TIME()+" - FINALIZANDO WORKFLOW DO PONTO DA EMPRESA "+aEmpJob[1])

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษออออออออออัออออออออออออออหออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบPrograma  ณ DIA_TRABALHO ณ MADALENO                   บ Data ณ  07/01/10   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออออออสออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.     ณ ROTINA PARA VERIFICAR SE FUNCIONARIO TRABALHA NO DIA           บฑฑฒ
ฒฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC FUNCTION DIA_TRABALHO()
	Local I
	PRIVATE LRET := .T.
	PRIVATE ATABPADRAO := {}

	dbselectArea("SRA")
	DBSETORDER(1)
	dbSeek(XFILIAL("SRA")+ ALLTRIM(_TRAB->RA_MAT) )


	CSQL := "SELECT MAX(PO_DATAINI) AS INI, MAX(PO_DATAFIM) AS FIM, PO_FLAGFEC FROM "+RETSQLNAME("SPO")+"  "
	CSQL += " WHERE D_E_L_E_T_ = '' GROUP BY PO_FLAGFEC "
	If chkfile("_PER")
		DbSelectArea("_PER")
		DbCloseArea()
	EndIf
	TCQUERY CSQL NEW ALIAS "_PER"
	PER_INI := _PER->INI 
	PER_FIM := _PER->FIM


	PER_INI := IIf( soma1(substr(_PER->INI,5,2)) == "13", soma1(substr(_PER->INI,1,4)) + "01" + substr(_PER->INI,7,2), substr(_PER->INI,1,4) + soma1(substr(_PER->INI,5,2)) + substr(_PER->INI,7,2))
	PER_FIM := IIf( soma1(substr(_PER->FIM,5,2)) == "13", soma1(substr(_PER->FIM,1,4)) + "01" + substr(_PER->FIM,7,2), substr(_PER->FIM,1,4) + soma1(substr(_PER->FIM,5,2)) + substr(_PER->FIM,7,2))


	dPerIni	:= DATA_REF 
	dPerFim	:= DATA_REF 

	cFil 	:= "01"					//"01"
	cMat	:= _TRAB->RA_MAT			//"000031"
	cTurno	:= _TRAB->RA_TNOTRAB		//"006"


	( aTabCalend := {} )
	//Gerar as datas do periodo completo
	cPonMes := GetPonMes(cFilAnt)
	dPerIniPM := Stod( Left( cPonMes , 08 ) )
	dPerFimPM := Stod( Right( cPonMes , 08 ) )
	////////

	// verificando se o periodo incial e maior que
	aTabPadrao	:= {}
	aTabGeral   := {}

	IF SRA->( CriaCalend(	dPerIniPM       		,; //01 -> Periodo Inicial
	dPerFimPM       		,; //02 -> Periodo Final (Com um Dia a Mais para a Obtencao da Proxima Sequencia)
	NIL/*SRA->RA_TNOTRAB*/	,; //03 -> Turno de Trabalho
	NIL/*SRA->RA_SEQTURN*/	,; //04 -> Sequencia de Turno
	@aTabPadrao				,; //05 -> Tabela de Horario Padrao
	@aTabCalend				,; //06 -> Calendario de Marcacoes
	SRA->RA_FILIAL	    	,; //07 -> Filial do Funcionario
	SRA->RA_MAT				,; //08 -> Matricula do Funcionario
	NIL   					,; //09 -> Classe de Valor do Funcionario (Nao Passar Pois Nao precisa carregar as Excecoes)
	NIL						,; //10 -> Array com as Trocas de Turno
	NIL						,; //11 -> Array com Todas as Excecoes do Periodo
	.F.						,; //12 -> Se executa Query para a Montagem da Tabela Padrao
	.F.						,; //13 -> Se executa a funcao se sincronismo do calendario
	.T.			 			;  //14 -> Se forca a Criacao de novo Calendario	
	);
	)
	EndIF

	//Verifica se periodo ainda nao foi encerrado e concatena o vetor do proximo periodo    
	aTabGeral := AClone(aTabCalend)
	dFimNext := dPerFimPM 

	While (dFimNext < DATA_REF) //.And. (ALLTRIM(SRA->RA_TNOTRAB) $ "003_006")

		//Gera inicio e fim do proximo perido
		dIniNext := dFimNext

		nMes:=Month(dPerFimPM)+1
		nYear:=Year(dPerFimPM)
		if nMes > 12
			nMes := 1
			nYear++
		endif
		dFimNext := STOD(STRZERO(nYear,4)+STRZERO(nMes,2)+STRZERO(Day(dPerFimPM),2))

		aTabPadrao	:= {}
		IF SRA->( CriaCalend(	dIniNext       			,; //01 -> Periodo Inicial
		dFimNext       			,; //02 -> Periodo Final (Com um Dia a Mais para a Obtencao da Proxima Sequencia)
		NIL/*SRA->RA_TNOTRAB*/	,; //03 -> Turno de Trabalho
		NIL/*SRA->RA_SEQTURN*/	,; //04 -> Sequencia de Turno
		@aTabPadrao				,; //05 -> Tabela de Horario Padrao
		@aTabCalend				,; //06 -> Calendario de Marcacoes
		SRA->RA_FILIAL	    	,; //07 -> Filial do Funcionario
		SRA->RA_MAT				,; //08 -> Matricula do Funcionario
		NIL   					,; //09 -> Classe de Valor do Funcionario (Nao Passar Pois Nao precisa carregar as Excecoes)
		NIL						,; //10 -> Array com as Trocas de Turno
		NIL						,; //11 -> Array com Todas as Excecoes do Periodo
		.F.						,; //12 -> Se executa Query para a Montagem da Tabela Padrao
		.F.						,; //13 -> Se executa a funcao se sincronismo do calendario
		.T.			 			; //14 -> Se forca a Criacao de novo Calendario	
		);
		)
		EndIF       

		//Adiciona na TabGeral as linhas a partir da ultima data anterior
		For I := 1 To Len(aTabCalend)   
			If aTabCalend[I][1] <> dIniNext
				AAdd(aTabGeral,aTabCalend[I])
			EndIf
		Next I

	EndDo   

	//nTamCalen := Len( aTabCalend )					 
	//cTurno := aTabCalend[ nTamCalen , 14	] 	// PROXIMO TURNO
	//cSeq := aTabCalend[ nTamCalen , 08	]		// PROXIMA SEQUENCIA
	//cNextReg := aTabCalend[ nTamCalen , 23	]	// PROXIMA REGRA

	//copiar toda a tabela para o aTabCalend e procura as linhas do dia atual
	aTabCalend := AClone(aTabGeral)
	nPosIni := AScan(aTabCalend,{|x| x[1] == DATA_REF})
	aTabAux := {}

	For I := nPosIni To Len(aTabCalend)
		If (I > nPosIni) .And. (aTabCalend[I][4] == '1E')
			exit
		EndIf

		AAdd(aTabAux,aTabCalend[I])
	Next I 

	aTabCalend := AClone(aTabAux)
	i := 1


	If len(aTabCalend) == 2
		LRET := .F.
	ELSE
		LRET := .T.
	END IF


RETURN(LRET)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษออออออออออัออออออออออออออหออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบPrograma  ณ P_ENVIA_EMAILณ MADALENO                   บ Data ณ  07/01/10   บฑฑฒ
ฒฑฑฬออออออออออุออออออออออออออสออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.     ณ ROTINA PARA ENVIAR E MONTAR O EMAIL PARA OS SUPERVISORES       บฑฑฒ
ฒฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

STATIC FUNCTION P_ENVIA_EMAIL(A_REG_EMAIL)

	Local I
	PRIVATE ENTER		:= CHR(13)+CHR(10)
	Private C_HTML  	:= ""
	Private lOK        := .F.
	PRIVATE N_FOLOWUP
	PRIVATE D_DATAA


	C_HTML  := ""
	C_HTML  := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	C_HTML  += '<html xmlns="http://www.w3.org/1999/xhtml"> '
	C_HTML  += '<head> '
	C_HTML  += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	C_HTML  += '<title>Untitled Document</title> '
	C_HTML  += '<style type="text/css"> '
	C_HTML  += '<!-- '
	C_HTML  += '.style12 {font-size: 9px; } '
	C_HTML  += '.style39 {font-size: 12pt; } '
	C_HTML  += '.style41 { '
	C_HTML  += '	font-size: 12px; '
	C_HTML  += '	font-weight: bold; '
	C_HTML  += '} '
	C_HTML  += '.style45 {color: #FFFFFF; font-size: 12px; } '
	C_HTML  += '.style46 {font-size: 12pt; color: #FFFFFF; } '
	C_HTML  += '.style48 {font-size: 12px} '
	C_HTML  += ' '
	C_HTML  += '--> '
	C_HTML  += '</style> '
	C_HTML  += '</head> '
	C_HTML  += ' '
	C_HTML  += '<body> '
	C_HTML  += '<table width="633" border="1"> '
	C_HTML  += '  <tr> '
	C_HTML  += '    <th width="415" rowspan="3" scope="col">OCORR&Ecirc;NCIAS NO PONTO ELETR&Oacute;NICO</th> '
	C_HTML  += '    <td width="202" class="style12"><div align="right"> DATA EMISSรO: '+ dtoC(DDATABASE) +' </div></td> '
	C_HTML  += '  </tr> '
	C_HTML  += '  <tr> '
	C_HTML  += '    <td class="style12"><div align="right">HORA DA EMISS&Atilde;O: '+SUBS(TIME(),1,8)+' </div></td> '
	C_HTML  += '  </tr> '
	C_HTML  += '  <tr> '
	IF cEmpAnt == "01"
		C_HTML  += '    <td><div align="center" class="style41"> BIANCOGRES CERยMICA SA </div></td> '
	ELSE
		C_HTML  += '    <td><div align="center" class="style41"> INCESA REVESTIMENTO CERยMICO LTDA </div></td> '
	END IF		


	C_HTML  += '  </tr> '
	C_HTML  += '</table> '


	C_HTML  += '<table width="633" border="1"> '
	C_HTML  += '  <tr bgcolor="#0066CC"> '
	C_HTML  += '    <th height="23" colspan="4" scope="col"><div align="left" class="style46"> '
	C_HTML  += '      <div align="center"> '
	C_HTML  += '        <p>Funcion&aacute;rios que n&atilde;o bateram o cart&atilde;o na data: ' + DTOC(DATA_REF) + ' </p> '
	C_HTML  += '      </div> '
	C_HTML  += '    </div></th> '
	C_HTML  += '  </tr> '
	C_HTML  += '  <tr bordercolor="#FFFFFF" class="style12"> '
	C_HTML  += '    <td colspan="4">&nbsp;</td> '
	C_HTML  += '  </tr> '
	C_HTML  += '  <tr bgcolor="#0066CC"> '
	C_HTML  += '	<th width="82" bgcolor="#0066CC"	scope="col"><span class="style45"> Matricula</span></th> '
	C_HTML  += '    <th width="386" bgcolor="#0066CC" 	scope="col"><span class="style45"> Nome </span></th> '
	C_HTML  += '    <th width="143" 	scope="col"><span class="style45"> Turno </span></th>			 '
	C_HTML  += '    <th width="143" 	scope="col"><span class="style45"> Ocorr๊ncia </span></th> '
	C_HTML  += '  </tr> '
	C_HTML  += '   '



	SCC	:= A_REG_EMAIL [1] [2] 
	// CABECALHO DO CC 
	C_HTML  += '  <tr bgcolor="#FFFFFF"> '
	C_HTML  += '    <th colspan="4" scope="col"><div align="left" class="style39">Classe de Valor: ' + SCC + ' </div></th> '
	C_HTML  += '  </tr> ' 

	FOR I:= 1 TO LEN(A_REG_EMAIL)

		IF SCC <> A_REG_EMAIL [I] [2] // QUANDO MUDAR O CLASSE DE VALOR MONTA O CABEC NOVAMENTE
			SCC	:= A_REG_EMAIL [I] [2] 
			// CABECALHO DO CV 
			C_HTML  += '  <tr bgcolor="#FFFFFF"> '
			C_HTML  += '    <th colspan="4" scope="col"><div align="left" class="style39">Classe de Valor: ' + SCC + ' </div></th> '
			C_HTML  += '  </tr> ' 
		ELSE
			C_HTML  += '   '
			C_HTML  += '  <tr> '
			C_HTML  += '    <td class="style12"> '+A_REG_EMAIL [I] [3]+'  </td> '
			C_HTML  += '    <td class="style12"> '+A_REG_EMAIL [I] [4]+' </td> '
			C_HTML  += '    <td class="style12"> '+A_REG_EMAIL [I] [5]+' </td> '
			C_HTML  += '    <td class="style12"> '+A_REG_EMAIL [I] [1]+' </td> '
			C_HTML  += '  </tr> '
		END IF
	NEXT


	C_HTML  += '   '
	C_HTML  += '  <tr bordercolor="#FFFFFF" class="style12"> '
	C_HTML  += '    <td colspan="4">&nbsp;</td> '
	C_HTML  += '  </tr> '
	C_HTML  += '</table> '



	C_HTML  += '<span class="style48">Esta ้ uma mensagem automแtica, favor nใo responde-la. </span> '
	C_HTML  += '</body> '
	C_HTML  += '</html> '

	// PASSANDO O HTML E O EMAIL DO SUPERVISOR
	ENV_EMAIL(C_HTML, A_REG_EMAIL [1] [6])

RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
ฒฑฑษอออออออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑฒ
ฒฑฑบ ENV_EMAIL           บAutor  ณ MADALENO           บ Data ณ  26/06/07   บฑฑฒ
ฒฑฑฬอออออออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑฒ
ฒฑฑบDesc.       ROTINA PARA ENVIAR O EMAIL E ENVIAR O MESMO                บฑฑฒ
ฒฑฑบ                                                                       บฑฑฒ
ฒฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑฒ
ฒฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION ENV_EMAIL(C_HTML, CEMAIL)

	IF cEmpAnt == "01"
		cRecebe		:= CEMAIL //"claudia.cardoso@biancogres.com.br"  
		cAssunto	:= 'BIANCOGRES - OCORRENCIAS NO PONTO - DATA: ' + DTOC(DATA_REF)
	ELSE
		cRecebe		:= CEMAIL //"claudia.cardoso@biancogres.com.br" // CEMAIL
		cAssunto	:= 'INCESA - OCORRENCIAS NO PONTO - DATA: ' + DTOC(DATA_REF)
	END IF 
	cRecebeCC	:= ""
	cRecebeCO	:= ""

	U_BIAEnvMail(,cRecebe,cAssunto,C_HTML)

RETURN