#Include "protheus.ch"
#INCLUDE "FILEIO.CH" 
#Include "tbiconn.ch"
#Include "topconn.ch"

/*/{Protheus.doc} AAPFIN55
Rotina para geração de remessa para Integração com o Serasa.
@type Function
@author Pontin
@since 04/10/2016
@version 1.0
/*/

/*
PARAMETROS:

MV_YNREMES
Descrição: Controla Sequencial do Arquivo.

MV_YSVAMIN
Descrição: Valor Minimo de saldo dos títulos

MV_YSEDIAS
Descrição: Dias de Atraso mínimo dos títulos a serem enviados

MV_YLOGSER
Descrição: Código do Login no Serasa

MV_YDIRESE
Descrição: Diretório Destino do arquivo de remessa
*/

User function AAPFIN55()

	Local aArea       := GetArea()
	Local aAlias	  	:= {}								
	Local aColumns	:= {}											
	Local oDlgMrk 	:= Nil
	Local cIndMrk	  	:= ''
	Local aFilter	  	:= {}
	Local aSeeks		:= {}
	Private cPerg		:= 'AAPFIN55'
	Private aRotina	:= {} 
	Private cAliasMrk	:= ''
	
	AtuPergunta()
	If Pergunte(cPerg,.T.)
	
		LjMsgRun("Carregando dados para seleção...",,{|| aAlias := fQryTrb() } )
		aRotina	  := FIMenudef()
		cAliasMrk := aAlias[1]
		aColumns  := aAlias[2]
		cIndMrk   := aAlias[3]
		aFilter	  := aAlias[4] 
		aSeeks	  := aAlias[5] 
		
		If !(cAliasMrk)->(Eof())
			oMrkBrowse:= FWMarkBrowse():New()
			oMrkBrowse:SetFieldMark("E1_OK")
			oMrkBrowse:SetOwner(oDlgMrk)
			oMrkBrowse:SetDataQuery(.F.)
			oMrkBrowse:SetDataTable(.T.)
			oMrkBrowse:SetSeek(.T.,aSeeks)
			oMrkBrowse:SetAlias(cAliasMrk)
			oMrkBrowse:bMark    := {|| fMark(cAliasMrk)}
			oMrkBrowse:bAllMark := {|| fInverte(cAliasMrk,.T.) }
			oMrkBrowse:SetDescription("SERASA")
			oMrkBrowse:SetColumns(aColumns)
			oMrkBrowse:oBrowse:SetDBFFilter(.T.) 
			oMrkBrowse:oBrowse:SetUseFilter()    
			oMrkBrowse:oBrowse:SetFieldFilter(aFilter)
			oMrkBrowse:oBrowse:bOnStartFilter := Nil
			oMrkBrowse:SetLocate() 
			oMrkBrowse:SetWalkThru(.F.)
			oMrkBrowse:SetAmbiente(.F.)
			oMrkBrowse:Activate()
		Else
			Help(" ",1,"RECNO")
		EndIf
	
	Endif	
	
	If !Empty(cAliasMrk)
		dbSelectArea(cAliasMrk)
		dbCloseArea()
		if file(cAliasMrk+GetDBExtension())
			Ferase(cAliasMrk+GetDBExtension())
		endif	
		if file(cAliasMrk+OrdBagExt())
			Ferase(cAliasMrk+OrdBagExt())
		endif
		if file(cIndMrk+OrdBagExt())
			Ferase(cIndMrk+OrdBagExt())
		endif
	Endif
	
	RestArea(aArea) 
	
Return


//Perguntas
Static Function AtuPergunta() 
	
	Local aHelp := {}
	
	aHelp := {}
	aAdd(aHelp,"Filial Inicial para o filtro")   
	PutSx1(cPerg, "01", "Filial de"	    ,"","","MV_CH1","C",8,0,1,"G","","SM0","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp)
	aHelp := {}
	aAdd(aHelp,"Filial Final para o filtro")   
	PutSx1(cPerg, "02", "Filial Ate"	,"","","MV_CH2","C",8,0,1,"G","","SM0","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp) 
	aHelp := {}
	aAdd(aHelp,"Cliente Inicial para o filtro")   
	PutSx1(cPerg, "03", "Cliente de"	,"","","MV_CH3","C",6,0,1,"G","","SA1","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp)
	aHelp := {}
	aAdd(aHelp,"Cliente Final para o filtro")   
	PutSx1(cPerg, "04", "Cliente Ate"	,"","","MV_CH4","C",6,0,1,"G","","SA1","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp) 
	aHelp := {}
	aAdd(aHelp,"Tipo de Remessa") 
	PutSx1(cPerg, "05", "Tipo de Remessa","","","MV_CH5","N",1,0,1,"C","",""  ,"","","MV_PAR05","Negativação","","","","Positivação","","","","","","","","","","","",aHelp,aHelp,aHelp)
	aHelp := {}
	aAdd(aHelp,"Vencimento inicial do titulo") 
	PutSx1(cPerg, "06", "Venc. Inicial","","","MV_CH6","D",8,0,1,"G","",""  ,"","","MV_PAR06","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp) 
	aHelp := {}
	aAdd(aHelp,"Vencimento final do titulo") 
	PutSx1(cPerg, "07", "Venc. Final","","","MV_CH7","D",8,0,1,"G","",""  ,"","","MV_PAR07","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp) 
	
	aHelp := {}
	aAdd(aHelp,"Tipos de titulos separados por virgula") 
	PutSx1(cPerg, "08", "Tipos Titulos","","","MV_CH8","C",90,0,1,"G","",""  ,"","","MV_PAR08","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp) 
	
	aAdd(aHelp,"Data Baixa inicial do titulo") 
	PutSx1(cPerg, "09", "Baixa Inicial","","","MV_CH9","D",8,0,1,"G","",""  ,"","","MV_PAR09","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp) 
	aHelp := {}
	aAdd(aHelp,"Data Baixa final do titulo") 
	PutSx1(cPerg, "10", "Baixa Final","","","MV_CHA","D",8,0,1,"G","",""  ,"","","MV_PAR10","","","","","","","","","","","","","","","","",aHelp,aHelp,aHelp) 
	
	
Return


Static Function FIMenudef()

	Local aRotina := {}
	
	If MV_PAR05 == 1
		aRotina := {{'Negativar',"U_fSpcSerasa",0,4}}
	Else
		aRotina := {{'Positivar',"U_fSpcSerasa",0,4}}
	EndIf	
 
Return(aRotina)


User Function fSpcSerasa()
	
	Local nSeq	:= 0
	
	//|Gera TXT para Serasa |
	nSeq	:= U_FSSERAS1("SERASA")
	
	//|Gera TXT para SPC |
	U_FSSERAS1("SPC",nSeq)


Return


Static Function fMark(cAliasTRB)
	
	Local lRet	:= .T.
	SE1->(dbGoto((cAliasTRB)->SE1RECNO))
	If SE1->(MsRLock()) .AND. (cAliasTRB)->(MsRLock())
		lRet := .t. 
	Else
		IW_MsgBox("Este registro est?sendo utilizado em outro terminal, nã podendo ser selecionado","Atenção","STOP")	
		lRet := .F.
	Endif
	
Return lRet


Static Function fInverte(cAliasTRB,lTudo)
	
	Local nReg 	  := (cAliasTRB)->(Recno())
	Local cMarca  := oMrkBrowse:cMark
	Default lTudo := .T.
	
	dbSelectArea(cAliasTRB)
	If lTudo
		(cAliasTRB)->(dbgotop()) 
		cMarca := oMrkBrowse:cMark
	Endif
	While (cAliasTRB)->(!Eof())
		SE1->(dbGoto((cAliasTRB)->SE1RECNO))
		If SE1->(MsRLock()) .AND. (cAliasTRB)->(MsRLock())
			IF (cAliasTRB)->E1_OK == cMarca
				(cAliasTRB)->E1_OK := "  "
				(cAliasTRB)->(MsUnlock())
				SE1->(MsUnlock())			
			Else
				(cAliasTRB)->E1_OK := cMarca
			Endif
			If !lTudo
				Exit
			Endif
		Endif
		(cAliasTRB)->(dbSkip())
	Enddo
	(cAliasTRB)->(dbGoto(nReg))
	oMrkBrowse:oBrowse:Refresh(.t.)
	
Return .T.


Static Function fQryTrb()

	Local aArea		:= GetArea()			
	Local aStruQry	:= {}	
	Local aStruct	:= {}	
	Local aColumns	:= {}					
	Local nX		:= 0					
	Local cTempTab	:= ""					
	Local cAliasTrb	:= GetNextAlias()
	Local aFilterX  := {}
	Local aSeeks	:= {}
	Local nValMin   := GetNewPar("MV_YSVAMIN",30)
	Local nDias	    := GetNewPar("MV_YSEDIAS",60)
	Local cTipos	:= "%"+FormatIn(mv_par08,",")+"%"
	Local cIndTRB1  := ''
	nDias++
	
	if MV_PAR05 == 2
	
		BeginSQL alias cAliasTrb   
		 	SELECT  SE1.E1_FILIAL,
		 			SE1.E1_PREFIXO,
		 			SE1.E1_NUM,
		 			SE1.E1_PARCELA,
		 			SE1.E1_TIPO,
					SE1.E1_CLIENTE,
				    SE1.E1_LOJA,
				    SA1.A1_NREDUZ,
			 	    SE1.E1_EMISSAO,
			        SE1.E1_VENCTO,
			 	    SE1.E1_VENCREA,
			        SE1.E1_VALOR,
			        SE1.E1_SALDO,
				    SE1.E1_NUMBOR,
			 	    SE1.E1_DATABOR,
			       	SE1.E1_AGECHQ,
					SE1.E1_BCOCHQ,
					SE1.E1_CTACHQ,
					SEF.EF_ALINEA2,	
					SEF.EF_NUM,
				    SA1.A1_NOME,
				    SA1.A1_PESSOA,
		            SA1.A1_CGC,
				    SA1.A1_END,
		       		SA1.A1_BAIRRO,
		       		SA1.A1_MUN,       
		       		SA1.A1_EST,
		       		SA1.A1_CEP, 
		       		SA1.A1_DDD,
		       		SA1.A1_TEL,
		       		'  ' E1_OK,
			        SE1.R_E_C_N_O_ AS SE1RECNO			 
		     FROM %Table:SE1% SE1 (NOLOCK)
			 INNER JOIN %Table:SA1% SA1 (NOLOCK) 
			  ON SA1.D_E_L_E_T_ = ''
			  AND SA1.A1_COD = SE1.E1_CLIENTE 
			  AND SA1.A1_LOJA = SE1.E1_LOJA    
			 LEFT JOIN %Table:SEF% SEF (NOLOCK) 
			  ON SEF.D_E_L_E_T_ = ''
			  AND SE1.E1_CLIENTE = SEF.EF_CLIENTE
			  AND SE1.E1_LOJA = SEF.EF_LOJACLI 
			  AND SE1.E1_NUM = SEF.EF_NUM 
			  AND SE1.E1_AGECHQ = SEF.EF_AGENCIA 
			  AND SE1.E1_BCOCHQ = SEF.EF_BANCO 
			  AND SE1.E1_CTACHQ = SEF.EF_CONTA 
			 WHERE SE1.D_E_L_E_T_ = '' 
			  AND SE1.E1_SALDO = 0 
			  AND SE1.E1_FILIAL BETWEEN %exp:MV_PAR01%  AND %exp:MV_PAR02% 
			  AND SA1.A1_COD BETWEEN %exp:MV_PAR03%  and %exp:MV_PAR04% 
			  AND SE1.E1_BAIXA BETWEEN %exp:MV_PAR09%  and %exp:MV_PAR10% 
			  AND SE1.E1_TIPO IN %exp:cTipos%
			  AND SE1.E1_YSPC = 'S' 
		     ORDER BY SE1.E1_FILIAL,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO              
		EndSQL
		 
	else
	
		BeginSQL alias cAliasTrb   
		 	SELECT  SE1.E1_FILIAL,
		 			SE1.E1_PREFIXO,
		 			SE1.E1_NUM,
		 			SE1.E1_PARCELA,
		 			SE1.E1_TIPO,
					SE1.E1_CLIENTE,
				    SE1.E1_LOJA,
				    SA1.A1_NREDUZ,
			 	    SE1.E1_EMISSAO,
			        SE1.E1_VENCTO,
			 	    SE1.E1_VENCREA,
			        SE1.E1_VALOR,
			        SE1.E1_SALDO,
				    SE1.E1_NUMBOR,
			 	    SE1.E1_DATABOR,
			       	SE1.E1_AGECHQ,
					SE1.E1_BCOCHQ,
					SE1.E1_CTACHQ,
					SEF.EF_ALINEA2,	
					SEF.EF_NUM,
				    SA1.A1_NOME,
				    SA1.A1_PESSOA,
		            SA1.A1_CGC,
				    SA1.A1_END,
		       		SA1.A1_BAIRRO,
		       		SA1.A1_MUN,       
		       		SA1.A1_EST,
		       		SA1.A1_CEP, 
		       		SA1.A1_DDD,
		       		SA1.A1_TEL,
		       		'  ' E1_OK,
			        SE1.R_E_C_N_O_ AS SE1RECNO
			 FROM %Table:SE1% SE1 (NOLOCK)
			 INNER JOIN %Table:SA1% SA1 (NOLOCK) 
			  ON SA1.D_E_L_E_T_ = ''
			  AND SA1.A1_COD = SE1.E1_CLIENTE 
			  AND SA1.A1_LOJA = SE1.E1_LOJA  
			  AND SA1.A1_YTIPOEX <> 'LOJ'  
			 LEFT JOIN %Table:SEF% SEF (NOLOCK) 
			  ON SEF.D_E_L_E_T_ = ''
			  AND SE1.E1_CLIENTE = SEF.EF_CLIENTE
			  AND SE1.E1_LOJA = SEF.EF_LOJACLI 
			  AND SE1.E1_NUM = SEF.EF_NUM 
			  AND SE1.E1_AGECHQ = SEF.EF_AGENCIA 
			  AND SE1.E1_BCOCHQ = SEF.EF_BANCO 
			  AND SE1.E1_CTACHQ = SEF.EF_CONTA 
			 WHERE SE1.D_E_L_E_T_ = '' 
		      AND SE1.E1_SALDO > 0 
			  AND SE1.E1_FILIAL BETWEEN %exp:MV_PAR01%  AND %exp:MV_PAR02% 
			  AND SA1.A1_COD BETWEEN %exp:MV_PAR03%  and %exp:MV_PAR04%  			  		      
		      AND SE1.E1_SALDO > %exp:nValMin%
		      AND SE1.E1_VENCREA BETWEEN %exp:MV_PAR06%  and %exp:MV_PAR07% 
			  AND SE1.E1_TIPO IN %exp:cTipos%
			  AND SE1.E1_YGARANT <> 'S'
			  AND SE1.E1_YSPC <> 'S'
		     ORDER BY SE1.E1_FILIAL,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO              
		EndSQL
	endif	
	DbSelectArea(cAliasTrb)
	TcSetField(cAliasTrb,"SE1RECNO","N",18)
	aStruQry := (cAliasTrb)->(DbStruct()) 
	
	DbSelectArea("SX3")	
	SX3->(DbSetOrder(2)) 
	for nx := 1 to len(aStruQry) 
		if SX3->(DbSeek(PADR(alltrim(aStruQry[nx,1]),10)))
			AADD(aStruct,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL} )
		endif
	next nx	
	cTempTab := CriaTrab( aStruct,.T. )
	
	DbSelectArea(cAliasTrb)
	if (cAliasTrb)->(!EOF())
		COPY TO &cTempTab
	endif
		
	If ( Select( cAliasTrb ) > 0 )
		(cAliasTrb)->(DbCloseArea())
	EndIf
	
	DbUseArea( .T.,,cTempTab,cTempTab, .T., .F. )  
	
	cIndTRB1 := CriaTrab(Nil, .F.)
	IndRegua(cTempTab,cIndTRB1,"E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA ",,,"Criando Indice")
	dbClearIndex()
	dbSetIndex(cIndTRB1 + OrdBagExt())
	
	For nX := 1 To Len(aStruct)
		If	!Alltrim(aStruct[nX,1]) $ "E1_OK/SE1RECNO"
		
			AAdd(aColumns,FWBrwColumn():New())
			If Alltrim(aStruct[nX,2]) == 'D'
				aColumns[Len(aColumns)]:SetData( &("{|| SToD("+aStruct[nX,1]+") }") )
			Else
				aColumns[Len(aColumns)]:SetData( &("{|| "+aStruct[nX,1]+"}") )
			EndIf	
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nX,1])) 
			aColumns[Len(aColumns)]:SetType(aStruct[nX,2])
			aColumns[Len(aColumns)]:SetSize(aStruct[nX,3]) 
			aColumns[Len(aColumns)]:SetDecimal(aStruct[nX,4])
			aColumns[Len(aColumns)]:SetPicture(PesqPict( iif( 'E1_'$ aStruct[nX,1],'SE1','SA1') ,aStruct[nX,1])) 
			
			If Alltrim(aStruct[nX,2]) == 'N'
				aColumns[Len(aColumns)]:SetAlign("RIGHT") 
			elseif Alltrim(aStruct[nX,2]) == 'D' 
				aColumns[Len(aColumns)]:SetAlign("CENTER") 
			endif
	
			AAdd( aFilterX, { aStruct[nX,1], RetTitle(aStruct[nX,1]), aStruct[nX,2], aStruct[nX,3], aStruct[nX,4], PesqPict( iif( 'E1_'$ aStruct[nX,1],'SE1','SA1') ,aStruct[nX,1]) } )
		endif
	Next nX 
	
	AAdd(aSeeks, {; //"E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA "
					AllTrim(RetTitle(aStruct[1,1])) + ' + ' + AllTrim(RetTitle(aStruct[2,1])) + ' + '+AllTrim(RetTitle(aStruct[3,1])) + ' + '+;
					AllTrim(RetTitle(aStruct[4,1])) + ' + ' + AllTrim(RetTitle(aStruct[5,1])) + ' + '+AllTrim(RetTitle(aStruct[6,1])) + ' + '+;
					AllTrim(RetTitle(aStruct[7,1])),;
				 {;
				 	{'SE1',aStruct[1,2],aStruct[1,3],aStruct[1,4],AllTrim(RetTitle(aStruct[1,1])),Nil},;
				 	{'SE1',aStruct[2,2],aStruct[2,3],aStruct[2,4],AllTrim(RetTitle(aStruct[2,1])),Nil},;
				 	{'SE1',aStruct[3,2],aStruct[3,3],aStruct[3,4],AllTrim(RetTitle(aStruct[3,1])),Nil},;
				 	{'SE1',aStruct[4,2],aStruct[4,3],aStruct[4,4],AllTrim(RetTitle(aStruct[4,1])),Nil},;
				 	{'SE1',aStruct[5,2],aStruct[5,3],aStruct[5,4],AllTrim(RetTitle(aStruct[5,1])),Nil},;
				 	{'SE1',aStruct[6,2],aStruct[6,3],aStruct[6,4],AllTrim(RetTitle(aStruct[6,1])),Nil},;
				 	{'SE1',aStruct[7,2],aStruct[7,3],aStruct[7,4],AllTrim(RetTitle(aStruct[7,1])),Nil};
				 }})
	
	RestArea(aArea)
	
Return({cTempTab,aColumns,cIndTRB1,aFilterX,aSeeks})


//gera arquivo de envio
User function FSSERAS1(cFornec,nSeq)

	Local aArea     	:= GetArea()
	Local cAlias  		:= cAliasMrk
	Local cLin    		:= ''
	Local nNRemessa 	:= 0
	Local cLogon		:= "" 
	Local cDir			:= ""
	Local cArqtxt   	:= ''
	Local nHdl			:= 0
	Local cSeqReg   	:= 0
	Local cNatu 		:= ''
	Local cNumDoc   	:= ''
	Local cDDD      	:= ''
	Local cTEL	    	:= ''
	Local cMotBX    	:= '01' // Pagamento da divida
	Local cTpEnv    	:= iif(MV_PAR05 == 1,'I','E') // I - Inclusão=Negativado ; E - Exclusão=positivado
	Local cMarca    	:= oMrkBrowse:cMark
	Local aRegsSE1  	:= {}
	
	Default cFornec		:= "SERASA"
	Default nSeq		:= 0
	
	If (cAlias)->(EOF())
		MsgInfo('Nenhum Registro Encontrado')
		RestArea(aArea)  
		return
	endif 
	
	If cFornec == "SERASA"
		
		cLogon		:= AllTrim(GetNewPar("MV_YLOGSER","12345678")) 
		cDir		:= GetNewPar("MV_YDIRESE","C:\serasa_pfin\envio\")
		nNRemessa 	:= GetNewPar("MV_YNREMES",1)+1
		
		PUTMV("MV_YNREMES",nNRemessa)
		
		cArqtxt := cDir + "pfin"+strZero(nNRemessa,6)+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))+cTpEnv+".txt"
		
	Else	//|SPC |
		cLogon		:= AllTrim(GetNewPar("MV_YLOGSPC","270619")) 
		cDir		:= GetNewPar("MV_YDIRSPC","C:\spc_pfin\envio\")
		nNRemessa 	:= nSeq
		
		cArqtxt := cDir + "pfin_"+strZero(nNRemessa,6)+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))+cTpEnv+".txt"
		
	EndIf
	
	FWMakeDir(cDir) 
	
	nHdl := fCreate(cArqTxt)
	
	cSeqReg++  
	                               			// Montagem do Header - Registro 0 
	                               			//                           Seq Ini Tam
	cLin := '0'                   			// Identificador HEADER       01 001 001
	cLin += '0'+ SubStr("27340074",1,8)    	// CNPJ da empresa            02 002 009 obs: buscar na sm0
	cLin += dtos(date())              		// Data geração arq.          03 011 008 obs: criar paramentro posteriormente
	cLin += '0028'							// DDD do Telefone da inst.   04 019 004
	cLin += '21010799'         				// Telefone de inst.          05 023 008 
	cLin += '0000'                			// Ramal da inst              06 031 004  
	cLin +=  space(70)			            	// Pessoa de contato          07 035 070  
	cLin += 'SERASA-CONVEM04'     			// Indetificador fixo         08 105 015
	cLin += strZero(nNRemessa,6)  			// N?da remessa              09 120 006
	cLin += 'E'                   			// Código de envio            10 126 001 obs: "E" - Entrada, "R" - Retorno
	cLin += "0057"              			// Diferencial entre remessa  11 127 004 
	cLin += space(3)              			// Deixar em branco           12 131 003 
	cLin += PADR(cLogon,8)         			// Logon de acesso            13 134 008 
	cLin += space(392)            			// Deixar em branco           14 142 392
	cLin += space(60)             			// Código de erro             15 534 060
	cLin += '0000001'    					// Sequencia do reg. no arq.  16 594 007   
	cLin +=  CRLF    
	
	fWrite(nHdl,cLin) 
	 
	(cAlias)->(dbgotop())
	While !(cAlias)->(EOF())
		  
		IF (cAlias)->E1_OK <> cMarca
			(cAlias)->(dbSkip())
			loop
		endif 
		  
		cSeqReg++  
		
		if (cAlias)->E1_TIPO == 'CH'   
			cNatu := ' DC' 
		else
			cNatu := ' NF'
		endif	
	    	
	    cLin := '1'               				    				// Identificador detalhe      01 001 001
	    
	    // obs: I - Inclusão; E - Exclusão
	    if cTpEnv == 'E'
	    	cLin += 'E'               								    // Cod. Operação              02 002 001 
	    else
	    	cLin += 'I'               								    // Cod. Operação              02 002 001 
	    endif
	    
	    aAreaSM0	:= SM0->(GetArea())
	    dbSelectArea("SM0")
	    SM0->(dbSetOrder(1))
	    SM0->(dbSeek(cEmpAnt + "AAPES002"))//(cAlias)->E1_FILIAL))
	    cCnpj		:= SM0->M0_CGC
	    RestArea(aAreaSM0)
	    
	    cLin += substr(cCnpj,9,6) 	    								// Filial e digito do CNPJ    03 003 006 
	    cLin += (cAlias)->E1_VENCREA							    // Data venc. divida          04 009 008 
	    cLin += (cAlias)->E1_VENCREA							    // Data term. contrato        05 017 008
	    cLin += cNatu           								    // Cod. natureza da operação  06 025 003   
	    cLin += '0000'            								    // Cod. da praça EMBRATEL     07 028 004
		cLin += PADR((cAlias)->A1_PESSOA,1)      						// Tipo de pessoa             08 032 001 obs: F-Fisica; J-Juridica
	    cLin += iif((cAlias)->A1_PESSOA == 'J','1','2') 				// Tipo pri. doc. principal   09 033 001
	    cLin += strZero(val((cAlias)->A1_CGC),15)   			 		// Primeiro documento         10 034 015    
	 
	    // obrigatorio para exclusões - tabela de motivo de baixa
	    if cTpEnv == 'E'
	    	cLin += PADR(cMotBX,2)                       					// Motivo da baixa            11 049 002
	    else
	    	cLin += space(2)                            					// Motivo da baixa            11 049 002
	    endif
	 
	    cLin += space(1)                          				  	// Tipo do segundo doc.       12 051 001
	    cLin += space(15)                           					// Segundo doc                13 052 015
	    cLin += space(2)                            					// UF segundo doc.            14 067 002  
	 
	    cLin += PADR((cAlias)->A1_PESSOA,1)              				// Tipo pessoa coobrigado     15 069 001
	    cLin += iif((cAlias)->A1_PESSOA == 'J','1','2') 				// Tipo pri. doc. coobrigado  16 070 001
	    cLin += space(15)                           					// Pri doc. coobrigado        17 071 015
	    cLin += space(2)                            					// Espaços                    18 086 002
	    cLin += space(1)                           	 				// Tipo seg. documento        19 088 001
	    cLin += space(15)                           					// Segundo documento          20 089 015
	    cLin += space(2)                            					// UF do documento            21 104 002
	    cLin += PADR(substr(allTrim((cAlias)->A1_NOME),1,70),70) 		// Nome do devedor            22 106 070
	    cLin += '00000000'                   	        					// Data nascimnto             23 176 008  		    
	    cLin += space(70)                    	  			      		// Nome do pai                24 184 070 
		cLin += space(70)                       	    					// Nome da mae                25 254 070
		cLin += PADR(substr(allTrim((cAlias)->A1_END),1,45),45)     	// Endereço                   26 324 045
		cLin += PADR(substr(allTrim((cAlias)->A1_BAIRRO),1,20),20)  	// Bairro                     27 369 020
		cLin += PADR(substr(allTrim((cAlias)->A1_MUN),1,25),25)     	// Municipio                  28 389 025
	    cLin += PADR(substr(allTrim((cAlias)->A1_EST),1,2),2)       	// Estado                     29 414 002
	    cLin += PADR(substr(allTrim((cAlias)->A1_CEP),1,8),8)       	// CEP                        30 416 008
	    cLin += STRZERO((cAlias)->E1_SALDO * 100,15)					// Valor                      31 424 015  
	   	
	  	//Case para efetuar "de para" de natureza de operação
	   	cNumDoc  := strZero((cAlias)->SE1RECNO,16)
	   	
	   	cDDD		:= LimpaChar((cAlias)->A1_DDD)
	   	cDDD     := substr(allTrim(cDDD)+space(4-len(allTrim(cDDD))),1,4)
	   	cTEL		:= LimpaChar((cAlias)->A1_TEL)
	   	cTEL	 	:= substr(allTrim(cTEL)+space(9-len(allTrim(cTEL))),1,9)
	   	
	 	if (cAlias)->E1_TIPO == 'CH'   
	 		cLin += PADR(Alltrim((cAlias)->E1_BCOCHQ),4) 				// N?do banco                32 439 004
	 		cLin += PADR(Alltrim((cAlias)->E1_AGECHQ),4)       		// Agencia                    33 443 004
	 		cLin += PADR(Alltrim((cAlias)->EF_NUM),6)         		 	// N?do cheque               34 447 006
	 		cLin += PADR(Alltrim((cAlias)->EF_ALINEA2),2)      		// Alinea                     35 453 002	    	      
		else
	   		cLin += PADR(cNumDoc,16)                      	   		// N?do contrato             32 439 016 		    	  
		endif	
	    cLin += space(9)                            					// Nosso n?                  33 455 009 
	    cLin += space(25)                           		  			// Complemento do endereço    34 464 025 obs : Montar a partir do endereço
	    cLin += PADR(cDDD,4)									  	// DDD do telefone do devedor 35 489 004		    
	    cLin += PADR(cTEL,9)										// N?do telefone do devedor  36 493 009
	    cLin += PADR((cAlias)->E1_VENCREA,8)		    		          	// Data compromisso devedor   37 502 008 
	    cLin += STRZERO((cAlias)->E1_SALDO * 100,15)          			// Valor compromisso devedor  38 510 015 
	    cLin += 'N'                                					// Indica envio de SMS        39 525 001 obs : S - envia SMS; N - não envia 
	    cLin += space(5)                            					// espaços                    40 526 005 
	    cLin += space(1)                            					// Tipo de comunicado         41 531 001 obs : ' ' -> ?; 'B' -> comunica com boleto; 'C' -> comunica com pgto contas publicas 
	    cLin += space(1)                            					// espaços                    42 532 001 
	    cLin += space(1)                            					// espaços                    43 533 001
	    cLin += space(60)                           					// codigos de erro            44 534 060
	    cLin += strZero(cSeqReg,7)                  					// Sequencia do registro      45 594 007 		    
	    cLin += CRLF	   
	   	 
	   	fWrite(nHdl,cLin) 
	   	
	   	AADD(aRegsSE1,(cAlias)->SE1RECNO)
	   	  
		(cAlias)->(dbSkip())
	end
	
	cSeqReg++  
	cLin := '9'               // Identificador TRAILLER     01 001 001
	cLin += space(592)        // Brancos                    02 002 592   
	cLin += strZero(cSeqReg,7)// Sequencia do registro      03 594 007   	
	cLin += CRLF    
	
	fWrite(nHdl,cLin) 	 
	fClose(nHdl) 
	
	For nX := 1 to Len(aRegsSE1)
		SE1->(dbGoTo(aRegsSE1[nX]))
		SE1->(MsRUnlock())
	Next
	
	if file(cArqtxt)    
		MsgInfo("Arquivo "+cArqtxt+" gerado com sucesso.","Atenção!") 
		oMrkBrowse:GetOwner():End()
	endif
	RestArea(aArea)  
	
return nNRemessa


//atualiza parametro
Static Function fAtuSX6()

	Local aSX6   := {}                                       
	Local aEstrut:= {}
	Local i      := 0
	Local j      := 0
	              
	aEstrut := {"X6_FIL","X6_VAR","X6_TIPO","X6_DESCRIC","X6_DSCSPA","X6_DSCENG","X6_DESC1","X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"}
	aAdd(asx6,{"  ", "MV_YNREMES", "N", "Remessa Serasa - Sequencial Arquivo", "Remessa Serasa - Sequencial Arquivo","Remessa Serasa - Sequencial Arquivo","","","","","","","0" ,"0" ,"0" ,"S","S"})
	aAdd(asx6,{"  ", "MV_YSVAMIN", "N", "Remessa Serasa - Valor Minimo"      , "Remessa Serasa - Valor Minimo"		,"Remessa Serasa - Valor Minimo"	  ,"","","","","","","30","30","30","S","S"})
	aAdd(asx6,{"  ", "MV_YSEDIAS", "N", "Remessa Serasa - Dias de Atrazo"    , "Remessa Serasa - Dias de Atrazo"	,"Remessa Serasa - Dias de Atrazo"	  ,"","","","","","","60","60","60","S","S"})
	aAdd(asx6,{"  ", "MV_YLOGSER", "C", "Remessa Serasa - Login"			 , "Remessa Serasa - Login"				,"Remessa Serasa - Login"			  ,"","","","","","","12345678","12345678","12345678","S","S"})
	aAdd(asx6,{"  ", "MV_YDIRESE", "C", "Remessa Serasa - Diretorio Destino" , "Remessa Serasa - Diretorio Destino"	,"Remessa Serasa - Diretorio Destino" ,"","","","","","","C:\serasa_pfin\envio\","C:\serasa_pfin\envio\","C:\serasa_pfin\envio\","S","S"})
	
	dbSelectArea("SX6")
	SX6->(dbSetOrder(1))
	For i:= 1 To Len(aSX6)
		If !Empty(aSX6[i][2])
			If !SX6->(dbSeek("  "+aSX6[i,2])) .And. !SX6->(dbSeek(cFilAnt+aSX6[i,2]))
				SX6->(RecLock("SX6",.T.))
				For j:=1 To Len(aSX6[i])
					If !Empty(FieldName(FieldPos(aEstrut[j])))
						FieldPut(FieldPos(aEstrut[j]),aSX6[i,j])
					EndIf
				Next j
				SX6->(dbCommit())        
				SX6->(MsUnLock())
			EndIf
		EndIf
	Next i
	
Return 


Static Function LimpaChar(cChar)

	If !Empty(cChar)
  		cChar		:= StrTran(cChar,',','')
  		cChar		:= StrTran(cChar,'.','')
  		cChar		:= StrTran(cChar,'/','')
  		cChar		:= StrTran(cChar,'-','')
  		cChar		:= StrTran(cChar,'(','')
  		cChar		:= StrTran(cChar,')','')
  		cChar		:= StrTran(cChar,' ','')
  		cChar		:= StrTran(cChar,'\','')
  		cChar		:= StrTran(cChar,';','')
  		cChar		:= StrTran(cChar,'[','')
  		cChar		:= StrTran(cChar,']','')
  		cChar		:= StrTran(cChar,'{','')
  		cChar		:= StrTran(cChar,'}','')
  	EndIf

Return cChar