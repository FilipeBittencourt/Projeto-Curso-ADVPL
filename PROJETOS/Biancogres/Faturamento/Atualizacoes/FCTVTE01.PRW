#include "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"                                                        
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³FCTVTE01  ³ Autor ³ Artur Antunes         ³ Data ³ 22.07.16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³Processamento de Contratos (Previsão)			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³BIANCOGRES                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User function FCTVTE01()

	Local aArea       := GetArea() 
	Local oBrowse     := nil
	private aRotina   := fMenuDef()
	private cCadastro := "Contratos de Verbas"    

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZA7')
	oBrowse:SetDescription(cCadastro)
	oBrowse:AddLegend("ZA7_STATUS = 'N'", "GREEN", "Novo") 
	oBrowse:AddLegend("ZA7_STATUS = 'A'", "RED"  , "Aprovado")
	oBrowse:Activate() 
	RestArea(aArea)

Return   


// funcao para o menu                                 
Static Function fMenuDef()
	local aRotina := {} 
	aRotina := {{"Pesquisar"   	,"AxPesqui"   , 0, 1},;     
	{"Visualizar"  	,"U_fFCTVT01" , 0, 2},; 
	{"Incluir"		,"U_fFCTVT01" , 0, 3},;
	{"Alterar"		,"U_fFCTVT01" , 0, 4},;
	{"Excluir"		,"U_fFCTVT01" , 0, 5},;
	{"Aprovar"		,"U_fFCTVT01" , 0, 2},;
	{"Legenda"      ,"U_fFCTVT01" , 0, 2}}
return aRotina


//Acoes do menu
User Function fFCTVT01(cAlias,nReg,nOpc)
	do case
		case nOpc == 5 
		if (cAlias)->ZA7_STATUS == 'A'
			MsgStop("Operação não permitida, contrato já aprovado!")
		else
			fMontaTela(cAlias,nReg,nOpc)
		endif
		case nOpc == 6   
		if (cAlias)->ZA7_STATUS == 'A'
			MsgInfo("Este Contrato já foi aprovado!")
		else
			fMontaTela(cAlias,nReg,nOpc)
		endif
		case nOpc == 7
		fLegenCTV()
		otherwise	
		fMontaTela(cAlias,nReg,nOpc)
	endcase  
return  


// funcao para exibir legenda
Static Function fLegenCTV() 
	Local aAreaL  := GetArea()
	Local _aCores := {}
	AADD(_aCores,{'BR_VERDE'	,"Novo"     }) 
	AADD(_aCores,{'BR_VERMELHO'	,"Aprovado" })    
	BrwLegenda(cCadastro,"Legenda",_aCores) 
	RestArea(aAreaL)
Return   


//Monta Tela
Static Function fMontaTela(cAlias,nReg,nOpc)

	local nTamRod		:= 0
	local cAlias2		:= 'ZA8'
	local nLargGet		:= 50
	local nLargSay		:= 20
	local nAltTemp		:= 10
	local nHorIni		:= 40
	local nHorTemp		:= 0
	private nQtdLinOri	:= 0
	private lMostraSal  := .F.
	private lSave		:= .F. 
	private nCredito	:= 0
	private nDebito		:= 0
	private nSaldo		:= 0
	private aSize 		:= MsAdvSize(.T.)
	Private _aObjects	:=	{}
	private aCamposCab  := {}
	Private lRefresh 	:= .T.
	Private nUsado 		:= 0
	private aCampAlt 	:= {}
	private cAliasCab 	:= 'ZA7'
	private cAliasIt	:= 'ZA8'
	private cCampoIT	:= 'ZA8_ITEM'
	private cChaveRel	:= '_CODIGO'
	private cLablDtIni  := ''
	private cLablDtFim  := ''
	Private aHeader 	:= {}
	Private aCols 		:= {}
	Private aTELA[0][0]
	Private aGETS[0]   

	AAdd(_aObjects, {100, 50, .T. , .T. })
	AAdd(_aObjects, {100, 50, .T. , .T. })                      

	_aInfo   := {aSize[1], aSize[2], aSize[3], aSize[4], 5, 5}	

	_aPosObj := MsObjSize(_aInfo, _aObjects, .T. )

	if nOpc==3 .or. (nOpc<>3 .and. (cAlias)->ZA7_STATUS <> 'A' )
		nTamRod	:= 5
	else
		nTamRod	:= 30
		lMostraSal := .T.
	endif	

	Define MsDialog oDlg Title cCadastro From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel

	//oDlg:=MSDialog():New(aSize[7],0,aSize[6],aSize[5],cCadastro,,,,,CLR_BLACK,,,,.T.) 

	RegToMemory(cAlias,If(nOpc==3,.T.,.F.)) 
	fLoadCab(cAlias,nOpc) 
	oCab := MsMGet():New(cAlias, nReg,iif(nOpc==6,2,nOpc),,,,aCamposCab,{_aPosObj[1,1]+5,_aPosObj[1,2],_aPosObj[1,3],_aPosObj[1,4]},aCamposCab,,,,,oDlg)    

	fLoadItens(cAliasIt,nOpc) 
	oGetDados := MsGetDados():New(_aPosObj[2,1],_aPosObj[2,2],_aPosObj[2,3],_aPosObj[2,4],iif(nOpc==6,2,nOpc),'U_FCTVLIOK','U_FCTVTDOK',"+"+cCampoIT,.T.,aCampAlt,,.F.,99,'U_FCTVFLOK','U_FCTVSDEL',,'U_FCTVTDEL',oDlg)

	fAjustaHelp()

	if lMostraSal
		nHorTemp := nHorIni
		oSay1 := tSay():new(aSize[4]-nTamRod+nAltTemp+3,nHorTemp,{|| "Credito: "  },oDlg,,,,,,.T.,,,nLargSay,nAltTemp)  
		nHorTemp += nLargSay
		oGet1 := TGet():New(aSize[4]-nTamRod+nAltTemp  ,nHorTemp,{|u| if(PCount()>0,nCredito:=u,nCredito)},oDlg,nLargGet,nAltTemp,"@E 999,999,999,999.99",,,,,,,.T.,,,,,,,.T.,,,'nCredito')
		nHorTemp += nLargGet+20 
		oSay2 := tSay():new(aSize[4]-nTamRod+nAltTemp+3,nHorTemp,{|| "Debito: "},oDlg,,,,,,.T.,,,nLargSay,nAltTemp)  
		nHorTemp += nLargSay 
		oGet2 := TGet():New(aSize[4]-nTamRod+nAltTemp  ,nHorTemp,{|u| if(PCount()>0,nDebito:=u,nDebito)},oDlg,nLargGet,nAltTemp,"@E 999,999,999,999.99",,,,,,,.T.,,,,,,,.T.,,,'nDebito')
		nHorTemp += nLargGet+20 
		oSay3 := tSay():new(aSize[4]-nTamRod+nAltTemp+3,nHorTemp,{|| "Saldo: " },oDlg,,,,,,.T.,,,nLargSay,nAltTemp)  
		nHorTemp += nLargSay 
		oGet3 := TGet():New(aSize[4]-nTamRod+nAltTemp  ,nHorTemp,{|u| if(PCount()>0,nSaldo:=u,nSaldo)},oDlg,nLargGet,nAltTemp,"@E 999,999,999,999.99",,,,,,,.T.,,,,,,,.T.,,,'nSaldo')
	endif

	Activate MsDialog oDlg Centered on Init EnchoiceBar(oDlg,{|| fConfirma(nOpc) },{|| oDlg:End()} )

	//oDlg:Activate(,,,.T.,,,EnchoiceBar(oDlg,{|| fConfirma(nOpc) },{|| oDlg:End()} )) 

	if nOpc == 3  
		if lSave
			ConfirmSX8()
		else 
			RollBAckSx8()
		endif
	endif  

return


//Confirmar operação
Static Function fConfirma(nOpc)

	Do case
		case nOpc==2
		oDlg:End()
		case nOpc==3 .or. nOpc==4	
		if fTudoOK(nOpc)
			lSave := fUpdateReg(nOpc)
			oDlg:End()
		endif
		case nOpc==5 	
		lSave := fUpdateReg(nOpc)
		oDlg:End()
		case nOpc==6
		Processa( {|| fAprova() },"Aguarde...","Processando Aprovação...")
		oDlg:End()
	endcase			
return


//Load Cabeçalho
Static Function fLoadCab(cAlias,nOpc)
	local ny 	 := 0
	local lExist := .F.

	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbSeek(cAlias))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
		If !("_FILIAL" $ SX3->X3_CAMPO) .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)       
			AADD(aCamposCab,SX3->X3_CAMPO) 
		EndIf
		SX3->(DbSkip())
	End  

	if nOpc == 3
		if lExist := (cAliasCab)->(DbSeek(xFilial(cAliasCab)+M->&(cAliasCab+cChaveRel) ))	
			while lExist
				ConfirmSX8()
				M->&(cAliasCab+cChaveRel) := GETSXENUM(cAliasCab,cAliasCab+cChaveRel)  
				lExist := (cAliasIt)->(DbSeek(xFilial(cAliasCab)+M->&(cAliasCab+cChaveRel) ))                                                                                                 
			end
		endif
	endif	

	if lMostraSal
		nCredito := U_FCTVUT01(M->&(cAliasCab+cChaveRel), 1)
		nDebito  := U_FCTVUT01(M->&(cAliasCab+cChaveRel), 2)
		nSaldo   := nCredito - nDebito 
	endif

return


//Load Itens
Static Function fLoadItens(cAlias,nOpc)
	local ny := 0
	Local nI

	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbSeek(cAlias))

	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == cAlias
		If !("_FILIAL" $ SX3->X3_CAMPO) .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)       
			nUsado++     
			AADD(aCampAlt,SX3->X3_CAMPO)   
			Aadd(aHeader,{AllTrim(X3Titulo()),;
			SX3->X3_CAMPO   	 ,;                      
			SX3->X3_PICTURE 	 ,;                      
			SX3->X3_TAMANHO 	 ,;                      
			SX3->X3_DECIMAL 	 ,;                      
			SX3->X3_VALID   	 ,;                      
			SX3->X3_USADO  	 ,;                      
			SX3->X3_TIPO    	 ,;                      
			SX3->X3_ARQUIVO  	 ,;                      
			SX3->X3_CONTEXT  	 })

			if Alltrim(SX3->X3_CAMPO) == "ZA8_DATINI" 
				cLablDtIni  :=  AllTrim(X3Titulo())
			Elseif Alltrim(SX3->X3_CAMPO) == "ZA8_DATFIM" 
				cLablDtFim  :=  AllTrim(X3Titulo())
			Endif
		EndIf
		SX3->(DbSkip())
	End  

	if nOpc == 3

		Aadd(aCols,Array(nUsado+1))
		For nI := 1 To nUsado    
			aCols[1][nI] := CriaVar(aHeader[nI][2])
		Next nI
		aCols[1][nUsado+1] := .F.
		aCols[1][1] 	   := '01'

	else

		dbselectarea(cAliasIt) 
		(cAliasIt)->(DbSetOrder(1))

		if (cAliasIt)->(DbSeek(xFilial(cAliasIt)+(cAliasCab)->&(cAliasCab+cChaveRel) ))	

			while !(cAliasIt)->(EOF()) .and. xFilial(cAliasIt)+(cAliasCab)->&(cAliasCab+cChaveRel) == xFilial(cAliasIt)+(cAliasIt)->&(cAliasIt+cChaveRel)

				Aadd(aCols,Array(nUsado+1))
				For nI := 1 To nUsado    
					aCols[LEN(aCols)][nI] := (cAliasIt)->&(aHeader[nI,2])
				Next nI
				aCols[LEN(aCols)][nUsado+1] := .F.

				(cAliasIt)->(DbSkip())
			end
		endif
	endif
	nQtdLinOri := len(aCols) 

return


//Grid - Linha OK
User Function FCTVLIOK(o,nLin)

	local lRet		:= .T.
	local nx  		:= 0
	local nPosDtIni	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZA8_DATINI"})
	local nPosDtFim	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZA8_DATFIM"})
	local nPosForma	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZA8_FORMA"})
	local nPosValFx	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZA8_VALOR"})
	local nPosPerc	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZA8_PERC"})
	default nLin 	:= 0

	if nLin == 0
		nLin := n
	endif

	If !GDdeleted(nLin)

		If lRet
			lRet:=MaCheckCols(aHeader,aCols,nLin)
		EndIf
		If lRet
			If !(lRet := aCols[nLin,nPosDtIni] <= aCols[nLin,nPosDtFim])
				Help(" ",1,"FCTV_PERIODO")
			EndIf
		EndIf 
		If lRet
			if aCols[nLin,nPosForma] == 'V'
				If !(lRet := aCols[nLin,nPosDtIni] == FirstDate(aCols[nLin,nPosDtIni]) .and. aCols[nLin,nPosDtFim] == LastDate(aCols[nLin,nPosDtIni]) )
					Help(" ",1,"FCTV_PERIMES")
				endif
			endif	
		endif
		If lRet
			if aCols[nLin,nPosForma] == 'V'
				if lRet
					If !(lRet := aCols[nLin,nPosValFx] > 0)
						Help(" ",1,"FCTV_VALFX1")
					endif	
				endif	
				if lRet
					If !(lRet := aCols[nLin,nPosPerc] == 0)
						Help(" ",1,"FCTV_VALFX2")
					endif
				endif	
				if lRet
					If nLin > nQtdLinOri .and. M->ZA7_STATUS == 'A' .and. aCols[nLin,nPosForma] == 'V' 
						lRet := .F.
						Help(" ",1,"FCTV_VALFX3")
					endif
				endif	
			else		
				If !(lRet := aCols[nLin,nPosValFx] == 0)
					Help(" ",1,"FCTV_PERCEN1")
				endif	
				if lRet
					If !(lRet := aCols[nLin,nPosPerc] > 0)
						Help(" ",1,"FCTV_PERCEN2")
					endif
				endif		
			endif		
		endif

		private cTempCtr

		if lRet .and. !fValidPeriodo(M->ZA7_CODIGO,M->ZA7_TIPO,M->ZA7_CODCLI,M->ZA7_LOJCLI,M->ZA7_GRPCLI,aCols[nLin,nPosForma],aCols[nLin,nPosDtIni],aCols[nLin,nPosDtFim],M->ZA7_MARCA )

			If (aCols[nLin,nPosForma] == 'V') 
				If !MsgNoYes("O Contrato numero "+cTempCtr+" possui períodos conflitantes a este!"+CRLF+"Deseja gravar este novo contrato?")
					lRet := .F.
				EndIf
			Else
				Help(" ",1,"FCTV_PERCONF")
				lRet := .F.
			EndIf
		endif

		if lRet 
			For nx:=1 to Len(aCols)
				if !GDdeleted(nx) .and. nx <> nLin 
					if lRet .and. ;
					( ; 
					( aCols[nLin,nPosDtIni] >= aCols[nx,nPosDtIni] .and. aCols[nLin,nPosDtIni] <= aCols[nx,nPosDtFim] .and. aCols[nLin,nPosForma] == aCols[nx,nPosForma] );
					.or.;
					( aCols[nLin,nPosDtFim] >= aCols[nx,nPosDtIni] .and. aCols[nLin,nPosDtFim] <= aCols[nx,nPosDtFim] .and. aCols[nLin,nPosForma] == aCols[nx,nPosForma] );
					.or.;
					( aCols[nLin,nPosDtIni] < aCols[nx,nPosDtIni] .and. aCols[nLin,nPosDtFim] > aCols[nx,nPosDtFim] .and. aCols[nLin,nPosForma] == aCols[nx,nPosForma] );  
					)
						Help(" ",1,"FCTV_CONFLIT")
						lRet := .F.
						Exit
					endif
				endif	
			Next nx
		endif	
	endif	
Return lRet


//Grid - Tudo OK
User Function FCTVTDOK(o)
	local nx   := 0
	local lRet := .T.

	/*For nx:=1 to Len(aCols)
	if !GDdeleted(nx)
	lRet := U_FCTVLIOK(o,nx)
	if !lRet
	Exit
	endif 
	endif	
	Next nx*/

Return lRet


//Rotina - Tudo OK
Static Function fTudoOK(nOpc)

	local lRet      := .T.
	local nPosDtIni	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZA8_DATINI"})
	local nPosDtFim	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZA8_DATFIM"})

	lRet :=  Obrigatorio(aGets,aTela)
	if lRet
		lRet := oGetDados:TudoOk()
	endif	

	if lRet .and. M->ZA7_TIPO == '1'
		if lRet
			if !(lRet := !Empty(M->ZA7_CODCLI))
				Help(" ",1,"FCTV_CLIVAZIO")
			endif
		endif
		if lRet
			if !(lRet := !Empty(M->ZA7_LOJCLI))
				Help(" ",1,"FCTV_LOJVAZIO")
			endif
		endif
		if lRet
			dbselectarea('SA1')
			SA1->(dbsetorder(1))
			if SA1->(dbseek(xfilial('SA1')+PADR(alltrim(M->ZA7_CODCLI),TamSX3("A1_COD")[1])+PADR(alltrim(M->ZA7_LOJCLI),TamSX3("A1_LOJA")[1])))
				if !(lRet := !empty(SA1->A1_YCTAPRE)) 
					Help(" ",1,"FCTV_CLIPREV")
				endif
			else
				lRet := .F.
				Help(" ",1,"FCTV_CLIPREV")
			endif
		endif
	endif

	if lRet .and. M->ZA7_TIPO == '2'
		if lRet
			if !(lRet := !Empty(M->ZA7_GRPCLI))
				Help(" ",1,"FCTV_GRPVAZIO")
			endif
		endif
		if lRet
			dbselectarea('ACY')
			ACY->(dbsetorder(1))
			if ACY->(dbseek( xfilial('ACY')+PADR(alltrim(M->ZA7_GRPCLI),TamSX3("ACY_GRPVEN")[1]) ))
				if !(lRet := !empty(ACY->ACY_YCTPRE)) 
					Help(" ",1,"FCTV_GRPPREV")
				endif
			else
				lRet := .F.
				Help(" ",1,"FCTV_GRPPREV")
			endif
		endif
	endif
return lRet


//Aprovacao
Static Function fAprova()
	local aLanc 	:= {}
	local cContaC 	:= ''
	local cContaD 	:= '31401020'                                                                                                                                                                                                                                                                                                    
	local lContinua := .T.
	local lValorFx	:= .F.
	local dData		:= Date()
	local cLote		:= '008810'
	local cSubLote	:= '001'
	local cLinha	:= '001'
	local nValor	:= 0
	local cHist		:= ''
	local cOrigem   := ''
	local cCCD		:= "2000"   
	local cCCC		:= ""  
	local cClasVDB	:= (cAliasCab)->ZA7_CLVLD
	local cClasVCD	:= ''
	local nx		:= 0    
	local cDc		:= '3'    
	local cKey		:= ''    
	local cItemC	:= 'I0202'                                                                                                                                                                                              
	local cItemD	:= 'I0202'
	local cCliAiD	:= ""
	local cCliAiC	:= ""
	local nTotReg  := len(aCols)  
	local nContReg := 0 
	local cAliasTmp
	Local cSQL

	ProcRegua(0)

	If !U_VALOPER("CV1",.F.) 
		MsgSTOP("Usuário sem permissão para aprovar Contratos de Verbas!!!", "OP CV1")
	else
		if MsgYesNo("Confirma a aprovação deste contrato?")

			dbselectarea('ACY')
			ACY->(dbsetorder(1))

			dbselectarea('SA1')
			SA1->(dbsetorder(1))

			if (cAliasCab)->ZA7_TIPO == '1'
				if SA1->(dbseek(xfilial('SA1')+PADR(alltrim(M->ZA7_CODCLI),TamSX3("A1_COD")[1])+PADR(alltrim(M->ZA7_LOJCLI),TamSX3("A1_LOJA")[1])))
					cContaC := SA1->A1_YCTAPRE
					cCliAiD := SA1->A1_COD
				endif
			else
				if ACY->(dbseek( xfilial('ACY')+PADR(alltrim(M->ZA7_GRPCLI),TamSX3("ACY_GRPVEN")[1]) ))
					cContaC := ACY->ACY_YCTPRE

					//buscar cliente com maior faturamento do Grupo para gerar LP					
					cAliasTmp := GetNextAlias()
					cSQL := "select dbo.FNC_AO_TOP_CLI('"+M->ZA7_MARCA+"','"+M->ZA7_GRPCLI+"','"+DTOS(dDataBase-360)+"','"+DTOS(dDataBase)+"','2')"
					TCQuery cSQL Alias (cAliasTmp) New

					(cAliasTmp)->(DbGoTop())
					If !(cAliasTmp)->(Eof())						
						_cliloja := &("(cAliasTmp)->"+(cAliasTmp)->(Field(1)))									
						cCliAiD := SubStr(_cliloja,1,6)					
					EndIf
					(cAliasTmp)->(DbCloseArea())					

				endif
			endif			

			dbselectarea(cAliasIt) 
			(cAliasIt)->(DbSetOrder(1))

			if (cAliasIt)->(DbSeek(xFilial(cAliasIt)+(cAliasCab)->&(cAliasCab+cChaveRel) ))	

				ProcRegua(nTotReg+1)
				while lContinua .and. !(cAliasIt)->(EOF()) .and. xFilial(cAliasIt)+(cAliasCab)->&(cAliasCab+cChaveRel) == xFilial(cAliasIt)+(cAliasIt)->&(cAliasIt+cChaveRel)

					if lContinua .and. (cAliasIt)->ZA8_DATFIM < Date()
						lContinua := .F.
						Help(" ",1,"FCTV_APRVENC")
					endif

					if (cAliasIt)->ZA8_FORMA == 'V' .and. lContinua	

						lValorFx := .T.

						if empty(cContaC) .and. lContinua
							lContinua := .F.
							if (cAliasCab)->ZA7_TIPO == '1'
								Help(" ",1,"FCTV_CLIPREV")
							else
								Help(" ",1,"FCTV_GRPPREV")
							endif
						endif	

						dData   := (cAliasIt)->ZA8_DATINI
						nValor  := (cAliasIt)->ZA8_VALOR
						cHist   := "PREVISAO VERBA CONTRATO No.: "+(cAliasCab)->&(cAliasCab+cChaveRel)+"/"+(cAliasIt)->ZA8_ITEM                                                                                                                                                                                                                                                               
						cOrigem := "CTV-"+(cAliasCab)->&(cAliasCab+cChaveRel)+"/"+(cAliasIt)->ZA8_ITEM 
						cKey	:= "CTV-"+(cAliasCab)->ZA7_FILIAL+(cAliasCab)->&(cAliasCab+cChaveRel)+"/"+(cAliasIt)->ZA8_ITEM 

						if lContinua	
							AADD(aLanc,{.F.,3,dData,cLote,cSubLote,nValor,cLinha,cHist,cContaD,cContaC,cOrigem,cCCD,cCCC,cDc,cClasVDB,cClasVCD,cKey,cItemD,cItemC,cCliAiD,cCliAiC})
						endif

					endif

					nContReg++
					IncProc("Processando Aprovação - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")	

					(cAliasIt)->(DbSkip())
				end
			endif

			if lContinua

				for nx:= 1 to len(aLanc) 
					aLanc[nx,1] :=  fGeraLanc(aLanc[nx,2], aLanc[nx,3], aLanc[nx,4], aLanc[nx,5], aLanc[nx,6], aLanc[nx,7], aLanc[nx,8],aLanc[nx,9],aLanc[nx,10],aLanc[nx,11],aLanc[nx,12],aLanc[nx,13],aLanc[nx,14],aLanc[nx,15],aLanc[nx,16],aLanc[nx,17],aLanc[nx,18],aLanc[nx,19],aLanc[nx,20],aLanc[nx,21])
					lContinua := aLanc[nx,1]
					if !lContinua
						exit
					endif				
				next nx

				if lContinua
					(cAliasCab)->(RecLock(cAliasCab,.F.))   
					(cAliasCab)->ZA7_APROV  := cUserName	
					(cAliasCab)->ZA7_DATAPR	:= Date()	
					(cAliasCab)->ZA7_HORAPR	:= Time()	
					(cAliasCab)->ZA7_STATUS := 'A'
					(cAliasCab)->(MsUnlock())   
				endif	

				nContReg++
				IncProc("Processando Aprovação - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")	

			endif
		endif
	endif
return


//chamada na validacao do campo ZA7_TIPO
User Function FCTVALID()
	local lRet := .T.
	if M->ZA7_TIPO=='1'
		M->ZA7_GRPCLI := space(TamSX3("ZA7_GRPCLI")[1])
		M->ZA7_NOMGRP := space(TamSX3("ZA7_NOMGRP")[1])
	else	
		M->ZA7_CODCLI := space(TamSX3("ZA7_CODCLI")[1])
		M->ZA7_LOJCLI := space(TamSX3("ZA7_LOJCLI")[1])
		M->ZA7_NOMCLI := space(TamSX3("ZA7_NOMCLI")[1])	
	endif
Return lRet


//valida edicao dos campos do grid
User Function FCTVFLOK()

	Local lRet      := .T.
	Local cMenVar   := ReadVar()
	Local nPosForma	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZA8_FORMA"})
	Local nPDATINI	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZA8_DATINI"})


	if ALTERA .and. M->ZA7_STATUS == 'A' .and. n <= nQtdLinOri
		if aCols[n,nPosForma]  == 'V'
			if lRet .and. !("ZA8_MSBLQL" $ cMenVar)
				lRet  := .F.
				Help(" ",1,"FCTV_EDITVF")
			endif
		else

			if lRet .and. !("ZA8_MSBLQL" $ cMenVar) .and. !("ZA8_DATFIM" $ cMenVar) .and. n <= nQtdLinOri

				If ("ZA8_PERC" $ cMenVar  .And. aCols[n, nPDATINI] <= Date() .Or. n <> nQtdLinOri)
					lRet  := .F.
					Help(" ",1,"FCTV_EDIT")
				EndIf

			endif
			if lRet .and. "ZA8_DATFIM" $ cMenVar
				if !(lRet := &(ReadVar()) >= Date()) 
					Help(" ",1,"FCTV_DATFIM")
				endif
			endif
		endif
	endif
	if lRet .and. "ZA8_DATINI" $ cMenVar
		if !(lRet := !(AnoMes(&(ReadVar())) < AnoMes(Date()))) 
			Help(" ",1,"FCTV_DATINI")
		endif	
	endif
Return lRet


//valida se a linha pode ser deletada
User Function FCTVTDEL()
	Local lRet      := .T.
	Local nPDATINI	:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZA8_DATINI"})

	If ALTERA .and. n <= nQtdLinOri .and. M->ZA7_STATUS == 'A' 
		lRet  := .F.
	EndIf

	If (ALTERA .And. aCols[n, nPDATINI] >= Date())
		Return lRet  := .T.
	EndIf

Return lRet


User Function FCTVSDEL()
Return .T. 


//Validação da Matricula  
Static Function fValidPeriodo(cContrato,cTipo,cCliente,cLoja,cGrupo,cForma,dDtIni,dDtFim,cMarca)
	local aArea     := GetArea()               
	local lRet      := .T. 
	local cTabTemp  := GetNextAlias() 
	local cQuery    := ''  
	local cMens     := ''
	local nc	    := 0	
	local lContinua := .T.
	local aHlpP  	:= {}
	default cTipo	:= ''

	if cTipo == '1' 
		if empty(cCliente) .or. empty(cLoja) .or. empty(cForma)
			lContinua := .F.
		endif
	elseif cTipo == '2' 
		if empty(cGrupo) .or. empty(cForma)
			lContinua := .F.
		endif
	else
		lContinua := .F.
	endif

	if lContinua
		cQuery := " SELECT TOP 1 ZA8.* "+ CRLF 
		cQuery += " FROM "+RetSQLName("ZA8")+" ZA8 ( NOLOCK ) "+ CRLF 
		cQuery += " JOIN "+RetSQLName("ZA7")+" ZA7 ( NOLOCK ) "+ CRLF 
		cQuery += "  ON ZA7.D_E_L_E_T_ <> '*' "+ CRLF  
		cQuery += "  AND ZA7.ZA7_FILIAL = ZA8.ZA8_FILIAL "+ CRLF
		cQuery += "  AND ZA7.ZA7_CODIGO = ZA8.ZA8_CODIGO "+ CRLF
		if cTipo == '1'
			cQuery += "  AND ZA7.ZA7_CODCLI = '"+cCliente+"' "+ CRLF
			cQuery += "  AND ZA7.ZA7_LOJCLI = '"+cLoja+"' "+ CRLF
		else
			cQuery += "  AND ZA7.ZA7_GRPCLI = '"+cGrupo+"' "+ CRLF
		endif	
		cQuery += "  AND ZA7.ZA7_MARCA = '"+Alltrim(cMarca)+"' "+ CRLF
		cQuery += " WHERE ZA8.D_E_L_E_T_ = '' "+ CRLF 
		cQuery += "  AND ZA8.ZA8_FILIAL = '"+xFilial('ZA8')+"' "+ CRLF
		cQuery += "  AND ZA8.ZA8_CODIGO <> '"+cContrato+"' "+ CRLF 
		cQuery += "  AND ZA8.ZA8_FORMA = '"+cForma+"' "+ CRLF	
		cQuery += "  AND ( "+ CRLF 	 
		cQuery += "       ( '"+DTOS(dDtIni)+"' >= ZA8.ZA8_DATINI AND '"+DTOS(dDtIni)+"' <= ZA8.ZA8_DATFIM ) "+ CRLF 	   
		cQuery += "        OR "+ CRLF 		
		cQuery += "   	   ( '"+DTOS(dDtFim)+"' >= ZA8.ZA8_DATINI AND '"+DTOS(dDtFim)+"' <= ZA8.ZA8_DATFIM ) "+ CRLF 	 
		cQuery += "        OR "+ CRLF 		
		cQuery += "   	   ( '"+DTOS(dDtIni)+"' < ZA8.ZA8_DATINI AND '"+DTOS(dDtFim)+"' > ZA8.ZA8_DATFIM ) "+ CRLF 	 
		cQuery += "      ) "+ CRLF 	 
		cQuery += " ORDER BY ZA8.ZA8_CODIGO "+ CRLF 
		TcQuery cQuery Alias (cTabTemp) New
		if (cTabTemp)->(!EOF()) 

			cTempCtr := (cTabTemp)->ZA8_CODIGO
			lRet := .F.

			aHlpP  := {}
			aAdd(aHlpP, "Contrato Invalido!")
			aAdd(aHlpP, "O Contrato numero "+cTempCtr+" possui ")
			aAdd(aHlpP, "períodos conflitantes a este!")
			PutHelp("PFCTV_PERCONF", aHlpP, aHlpP, aHlpP, .T.)
			aHlpP  := {}
			aAdd (aHlpP, "Informe um período valido! " )
			PutHelp("SFCTV_PERCONF", aHlpP, aHlpP, aHlpP, .T.)    	
		endif
	endif

	RestArea(aArea)
return lRet


// Atualiza registros
Static Function fUpdateReg(nOpc)     

	Local lLock	 := .T.   
	local lGrvIt := .F.
	local ny	 := 0   
	local nx	 := 0
	Local aArea	 := GetArea()

	BEGIN TRANSACTION

		if nOpc == 3 
			lLock := .T.
		else
			lLock := .F.   
		endif	

		//Atualiza cabeçalho
		(cAliasCab)->(RecLock(cAliasCab,lLock))   
		if nOpc == 5
			(cAliasCab)->(DbDelete())
		else
			for ny:=1 to Len(aCamposCab) 
				(cAliasCab)->&(aCamposCab[ny]) := M->&(aCamposCab[ny]) 
			next ny      
			if nOpc == 3 	  
				(cAliasCab)->&(cAliasCab+'_FILIAL') := xFilial(cAliasCab)  
			endif	
			(cAliasCab)->ZA7_USUINC := cUserName	
			(cAliasCab)->ZA7_DATA 	:= Date()	
			(cAliasCab)->ZA7_HORA 	:= Time()	
		endif		
		(cAliasCab)->(MsUnlock())   

		dbselectarea(cAliasIt) 
		(cAliasIt)->(DbSetOrder(1))

		for ny:=1 to Len(aCols) 
			if !aCols[ny,len(aCols[ny])]

				if nOpc == 3 
					lGrvIt := .T.
					lLock  := .T.
				else
					if (cAliasIt)->(DbSeek(xFilial(cAliasIt)+M->&(cAliasCab+cChaveRel)+aCols[ny,aScan(aHeader,{|x| Alltrim(x[2])==Alltrim(cCampoIT)})] ))	
						lGrvIt := .T.
						lLock  := .F.				
					elseif nOpc == 4
						lGrvIt := .T.	
						lLock  := .T.
					endif
				endif

				if lGrvIt 
					(cAliasIt)->(RecLock(cAliasIt,lLock))  
					if nOpc == 5
						(cAliasIt)->(DbDelete())
					else
						(cAliasIt)->&(cAliasIt+'_FILIAL') := xFilial(cAliasIt)
						(cAliasIt)->&(cAliasIt+cChaveRel) := (cAliasCab)->&(cAliasCab+cChaveRel)
						for nx := 1 to Len(aHeader)
							(cAliasIt)->&(aHeader[nx,2]) := aCols[ny,nx]
						next nx			
					endif				
					(cAliasIt)->(MsUnlock())   
				endif	
			elseif nOpc == 4 .or. nOpc == 5
				if (cAliasIt)->(DbSeek(xFilial(cAliasIt)+M->&(cAliasCab+cChaveRel)+aCols[ny,aScan(aHeader,{|x| Alltrim(x[2])==Alltrim(cCampoIT)})] ))	
					(cAliasIt)->(RecLock(cAliasIt,.F.))  
					(cAliasIt)->(DbDelete())
					(cAliasIt)->(MsUnlock())  
				endif
			endif
		next ny

	END TRANSACTION  

	RestArea(aArea)
return .T.


//Gera Pré-Lançamento
Static Function fGeraLanc(_nOPC, _dData, _cLote, _cSbLote, _nValor, _cLinha, _cHist,_cDebito,_cCredito,_cLanOri,_cCCusD,_cCCusC,_cDc,_cClasVDB,_cClasVCD,_cKey,_cItemD,_cItemC,_cCliAiD,_cCliAIC)
	Local aArea    			:= GetArea()
	Local aCab     			:= {}
	Local aTotItem 			:= {}  
	Local lRet	   			:= .T.	
	Local cDoc  			:= "" 
	Local CTF_LOCK			:= 0
	Local aErro				:= {}
	Local cMens				:= ""
	local lRpc  			:= Type("oMainWnd") = "U"
	local cRetCta			:= ""   
	Local nX				:= 0 
	Local aRecSX7			:= {}
	Local lExist			:= .T.
	Private	lMsErroAuto 	:= .F.            
	Private lMSHelpAuto 	:= .F.
	Private lAutoErrNoFile  := .T.  
	default _cCCusD			:= ""
	default _cCCusC			:= ""
	default _cClasVDB		:= ""
	default _cClasVCD		:= ""
	default _cKey			:= ""
	default _cItemD			:= ""
	default _cItemC			:= ""

	if _nOPC == 3      

		ProxDoc( _dData, Padr(Alltrim(_cLote),TamSx3("CT2_LOTE")[1]), Padr(Alltrim(_cSbLote),TamSx3("CT2_SBLOTE")[1]), @cDoc, @CTF_LOCK)

		dbselectarea("CT2") 
		aCab := { 	{"DDATALANC"  ,_dData											,.F.},;
		{"CLOTE"	  ,Padr(Alltrim(_cLote),TamSx3("CT2_LOTE")[1])		,.F.},;
		{"CSUBLOTE"	  ,Padr(Alltrim(_cSbLote),TamSx3("CT2_SBLOTE")[1])	,.F.},;
		{"CDOC"       ,Padr(Alltrim(cDoc),TamSx3("CT2_DOC")[1])  		,.F.},;        
		{"CPADRAO"    ,'' 												,.F.},;
		{"NTOTINF"    ,0 												,.F.},;
		{"NTOTINFLOT" ,0 												,.F.} }  	            

		AADD(aTotItem,{	{"CT2_FILIAL"	,xFilial("CT2")									 , .F.},;
		{"CT2_LINHA"	,_cLinha										 , .F.},;
		{'CT2_MOEDLC'   ,'01'   										 , .F.},; 
		{"CT2_DC"		,_cDc											 , .F.},;
		{"CT2_DEBITO"	,Padr(Alltrim(_cDebito),TamSx3("CT2_DEBITO")[1]) , .F.},;
		{"CT2_CREDIT"	,Padr(Alltrim(_cCredito),TamSx3("CT2_CREDIT")[1]), .F.},;
		{"CT2_VALOR"	,_nValor										 , .F.},;
		{"CT2_ORIGEM"	,_cLanOri										 , .F.},;
		{"CT2_KEY"		,_cKey											 , .F.},;
		{"CT2_HIST"		,_cHist       									 , .F.},;
		{"CT2_TPSALD"	,"1" 											 , .F.},;
		{"CT2_CLVLDB"	,_cClasVDB										 , .F.},;
		{"CT2_CLVLCR"	,_cClasVCD										 , .F.},; 
		{"CT2_CCD"      ,_cCCusD										 , .F.},;  
		{"CT2_CCC"      ,_cCCusC										 , .F.},;  
		{"CT2_ITEMD"    ,_cItemD										 , .F.},;  
		{"CT2_ITEMC"    ,_cItemC										 , .F.},;
		{"CT2_ATIVDE"   ,_cCliAiD										 , .F.},;
		{"CT2_ATIVCR"   ,_cCliAiC										 , .F.};  
		} )
	endif

	dbSelectArea("SX7")
	SX7->(dbSetOrder(1))
	if SX7->(dbSeek("CT2_DC")) 
		aAdd(aRecSX7, SX7->(Recno()))
		SX7->(Reclock("SX7",.F.))
		SX7->(DbDelete())
		SX7->(MsUnlock())
	endif	
	dbSelectArea("SX7")
	SX7->(dbSetOrder(1))
	if SX7->(dbSeek("CT2_CLVLCR")) 
		aAdd(aRecSX7, SX7->(Recno()))
		SX7->(Reclock("SX7",.F.))
		SX7->(DbDelete())
		SX7->(MsUnlock())
	endif	
	dbSelectArea("SX7")
	SX7->(dbSetOrder(1))
	if SX7->(dbSeek("CT2_CLVLDB")) 
		aAdd(aRecSX7, SX7->(Recno()))
		SX7->(Reclock("SX7",.F.))
		SX7->(DbDelete())
		SX7->(MsUnlock())
	endif	

	lMsErroAuto := .F. 
	BEGIN TRANSACTION  
		MSExecAuto({|x,y,Z| Ctba102(x,y,Z)},aCab,aTotItem,_nOPC) 
		If lMsErroAuto 
			aErro := GetAutoGRLog()
			For nX := 1 To Len(aErro)
				cMens += aErro[nX]+CRLF
			Next nX     
			DisarmTransaction()
			lRet := .F.  
			if lRpc
				conout(cMens)
			else
				MsgStop(cMens,"Geração de Lançamento")
			endif	
		Else 
			MsUnlockAll() 
		endif  
	END TRANSACTION


	if _nOPC == 3
		ConfirmSX8() 
	endif	

	For nX := 1 TO Len(aRecSX7)
		SX7->(dbGoto(aRecSX7[nX]))
		SX7->(Reclock("SX7",.F.))
		SX7->(DbRecall())
		SX7->(MsUnlock())
	Next nX	

	If CTF_LOCK > 0	// LIBERA O REGISTRO NO CTF COM A NUMERCAO DO DOC FINAL
		dbSelectArea("CTF")
		dbGoTo(CTF_LOCK)
		CtbDestrava( _dData, Padr(Alltrim(_cLote),TamSx3("CT2_LOTE")[1]), Padr(Alltrim(_cSbLote),TamSx3("CT2_SBLOTE")[1]), cDoc, @CTF_LOCK)			
	Endif

	RestArea(aArea)
Return lRet            


//Help customizado
Static Function fAjustaHelp()

	aHlpP  := {}
	aAdd(aHlpP, "Período Invalido!")
	aAdd(aHlpP, "Campos: "+cLablDtIni+" e "+cLablDtFim )
	PutHelp("PFCTV_PERIODO", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "A data informada no campo "+cLablDtIni )
	aAdd (aHlpP, "deve ser menor ou igual que a do campo "+cLablDtFim+" !")
	PutHelp("SFCTV_PERIODO", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Período Invalido!")
	aAdd(aHlpP, "Campos: "+cLablDtIni+" e "+cLablDtFim )
	PutHelp("PFCTV_PERIMES", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Para forma de calculo do tipo valor " )
	aAdd (aHlpP, "fixo o período deve ser mensal!")
	PutHelp("SFCTV_PERIMES", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Cliente não informado!")
	PutHelp("PFCTV_CLIVAZIO", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Informe um cliente que possua conta " )
	aAdd (aHlpP, "contábil de previsão preenchida!" )
	PutHelp("SFCTV_CLIVAZIO", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Loja do Cliente não informada!")
	PutHelp("PFCTV_LOJVAZIO", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Informe a Loja do Cliente!" )
	PutHelp("SFCTV_LOJVAZIO", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Cliente Invalido!")
	PutHelp("PFCTV_CLIPREV", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Informe um cliente que possua conta " )
	aAdd (aHlpP, "contábil de previsão preenchida!" )
	PutHelp("SFCTV_CLIPREV", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Grupo de cliente não informado!")
	PutHelp("PFCTV_GRPVAZIO", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Informe um grupo de cliente que possua " )
	aAdd (aHlpP, "conta contábil de previsão preenchida!" )
	PutHelp("SFCTV_GRPVAZIO", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Grupo de Cliente Invalido!")
	PutHelp("PFCTV_GRPPREV", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Informe um grupo de cliente que possua " )
	aAdd (aHlpP, "conta contábil de previsão preenchida!" )
	PutHelp("SFCTV_GRPPREV", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Este campo não pode ser alterado pois ")
	aAdd(aHlpP, "o contrato já foi aprovado!")
	PutHelp("PFCTV_EDIT", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Bloqueie este item e inclua um novo! " )
	PutHelp("SFCTV_EDIT", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Valor Fixo Invalido! ")
	PutHelp("PFCTV_VALFX1", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Para forma de calculo do tipo valor" )
	aAdd (aHlpP, "fixo, o campo Valor Fixo deve ser ")
	aAdd (aHlpP, "maior que zero!")
	PutHelp("SFCTV_VALFX1", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Percentual Invalido! ")
	PutHelp("PFCTV_VALFX2", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Para forma de calculo do tipo valor" )
	aAdd (aHlpP, "fixo, o campo Percentual deve ser")
	aAdd (aHlpP, "igual a zero!")
	PutHelp("SFCTV_VALFX2", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Valor Fixo Invalido! ")
	PutHelp("PFCTV_PERCEN1", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Para forma de calculo do tipo" )
	aAdd (aHlpP, "Percentual, o campo Valor Fixo deve")
	aAdd (aHlpP, "ser igual a zero!")
	PutHelp("SFCTV_PERCEN1", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Percentual Invalido! ")
	PutHelp("PFCTV_PERCEN2", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Para forma de calculo do tipo" )
	aAdd (aHlpP, "Percentual, o campo Percentual deve")
	aAdd (aHlpP, "ser maior que zero!")
	PutHelp("SFCTV_PERCEN2", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Período Invalido! ")
	aAdd(aHlpP, "Existem períodos conflitantes! ")
	PutHelp("PFCTV_CONFLIT", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Altere os períodos conflitantes!" )
	PutHelp("SFCTV_CONFLIT", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Data Final Invalida! ")
	PutHelp("PFCTV_DATFIM", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Para contratos aprovados, a data")
	aAdd (aHlpP, "informada na alteração deve ser maior")
	aAdd (aHlpP, "que a data do dia!" )
	PutHelp("SFCTV_DATFIM", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Data Inicial Invalida! ")
	aAdd(aHlpP, "A data inicial não pode conter meses ")
	aAdd(aHlpP, "Vencidos! ")
	PutHelp("PFCTV_DATINI", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Favor Informar uma data valida!")
	PutHelp("SFCTV_DATINI", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Este campo não pode ser alterado, pois ")
	aAdd(aHlpP, "o item é de valor Fixo e o contrato já ")
	aAdd(aHlpP, "foi aprovado!")
	PutHelp("PFCTV_EDITVF", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Inclua um novo contrato! " )
	PutHelp("SFCTV_EDITVF", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Item Invalido! ")
	aAdd(aHlpP, "Não é permitido a inclusão de um novo ")
	aAdd(aHlpP, "item do tipo valor fixo, para contratos ")
	aAdd(aHlpP, "aprovados!  ")
	PutHelp("PFCTV_VALFX3", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Inclua um novo contrato! " )
	PutHelp("SFCTV_VALFX3", aHlpP, aHlpP, aHlpP, .T.)

	aHlpP  := {}
	aAdd(aHlpP, "Aprovação não permitida! ")
	aAdd(aHlpP, "Este contrato possui períodos vencidos!")
	PutHelp("PFCTV_APRVENC", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd (aHlpP, "Corrija o período e tente novamente! " )
	PutHelp("SFCTV_APRVENC", aHlpP, aHlpP, aHlpP, .T.)

return

/*/{Protheus.doc} IZA7ULTV
@description Inicializador padrao para o campo ZA7_ULTVIG
@author Fernando Rocha
@since 08/02/2018
@version 1.0
@type function
/*/
User Function IZA7ULTV()

	Local cTmpAlias
	Local dUltVig

	cTmpAlias := GetNextAlias()
	BeginSql Alias cTmpAlias
		select ZA8_DATFIM = MAX(ZA8_DATFIM) from %Table:ZA8% where ZA8_FILIAL = %Exp:ZA7->ZA7_FILIAL% and ZA8_CODIGO = %Exp:ZA7->ZA7_CODIGO% and D_E_L_E_T_=''
	EndSql

	If !(cTmpAlias)->(Eof())
		dUltVig := STOD((cTmpAlias)->ZA8_DATFIM)
	Else
		dUltVig := CTOD(" ")
	EndIf

Return(dUltVig)