#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"  


/*/{Protheus.doc} FPVERE01
@description Planilha Geral de Metas X Realizado Promotoras
@author Fernando Rocha
@since 25/01/2017
@version undefined
@type function
/*/
User Function FPVERE01

	Local lEnd			:= .F.
	Local aPergs		:= {}
	Local cRefPer	  	:= 'FPVER01' + cEmpAnt
	Local cFileName    	:= __cUserID +"_"+ cRefPer

	Private cAno		:= Space(4)
	Private nEmpresa	:= 0
	Private cClasse		:= Space(4)
	private cDirDest   	:= space(170)
	Private oExcel
	private cArqXML    	:= "REL_PROM_METASXREAL_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	private cTitulo		:= "Planilha Metas x Realizado Promotores"

	private cEmpresa   	:= StrTran(AllTrim(CapitalAce(SM0->M0_NOMECOM)),"S.a.","S.A.") 

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

	aAdd( aPergs ,{2,"Empresa:"  		,1  ,{"Biancogres","Incesa","LM"},50,'.T.',.T.})
	aAdd( aPergs ,{1,"Ano:"	   			,cAno  ,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino: " 	,cDirDest  ,"","","", 75 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE} )

	If !ParamBox(aPergs ,cTitulo,,,,,,,,cRefPer,.T.,.T.)
		Return
	EndIf

	nEmpresa	:= ParamLoad(cFileName,,1 , nEmpresa)
	cAno   		:= ParamLoad(cFileName,,2 , cAno)
	cDirDest	:= ParamLoad(cFileName,,3 , cDirDest)

	cClasse 	:= IIF(nEmpresa == 1, "2115", "2215")

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

	oExcel:AddPlanilha('Planilha_Geral',{100,200,200,50,50,100,50,50,80,80,80,80,80,80,80,80,80,80,80,80,80,80})
	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,21) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,1,21) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,21)  

	oExcel:AddLinha(30)
	oExcel:AddLinha(12) 
	oExcel:AddCelula("Matricula"			,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Promotor(a)"			,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Nome da Loja(s)"		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Rateio" 			 	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Mês.Adm."			   	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Representante"   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Estado"		   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Tipo"			   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Jan/"+cAno	 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Fev/"+cAno	 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Mar/"+cAno	 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Abr/"+cAno	 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Mai/"+cAno	 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Jun/"+cAno	 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Jul/"+cAno	 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Ago/"+cAno	 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Set/"+cAno	 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Out/"+cAno	 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nov/"+cAno	 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dez/"+cAno	 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Total"		 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Média"		 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)

Return


Static Function MontaLinhas()

	Local cAliasTmp
	Local aMeses := {"Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"}
	Local cCorF := cWhite
	Local cFNCName
	Local I
	
	_nTotMet	:= 0
	_nTotRea	:= 0
	_lTotper	:= .F.
	
	cFNCName := "% FNC_PVE_RELAT01_"+AllTrim(CEMPANT)+" %"

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
	%NoParser%

	select * from %Exp:cFNCName%(%Exp:cAno%,%Exp:cClasse%) 
	order by P_MAT, TIPO, MES

	EndSql

	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())

		__P_MAT		:= (cAliasTmp)->P_MAT		
		__lImpOk	:= .F.

		oExcel:AddLinha(12) 
		oExcel:AddCelula((cAliasTmp)->P_MAT										,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->P_NOME									,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->CLINOME									,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->P_RATEIO 									,0,'C',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->P_MESADMISSA								,0,'C',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->REPRESENTANTE  							,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->ESTADO		   							,0,'C',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->TIPO			   							,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.) 

		_nTotLin	:= 0
		_nContM		:= 0
		
		if _lTotper
			_nTotMet	:= 0
			_nTotRea	:= 0
			_lTotper	:= .F.
		endif

		For I := 1 To 12

			If !(cAliasTmp)->(Eof()) .And.;
			( __P_MAT == (cAliasTmp)->P_MAT ) .And.;
			( (cAliasTmp)->MES == StrZero(I,2) )

				__lImpOk := .T.	

				_cContent = IIF(SubStr((cAliasTmp)->TIPO,1,1)=='0',(cAliasTmp)->VALOR, Val((cAliasTmp)->VALOR))			
				_cFormatNum := IIF(SubStr((cAliasTmp)->TIPO,1,1)=='3','P','')
				_nDecimal := IIF(SubStr((cAliasTmp)->TIPO,1,1)=='0',0, 2)

				If ( SubStr((cAliasTmp)->TIPO,1,1) $ '1_2' .And. Val((cAliasTmp)->VALOR) > 0 ) //Totalizar Real e Meta

					_nTotLin += Val((cAliasTmp)->VALOR)
					_nContM += 1

					_nTotMet += IIf( SubStr((cAliasTmp)->TIPO,1,1) == '1', Val((cAliasTmp)->VALOR), 0)
					_nTotRea += IIf( SubStr((cAliasTmp)->TIPO,1,1) == '2', Val((cAliasTmp)->VALOR), 0)

				EndIf

				If ( SubStr((cAliasTmp)->TIPO,1,1) == '3' ) //Performance
					_lTotper := .T.
				EndIf

				oExcel:AddCelula(_cContent, _nDecimal,'C',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.,,,,_cFormatNum)
				(cAliasTmp)->(DbSkip())

			Else

				_cContent = IIF(SubStr((cAliasTmp)->TIPO,1,1)=='0','',0)
				oExcel:AddCelula(_cContent, 0,'C',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)

			EndIf

		Next I

		If !__lImpOk
			exit
		EndIf

		//Total do Ano
		_nMediaLin := 0
		If ( _nTotLin > 0 )

			if (_nContM > 0)
				_nMediaLin := _nTotLin/_nContM
			endif

			oExcel:AddCelula(_nTotLin, 2,'C',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.,,,,'')

		Else
			If (_lTotper)

				If ( _nTotMet > 0 )
					oExcel:AddCelula((_nTotRea/_nTotMet), 2,'C',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.,,,,'P')
				Else
					oExcel:AddCelula(0, 2,'C',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.,,,,'P')
				EndIf
	
			Else		
				oExcel:AddCelula("", 0,'C',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
			EndIf
		EndIf

		


		//Media do Ano
		If ( _nMediaLin > 0 )
			oExcel:AddCelula(_nMediaLin, 2,'C',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.,,,,'')
		Else
			oExcel:AddCelula("", 0,'C',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		EndIf		


		If (__P_MAT <> (cAliasTmp)->P_MAT)
			cCorF := IIf(cCorF == cWhite,cLGray,cWhite)
		EndIf

	EndDo
	(cAliasTmp)->(DbCloseArea())

Return