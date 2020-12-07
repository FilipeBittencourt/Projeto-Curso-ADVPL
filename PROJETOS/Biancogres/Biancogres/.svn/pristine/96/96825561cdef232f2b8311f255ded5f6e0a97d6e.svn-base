#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"  


/*/{Protheus.doc} FPVERE02
@description Planilha Promotoras para envio ao RH
@author Fernando Rocha
@since 09/02/2017
@version undefined
@type function
/*/
User Function FPVERE02

	Local lEnd			:= .F.
	Local aPergs		:= {}
	Local cRefPer	  	:= 'FPVER02' + cEmpAnt
	Local cFileName    	:= __cUserID +"_"+ cRefPer

	Private cAno		:= Space(4)
	Private cMes		:= Space(2)

	Private nEmpresa	:= 0
	Private cEmpresa    := ""
	Private cClasse		:= Space(4)
	private cDirDest   	:= space(170)
	Private oExcel
	private cArqXML    	:= "REL_PROM_RH_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	private cTitulo		:= "Relatório de Pagamento de Parcela Variável do Promotor"

	private cNomeEmp  	:= StrTran(AllTrim(CapitalAce(SM0->M0_NOMECOM)),"S.a.","S.A.") 

	private cFonte1	 	:= 'Calibri'
	private nTamFont1	:= 12   
	private cCorFont1  	:= '#FFFFFF'
	private cCorFun1	:= '#000066'

	private cFonte2	 	:= 'Calibri' 
	private nTamFont2	:= 12   
	private cCorFont2  	:= '#FFFFFF'
	private cCorFun2	:= '#3333FF'

	private cFonte3	 	:= 'Calibri'
	private nTamFont3	:= 8   
	private cCorFont3  	:= '#000000'
	private cCorFun3	:= '#FFFFFF'

	private cWhite		:= '#FFFFFF'
	private cLGray		:= '#9494E7'

	private cDkSlBlue	:= '#483D8B'

	aAdd( aPergs ,{2,"Empresa:"  		,1  ,{"Biancogres","Incesa","LM"},50,'.T.',.T.})
	aAdd( aPergs ,{1,"Ano:"	   			,cAno  ,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Mês:"	   			,cMes  ,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino: " 	,cDirDest  ,"","","", 75 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE} )

	If !ParamBox(aPergs ,cTitulo,,,,,,,,cRefPer,.T.,.T.)
		Return
	EndIf

	nEmpresa	:= ParamLoad(cFileName,,1 , nEmpresa)
	cAno   		:= ParamLoad(cFileName,,2 , cAno)
	cMes		:= ParamLoad(cFileName,,3 , cMes)
	cDirDest	:= ParamLoad(cFileName,,4 , cDirDest)

	cClasse 	:= IIF(nEmpresa == 1, "2115", "2215")
	cEmpresa	:= IIF(nEmpresa == 1, "01", "05")

	oProcess := MsNewProcess():New( {|lEnd| fImprime(@lEnd)},"Por favor aguarde, processando...","Carregando Informações",.T.)
	oProcess:Activate()

Return


Static Function fImprime(lEnd)

	oExcel := ARSexcel():New()

	if empty(cDirDest) .or. !ExistDir(cDirDest)	
		cDirDest := Alltrim(GetTempPath()) 
	endif

	MontaCabecalho()
	MontaLinhas()

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.)

Return


Static Function MontaCabecalho()

	oExcel:AddPlanilha('Planilha_RH',{100,200,200,50,50,100,50,50,80,80,80,80,80,80})
	oExcel:AddLinha(20)
	oExcel:AddCelula(cNomeEmp,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,13) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,13) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,13)
	oExcel:AddLinha(15)  
	oExcel:AddCelula("Mês de Apuração: "+cMes+"/"+cAno,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,13)

	oExcel:AddLinha(30)
	oExcel:AddLinha(12)
	oExcel:AddCelula("Nome do Promotor(a)"	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Matricula"			,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Representante"		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Nome da Loja(s)"		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Faixa Salarial"  	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Mês Admissão"   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Meta(R$)"	 		    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Realizado(R$)" 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Performance(%)" 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Fat.Afast."			,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dias.Afast."			,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Prêmio(R$)"	 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Pgto Bianco(R$)" 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Pgto Incesa(R$)" 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Pgto LM(R$)" 	 		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,,cCorFun2  ,.T.,.T.,.T.,.T.)

Return


Static Function MontaLinhas()

	Local cAliasTmp
	Local cCorF := cWhite
	Local cFNCName

	_nTotMet	:= 0
	_nTotRea	:= 0
	_lTotper	:= .F.
	
	cFNCName := "% FNC_PVE_RELAT02_"+AllTrim(CEMPANT)+" %"

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NoParser%

		select * from %Exp:cFNCName%(%Exp:cEmpresa%,%Exp:cAno%,%Exp:cMes%,0) order by P_NOME

	EndSql

	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())

		oExcel:AddLinha(12) 
		oExcel:AddCelula((cAliasTmp)->P_NOME									,0,'L',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->P_MAT										,0,'L',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->REPRESENTANTE  							,0,'L',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->C_NOME									,0,'L',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->P_DESFUNC									,0,'L',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->P_MESADMISSA								,0,'C',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->V_META									,0,'C',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->V_REAL									,0,'C',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->V_PERFORMANCE								,1,'C',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.,,,,"P")
		oExcel:AddCelula((cAliasTmp)->V_FATOR									,4,'C',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->DIAS_AFAST								,0,'C',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->V_PREMIO									,2,'C',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->V_PAG_BIANCO								,2,'C',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->V_PAG_INCESA								,2,'C',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->V_PAG_LM									,2,'C',cFonte3,nTamFont3,cCorFont3,,,cCorF  ,.T.,.T.,.T.,.T.)
		

		_nTotMet	+= (cAliasTmp)->V_META
		_nTotRea	+= (cAliasTmp)->V_REAL

		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbCloseArea())


	//TOTAL SOMATORIA DAS LINHAS
	oExcel:AddLinha(12) 
	oExcel:AddCelula(""							,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula(""							,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula(""  						,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("(+)TOTAL"					,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula(""							,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula(""							,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula(_nTotMet					,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula(_nTotRea					,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula(""							,1,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.,,,,"P")
	oExcel:AddCelula(""							,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula(""							,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula(""							,2,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula(""							,2,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula(""							,2,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula(""							,2,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
	
	cFNCName := "% FNC_PVE_RELAT02_TOT_"+AllTrim(CEMPANT)+" %"

	//TOTALIZADORES
	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NoParser%

		select top 1 * from %Exp:cFNCName%(%Exp:cEmpresa%,%Exp:cAno%,%Exp:cMes%)

	EndSql

	(cAliasTmp)->(DbGoTop())
	If !(cAliasTmp)->(Eof())

		//TOTAL SOMATORIA DAS LINHAS
		oExcel:AddLinha(12) 
		oExcel:AddCelula(""							,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(""							,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula(""  						,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula("(-)LOJAS COM 2 PROMOTORES",0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula(""							,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula(""							,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		
		oExcel:AddCelula(_nTotMet - (cAliasTmp)->V_META					,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula(_nTotRea - (cAliasTmp)->V_REAL					,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		
		oExcel:AddCelula(""							,1,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.,,,,"P")
		oExcel:AddCelula(""							,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(""							,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(""							,2,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(""							,2,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(""							,2,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(""							,2,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		
		
		//LINHA DO TOTAL CALCULADO - CLIENTES EXCLUSIVOS QUE TIVERAM ALGUEM TRABALHANDO NO MES CONFORME REGRAS DE AFASTAMENTOS/DEMISSAO/ETC.
		oExcel:AddLinha(12) 
		oExcel:AddCelula(""							,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(""							,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula(""  						,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula("RESULTADO FINAL"			,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula(""							,0,'L',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula(""							,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->V_META		,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->V_REAL		,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->V_PERFORMANCE	,1,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.,,,,"P")
		oExcel:AddCelula(""							,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(""							,0,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->V_PREMIO		,2,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->V_PAG_BIANCO	,2,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->V_PAG_INCESA	,2,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->V_PAG_LM	,2,'C',cFonte3,nTamFont3,cWhite,.T.,,cDkSlBlue  ,.T.,.T.,.T.,.T.)
		

	EndIf
	(cAliasTmp)->(DbCloseArea())	

	oExcel:AddLinha(20)
	oExcel:AddLinha(20)
	oExcel:AddCelula("_____________________"					,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,,cCorF)
	oExcel:AddCelula("                     "					,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,,cCorF)
	oExcel:AddCelula("_____________________"					,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,,cCorF)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Coordenação"								,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,,cCorF)
	oExcel:AddCelula("                     "					,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,,cCorF)
	oExcel:AddCelula("Diretoria Comercial  "					,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,,cCorF)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Data: 			   "					,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,,cCorF)
	oExcel:AddCelula("                     "					,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,,cCorF)
	oExcel:AddCelula("Data: 			   "					,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,,cCorF)

Return