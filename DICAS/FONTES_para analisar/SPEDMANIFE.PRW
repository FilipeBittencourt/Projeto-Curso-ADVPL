#INCLUDE "PROTHEUS.CH"  
#INCLUDE "SPEDNFE.CH"                                                                                          
#INCLUDE "APWIZARD.CH"

Static cVersaoTSS := IIf( UsaColaboracao("4"), "", StrTran(getVersaoTSS(),".","" ))

//-----------------------------------------------------------------------
/*/{Protheus.doc} SPEDMANIFE
Função principal

@author Natalia Sartori
@since 04.07.2012
@version 1.00

/*/
//-----------------------------------------------------------------------
Function SPEDMANIFE()               

Local aArea     := GetArea()

Local lRetorno  := .T.

Local nVezes    := 0

PRIVATE lBtnFiltro:= .F.

While lRetorno
	lBtnFiltro:= .F.
    lRetorno	:= FiltroManif(nVezes==0)
    nVezes++
    If !lBtnFiltro
    	Exit
    EndIf
EndDo
RestArea(aArea)
Return Nil
//-----------------------------------------------------------------------
/*/{Protheus.doc} FiltroManif
Função de montagem das perguntas e condição para efeturar o filtro

@author Natalia Sartori
@since 04.07.2012
@version 1.00
/*/
//-----------------------------------------------------------------------
Static Function FiltroManif(lInit,cAlias)
Local lOk		:= .F.
Local aPerg		:={}
Local aStatus	:={}
Local aMes		:={} 
Local aFiltro	:= {}
Local aParam	:={"","","","","","","","",""}  

Local cMes		:= ""
Local cFilMani	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"FILTMANIFEST"

Local lEvento	:= .F.
Local lEntAtiva	:= .T.  
Local lPeFil	:= ExistBlock("MDeFil") 
Local aPeFil	:= {}

Local nCombo7	:= 0
Local nCombo9	:= 0
Local nMiliseg:= 4000
Private aRotina		:= {}
Private aFilBrw		:= {}
Private cCadastro	:= "Manifestação do Destinatário"  
Private cMarca		:= GetMark() 

Private bFiltraBrw

Private cCondicao   := ""
Private cCondQry    := ""
Private lUsaColab		:= UsaColaboracao("4")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Manifestação destinatário TC2.0                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lUsaColab
		cCadastro+= " - TOTVS Colaboração 2.0"
	EndIf
aRotina := MarkBr()

aadd(aStatus,"0 - "+STR0414)//"Sem manifestação"
aadd(aStatus,"1 - "+STR0415)//"Confirmada"
aadd(aStatus,"2 - "+STR0416)//"Desconhecida"
aadd(aStatus,"3 - "+STR0417)//"Não realizada"
aadd(aStatus,"4 - "+STR0418)//"Ciência"
aadd(aStatus,"5 - Todas")
aadd(aStatus,"6 - Em processamento")
                         
aadd(aMes,"1 - Janeiro")
aadd(aMes,"2 - Fevereiro")
aadd(aMes,"3 - Março")
aadd(aMes,"4 - Abril")
aadd(aMes,"5 - Maio")
aadd(aMes,"6 - Junho")
aadd(aMes,"7 - Julho")
aadd(aMes,"8 - Agosto")
aadd(aMes,"9 - Setembro")
aadd(aMes,"10 - Outubro")
aadd(aMes,"11 - Novembro")
aadd(aMes,"12 - Dezembro")
aadd(aMes,"             ")

SX2->(DBSETORDER(1))
If SX2->(DBSEEK("C00"))
        
	MV_PAR01 := aParam[01] := PadR(ParamLoad(cFilMani,aPerg,1,aParam[01]),Len(C00->C00_CNPJEM))
	MV_PAR02 := aParam[02] := PadR(ParamLoad(cFilMani,aPerg,2,aParam[02]),Len(C00->C00_CNPJEM))
	MV_PAR03 := aParam[03] := PadR(ParamLoad(cFilMani,aPerg,3,aParam[03]),Len(C00->C00_SERNFE))
	MV_PAR04 := aParam[04] := PadR(ParamLoad(cFilMani,aPerg,4,aParam[04]),Len(C00->C00_SERNFE))
	MV_PAR05 := aParam[05] := PadR(ParamLoad(cFilMani,aPerg,5,aParam[05]),Len(C00->C00_NUMNFE))
	MV_PAR06 := aParam[06] := PadR(ParamLoad(cFilMani,aPerg,6,aParam[06]),Len(C00->C00_NUMNFE))
	MV_PAR07 := aParam[07] := PadR(ParamLoad(cFilMani,aPerg,7,aParam[07]),13)
	MV_PAR08 := aParam[08] := PadR(ParamLoad(cFilMani,aPerg,8,aParam[08]),Len(C00->C00_ANONFE))
	MV_PAR09 := aParam[09] := PadR(ParamLoad(cFilMani,aPerg,9,aParam[09]),36)
	nCombo7	 := Iif(aScan(aMes,{|x| x == AllTrim(aParam[07])}) > 0,aScan(aMes,{|x| x == Alltrim(aParam[07]) }),13)
	nCombo9	 := Iif(aScan(aStatus,{|x| x == Alltrim(aParam[09]) }) > 0,aScan(aStatus,{|x| x == AllTrim(aParam[09]) }),6)
	
	aadd(aPerg,{1,STR0423,aParam[01],'@R 99.999.999/9999-99',"ValidAPerg('Cnpj')",,'Empty(MV_PAR02)',55,.F.})//"Cnpj"
	aadd(aPerg,{1,STR0424,aParam[02],'@R 999.999.999-99',"ValidAPerg('Cpf')",,'Empty(MV_PAR01)',55,.F.})//"Cpf"
	aadd(aPerg,{1,STR0229,aParam[03],,,,,30,.F.})//"Serie de"
	aadd(aPerg,{1,STR0230,aParam[04],,,,,30,.F.})//"Serie Até"
	aadd(aPerg,{1,STR0227,aParam[05],,,,,55,.F.})//"Nota de"
	aadd(aPerg,{1,STR0228,aParam[06],,,,,55,.F.})//"Nota Ate"
	aadd(aPerg,{2,STR0425,aParam[07],aMes,105,".T.",.F.,".T."}) //Mês
	aadd(aPerg,{1,STR0426,aParam[08],,"ValidAPerg('Ano')",,,55,.F.})//"Ano"
	aadd(aPerg,{2,STR0427,aParam[09],aStatus,105,".T.",.F.,".T."})//Status
	
    
	//Verifica se o serviço foi configurado - Somente o Adm pode configurar 
	If lInit .And. !lUsaColab
		If (!ReadyTss() .Or. !ReadyTss(,2))
			If PswAdmin( /*cUser*/, /*cPsw*/,RetCodUsr()) == 0
				SpedNFeCFG()
			Else
				HelProg(,"FISTRFNFe")
			EndIf
		EndIf
		lEntAtiva := EntAtivTss()		
	EndIf
	If lUsaColab .Or. ( lEntAtiva .And. (!lInit .Or. ReadyTSS()) )
				
		/*FILIAL SEMPRE FILTRA, INDEPENDENTE DO PE OU NAO*/
		cCondicao	:= "C00_FILIAL=='"+xFilial("C00")+"' "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada para customizar o filtro da C00³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lPeFil
			aPeFil		:=  ExecBlock("MDeFil",.F.,.F.)
			cCondicao	+= aPeFil[1]
			cCondQry	+= aPeFil[2]
			lOk			:= .T.
		ElseIf ParamBox(aPerg,"Filtro",aParam,,,.T.,,,,cFilMani,.T.,.T.) 
			aFilBrw		:= MontaFiltro()
			cCondicao	+= aFilBrw[1]
			cCondQry	+= aFilBrw[2]
			lOk			:= .T.
		EndIf
	   
		If lOk		
			execMarkbrowse()
		EndIf
	Else 
		HelProg(,"FISTRFNFe")
	EndIf		
Else                       
	Aviso("Manifesto","Execute o compatibilizador NFEP11R1 (Id. NFE11R122) para o Manifesto do destinatário" ,{STR0114},3)
EndIf

Return lOk

static function execMarkbrowse()
	Local aIndArq	:={}
	Local aCores	:={} 
	Local aCampos	:={}
	
	Private cMarkDlg
	 
	aCores := {	{"C00_STATUS=='1' .and. alltrim(C00_CODEVE)=='3'",'ENABLE'},;
					{"C00_STATUS=='2' .and. alltrim(C00_CODEVE)=='3'",'BR_CINZA'},;								
		  			{"C00_STATUS=='3' .and. alltrim(C00_CODEVE)=='3'",'DISABLE'},;								
		  			{"C00_STATUS=='4' .and. alltrim(C00_CODEVE)=='3'",'BR_AZUL'},;								
					{"C00_STATUS=='0'",'BR_BRANCO'},;
					{"C00_STATUS $ '1234' .and. alltrim(C00_CODEVE)=='4' .and. alltrim(C00_CODRET)=='999'",'BR_AMARELO'},;
					{"C00_STATUS $ '1234' .and. alltrim(C00_CODEVE)=='2'",'BR_AMARELO'}}
	
	//aFilBrw		:=	{'C00',cCondicao}
	//bFiltraBrw := {|| FilBrowse("C00",@aIndArq,@cCondicao) }
	//Eval(bFiltraBrw)
	
	AADD(aCampos,{"C00_OK","",""})
	AADD(aCampos,{"C00_CHVNFE","","Chave da NFe"})
	AADD(aCampos,{"C00_SERNFE","","Serie"})
	AADD(aCampos,{"C00_NUMNFE","","Numero"})
	AADD(aCampos,{"C00_VLDOC","","Valor Nfe","@E 99,999,999,999.99"})
	AADD(aCampos,{{||RetSitDoc(C00_SITDOC)},"","Sit.Nfe"})
	AADD(aCampos,{{||RetSitEve(C00_CODEVE)},"","Sit.Evento"})

	cMarkDlg := GetMark(,"C00","C00_OK")
	MarkBrow("C00","C00_OK",.f.,aCampos,.F.,cMarkDlg,'MDeMarkAll()',,,,,,"C00_FILIAL = '"+xFilial("C00")+"' " + cCondQry,,aCores)
							
	/*Restaura a integridade da rotina*/
	RetIndex("C00")
	dbClearFilter()
	aEval(aIndArq,{|x| Ferase(x[1]+OrdBagExt())})	

return

static function MontaFiltro()

local cCondicao	:= ""
local cCondQry	:= ""

local aMes			:= {}
local aStatus		:= {}

aadd(aMes,"1 - Janeiro")
aadd(aMes,"2 - Fevereiro")
aadd(aMes,"3 - Março")
aadd(aMes,"4 - Abril")
aadd(aMes,"5 - Maio")
aadd(aMes,"6 - Junho")
aadd(aMes,"7 - Julho")
aadd(aMes,"8 - Agosto")
aadd(aMes,"9 - Setembro")
aadd(aMes,"10 - Outubro")
aadd(aMes,"11 - Novembro")
aadd(aMes,"12 - Dezembro")
aadd(aMes,"             ")

aadd(aStatus,"0 - "+STR0414)//"Sem manifestação"
aadd(aStatus,"1 - "+STR0415)//"Confirmada"
aadd(aStatus,"2 - "+STR0416)//"Desconhecida"
aadd(aStatus,"3 - "+STR0417)//"Não realizada"
aadd(aStatus,"4 - "+STR0418)//"Ciência"
aadd(aStatus,"5 - Todas")
aadd(aStatus,"6 - Em processamento")

If ValType(MV_PAR07) == "N"
	MV_PAR07 := aMes[MV_PAR07]
EndIf                      

If ValType(MV_PAR09) == "N"
	MV_PAR09 := aStatus[MV_PAR09]
EndIf			

If !Empty(MV_PAR01) //"Cnpj"
	cCondicao+=".and. C00_CNPJEM == '"+MV_PAR01+"' "
	cCondQry += "and C00_CNPJEM	= '"+MV_PAR01+"' "
EndIF

If !Empty(MV_PAR02) //"Cpf"
	cCondicao+=".and. C00_CNPJEM == '"+MV_PAR02+"' "
	cCondQry += "and C00_CNPJEM	= '"+MV_PAR02+"' "
EndIF
 
If !Empty(MV_PAR03) //"Serie de"
	cCondicao+=".and. C00_SERNFE	>= '"+MV_PAR03+"' "
	cCondQry +="and C00_SERNFE	>= '"+MV_PAR03+"' "
EndIF 
If !Empty(MV_PAR04) //"Serie até"
	cCondicao+=".and. C00_SERNFE	<= '"+MV_PAR04+"' "
	cCondQry +="and C00_SERNFE	<= '"+MV_PAR04+"' "
EndIF
If !Empty(MV_PAR05) //"Nota de"
	cCondicao+=".and. C00_NUMNFE	>= '"+MV_PAR05+"' "
	cCondQry +="and C00_NUMNFE	>= '"+MV_PAR05+"' "
EndIF 
If !Empty(MV_PAR06) //"Nota até"
	cCondicao+=".and. C00_NUMNFE	<= '"+MV_PAR06+"' "
	cCondQry +="and C00_NUMNFE	<= '"+MV_PAR06+"' "
EndIF
If !Empty(MV_PAR07)//Mês
	cMes:= Strzero(Val(SubStr(MV_PAR07,1,2)),2)		
	cCondicao+=".and. C00_MESNFE	== '"+cMes+"' "
	cCondQry +="and C00_MESNFE	= '"+cMes+"' "
Endif			

If !Empty(MV_PAR08) //"Ano"
	cCondicao+=".and. C00_ANONFE	== '"+MV_PAR08+"' "
	cCondQry +="and C00_ANONFE	= '"+MV_PAR08+"' "
EndIF
 
If !Empty(MV_PAR09) .and. SubStr(MV_PAR09,1,1) <> '5'  //"Status"

	if SubStr(MV_PAR09,1,1) == '6'
		cCondicao	+= ".and. alltrim(C00_CODEVE) == '2' "
		cCondQry += "and LTRIM(RTRIM(C00_CODEVE)) = '2' "
	else
		cCondicao += ".and. C00_STATUS == '"+SubStr(MV_PAR09,1,1)+"' "
		cCondQry +="and C00_STATUS = '"+SubStr(MV_PAR09,1,1)+"' "
	endif	

EndIf


return({cCondicao,cCondQry})
//-----------------------------------------------------------------------
/*/{Protheus.doc} MarkBr()
Utilizacao de menu Funcional

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param	aRotina		1. Nome a aparecer no cabecalho   
					2. Nome da Rotina associada                              
					3. Reservado                                              
					4. Tipo de Transação a ser efetuada:                       
          	  			1 - Pesquisa e Posiciona em um Banco de Dados         
						2 - Simplesmente Mostra os Campos                      
						3 - Inclui registros no Bancos de Dados                 
						4 - Altera o registro corrente                         
						5 - Remove o registro corrente do Banco de Dados       
					5. Nivel de acesso                                         
					6. Habilita Menu Funcional
@return	aRotina 	Array com opcoes da rotina	
/*/
//-----------------------------------------------------------------------
Static Function MarkBr()        
 
Local aRotina2  := { {"Solicitar","BaixaZip(0)",0,2},; //"Solicitar" 
                     {"Monitorar","BaixaZip(1)",0,2}}  //"Monitorar"
                     
Local aRotina3  := { { STR0474,	"MDeInclui"	,0,3,0,.F.},; //Incluir
		           { STR0475,	"MDeAltera"	,0,2,0,.F.},; //Alterar
		           { STR0477,	"MDeExclui"	,0,2,0,.F.}} //Excluir
		            
Private aRotina := {}   
Private cMark:=GetMark()

if !lUsaColab

	aRotina   := { { STR0004,		"PesqBrw"		,0,1,0,.F.},; //Pesquisar
	               { STR0005,		"SpedNFeCfg"	,0,3,0,.F.},; //Wiz.Config.
	               { STR0429,		"btConfig"		,0,3,0,.F.},; //Configurar
	               { STR0430,		"Sincronizar"	,0,3,0,.F.},; //Sincronizar
		           { STR0431,		"Manifest"		,0,2,0,.F.},; //Manifestar
		           { STR0432,		"MontaMonitor"	,0,2,0,.F.},; //Monitorar
		           { "Exportar",	"BaixaZip(0)" 	,0,2,0,.F.},; //Exportar Zip
		           { STR0299,		"BtLegenda"		,0,3,0,.F.},; //Legenda
				   {"Filtro",       "ManiFiltro"    ,0,3,0,.F.},; //ManiFiltro
		           {"MD-e manual"	,aRotina3		,0,3,0,.F.}}  //MD-e Manual       	           				   
		           /*{"Eventos"	,"listaEventos", 0, 2, 0, .F.}}*/ //Eventos     	           
		           
else
	aRotina   := { { STR0004,		"PesqBrw"		,0,1,0,.F.},; //Pesquisar	               
	               { STR0429,		"btConfig"		,0,3,0,.F.},; //Configurar
	               { STR0430,		"Sincronizar"	,0,3,0,.F.},; //Sincronizar
	               { "Atualizar",	"AtuBrowse"		,0,3,0,.F.},; //Atualizar
		           { STR0431,		"Manifest"		,0,2,0,.F.},; //Manifestar
		           { STR0432,		"MontaMonitor"	,0,2,0,.F.},; //Monitorar
		           { "Exportar",	aRotina2 		,0,2,0,.F.},; //Exportar Zip//Colaboração
				   {"Filtro",       "ManiFiltro"    ,0,3,0,.F.},; //ManiFiltro
		           { STR0299,		"BtLegenda"		,0,3,0,.F.}}  //Legenda
endif
          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³     Ponto de entrada para o cliente customizar os botoes apresentados     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MDEMenu") 
	aRotina := ExecBlock("MDEMenu", .F., .F.,{aRotina})
EndIf
Return aRotina
//-----------------------------------------------------------------------
/*/{Protheus.doc} BtLegenda()
Legenda da MarkBrow

@author Natalia Sartori
@since 04.07.2012
@version 1.00
/*/
//-----------------------------------------------------------------------   
Function BtLegenda()

Local aLegenda:= {}

AADD(aLegenda, {"BR_BRANCO"	,STR0414})//Sem manifestação
AADD(aLegenda, {"ENABLE"		,STR0415})//Confirmada
AADD(aLegenda, {"BR_CINZA"	,STR0416})//Desconhecida
AADD(aLegenda, {"DISABLE"	,STR0417})//Não realizada
AADD(aLegenda, {"BR_AZUL"	,STR0418})//Ciência
AADD(aLegenda, {"BR_AMARELO","Manifestação em processamento"})//Em processamento

BrwLegenda(cCadastro,STR0117,aLegenda) 

Return  
//-----------------------------------------------------------------------
/*/{Protheus.doc} BtConfig()
Executa a funcionalidade do menu 'Configurar'

@author Natalia Sartori
@since 04.07.2012
@version 1.00
/*/
//-----------------------------------------------------------------------    
Function BtConfig()

Local nEvento := 5 
Local lAtuParam := .F.

SpedCCePar(nEvento,lAtuParam)

Return
//-----------------------------------------------------------------------
/*/{Protheus.doc} ReadyTSS()
Verifica se a conexao com o TSS pode ser estabelecida

@author Natalia Sartori
@since 04.07.2012
@version 1.00
/*/
//-----------------------------------------------------------------------    
Function RetRdTSS(cURL,nTipo,lHelp)
Return  ReadyTSS(cURL,nTipo,lHelp)

Static Function ReadyTSS(cURL,nTipo,lHelp)
Local lUsaColab := UsaColaboracao("4")
Return (CTIsReady(cURL,nTipo,lHelp,lUsaColab))

//-----------------------------------------------------------------------
/*/{Protheus.doc} Sincronizar()
Montagem da Dialog 'Sincronizar'

@author Natalia Sartori
@since 04.07.2012
@version 1.00
/*/
//-----------------------------------------------------------------------  
Function Sincronizar()

Local oTButton2
Local oTButton1
Local oDlg
Local oSay     
Local oCheck   
Local oCheck1
local cfonte := IIf (FunName()$ "SPEDMANIFE","SPEDMANIFE","")

Local lCheck	:= .F.
Local lCheck1 := .F.

Local lContinua := .F.

local cMsg := ""

If ReadyTSS()
	DEFINE MSDIALOG oDlg TITLE "Sincronização de Documentos"+IIF(lUsaColab," - Via TOTVS Colaboração 2.0", "") FROM 0,0 TO  155, 400 PIXEL
	
	DEFINE FONT oFont BOLD
	//Alterado a legenda da tela pois a operação de sincronizar não será utilizada apenas para a rotina do manifesto do destinatário
	If cfonte $ "SPEDMANIFE"
		//======================= Inicializa uma linha com SAY ===========================
		@ 5,5  SAY oSay PROMPT STR0434 OF oDlg FONT oFont PIXEL SIZE 230, 030 //"Esta opção tem por objetivo sincronizar com a Sefaz os documentos"
		@ 15,5 SAY oSay PROMPT STR0435 OF oDlg FONT oFont PIXEL SIZE 230, 030//"que ainda não sofreram manifestações do destinatário."
		@ 30,5 SAY oSay PROMPT STR0436 OF oDlg FONT oFont PIXEL SIZE 230, 030 //"Deseja sincronizar os documentos agora? "
	Else
		//======================= Inicializa uma linha com SAY ===========================
		@ 5,5 SAY oSay PROMPT (STR0434+'.') OF oDlg FONT oFont PIXEL SIZE 230, 030 //"Esta opção tem por objetivo sincronizar com a Sefaz os documentos"
		@ 15,5 SAY oSay PROMPT STR0436 OF oDlg FONT oFont PIXEL SIZE 230, 030 //"Deseja sincronizar os documentos agora? "
	EndIf
	//======================= Buttons ===========================
	oTButton1	:= TButton():New( 045, 060, "Sim",oDlg,{|| (lContinua := .T.,oDlg:End())},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oTButton2	:= TButton():New( 045, 105, "Não",oDlg,{||(lContinua :=.F.,oDlg:End())},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	 
	if !lUsaColab
		oCheck		:= TCheckBox():New( 057, 005, "Sincronizar até finalizar todos os documentos.", {||lCheck }, oDlg, 200 ,,,{||lCheck := !lCheck,oDlg:Refresh()},,,,,,.T.,"Esta opção sincroniza todos documentos, aumentando o processamento e o tempo para finalização.",,)
		oCheck1	:= TCheckBox():New( 067, 005, "Refaz a sincronização dos documentos.", {||lCheck1 }, oDlg, 200 ,,,{||lCheck1 := !lCheck1,oDlg:Refresh()},,,,,,.T.,"Esta opção irá refazer a sincronização de todos os documentos disponíveis na Sefaz.",,)
	endif
	
	if lUsaColab
		oCheck1	:= TCheckBox():New( 067, 005, "Refaz a sincronização dos documentos.", {||lCheck1 }, oDlg, 200 ,,,{||lCheck1 := !lCheck1,oDlg:Refresh()},,,,,,.T.,"Esta opção irá refazer a sincronização de todos os documentos disponíveis na Sefaz.",,)
	endif
	ACTIVATE MSDIALOG oDlg CENTERED
		
	If lContinua
		if lUsaColab
			
			MsgRun("Aguarde Sincronização","Processando",{|| lContinua := ColMdeSinc(@cMsg,lCheck1)})
			
			if lContinua			 
				Aviso("SPED","Solicitação de sincronização enviada com sucesso, aguarde alguns segundos e atualize a tela.",{STR0114},3)
			else
				Aviso("SPED",cMsg,{STR0114},3)
			endif
			
		else
			MsgRun("Aguarde Sincronização","Processando",{|| SincDados(lCheck,lCheck1)}) 
		endif	
	EndIf	
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf
	
Return 

//-----------------------------------------------------------------------
/*/{Protheus.doc} SincDados()
Executa a funcionalidade do menu 'Sincronizar'

@param	lCheck	Define se será realizado a sincronziação até finalizar
				os documentos disponíveis na SEFAZ.

@author Natalia Sartori
@since 04.07.2012
@version 1.00
/*/
//-----------------------------------------------------------------------  
Static Function SincDados(lProcAll,lRefazSinc)

Local aChave	:= {}
Local aDocs		:= {}
Local aProc		:= {}

Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
local lUsaColab	:= UsaColaboracao("4")
Local cIdEnt	:= RetIdEnti(lUsaColab)
Local cChave	:= ""
Local cCancNSU	:= ""
Local cAlert	:= ""
Local cSitConf	:= ""
Local cCodEvento	:= ""
Local cAmbiente	:= "" 
Local lContinua	:= .T.

Local dData		:= CtoD("  /  /    ")

Local lOk		:= .F.
Local lDestcnpj	:= .T.

Local nX		:= 0                 
Local nZ		:= 0

Private oWs		:= Nil
Private oInfdoc	:= Nil

Default lProcAll := .F.
Default lRefazSinc	:= .F.

If ReadyTSS()
	oWs :=WSMANIFESTACAODESTINATARIO():New()
	oWs:cUserToken   := "TOTVS"
	oWs:cIDENT	     := cIdEnt
	oWs:cINDNFE		 := "0"
	oWs:cINDEMI      := "0"
	oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

	cAmbiente		 := getAmbMde() 

	// Refaz a sincronização de todos os documentos disponiveis na SEFAZ
	If lRefazSinc 
		oWs:cUltNSU	:= "0"
		oWs:CONFIGURARPARAMETROS()
	Endif
		
	//Tratamento para solicitar a sincronização enaquanto o IDCONT não retornar zero.

	While lContinua
	
		lOk		:= .F.
		aChave	:= {}
		aProc	:= {}
		
		If oWs:SINCRONIZARDOCUMENTOS()
			If Type ("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO") <> "U"
				If Type("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO")=="A"
					aDocs := oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO                  
				Else
					aDocs := {oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO}
				EndIf
			
				For nX := 1 To Len(aDocs)
					lDestcnpj:=.T.
					oInfdoc := aDocs[nx]
					If Type("oInfdoc:CCHAVE") <> "U" .and. Type("oInfdoc:CSITCONF") <> "U" 
					    cSitConf  := oInfdoc:CSITCONF
					    cChave    := oInfdoc:CCHAVE  
					    cCancNSU  := oInfdoc:CCANCNSU
					    If Type("oInfdoc:CCODEVENTO") <> "U"
					    	cCodEvento:= oInfdoc:CCODEVENTO
					    Else
					    	CodEvento:= ""
					    EndIf
						If Type("oInfdoc:cDESTCNPJ") <> "U" .AND. !empty(oInfdoc:cDESTCNPJ)
							If SM0->M0_CGC <> oInfdoc:cDESTCNPJ
					    			lDestcnpj:= .F.
							EndIf
						EndIf
					    
						// Caso o doc sincronizado tenha TPEVENTO não deve ir pra tabela C00
						If !cCodEvento $ "411500|411501|411502|411503" .and. lDestcnpj
						    if SincAtuDados(cChave,cSitConf,cCancNSU)
						    	aadd(aChave, cChave)
						    	lOk := .T.
						    endif
						EndIf
					EndIf	
				Next                   
				
				If lOk
					For nZ := 1 To Len( aChave )
					
						AADD( aProc, aChave[nZ] )
					                             
						If Len( aProc ) >= 30
							MonitoraManif(aProc,cAmbiente,cIdEnt,cUrl)
							aProc := {}
						Endif
						
					Next
					If Len( aProc ) > 0
						MonitoraManif(aProc,cAmbiente,cIdEnt,cUrl)
					Endif
				EndIf						
				
				If Type("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:CINDCONT") <> "U"
						
					If oWs:OWSSINCRONIZARDOCUMENTOSRESULT:CINDCONT == "0"
						lContinua := .F.						               
					endif	
				else
					lContinua := .F.				
				endif
				
				If Empty(aDocs) .And. !lContinua .And. !lOk
					cAlert:= STR0437 //"Não há documentos para serem sincronizados"
					Aviso("Sincronização",cAlert,{"OK"},3)
				EndIF
				
				if lContinua .And. !lProcAll .And. !lRefazSinc
					lContinua := MsgYesNo("Ainda existem documentos na SEFAZ a serem sincronizados, deseja solicitar novamente a sincronização ?")
				endif
				Sleep(2000)
			EndIf	
		Else
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
			lContinua := .F.
		EndIf
	EndDo	
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

oWs := Nil
oInfdoc := Nil
aDocs := Nil
DelClassIntf()

Return
//-----------------------------------------------------------------------
/*/{Protheus.doc} Manifest()
Montagem da Dialog 'Manifestar'

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param cAlias, nReg, nOpc, cMarca, lInverte
/*/
//-----------------------------------------------------------------------   
Function Manifest(cAlias, nReg, nOpc,cMarca, lInverte)    

Local aListBox	:= {}
Local aItensCb	:= {}
Local aMontXml	:= {}

Local cAliasC00	:= GetNextAlias()
Local cWhere	:= ""
Local cCNPJEM	:= ""
Local cRazao	:= ""
Local cIEemit	:= ""
Local cDataEmis	:= ""
Local cDtAut	:= ""
Local cCbCpo	:= ""                                   
Local cRetorno	:= ""
Local cJustific := Space(255)
Local cTexto	:= ""

Local nOpcJust	:= 0
Local nX		:= 0

Local lContinue := .F.
Local lEnvOk 	:= .F.
Local lProc		:= .T.
Local lMarkAll	:= .T.

Local oOkx		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oBmpVerm	:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Local oBmpVerd	:= LoadBitmap( GetResources(), "BR_VERDE" )
Local oBmpAzul	:= LoadBitmap( GetResources(), "BR_AZUL" )
Local oBmpBran	:= LoadBitmap( GetResources(), "BR_BRANCO" )
Local oBmpCinz	:= LoadBitmap( GetResources(), "BR_CINZA" )
Local oDlg
Local oTBut1
Local oTBut2
Local oListBox
Local oGrpForm2
Local oGrpForm1
Local oGrpForm
Local oCombo
Local oSay
Local oRazao
Local oCnpjEmi
Local oCnpjEmi1
Local oIEEst
Local oIEEst1
Local oDtEmis
Local oDtEmis1
Local oDtAut
Local oDtAut1

If ReadyTss()    
	If lInverte
		cWhere+="%C00.C00_FILIAL='"+xFilial("C00")+"' AND C00.C00_OK <>'"+cMarca+"' "+cCondQry+"%"
	Else
		cWhere+="%C00.C00_FILIAL='"+xFilial("C00")+"' AND C00.C00_OK ='"+cMarca+"' "+cCondQry+"%"
	EndIF
	
	BeginSql Alias cAliasC00
	
	SELECT C00_CHVNFE,C00_SERNFE,C00_NUMNFE,C00_VLDOC,C00_CNPJEM,C00_NOEMIT,C00_IEEMIT,C00_DTEMI,C00_DTREC,C00_STATUS,C00_CODEVE,R_E_C_N_O_
	FROM %Table:C00% C00
	WHERE %Exp:cWhere% AND
	C00.%notdel%
	EndSql                                                                             
	
	TcSetField(cAliasC00,"C00_DTEMI"  ,"D",008,0)
	TcSetField(cAliasC00,"C00_DTREC" ,"D",008,0)
	      
	While (cAliasC00)->(!Eof())
		aadd(aListBox,{oNo,(cAliasC00)->C00_CHVNFE,(cAliasC00)->C00_SERNFE,(cAliasC00)->C00_NUMNFE,(cAliasC00)->C00_VLDOC,(cAliasC00)->C00_CNPJEM,(cAliasC00)->C00_NOEMIT,(cAliasC00)->C00_IEEMIT,(cAliasC00)->C00_DTEMI,(cAliasC00)->C00_DTREC,.T.,(cAliasC00)->C00_STATUS,(cAliasC00)->C00_CODEVE})
		(cAliasC00)->(dbSkip())
	End
   
   	If Len(aListBox) > 0 .and. Len(aListBox) <= 20
	
		DEFINE MSDIALOG oDlg TITLE "Manifestar" FROM 0,0 TO  540, 700 PIXEL
	
		DEFINE FONT oFont BOLD
		
		
		//======================= ListBox ===========================
	   	@065,020 LISTBOX oListBox FIELDS HEADER "","","Chave","Serie","Numero","Valor NFe" SIZE 310,115 PIXEL OF oDlg ON dblClick (aListBox[oListBox:nAt,11]:= !aListBox[oListBox:nAt,11])
	    	   	oListBox:SetArray( aListBox )
				oListBox:bLine := {||     {If(aListBox[oListBox:nAt,11],oOkx,oNo),;
										getColorStat( aListBox[oListBox:nAt,12] ),;
						                aListBox[oListBox:nAt,2],;
						                aListBox[oListBox:nAt,3],;
						                aListBox[oListBox:nAt,4],;
			         	        		Transform(aListBox[oListBox:nAt,5],"@E 99,999,999,999.99")}} 
				
				oListBox:bChange := {|| AtuDetalhe(aListBox[oListBox:nAt],@cCNPJEM,@cRazao,@cIEemit,@cDataEmis,@cDtAut),oCnpjEmi1:Refresh(),oRazao:Refresh(),oIEEst1:Refresh(),oDtEmis1:Refresh(),oDtAut1:Refresh()}
				oListBox:bHeaderClick := {|| aEval(aListBox, {|e| e[11] := lMarkAll}),lMarkAll:=!lMarkAll, oListBox:Refresh()}
		//======================= Adicionando dados no Array do Combo ===========================
		aadd(aItensCb,STR0419)//"210200 - Confirmação da Operação"
		aadd(aItensCb,STR0420)//"210210 - Ciência da Operação"
		aadd(aItensCb,STR0421)//"210220 - Desconhecimento da Operação"
		aadd(aItensCb,STR0422)//"210240 - Operação não Realizada"
		if(ExistBlock("MANIOPCEVT") )
			aItensCb := ExecBlock("MANIOPCEVT",.F.,.F.,{aClone(aItensCb)})			
		endif
		
		//======================= Borda ===========================
		@010,010 GROUP oGrpForm2 TO 050,340  OF oDlg PIXEL 
		@055,010 GROUP oGrpForm TO 250,340  PROMPT "Dados da Nota" OF oDlg PIXEL 
		@185,015 GROUP oGrpForm1 TO 200,335  PROMPT "Legenda" OF oGrpForm PIXEL    
		
		//======================= Combo ===========================
		@035,020 COMBOBOX oCombo VAR cCbCpo ITEMS aItensCb SIZE 120,30 PIXEL OF oDlg  
		
		//======================= Says ===========================	
		@015,020 SAY oSay PROMPT STR0438 OF oDlg FONT oFont PIXEL SIZE 290, 030 //"Esta rotina permite que o destinatário da NFe se manifeste sobre as notas emitidas para o seu CNPJ.  " 
		@025,020 SAY oSay PROMPT STR0439 OF oDlg FONT oFont PIXEL SIZE 290, 030 //"Escolha uma das opções abaixo para as notas selecionadas: "
		
		@210,020 SAY oRazao PROMPT "Nome/Razao Social: " OF oDlg FONT oFont PIXEL SIZE 300, 200
		@210,075 SAY oRazao PROMPT cRazao OF oDlg PIXEL SIZE 300, 200
		         	        		
		@220,020 SAY oCnpjEmi PROMPT "Cpf/Cnpj Emitente: " OF oDlg FONT oFont PIXEL SIZE 230, 030
		@220,075 SAY oCnpjEmi1 PROMPT cCNPJEM  OF oDlg PIXEL SIZE 230, 030
		
		@220,230 SAY oIEEst PROMPT "IE Emitente: " OF oDlg FONT oFont PIXEL SIZE 230, 030
		@220,265 SAY oIEEst1 PROMPT cIEemit OF oDlg PIXEL SIZE 230, 030
		
		@230,020 SAY oDtEmis PROMPT "Data Emissão: " OF oDlg FONT oFont PIXEL SIZE 230, 030
		@230,060 SAY oDtEmis1 PROMPT cDataEmis OF oDlg PIXEL PICTURE "@D" SIZE 230, 030
		  
	   	@230,230 SAY oDtAut PROMPT "Data Autorização: " OF oDlg FONT oFont PIXEL SIZE 230, 030
		@230,279 SAY oDtAut1 PROMPT cDtAut OF oDlg PIXEL PICTURE "@D" SIZE 230, 030
		
		//======================= Legendas ===========================
		@ 190,040 BITMAP oBmpVerd RESOURCE "BR_VERDE.PNG" NO BORDER SIZE 017, 017 OF oDlg PIXEL
		@ 190,050 SAY oSay PROMPT STR0415 SIZE 100,010 PIXEL OF oDlg //Confirmada
		
		@ 190, 095 BITMAP oBmpVerm RESOURCE "BR_VERMELHO.PNG" NO BORDER SIZE 017, 017 OF oDlg PIXEL
		@ 190, 105 SAY oSay PROMPT STR0417 SIZE 100,010 PIXEL OF oDlg //Não realizada
	
		@ 190, 155 BITMAP oBmpAzul RESOURCE "BR_AZUL.PNG" NO BORDER SIZE 017, 017 OF oDlg PIXEL
		@ 190, 165 SAY oSay PROMPT STR0418 SIZE 100,010 PIXEL OF oDlg //Ciência
		
		@ 190, 200 BITMAP oBmpCinz RESOURCE "BR_CINZA.PNG" NO BORDER SIZE 017, 017 OF oDlg PIXEL
		@ 190, 210 SAY oSay PROMPT STR0416 SIZE 100,010 PIXEL OF oDlg //Desconhecida
		
		@ 190, 256 BITMAP oBmpbran RESOURCE "BR_BRANCO.PNG" NO BORDER SIZE 017, 017 OF oDlg PIXEL
		@ 190, 270 SAY oSay PROMPT STR0414 SIZE 100,010 PIXEL OF oDlg //Sem manifestação
		
		//======================= Buttons ===========================
		oTBut1 := TButton():New( 255, 245, "Manifestar",oDlg,{|| (lContinue := ValidManif( cCbCpo, @cJustific, aListBox, aMontXml ),if(lContinue,oDlg:End(),(cJustific := "",cJustific := space(255))))},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oTBut2 := TButton():New( 255, 290, "Cancelar",oDlg,{||(lContinue :=.F.,oDlg:End())},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
        
		ACTIVATE MSDIALOG oDlg CENTERED
		
		
		If lContinue
			MsgRun("Aguarde Manifestação","Processando",{|| lEnvOk := MontaXmlManif(cCbCpo,aMontXml,@cRetorno,cJustific)}) 
		EndIf                                                                                       
		
		If lEnvOk
			Aviso("Envio Manifesto",cRetorno,{"OK"},3)
			MDeDesMark()
		EndIF
	Else
    	Aviso("Envio Manifesto",STR0440,{"OK"},3)//"Selecione uma ou no maximo 20 chaves pendentes de manifestação"
	EndIf
		
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf
		
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} SincAtuDados()
Realiza a atualzação do sincroizar dados.

@author Rafael Iaquinto
@since 18.08.2014
@version 1.00

@param cChave, string, chave do documento.
@param cSitConf, string, Situação da Manifestação do Destinatário.
@param cCancNSU, string, NSU do Cancelamento.
/*/
//-----------------------------------------------------------------------   
function SincAtuDados(cChave,cSitConf,cCancNSU)

Local dData		:= CtoD("  /  /    ")
Local lOk			:= .F.

C00->(DbsetOrder(1))
If !C00->( DbSeek( xFilial("C00") + cChave) )
	RecLock("C00",.T.)
	C00->C00_FILIAL     := xFilial("C00")
	C00->C00_STATUS     := cSitConf
	C00->C00_CHVNFE		:= cChave
	dData := CtoD("01/"+Substr(cChave,5,2)+"/"+Substr(cChave,3,2))
	C00->C00_ANONFE		:= Strzero(Year(dData),4)
	C00->C00_MESNFE		:= Strzero(Month(dData),2)
	C00->C00_SERNFE		:= Substr(cChave,23,3)
	C00->C00_NUMNFE		:= Substr(cChave,26,9)
	C00->C00_CODEVE		:= Iif(cSitConf $ '0',"1","3")	
	If !Empty(cCancNSU)
		C00->C00_SITDOC := "3" //nota cancelada
	Else
		C00->C00_SITDOC := "1" //nota autorizada
	EndIf
	lOk := .T.
	MsUnLock()
	If ExistBlock("MANIGRV")
		ExecBlock("MANIGRV",.F.,.F.,{Substr(cChave,23,3),Substr(cChave,26,9),cChave,cSitConf})
	EndIf
Else
	If !Empty(cCancNSU)
		RecLock("C00",.F.)
		C00->C00_SITDOC := "3"
		MsUnLock()
	EndIf
EndIf	

return (lOk)

//-----------------------------------------------------------------------
/*/{Protheus.doc} MonAtuDados()
Realiza a atualização do sincronizar dados.

@author Rafael Iaquinto
@since 18.08.2014
@version 1.00

@param cChave, string, chave do documento.
@param cCNPJEmit, string, CNPJ do Emitente.
@param cIeEmit, string, IE do Emitente
@param cNomeEmit, string, Nome do Emitente
@param cSitConf, string, Situação da Manifestação do Destinatário.
@param cSituacao, string, Situação da NF-e.
@param cDesResp, string, xMotivo do retConsNFeDest.
@param cDesCod, string, CSTAT do retConsNFeDest.
@param dDtEmi, date, Data de Emissão. DEMI
@param dDtRec, date, Data de Autorização DHRECBTO
@param nValDoc, inteiro, Valor total do documento. VNF 
/*/
//-----------------------------------------------------------------------   
function MonAtuDados(cChave,cCNPJEmit,cIeEmit,cNomeEmit,cSitConf,cSituacao,cDesResp,cDesCod,dDtEmi,dDtRec,nValDoc,cOpcUpd)
				
C00->(DbsetOrder(1))
If C00->(DbSeek( xFilial("C00") + cChave))
	RecLock("C00",.F.)
	C00->C00_CNPJEM		:= Alltrim(cCNPJEmit)
	C00->C00_IEEMIT		:= AllTrim(cIeEmit)
	C00->C00_NOEMIT		:= Alltrim(cNomeEmit)
	C00->C00_STATUS		:= cSitConf
	C00->C00_SITDOC		:= cSituacao
	C00->C00_DESRES		:= Alltrim(cDesResp)
	C00->C00_CODRET		:= cDesCod
	C00->C00_DTEMI  		:= dDtEmi
	C00->C00_DTREC		:= dDtRec
	C00->C00_VLDOC		:= nValDoc
	C00->C00_CODEVE		:= Iif(alltrim(cOpcUpd) $ '4','4',Iif(alltrim(C00->C00_STATUS) $ '0',"1","3"))
	C00->(MsUnLock())
EndIf

return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} AtuBrowse()
Realiza a atualização da MarkBrowse píncipal.

@author Rafael Iaquinto
@since 18.08.2014
@version 1.00

/*/
//-----------------------------------------------------------------------  
function AtuBrowse()
	local cMsg := ""
	
	ColMdeCons(@cMsg)
	
	if !empty(cMsg)
		Aviso("Manifesto",cMsg ,{STR0114},3)	
	endif
return nil
//-----------------------------------------------------------------------
/*/{Protheus.doc} AtuDetalhe()
Atualiza os dados dos Says ao trocar a seleção no ListBox

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param 	aList     - Dados da Nota selecionada no ListBox	
		cCNPJEM   - Cnpj Emitente
		cRazao    - Razao Social
		cIEemit   - Ie do emitente
		cDataEmis - Data de Emissao da Nota
		cDtAut    - Data de autorização da Nota
/*/
//-----------------------------------------------------------------------  
Static Function AtuDetalhe(aList,cCNPJEM,cRazao,cIEemit,cDataEmis,cDtAut)

cCNPJEM := 	aList[6]
cRazao  :=  aList[7] 
cIEemit :=  aList[8]
cDataEmis:= aList[9]
cDtAut  :=  aList[10]

Return () 
//-----------------------------------------------------------------------
/*/{Protheus.doc} MontaXmlManif()
Monta xml para transmissão da manifestação

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param 	cCbCpo     - Evento Selecionado no listbox
		aMontXml   - Dados da nota que deve ser transmitida
		cRetorno   - Chaves de acesso das notas transmitidas
		cJustific  - Justificativa da Operação não realizada

@Return lRetOk	   - Se a transmissão foi concluída ou não		
/*/
//-----------------------------------------------------------------------     
Static Function MontaXmlManif(cCbCpo,aMontXml,cRetorno,cJustific) 

Local aRet			:={}

Local cAmbiente		:= "" 
Local cXml			:= ""
Local cTpEvento		:= SubStr(cCbCpo,1,6)
Local lUsaColab		:= UsaColaboracao("4")
Local cIdEnt		:= RetIdEnti(lUsaColab)
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cChavesMsg	:= ""
Local cMsgManif		:= ""
Local cIdEven		:= ""
Local cErro		:= ""
Local cRetPE		:= ""

Local aNfe			:= {}

Local lRetOk		:= .T. 
Local lManiEven	:= ExistBlock("MANIEVEN")
Local lMata103	:= IIf(FunName()$"MATA103",.T.,.F.)

Local nX 			:= 0
Local nZ 			:= 0

Private oWs			:= Nil

Default cJustific 	:= ""

If ReadyTSS()
	If lUsaColab	
		cAmbiente := ColGetPar("MV_AMBIENT")
		lRetOk := .F.
		
		For nX:=1 To Len(aMontXml)
			aNfe := {}
			aNfe := {aMontXml[nX][2],"","",""}
			cIdEven := ""
			cXML	 := ""
			cXml := SpedCCeXml(aNfe,cJustific,cTpEvento)		
			//Adiciona a CHAVE da nota para solicitar o envio.
					
			
			If ColEnvEvento("MDE",aNfe,cXml,@cIdEven,@cErro)
				lRetOk := .T.
				aadd(aRet,cIdEven)
			else
				Aviso("MD-e TOTVS Colaboração 2.0",cErro,{STR0114},3)	
			EndIf
		Next
	else
		oWs :=WSMANIFESTACAODESTINATARIO():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cIDENT	     := cIdEnt
		oWs:cAMBIENTE	 := ""
		oWs:cVERSAO      := ""
		oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw" 
		
		If oWs:CONFIGURARPARAMETROS()
			cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE
			
			cXml+='<envEvento>'
			cXml+='<eventos>'
			
			For nX:=1 To Len(aMontXml)
				cXml+='<detEvento>'
				If lManiEven
					cRetPE := ExecBlock("MANIEVEN",.F.,.F.,{cTpEvento,aMontXml[nX][2]})
					If cRetPE <> Nil .And. !Empty(cRetPE)
						cTpEvento := cRetPE
					EndIf
				EndIf
				cXml+='<tpEvento>'+cTpEvento+'</tpEvento>'
				cXml+='<chNFe>'+Alltrim(aMontXml[nX][2])+'</chNFe>'
				cXml+='<ambiente>'+cAmbiente+'</ambiente>'
				If '210240' $ cTpEvento .and. !Empty(cJustific)
					cXml+='<xJust>'+Alltrim(cJustific)+'</xJust>'
				EndIf		
				cXml+='</detEvento>'
			Next
			cXml+='</eventos>'
			cXml+='</envEvento>'
			
			lRetOk:= EnvioManif(cXml,cIdEnt,cUrl,@aRet)
		
		Else                                                                               
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		endif	
	endif
		
		
		
	If lRetOk .And. Len(aRet) > 0
		For nZ:=1 to Len(aRet)
		    aRet[nZ]:= Substr(aRet[nZ],9,44)
		    cChavesMsg += aRet[nZ] + Chr(10) + Chr(13)	    	    
		Next
		cMsgManif := STR0441+ Chr(10) + Chr(13)//"Transmissão da Manifestação concluída com sucesso!"
		cMsgManif += cCbCpo + Chr(10) + Chr(13)
		cMsgManif += "Chave(s): "+ Chr(10) + Chr(13)
		cMsgManif += cChavesMsg
		IF lMata103
			cMsgManif += Chr(10) + Chr(13)+ "Consulte a rotina de Manifestação do Destinatário para verificar o resultado!"
		EndIf
		cRetorno := Alltrim(cMsgManif)
		
	EndIf
		
	AtuStatus(aRet,cTpEvento)			
	
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf
		
Return lRetOk 
//-----------------------------------------------------------------------
/*/{Protheus.doc} EnvioManif()
Envia o xml para transmissão da manifestação

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param 	cXmlReceb  - String com o XML a ser transmitido
		cIdEnt	   - Codigo da Entidade
		cUrl	   - URL
		aRetorno   - Retorno do RemessaEvento

@Return lRetOk	   - Se a transmissão foi concluída ou não		
/*/
//-----------------------------------------------------------------------    
Function RetEnvManif(cXmlReceb,cIdEnt,cUrl,aRetorno,cModel)
Return EnvioManif(cXmlReceb,cIdEnt,cUrl,aRetorno,cModel)

Static Function EnvioManif(cXmlReceb,cIdEnt,cUrl,aRetorno,cModel)

Local lRetOk		:= .T.

Default cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)  
Default cIdEnt		:= RetIdEnti(lUsaColab)
Default aRetorno	:= {}
Default cModel		:= ""

If ReadyTSS() .And. !(UsaColaboracao("4"))
	// Chamada do metodo e envio
	oWs:= WsNFeSBra():New()
	oWs:cUserToken	:= "TOTVS"
	oWs:cID_ENT		:= cIdEnt
	oWs:cXML_LOTE	:= cXmlReceb
	oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
	If !Empty(cModel)
		oWS:cModelo := cModel
	EndIf
	//oWs:RemessaEvento()
	
	If oWs:RemessaEvento()
		If Type("oWS:oWsRemessaEventoResult:cString") <> "U"
			If Type("oWS:oWsRemessaEventoResult:cString") <> "A"
				aRetorno:={oWS:oWsRemessaEventoResult:cString}
			Else
				aRetorno:=oWS:oWsRemessaEventoResult:cString
			EndIf
		EndIf
	Else
		lRetOk := .F.	
		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
	Endif
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return lRetOk
//-----------------------------------------------------------------------
/*/{Protheus.doc} MonitoraManif
Realiza o monitoramento da Manifestação ao sincronizar os dados.

@author Natalia Sartori
@since 04.07.2012
@version 1.00 

@param		aChave 	  - Array com as chaves de acesso sincronizadas e gravadas 
					    na tabela C00
			cAmbiente - Ambiente (1-Produção,2-Homologação)
			cIdEnt    - Codigo da Entidade
			cUrl	  - URL 

/*/
//----------------------------------------------------------------------- 
Function MonitoraManif(aChave,cAmbiente,cIdEnt,cUrl,lJob,cOpcUpd)

Local cChave		:= ""
Local cCNPJEmit	:= ""
Local cIeEmit		:= ""
Local cNomeEmit	:= ""
Local cSitConf	:= ""	
Local cSituacao	:= ""
Local cDesResp	:= ""
Local cDesCod		:= ""

Local dDtEmi		:= CTOD("  /  /  ")
Local dDtRec		:= CTOD("  /  /  ")

Local nValDoc		:= 0
Local nZ := 0
Local nY := 0

Local aMonDoc	:={}

Default cOpcUpd :=""

Private oWS		:= Nil

Default lJob	:= .F.

if ReadyTSS() .And. !(UsaColaboracao("4"))
	oWs :=WSMANIFESTACAODESTINATARIO():New()
	oWs:cUserToken   := "TOTVS"
	oWs:cIDENT	     := cIdEnt
	oWs:cAMBIENTE	 := cAmbiente     
	oWs:OWSMONDADOS:OWSDOCUMENTOS  := MANIFESTACAODESTINATARIO_ARRAYOFMONDOCUMENTO():New()
	For nY := 1 to Len(aChave)
		aadd(oWs:OWSMONDADOS:OWSDOCUMENTOS:OWSMONDOCUMENTO,MANIFESTACAODESTINATARIO_MONDOCUMENTO():New())
		oWs:OWSMONDADOS:OWSDOCUMENTOS:OWSMONDOCUMENTO[nY]:CCHAVE := aChave[nY]
	Next
	oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw" 
	
	If oWs:MONITORARDOCUMENTOS()
		If Type ("oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET") <> "U"
			If Type ("oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET") == "A"
				aMonDoc := oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET
			Else 
				aMonDoc := {oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET}
			EndIf
		EndIF
		For nZ :=1 to Len(aMonDoc)
			If Type(aMonDoc[nZ]:CCHAVE) <> "U"
				cChave := aMonDoc[nZ]:CCHAVE
				
				cCNPJEmit	:= Iif(!Empty(Alltrim(aMonDoc[nZ]:CEMITENTECNPJ)),Alltrim(aMonDoc[nZ]:CEMITENTECNPJ),Alltrim(aMonDoc[nZ]:CEMITENTECPF))
				cIeEmit	:= AllTrim(aMonDoc[nZ]:CEMITENTEIE)
				cNomeEmit	:= Alltrim(aMonDoc[nZ]:CEMITENTENOME)
				cSitConf	:= aMonDoc[nZ]:CSITUACAOCONFIRMACAO
				cSituacao	:= aMonDoc[nZ]:CSITUACAO
				cDesResp	:= Alltrim(aMonDoc[nZ]:CRESPOSTADESCRICAO)
				cDesCod	:= aMonDoc[nZ]:CRESPOSTASTATUS
				
				dDtEmi		:= StoD(StrTran(aMonDoc[nZ]:CDATAEMISSAO,"-",""))
				dDtRec		:= StoD(StrTran(aMonDoc[nZ]:CDATAAUTORIZACAO,"-",""))
				
				nValDoc		:= aMonDoc[nZ]:NVALORTOTAL
				
				
				MonAtuDados(cChave,cCNPJEmit,cIeEmit,cNomeEmit,cSitConf,cSituacao,cDesResp,cDesCod,dDtEmi,dDtRec,nValDoc,cOpcUpd)
								
			EndIf	
		Next
	Else	
		If !lJob
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		Endif
	EndIf
Else
	If !lJob
		Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
	Endif
EndIf

oWs := Nil
DelClassIntf()	

Return 

//-----------------------------------------------------------------------
/*/{Protheus.doc} MontaMonitor()
Montagem da Dialog 'Monitorar'

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param cAlias, nReg, nOpc, cMarca, lInverte
/*/
//----------------------------------------------------------------------- 
Function MontaMonitor()
Local aPerg		:= {}	
Local aChaves	:= {}
Local aListBox 	:= {}
Local aListChv	:= {}
Local aParam	:={Space(3),Space(09),Space(09),Space(01)}
Local aSize		:= MsAdvSize()
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local aArea		:= GetArea()
Local cParManif := SM0->M0_CODIGO+SM0->M0_CODFIL+"MonitManif"
Local cEventMon := ""
Local cWhere	:= ""
Local cAliasTemp:= GetNextAlias()
Local cChvIni	:= ""
Local cChvFin	:= ""
Local cCodEve	:= "" 
Local nCombo	
Local cChaves	:= ""
Local nCont := 0

Local bBloco
Local oWS
Local oDlg
Local oListBox
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local lUsaColab := .F.

Private aCodEve	:= {}

//verifica se usa Totvs colaboracao
lUsaColab := UsaColaboracao("4")

aadd(aCodEve,STR0419)//"210200 - Confirmação da Operação"
aadd(aCodEve,STR0420)//"210210 - Ciência da Operação"
aadd(aCodEve,STR0421)//"210220 - Desconhecimento da Operação"
aadd(aCodEve,STR0422)//"210240 - Operação não Realizada"
				
MV_PAR01 := aParam[01] := PadR(ParamLoad(cParManif,aPerg,1,aParam[01]),Len(C00->C00_SERNFE))
MV_PAR02 := aParam[02] := PadR(ParamLoad(cParManif,aPerg,2,aParam[02]),Len(C00->C00_NUMNFE))
MV_PAR03 := aParam[03] := PadR(ParamLoad(cParManif,aPerg,3,aParam[03]),Len(C00->C00_NUMNFE))
MV_PAR04 := aParam[04] := ParamLoad(cParManif,aPerg,4,aParam[04])
nCombo	:= Iif(aScan(aCodeve,{|x| x == aParam[04] }) > 0,aScan(aCodeve,{|x| x == aParam[04] }),1)

aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
aadd(aPerg,{1,STR0011,aParam[02],"",,"",".T.",30,.F.})	//"Nota fiscal inicial"
aadd(aPerg,{1,STR0012,aParam[03],"",,"",".T.",30,.F.}) 	//"Nota fiscal final"
aadd(aPerg,{2,"Codigo do Evento",nCombo,aCodEve,115,".T.",.F.,".T."})  //Código do Evento 

If ReadyTSS()
	If ParamBox(aPerg,"Monitor Manifestação",aParam,,,,,,,cParManif,.T.,.T.)  
		aChaves := getChaves(@cCodEve)
		RestArea(aArea)
		
		If Len(aChaves) > 0
			aListBox := getEventos(cChvIni,cChvFin,cCodEve,aChaves, lUsaColab)

			If !Empty(aListBox)
				AAdd( aObjects, { 100, 100, .t., .t. } )
				AAdd( aObjects, { 100, 015, .t., .f. } )
				aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
				aPosObj := MsObjSize( aInfo, aObjects )
				
				DEFINE FONT oBold BOLD	
				DEFINE MSDIALOG oDlg TITLE "Monitoramento da Manifestação" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
				                                                                                         //607,365
				@aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox 	FIELDS HEADER "","Protocolo","ID","Ambiente","Mensagem" ; 
					SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL	
				        oListBox:SetArray(aListBox)
				        oListBox:bLine:={||	{	aListBox[oListBox:nAt][01],;
				        						Alltrim(aListBox[oListBox:nAt][02]),;
				        						Alltrim(aListBox[oListBox:nAt][03]),;
				        						Alltrim(aListBox[oListBox:nAt][04]),;
				        						Alltrim(aListBox[oListBox:nAt][06])}}
		
				@ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn1 PROMPT STR0118		ACTION (aChaves := {}, aChaves := getChaves(@cCodEve), aListBox := getEventos(cChvIni,cChvFin,cCodEve,aChaves, lUsaColab) ,oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
				@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn2 PROMPT STR0294		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //Sair
				@ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn3 PROMPT "Legenda"	ACTION btLegMonit() OF oDlg PIXEL SIZE 035,011 
				@ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn4 PROMPT "Vis. XML"	ACTION btVisuXml(Alltrim(aListBox[oListBox:nAt][03]),aListBox[oListBox:nAt][07]) OF oDlg PIXEL SIZE 035,011 
				
				ACTIVATE MSDIALOG oDLg CENTERED
			else
				Aviso("SPED",STR0106,{STR0114}) // Não ha Dados
			EndIf		
		else
			Aviso("SPED",STR0106,{STR0114}) // Não ha Dados
		endif
	EndIf
Else
	Aviso("SPED",STR0021,{STR0114},3) //"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf
Return 

//-----------------------------------------------------------------------
/*/{Protheus.doc} getEventos
Montagem da Lista de Eventos - ListBox

@author Jonatas Almeida
@since 13.07.2012
@version 1.00

@param cChvIni, cChvFin, cCodEve, aChaves
/*/
//-----------------------------------------------------------------------
static function getEventos(cChvIni, cChvFin, cCodEve, aChaves, lUsaColab)
	local nW		:= 0
	local nY		:= 0
	local cEventMon	:= "MonitEven"
	local aListChv	:= {}
	local aListBox	:= {}
	local cChaves	:= ""
	local nCont		:= 0

	if lUsaColab
		cEventMon	:= "ColEveMonit"
		bBloco		:= "{|| " + cEventMon + "(aChaves, cCodEve) }"
		aListBox	:= Eval(&bBloco)
	else
		cEventMon	:= "MonitEven"
		aListChv	:= {}
		aListBox	:= {}
		cChaves		:= ""
		nCont		:= 0

		For nW := 1 To Len( aChaves )
			++nCont
			cChaves += IIf(!Empty(cChaves),",","") + "'" + aChaves[nW] + "'" 				

			If nCont >= 50
				aListChv := MonitEven(cChvIni,cChvFin,cCodEve,,cChaves, lUsacolab)

				For nY := 1 To Len( aListChv )
					AADD( aListBox, aListChv[nY] )
				Next

				nCont		:= 0
				cChaves		:= ""
				aListChv	:= {}						
			Endif
		Next nW

		If nCont > 0
			aListChv := MonitEven(cChvIni,cChvFin,cCodEve,,cChaves, lUsacolab)
			
			For nY := 1 To Len( aListChv )
				AADD( aListBox, aListChv[nY] )
			Next
			
			cChaves := ""						
		Endif
	endif
return aListBox

//-----------------------------------------------------------------------
/*/{Protheus.doc} getChaves
Montagem da Lista de Chaves

@author Jonatas Almeida
@since 13.07.2012
@version 1.00

@param cCodEve
/*/
//-----------------------------------------------------------------------
static function getChaves(cCodEve)
	local aChaves		:= {}
	local cAliasTemp	:= GetNextAlias()
	 
	If ValType(MV_PAR04) == "N"
		MV_PAR04 := aCodEve[MV_PAR04]
	EndIf 
		
	cCodEve	:= SubStr(MV_PAR04,1,6)
	
	BeginSql Alias cAliasTemp
		SELECT
			C00_CHVNFE AS CHAVE
		FROM
			%Table:C00% C00    
		WHERE
			C00.C00_FILIAL = %xFilial:C00% AND 
			C00.C00_NUMNFE BETWEEN %exp:MV_PAR02% AND %exp:MV_PAR03% AND 
			C00.C00_SERNFE = %exp:MV_PAR01% AND 
			C00.%notdel%
	EndSql

	(cAliasTemp)->(dbGotop())
	
	If (cAliasTemp)->(Eof())
		//msgInfo(STR0398)//"Nenhum registro à monitorar "
		(cAliasTemp)->(dbCloseArea())
		return {}
	EndIf
	
	While (cAliasTemp)->(!EOF())
		aadd(aChaves, (cAliasTemp)->CHAVE )
		(cAliasTemp)->(DbSkip())
	endDo
	
	(cAliasTemp)->(dbCloseArea())
return aChaves
//-----------------------------------------------------------------------
/*/{Protheus.doc} MonitEven
Realiza o monitoramento do Evento

@author Natalia Sartori
@since 04.07.2012
@version 1.00 

@param		cChvIni   - Chave inicial a ser monitorada
			cChvFin   - Chave final a ser monitorada		    
			cCodEve	  - Codigo de Evento utilizado na busca

@return		aListBox  - Retorna o resultado da solicitação 
/*/
//----------------------------------------------------------------------- 
Function RetMonEven(cChvIni,cChvFin,cCodEve,cModelo,lUsaColab)
Return  MonitEven(cChvIni,cChvFin,cCodEve,cModelo,,lUsaColab)

Static Function MonitEven(cChvIni,cChvFin,cCodEve,cModelo,cChaves,lUsaColab)

Local aListBox		:= {}

Local oOk			:= LoadBitMap(GetResources(), "ENABLE")
Local oNo			:= LoadBitMap(GetResources(), "DISABLE")

Local cURL   		:= PadR(GetNewPar("MV_SPEDURL","http://"),250) 
Local cOpcUpd		:= ""
Local cIdEnt		:= RetIdEnti(lUsaColab)

Local nX			:= 0

Local lOk      		:= .T.

Private oXmlCCe
Private oDados
Private oWS			:= Nil	

Default cModelo 	:= ""
Default cChaves	    := ""

If ReadyTss()

	// Executa o metodo NfeRetornaEvento()
	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN	:= "TOTVS"
	oWS:cID_ENT		:= cIdEnt 
	oWS:_URL			:= AllTrim(cURL)+"/NFeSBRA.apw"
	oWS:cEVENTO		:= cCodEve
	oWS:cCHVINICIAL	:= cChvIni
	oWS:cCHVFINAL		:= cChvFin
	oWS:cCHAVES		:= cChaves
	lOk:=oWS:NFEMONITORLOTEEVENTO()
	
	If lOk
	
		// Tratamento do retorno do evento
		If Type("oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento") <> "U" 
			
			If Valtype(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "A"
				aMonitor := {oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento}
			Else
				aMonitor := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento
			EndIF

			For nX:=1 To Len(aMonitor)                                          					
				AADD( aListBox, {	If(aMonitor[nX]:nStatus <> 6 .And. aMonitor[nX]:nStatus <> 7 ,oNo,oOk),;
									If(aMonitor[nX]:nProtocolo <> 0 ,Alltrim(Str(aMonitor[nX]:nProtocolo)),""),;
									aMonitor[nX]:cId_Evento,;
									Alltrim(Str(aMonitor[nX]:nAmbiente)),;	
									Alltrim(Str(aMonitor[nX]:nStatus)),;
									If(!Empty(aMonitor[nX]:cCMotEven),Alltrim(aMonitor[nX]:cCMotEven),Alltrim(aMonitor[nX]:cMensagem)),;
									"" }) //XML manter devido ao TOTVS Colaboração.
				//Atualizacao do Status do registro de saida
				cOpcUpd := "3"					
				
				If aListBox[nX][5]	== "3" .Or. aListBox[nX][5] == "5"					
					cOpcUpd :=	"4"  //Evento rejeitado +msg rejeiçao					
				ElseIf aListBox[nX][5] == "6"  
					cOpcUpd := "3"  //Evento vinculado com sucesso
				ElseIf aListBox[nX][5] == "1"
					cOpcUpd := "2"  //Envio de Evento realizado - Aguardando processamento
				EndIF

				cChave:= Substr(aMonitor[nX]:cId_Evento,9,44)
				
				AtuCodeEve( cChave, cOpcUpd, cCodEve, cModelo, aListBox[nX][4], cIdEnt, cUrl )
				
			Next       

		EndIF

	EndIf

Else
	Aviso("SPED",STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return aListBox 

//-----------------------------------------------------------------------
/*/{Protheus.doc} AtuCodeEve()
Atualiza o com o codigo do evento as tabelas conforme modelo.

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param 	aRet   	   - Chaves de acesso das notas transmitidas
		cTpEvento  - Tipo do Evento em que a nota foi transmitida
	
/*/
//----------------------------------------------------------------------- 
function AtuCodeEve( cChave, cOpcUpd, cCodEve, cModelo, cAmbiente, cIdEnt, cUrl )

Local aArea	:= GetArea()

If cModelo <> '58' //MDFe

	C00->(DbSetOrder(1))
	If C00->(DBSEEK(xFilial("C00")+cChave))
	
		if alltrim(C00->C00_STATUS) == getSitConf(cCodEve)//Atualiza apenas evento atual 
			if cOpcUpd <> "4" 
				RecLock("C00")
				C00->C00_CODEVE := cOpcUpd
				MsUnlock()
			ElseIf cOpcUpd = "4" .and. alltrim(C00->C00_CODRET) = "999" //inclusão manual
				RecLock("C00")
				C00->C00_CODEVE := cOpcUpd
				MsUnlock()
			else
				//para Mde caso o evento seja rejeitado, executa monitor Md-e para retornar status anterior
				If lUsacolab
					MonitoraManif({cChave}, cAmbiente, /*cIdEnt*/, /*cURL + "/MANIFESTACAODESTINATARIO.apw"*/)
				Else
					MonitoraManif({cChave}, cAmbiente, cIdEnt, Alltrim(cURL) + "/MANIFESTACAODESTINATARIO.apw",,cOpcUpd)
				endif
			endif
		Else
			If alltrim(C00->C00_STATUS) <> '4'
				RecLock("C00")
				C00->C00_CODEVE := cOpcUpd
				MsUnlock() 
			endif
		
		endIf
	endif	

Else	
	If cCodEve == '110112'
		DTX->(DbSetOrder(7))
		If DTX->(DbSeek(xFilial("DTX")+cFilAnt+AllTrim(cChave)))
			RecLock("DTX")
			DTX->DTX_CODEVE := cOpcUpd  
			MsUnlock()
		EndIf
	Else
		DYN->(DbSetOrder(2))
		If DYN->(DbSeek(xFilial("DYN")+cFilAnt+AllTrim(cChave)))
			RecLock("DYN")
			DYN->DYN_CODEVE := cOpcUpd  
			MsUnlock()
		EndIf							
	EndIf
EndIf	

RestArea(aArea)
return
//-----------------------------------------------------------------------
/*/{Protheus.doc} AtuStatus()
Atualiza o Status da Manifestação de acordo com o Tipo de Evento

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param 	aRet   	   - Chaves de acesso das notas transmitidas
		cTpEvento  - Tipo do Evento em que a nota foi transmitida
	
/*/
//----------------------------------------------------------------------- 
Static Function AtuStatus(aRet,cTpEvento)

Local aAreas	:= {}

Local cStat		:= "0"
Local nX		:= 0

If cTpEvento $ '210200'
	cStat:= "1"  //Confirmada operação
ElseIf cTpEvento $ '210220'
	cStat:= "2"  //Desconhecimento da Operação
ElseIf cTpEvento $ '210240' 
	cStat:= "3"  //Operação não Realizada		 
ElseIf cTpEvento $ '210210' 
	cStat:= "4"  //Ciência da operação
EndIf

If Len(aRet) > 0
	aAreas := GetArea()
	For nX:=1 to Len(aRet)
		C00->(DbSetOrder(1))
		If C00->(DBSEEK(xFilial("C00")+aRet[nX]))
			RecLock("C00")
			C00->C00_STATUS := cStat
			C00->C00_CODEVE := "2"
			MsUnlock()
		EndIf
	Next
	RestArea(aAreas)	
EndIf	

Return 
//-----------------------------------------------------------------------
/*/{Protheus.doc} RetSitDoc()
Retorna a descrição do tipo da NF para mostrar a descrição na MarkBrow
Coluna (Sit.Nfe)

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param 	cSitDoc    - Codigo da Situação da NF(C00_SITDOC)

@return cDescSit   - Retorna a descrição do tipo da Nota
	
/*/
//----------------------------------------------------------------------- 
Static Function RetSitDoc(cSitDoc)

Local cDescSit	:= ""

If !Empty(cSitDoc)
	If Alltrim(cSitDoc) $ "1" 
     	cDescSit	:= STR0442  //"Uso autorizado da NFe"
    ElseIf Alltrim(cSitDoc) $ "2"
    	cDescSit	:= STR0443	//"Uso denegado"
    ElseIf Alltrim(cSitDoc) $ "3"
    	cDescSit	:= STR0444	//"NFe cancelada"
    EndIf	
EndIf

Return cDescSit
//-----------------------------------------------------------------------
/*/{Protheus.doc} RetSitEve()
Retorna a descrição do processamento do Evento
Coluna (Sit.Evento)

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param 	cCodEve    - Codigo do Evento(C00_CODEVE)

@return cDescEve   - Retorna a descrição do Codigo do evento
	
/*/
//----------------------------------------------------------------------- 
Static Function RetSitEve(cCodEve)

Local cDescEve	:= ""

If !Empty(cCodEve)
	If Alltrim(cCodEve) $ "1" 
     	cDescEve	:=	STR0445//"Envio de Evento não realizado"
    ElseIf Alltrim(cCodEve) $ "2"
    	cDescEve	:=	STR0446//"Envio de Evento realizado - Aguardando processamento"
    ElseIf Alltrim(cCodEve) $ "3"
    	cDescEve	:=	STR0447//"Evento vinculado com sucesso"
    ElseIf Alltrim(cCodEve) $ "4"
    	cDescEve	:=	STR0448//"Evento rejeitado - Verifique o monitor para saber os motivos"	
    EndIf	
EndIf

Return cDescEve
//-----------------------------------------------------------------------
/*/{Protheus.doc} btLegMonit()
Legenda dos eventos no menu 'Monitorar'

@author Natalia Sartori
@since 04.07.2012
@version 1.00
/*/
//-----------------------------------------------------------------------  
Function RetLegMon()
Return btLegMonit()      

Static Function btLegMonit()

Local aLegenda:= {}

AADD(aLegenda, {"ENABLE"		,STR0447})//"Evento vinculado com sucesso"
AADD(aLegenda, {"DISABLE"		,STR0449})//"Evento não vinculado"

BrwLegenda(cCadastro,STR0117,aLegenda) 

Return 
//-----------------------------------------------------------------------
/*/{Protheus.doc} btVisuXml()
Visualização do xml do evento no menu Monitorar

@author Natalia Sartori
@since 04.07.2012
@version 1.00 

@param cIdEvento - ID do Evento
/*/
//-----------------------------------------------------------------------  
Function RetVisuXml(cIdEvento)
Return btVisuXml(cIdEvento)

Static Function btVisuXml(cIdEvento,cXml)

Local cURL     		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lUsaColab	:= .F.
Local cIdEnt		:= ""

Local lOk      		:= .T.

Local oWS			:= Nil
Default cXml		:= ""

if substr(Alltrim(cIdEvento),3,6) $ "210200-210210-210220-210240"
	lUsaColab := UsaColaboracao("4")
endif

cIdEnt		:= RetIdEnti(lUsaColab)

if !Empty(cXml)
	
	Aviso("Xml do Evento",cXml,{STR0114},3)
		
elseIf ReadyTSS()
	// Executa o metodo NfeRetornaEvento()
	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN	:= "TOTVS"
	oWS:cID_ENT		:= cIdEnt 
	oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
	oWS:cID_EVENTO	:= cIdEvento
	lOk:=oWS:NFERETORNAEVENTO()
	
	If lOk
		If ValType(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) <> "U" .and. Len(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) > 0
			If !Empty(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento[1]:CXML_SIG)
				Aviso("Xml do Evento",DecodeUtf8(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento[1]:CXML_SIG),{STR0114},3)
			Else 
				Aviso("Xml do Evento","Xml ainda não gerado",{STR0114},3)
			EndIf		
		EndIf
	EndIf
Else
	Aviso("SPED",STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf
	
Return 

//-----------------------------------------------------------------------
/*/{Protheus.doc} BaixaZip()
Montagem da Dialog 'Exportar Zip'

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param cAlias, nReg, nOpc, cMarca, lInverte
/*/
//----------------------------------------------------------------------- 
Function BaixaZip(nOpc)

Local aArea		:= GetArea()
Local aPerg		:= {}	
Local aParam	:= {Space(3),Space(09),Space(09),Space(60),Space(1)}
Local aChaves	:= {}
Local aXmlRet	:= {}

Local cPaExpXml	:= SM0->M0_CODIGO+SM0->M0_CODFIL+"BxXml"
Local cWhere	:= ""
Local cAliasTemp:= GetNextAlias()
Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cIdEnt	:= RetIdEnti(lUsaColab)
Local cAmbiente	:= ""
Local cAviso	:= ""
Local cHelp		:= ""
Local lParamOk	:= .F.
Local lRet		:= .F.

Local nX		:= 0
Local nY		:= 0
Local nZ		:= 0
Local nW		:= 0
Local nXAux		:= 0
Local nQtdChv	:= 0

//Váriável que define se vai ser a exportação direta ou irá montar browse para marcar - usado apenas para TOTVS Colaboração
Default nOpc		:= 0

Private oRet
	
If ReadyTss()
	MV_PAR01 := aParam[01] := PadR(ParamLoad(cPaExpXml,aPerg,1,aParam[01]),Len(C00->C00_SERNFE))
	MV_PAR02 := aParam[02] := PadR(ParamLoad(cPaExpXml,aPerg,2,aParam[02]),Len(C00->C00_NUMNFE))
	MV_PAR03 := aParam[03] := PadR(ParamLoad(cPaExpXml,aPerg,3,aParam[03]),Len(C00->C00_NUMNFE))
	MV_PAR04 := aParam[04] := ParamLoad(cPaExpXml,aPerg,4,aParam[04])
	MV_PAR05 := aParam[05] := ParamLoad(cPaExpXml,aPerg,5,aParam[05])
		
	aadd(aPerg,{1,STR0010,aParam[01],"",".T.","",".T.",30,.F.})	//"Serie da Nota Fiscal"
	aadd(aPerg,{1,STR0011,aParam[02],"",,"",".T.",30,.F.})	//"Nota fiscal inicial"
	aadd(aPerg,{1,STR0012,aParam[03],"",,"",".T.",30,.F.}) 	//"Nota fiscal final"

	if !lUsaColab
		aadd(aPerg,{6,STR0119,aParam[04],"",".T.","!Empty(mv_par04)",80,.T.," |*.","c:\",GETF_RETDIRECTORY+GETF_LOCALHARD,.F.}) //"Diretório de destino"
	endif

	If ( Left(LTrim(cVersaoTSS),2) <> "12" .And. Val(cVersaoTSS) < 271 ) .Or. ( Left(LTrim(cVersaoTSS),2) == "12" .And. Val(cVersaoTSS) < 121016 )
	   aadd(aPerg,{2,"Exportar arquivos",aParam[05],{"1=Separados","2=Unificados"},50,".T.",.F.}) 	//"Unificado ou Separado"
	Endif
		
	if nOpc == 0
		MsgInfo(STR0450)//"Serão consideradas apenas as notas com status 'Confirmada Operação e 'Ciência da Operação'"
	endif	
	
	If ParamBox(aPerg,"Exportar",aParam,,,,,,,cPaExpXml,.T.,.T.)
	
		cWhere += "%"
		cWhere += " C00_FILIAL='"+xFilial("C00")+"'"
		cWhere += " AND C00_NUMNFE BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'"
		cWhere += " AND C00_SERNFE = '" + MV_PAR01+ "'"					
		cWhere += " AND C00_STATUS IN ('1','4') "

		//Ponto de entrada para customizar o filtro dos itens exportados.
		If ExistBlock("MDeExpFil")	
			cWhere += ExecBlock("MDeExpFil",.F.,.F.)					
		EndIf
		cWhere += "%"	

		BeginSql Alias cAliasTemp				
			SELECT C00_CHVNFE
			FROM %Table:C00%    
			WHERE %Exp:cWhere% AND
			%notdel%
		EndSql
	
		(cAliasTemp)->(dbGotop())
					
		If (cAliasTemp)->(Eof())
			Aviso("Baixar ZIP",STR0451,{STR0114},3)//"As notas selecionadas não foram localizadas. Verifique os parâmetros de busca."
			Return nil
		Else 
			While !(cAliasTemp)->(Eof())
				aadd(aChaves,(cAliasTemp)->C00_CHVNFE)
				(cAliasTemp)->(dbSkip())
			End
		EndIf
		(cAliasTemp)->(dbCloseArea())
		RestArea(aArea)
		
		if lUsaColab
			if nOpc == 0
				if Len( aChaves ) > 0
					Processa({|| lRet := ColMdeDown(aChaves,@cAviso) },"Processando","Aguarde, realizando as solicitações de download",.T.)					
				endif
			else
				Processa({|| lRet := ColDownTela( aChaves )},"Processando","Aguarde, abrindo monitor para download",.T.)
			endif
			 	
		else
			oWs :=WSMANIFESTACAODESTINATARIO():New()
			oWs:cUserToken   := "TOTVS"
			oWs:cIDENT	     := cIdEnt
			oWs:cAMBIENTE	 := ""
			oWs:cVERSAO      := ""
			oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw" 
			oWs:CONFIGURARPARAMETROS()
			cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE 
			
			oWs:cUserToken   := "TOTVS"
			oWs:cIDENT	     := cIdEnt
			oWs:cAMBIENTE	 := cAmbiente
			
			oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
			
			cAviso := "Arquivos gerados: "+ CRLF + CRLF + "Série  Número" + CRLF
			
			While nQtdChv < Len(aChaves)
			
				oWs:oWSDOCUMENTOS:oWSDOCUMENTO  := MANIFESTACAODESTINATARIO_ARRAYOFBAIXARDOCUMENTO():New()  
				
				If (Len(aChaves) - nQtdChv) < 5
					nXAux := 1
					For nX:= nQtdChv+1 to Len(aChaves)
						aadd(oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO,MANIFESTACAODESTINATARIO_BAIXARDOCUMENTO():New())
						oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO[nXAux]:CCHAVE := aChaves[nX]
						nXAux++
						nQtdChv++					
					Next nX
					If oWs:BAIXARXMLDOCUMENTOS()
						If Type ("oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") <> "U"
							If Type ("oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") == "A"
								aXmlRet := oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET
							Else 
								aXmlRet := {oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET}
							EndIf
						EndIF
						
						Processa({|| lRet := VerifProces(oRet,aXmlRet,aParam,@cAviso)},"Processando","Aguarde, exportando arquivos",.T.)
						
					EndIf
			    Else
			    	For nY:= 1 to 5
			    		aadd(oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO,MANIFESTACAODESTINATARIO_BAIXARDOCUMENTO():New())
						oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO[nY]:CCHAVE := aChaves[nY+nQtdChv]		    				    		
			    	Next nY                                                                                     
			    	nQtdChv := nQtdChv + 5
			    	
			    	If oWs:BAIXARXMLDOCUMENTOS()
			    		If Type ("oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") <> "U"
							If Type ("oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") == "A"
								aXmlRet := oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET
							Else 
								aXmlRet := {oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET}
							EndIf
						EndIF
						Processa({|| lRet := VerifProces(oRet,aXmlRet,aParam,@cAviso)},"Processando","Aguarde, exportando arquivos",.T.)
			    	EndIf
			    EndIf
			EndDo
		endif
		
		If lRet .And. nOpc == 0
		 	Aviso(IIF(lUsaColab,"Solicitar Download","Baixar ZIP"),cAviso,{STR0114},3)
		ElseIf nOpc == 0
			cHelp := STR0452//"Não existem arquivos para serem exportados."
			Aviso(IIF(lUsaColab,"Solicitar Download","Baixar ZIP"),cHelp,{STR0114},3)
		EndIF	
	EndIf
Else
	Aviso("SPED",STR0021,{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf
 
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} getColorStat
Atualiza cor da legenda do listbox no menu 'manifestar'

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param	cStatus		Status da Manifestaçao (C00_STATUS)	

@return	oClrRet 	Cor da legenda no listbox		
/*/
//-----------------------------------------------------------------------
Static function getColorStat( cStatus )

Local oAzul    := LoadBitmap( GetResources(), "BR_AZUL" )
Local oBranco  := LoadBitmap( GetResources(), "BR_BRANCO" )
Local oCinza   := LoadBitmap( GetResources(), "BR_CINZA" )
Local oVerde   := LoadBitmap( GetResources(), "BR_VERDE" )
Local oVermelho:= LoadBitmap( GetResources(), "BR_VERMELHO" )
Local oClrRet 

If ( cStatus == "0" )
	oClrRet := oBranco
Elseif ( cStatus == "1" )
	oClrRet := oVerde
Elseif ( cStatus == "2" )
	oClrRet := oCinza
Elseif ( cStatus == "3" )
	oClrRet := oVermelho
Elseif ( cStatus == "4" )
	oClrRet := oAzul			
endif

return oClrRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} ValidManif
Função de validação do botão Manifestar, para continuar ou não o 
processamento

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param	cOpcEve		Opção da manifestação	
		cJustific   Justificativa do Operação não realizada
		aListBox    Array com todas as notas do listbox
		aMontXml    Array com as notas selecionadas no listbox
	
@return	lContinua	Continua ou não o processamento da manifestação		
/*/
//-----------------------------------------------------------------------
Static Function ValidManif( cOpcEve, cJustific, aListBox, aMontXml, lValid )

Local aProcessa := {}

Local lContinua	:= .T.    
Local lCiencia	:= .F.

Local nOpcJust	:= 2
Local nX		:= 0  
Local nCount	:= 0

Default lValid	:= .T.

If lValid
	For nX:=1 to Len(aListBox)
		If aListBox[nX][11]
			aadd(aMontXml,aListBox[nX])
		else
			nCount++
		EndIf	
	Next   
	
	If ( nCount == len(aListBox) )
		msgInfo(STR0453)//"Para manifestar deve ser selecionada ao menos uma nota."
		return .F.
	endif
EndIf

//Valida se o manifesto esta pendente
If lValid
	For nX:=1 to Len(aMontXml)
		If Alltrim(aMontXml[nX][13]) == '2'
			msgInfo(STR0497) //Existe uma ou mais notas com manifestação pendente, por favor verificar o monitor. 
			return .F.
		Endif
	Next   
EndIf

If ( cOpcEve $ "210240 - Operação não Realizada" )

	nOpcJust := Aviso("Manifesto - Justificativa de Op. não realizada",@cJustific,{"Confirma","Cancela"},3,,,,.T.)
	
	cJustific := allTrim(cJustific)
	
	If( ( nOpcJust == 1 .and. ( len(cJustific) <= 15 .or. empty(cJustific) ) ) )
		msgInfo("A justificativa para "+cOpcEve+" deve ser preenchida com mais de 15 caracteres.")
		lContinua := ValidManif( cOpcEve, @cJustific,aListBox,aMontXml,.F.)		
	Elseif ( nOpcJust == 2 )
		lContinua	:= .F.
		aMontXml	:= {}
	Endif

Elseif ( cOpcEve $ "210210 - Ciência da Operação" )  

	For nX := 1 to Len(aMontXml)
	
		If !(Alltrim(aMontXml[nX][12]) == "4" .and. Alltrim(aMontXml[nX][13]) == "3")
  			aAdd(aProcessa,aMontXml[nX])
  		else
  			lCiencia := .T.
		EndIf
		
	Next 
	
	If ( lCiencia )
		If ( empty(aProcessa) )
			msgInfo("As notas selecionadas já foram manifestadas com a opção:"+CRLF+cOpcEve+CRLF+"Selecione outras notas")
			lContinua := .F.
		Else
			If MsgYesNo("Existem notas selecionadas que já foram manifestadas com a opção:"+CRLF+cOpcEve+CRLF+CRLF+"Deseja ignorá-las na transmissão?"+CRLF+CRLF+;
						"IMPORTANTE"+CRLF+;
						"Ao selecionar a opção 'Não', nenhuma manifestação será transmitida!")
			
				lContinua := .T.				
			Else
				lContinua := .F.
				aMontXml  := {}
			Endif
		Endif
	Endif
		
	If ( lContinua )
		aMontXml  := aclone(aProcessa)
	Endif
	
Endif

Return lContinua 

//-----------------------------------------------------------------------
/*/{Protheus.doc} VerifProces() 

Função auxiliar para o processamento da exportação do arquivo zip

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param oRet, aXmlRet, aParam, cAviso 

@return lRet - Se o arquivo foi gerado ou não
/*/
//----------------------------------------------------------------------- 
Static Function VerifProces(oRet,aXmlRet,aParam,cAviso)

Local nZ 		:= 0
Local lRet 		:= .F.

ProcRegua(Len(aXmlRet))

For nZ:=1 to Len(aXmlRet)
	IncProc()
	oRet := aXmlRet[nZ]
	If GeraArq( aParam, oRet )
		lRet := .T.
	 	cAviso += SubStr(oRet:CCHAVE,23,3)+ "    "+SubStr(oRet:CCHAVE,26,9) + CRLF
	EndIf	
Next

Return(lRet)

//-----------------------------------------------------------------------
/*/{Protheus.doc} GeraArq() 

Função que exporta os arquivos conforme o retorno do método

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param aParam		- Parametros do parambox
        oRetorno	- Retorno do metodo com o resultado da solicitação
       
@return lRet	- Arquivo gerado ou não       
/*/
//----------------------------------------------------------------------- 
Static Function GeraArq(aParam,oRetorno)

Local cDestino 	:= ""
Local cDrive   	:= ""
Local cNfeProt  := ""
Local cNfe		:= ""
Local cNfeProc	:= ""
Local cChave	:= ""
Local cNfeProtzi:= ""
Local cNfeZip	:= ""
Local cNfeProcZi:= ""
Local cExportar	:= ""

Local lRet		:= .F.

Local nHandle	:= 0
If ( Left(LTrim(cVersaoTSS),2) <> "12" .And. Val(cVersaoTSS) < 271 ) .Or. ( Left(LTrim(cVersaoTSS),2) == "12" .And. Val(cVersaoTSS) < 121016 )
	cExportar := aParam[5]	// 1=Separado ou 2=Unificado
Endif

oRet := oRetorno

SplitPath(aParam[04],@cDrive,@cDestino,"","")
cDestino := cDrive+cDestino


If Type ("oRet:CCHAVE") <> "U" .and. !Empty(oRet:CCHAVE)
	cChave	:= oRet:CCHAVE
EndIf
If Type ("oRet:CCHVSTATUS") <> "U" .and. (!Empty(oRet:CCHVSTATUS) .and. ('138' $ oRet:CCHVSTATUS .or. '140' $ oRet:CCHVSTATUS .or. '656' $ oRet:CCHVSTATUS))   //140: Download disponibilizado - 656:Consumo indevido (tras dos campos da SPED156)
	If Type ("oRet:CNFEPROTZIP") <> "U" .and. !Empty(oRet:CNFEPROTZIP)
		cNfeProtZi	:= oRet:CNFEPROTZIP
	EndIf
	If Type ("oRet:CNFEZIP") <> "U" .and. !Empty(oRet:CNFEZIP)
		cNfeZip	:= oRet:CNFEZIP
	EndIf
	If Type ("oRet:CNFEPROCZIP") <> "U" .and. !Empty(oRet:CNFEPROCZIP)
		cNfeProcZi	:= oRet:CNFEPROCZIP
	EndIf
EndIf	 

If !Empty(cChave)

	If ( Left(LTrim(cVersaoTSS),2) <> "12" .And. Val(cVersaoTSS) >= 271 ) .Or. ( Left(LTrim(cVersaoTSS),2) == "12" .And. Val(cVersaoTSS) >= 121016 )
	
		If !Empty( cNfeProcZi ) .AND. !'<nfeProc' $ cNfeProcZi
			nHandle  := FCreate( cDestino+cChave+"-"+"nfeProc.gz" )
			If nHandle > 0
				FWrite( nHandle, cNfeProcZi )
				FClose( nHandle )
				lRet   := .T.
			EndIf
		EndIf
	
	Else
	
		If cExportar == "1"	// Separado
		
			If !Empty(cNfeProtZi) .AND. !'<protNFe' $ cNfeProtZi
				cNfeProt := EncodeUtf8(Decode64(cNfeProtZi))
				nHandle  := FCreate(cDestino+cChave+"-"+"protNFe.zip")
				If nHandle > 0
					FWrite ( nHandle, cNfeProt)
					FClose(nHandle)
					lRet	:= .T.
				EndIf	
			EndIf
	
			/*Inserido este If pois para os Estados diferentes de RS,o retorno não vem zipado e não é necessário dar o decode64*/
			If '<protNFe' $ cNfeProtZi
				nHandle  := FCreate(cDestino+cChave+"-"+"protNFe.xml")
				If nHandle > 0
					FWrite ( nHandle, EncodeUtf8(cNfeProtZi))
					FClose(nHandle)
					lRet	:= .T.
				EndIf 
			EndIf		
			
			If !Empty(cNfeZip) .AND. !'<NFe' $ cNfeZip
				cNfe := EncodeUtf8(Decode64(cNfeZip))
				nHandle  := FCreate(cDestino+cChave+"-"+"NFeZip.zip")
				If nHandle > 0
					FWrite ( nHandle, cNfe)
					FClose(nHandle)
					lRet	:= .T.          
				EndIf	
			EndIf
			/*Inserido este If pois para os Estados diferentes de RS,o retorno não vem zipado e não é necessário dar o decode64*/
			If '<NFe' $ cNfeZip
				nHandle  := FCreate(cDestino+cChave+"-"+"XmlNFe.xml")
				If nHandle > 0
					FWrite ( nHandle, EncodeUtf8(cNfeZip))
					FClose(nHandle)
					lRet	:= .T.
				EndIf 
			EndIf
	
		Endif
		
		If cExportar == "2"	// Unificado
		
			if '<protNFe' $ cNfeProtZi .And. '<NFe' $ cNfeZip
				nHandle  := FCreate(cDestino+cChave+"-"+"nfeProc.xml")
				nAt	:= At(' versao="', cNfeZip )
				cVersao := SubStr(cNfeZip,nAt,14)		
				If nHandle > 0
					FWrite ( nHandle, EncodeUtf8('<nfeProc'+cVersao+' xmlns="http://www.portalfiscal.inf.br/nfe">'+cNfeZip+cNfeProtZi+'</nfeProc>'))
					FClose(nHandle)
					lRet	:= .T.
				EndIf
			endif
			
			If !Empty(cNfeProcZi)
				cNfeProc := EncodeUtf8(Decode64(cNfeProcZi))
				nHandle  := FCreate(cDestino+cChave+"-"+"procNFe.zip")
				If nHandle > 0
					FWrite ( nHandle, cNfeProc)
					FClose(nHandle)
					lRet	:= .T.
				EndIf	
			EndIf

		Endif
		
	Endif

EndIf		

Return lRet  

//-----------------------------------------------------------------------
/*/{Protheus.doc} ValidAPerg() 

Função que valida a máscara das perguntas do filtro

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param cPerg 	- Pergunta do parambox

@return lRet	- Libera o cursor para o proximo campo      
/*/
//----------------------------------------------------------------------- 
Function ValidAPerg(cPerg)

Local lRet := .F.
 
If cPerg == "Cnpj"
	If Len(Alltrim(MV_PAR01)) == 14 .or. Empty(MV_PAR01)
		lRet := .T.
	EndIf	
Elseif cPerg == "Cpf"	
	If Len(Alltrim(MV_PAR02)) == 11 .or. Empty(MV_PAR02)
		lRet := .T.		
	EndIf
ElseIf cPerg == "Ano"
	If len(Alltrim(MV_PAR08)) == 4 .or. Empty(MV_PAR08) 
		lRet := .T.
	EndIf
EndIf	    

Return lRet

static function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
endif
return (lUsa)

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} getAmbMde()

retorna ambiente de configuração do Md-e

@param	

@return cAmbiente		Ambiente 
/*/
//-------------------------------------------------------------------------------------------
static function getAmbMde()
	
	local cAmbiente := ""
	local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)	
	local oWs
	local lUsacolab := UsaColaboracao("4")
	
	if !lUsacolab .and. ReadyTSS()
		oWs :=WSMANIFESTACAODESTINATARIO():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cIDENT	     := retIdEnti(lUsacolab)
		oWs:cAMBIENTE	 := ""
		oWs:cVERSAO      := ""
		oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw" 
		oWs:CONFIGURARPARAMETROS()
		cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE
	
		freeObj(oWs)
		oWs := nil 	

	endif

return cAmbiente

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} getDescEvento()

retorna desrção do evento

@param	cEvento	codigo do evento

@return cDesc		descrição do evento 
/*/
//-------------------------------------------------------------------------------------------
static Function getDescEvento(cEvento)
	local cDesc := ""
	
	do case
		case cEvento == "210200"
			cDesc := "Confirmação da Operação"
		case cEvento == "210210"
			cDesc := "Ciencia da Operação"
		case cEvento == "210220"
			cDesc := "Desconhecimento da Operação"						
		case cEvento == "210240"
			cDesc := "Operação não Realizada"			
	end Case
return cDesc
//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} listaEventos()

Apresenta dados dos eventos emitidos para a Nfe

@param

@return nil 
/*/
//-------------------------------------------------------------------------------------------

function listaEventos( cAlias, nReg, nOpc,cMarca, lInverte )

	local cAliasC00		:= getNextAlias() 
	local aListBox		:= {}
	local aObjects	:= {}
	local aSize		:= MsAdvSize()
	local aPosObj		:= {}
	local cMensagem	:= ""
	local nCount		:= 0
	local lOk			:= .T.
	local oListBox
	local oDlg			:= nil
	
		
	BeginSql ALIAS cAlias
		SELECT C00_CHVNFE
		FROM %table:C00%
		WHERE C00_OK = %exp:cMarca%
		AND %NOTDEL%
	endSql
	
	while( (cAlias)->( !eof() ) )
		nCount++
		cChave := (cAlias)->C00_CHVNFE
		(cAlias)->(dbSkip())
	end

	aListBox := retornaEventos(cChave , @cMensagem)

	if( len(aListBox) == 0 )
		aviso("SPED", cMensagem ,{"OK"},3)
	elseif nCount > 1
		aviso("SPED", "Selecione o documento a ser consultado." ,{"OK"},3)
	else
	
		DEFINE FONT oBold BOLD	
		
		DEFINE MSDIALOG oDlg TITLE "Eventos" FROM 0,0 TO  430, 900 PIXEL
		@015, 010 SAY oSay PROMPT "Histórico de Eventos" OF oDlg FONT oBold PIXEL SIZE 230, 030 //"Esta opção tem por objetivo sincronizar com a Sefaz os documentos"                                                                     
		@030,010 LISTBOX oListBox 	FIELDS HEADER "  ","Lote","protocolo","Evento","Descrição","Status Evento" OF oDlg SIZE 435, 160 PIXEL	
		
		oListBox:SetArray(aListBox)
		
		oListBox:bLine :={||	{	aListBox[oListBox:nAt][01],;
		        					aListBox[oListBox:nAt][02],;
		        					aListBox[oListBox:nAt][03],;
		        					aListBox[oListBox:nAt][04],;
		        					getDescEvento( aListBox[oListBox:nAt][04] ),;
		        					aListBox[oListBox:nAt][05]}}
 
		@195,010 BITMAP oBmpVerd RESOURCE "BR_VERDE.PNG" NO BORDER SIZE 017, 017 OF oDlg PIXEL
		@195,020 SAY oSay PROMPT "Evento autorizado"  SIZE 100,010 PIXEL OF oDlg //Confirmada
		@195,070 BITMAP oBmpVerd RESOURCE "BR_VERMELHO.PNG" NO BORDER SIZE 017, 017 OF oDlg PIXEL
		@195,080 SAY oSay PROMPT "Evento rejeitado"  SIZE 100,010 PIXEL OF oDlg //Confirmada
		
		@195,410 BUTTON oBtn1 PROMPT "Sair"		ACTION (oDlg:end())  OF oDlg PIXEL SIZE 035,011 //"Refresh"
		
		ACTIVATE MSDIALOG oDLg CENTERED
						
	endif	

	(cAlias)->(dbGoto(nRecno))	

return nil

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} retornaEventos()

retorna os eventos de Nfe

@param cChaveNfe		Chave da nota fiscal

@return aList			Array com dados do evento
						aList[nX][1]	Legenda: oOk = autorizado oNo="Rejeitado"
						aList[nX][2]	numero do lote
						aList[nX][3]	Protocolo
						aList[nX][4]	codigo do evento
						aList[nX][5]	Status processamento
						
								
/*/
//-------------------------------------------------------------------------------------------
function retornaEventos(cChaveNfe, cMensagem)
	 
	local aList	:= {}
	local aMonitor:= {}
	local cUrl		:=  PadR(GetNewPar("MV_SPEDURL","http://"),250)
	local lUsaColab	:= UsaColaboracao("4")
	local cIdEnt	:= RetIdEnti(lUsaColab)
	
	local nX		:= 0
	local oOk		:= loadBitmap(getResources(), "ENABLE" )	
	local oNo		:= loadBitmap(getResources(), "DISABLE" )

	local oWs
	
	default cMensagem := ""
	
	if readyTss()
		oWs					:= WSNFESBRA():new()
		oWs:_Url			:= cUrl+"/nfesBra.apw" 
		oWs:cUserToken	:= "TOTVS"
		oWs:cId_Ent		:= cIdEnt
		oWs:cEvenChvNfe	:= cChaveNfe
		
		if oWs:nfeRetornaEvento()
			
			if( valtype(oWs:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) <> "A"  )
				aMonitor := {oWs:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento}
			else
				aMonitor := oWs:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento
			endif

			for nX := 1 to len(aMonitor)
				aadd(aList,	{	if(aMonitor[nX]:nStatus == 6 .or. aMonitor[nX]:nStatus == 7, oOk, oNo),;
									cValToChar(aMonitor[nX]:nLote),;
									cValToChar(if( aMonitor[nX]:nProt = 0,"",aMonitor[nX]:nProt )),;
									substr(aMonitor[nX]:cId_Evento, 3, 6 ),;
									alltrim(if( empty(aMonitor[nX]:cXmotivoEven), aMonitor[nX]:cXmotivo, aMonitor[nX]:cXmotivoEven )),;
									})

			next
		
			cAmbiente := getAmbMde()
			MonitoraManif({cChaveNfe},cAmbiente,cIdEnt,cUrl)
		else
			cMensagem := if(empty(getWscError(3)),getWscError(1),getWscError(3)) 
		endif 
	else
		cMensagem := STR0021//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"		
	endif
	
	aSort(aList, , , {|x,y| x[2] > y[2]})
	
	aMonitor := asize(aMonitor,0)
	aMonitor := nil	
	
return aList	


static  function getSitConf(cCodEvento)
	
	local cSitConf := "0"

	cCodEvento := alltrim(cCodEvento)
		
	do case
		case cCodEvento == "210200"
			cSitConf := "1"
		case cCodEvento == "210210"
			cSitConf := "4"
		case cCodEvento == "210220"
			cSitConf := "2"
		case cCodEvento == "210240"
			cSitConf := "3"									
	endCase	
	
return cSitConf

/******************************************************************************************************************************
* Sessao MD-e
******************************************************************************************************************************/
//----------------------------------------------------------------------
/*/{Protheus.doc} MDeInclui
Montagem da Dialog de inclusão do MDe

@author Natalia Sartori
@since 30/07/2015
@version P11 

@param	cAlias, nReg, nOpc, cMarca
@Return Nil
/*/
//-----------------------------------------------------------------------
Function MDeInclui(cAlias, nReg, nOpc, cMarca)
	MDeShowDlg(cAlias, nReg, nOpc, cMarca)
Return 
//----------------------------------------------------------------------
/*/{Protheus.doc} MDeAltera
Montagem da Dialog de alteração do MDe

@author Natalia Sartori
@since 30/07/2015
@version P11 

@param	cAlias, nReg, nOpc, cMarca
@Return Nil 
/*/
//-----------------------------------------------------------------------
Function MDeAltera(cAlias, nReg, nOpc, cMarca)
	MDeShowDlg(cAlias, nReg, nOpc, cMarca)
Return

//----------------------------------------------------------------------
/*/{Protheus.doc} MDeExclui
Montagem da Dialog de exclusão do MDe

@author Natalia Sartori
@since 30/07/2015
@version P11 

@param	cAlias, nReg, nOpc, cMarca
@Return Nil
/*/
//-----------------------------------------------------------------------
Function MDeExclui(cAlias, nReg, nOpc, cMarca)
	MDeShowDlg(cAlias, nReg, nOpc, cMarca)
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} MDeShowDlg()
Montagem da Dialog 'MD-e Manual e suas opções'

@author Natalia Sartori
@since 30.07.2015
@version P11

@param cAlias, nReg, nOpc, cMarca
@Return Nil
/*/
//-----------------------------------------------------------------------   
Function MDeShowDlg(cAlias, nReg, nOpc, cMarca)    

Local aListBox	:= {}

Local cAliasC00	:= GetNextAlias()
Local cWhere	:= ""
Local cChave1	:= Space(TamSx3("C00_CHVNFE")[1])
Local cSerie	:= Space(TamSx3("C00_SERNFE")[1])
Local cNumNFe	:= Space(TamSx3("C00_NUMNFE")[1])
Local cCNPJEM	:= Space(TamSx3("C00_CNPJEM")[1])
Local cRazao	:= Space(TamSx3("C00_NOEMIT")[1])
Local cIEemit	:= Space(TamSx3("C00_IEEMIT")[1])
Local cOperation	:= ""
Local dDtAut	:= Date()
local dDtEmis	:= Date()


Local nValNFe	:= 0

Local lContinue := .F.
Local lIncluir	:= .F.
Local lAlterar	:= .F.
Local lExcluir	:= .F.

Local oDlg
Local oTBut1
Local oTBut2
Local oGrpForm1
Local oGrpForm
Local oRazao
Local oRazao1
Local oCnpjEmi
Local oIEEst
Local oIEEst1
Local oDtEmis
Local oDtEmis1
Local oDtAut
Local oDtAut1
Local oChave
Local oChave1
Local oSerie

Local oNumNFe
Local oValNFe
Local oValNFe1

Private oSerie1
Private oNumNFe1
Private oCnpjEmi1

	Do Case
		Case nOpc == 1
			cOperation := "Incluir"
			lIncluir := .T.
		Case nOpc == 2
			cOperation := "Alterar"
			lAlterar := .T.
		Case nOpc == 3
			cOperation := "Excluir"
			lExcluir := .T.
	EndCase


		cWhere+="%C00.C00_FILIAL='"+xFilial("C00")+"' AND C00.C00_OK ='"+cMarca+"' "+cCondQry+"%"
				
		BeginSql Alias cAliasC00
		
		SELECT C00_CHVNFE,C00_SERNFE,C00_NUMNFE,C00_VLDOC,C00_CNPJEM,C00_NOEMIT,C00_IEEMIT,C00_DTEMI,C00_DTREC,C00_CODRET,C00_STATUS,C00_DESRES,R_E_C_N_O_
		FROM %Table:C00% C00
		WHERE %Exp:cWhere% AND
		C00.%notdel%
		EndSql                                                                             
		
		TcSetField(cAliasC00,"C00_DTEMI"  ,"D",008,0)
		TcSetField(cAliasC00,"C00_DTREC" ,"D",008,0)
		      
		While (cAliasC00)->(!Eof())
			aadd(aListBox,{(cAliasC00)->C00_CHVNFE,(cAliasC00)->C00_SERNFE,(cAliasC00)->C00_NUMNFE,(cAliasC00)->C00_VLDOC,(cAliasC00)->C00_CNPJEM,(cAliasC00)->C00_NOEMIT,(cAliasC00)->C00_IEEMIT,(cAliasC00)->C00_DTEMI,(cAliasC00)->C00_DTREC,(cAliasC00)->C00_STATUS,(cAliasC00)->C00_CODRET,(cAliasC00)->C00_DESRES})
			(cAliasC00)->(dbSkip())
		End
	   
	   	If Len(aListBox) == 1 .or. lIncluir 
	   		If lIncluir // inclui array vazio
	   			aadd(aListBox,{"","","",0,"","","","","","","",""})
	   		EndIf
	   		If (aListBox[1][10] == '0' .and. aListBox[1][11] $ '999' .and. Alltrim(aListBox[1][12]) $ 'Documento incluido manualmente') .or. lIncluir
				DEFINE MSDIALOG oDlg TITLE "MD-e manual - " + cOperation FROM 0,0 TO  300, 700 PIXEL
			
				DEFINE FONT oFont BOLD
				
				If lAlterar .or. lExcluir
					GetDetails(aListBox[1],@cChave1,@cSerie,@cNumNFe,@nValNFe,@dDtEmis,@dDtAut,@cRazao,@cCNPJEM,@cIEemit)
				EndIf
				
				//======================= Borda ===========================
				@010,010 GROUP oGrpForm TO 130,340  PROMPT "Dados da Nota" OF oDlg PIXEL //250,340
				@070,015 GROUP oGrpForm1 TO 118,335  PROMPT "Emitente" OF oGrpForm PIXEL  
				
				//======================= Says e Gets ===========================
				@030,015 SAY oChave PROMPT "Chave" OF oDlg FONT oFont PIXEL SIZE 230, 030
				@030,035 MSGET oChave1 VAR cChave1 PICTURE ("@R " + Replicate("9",44)) SIZE 140,008 PIXEL OF oDlg WHEN lIncluir
				oChave1:bChange := {|| LoadSerNum(cChave1,@cSerie,@cNumNFe,@cCNPJEM)}
				
				@030,180 SAY oSerie PROMPT "Série" OF oDlg FONT oFont PIXEL SIZE 230, 030
				@030,198 MSGET oSerie1	VAR cSerie	PICTURE "@!"  SIZE 020,008 PIXEL OF oDlg WHEN .F. 
				
				@030,225 SAY oNumNFe PROMPT "Número" OF oDlg FONT oFont PIXEL SIZE 240, 030
				@030,250 MSGET oNumNFe1	VAR cNumNFe	PICTURE "@!"  SIZE 050,008 PIXEL OF oDlg WHEN .F.
				
				@050,015 SAY oValNFe PROMPT "Valor" OF oDlg FONT oFont PIXEL SIZE 240, 030
				@050,035 MSGET oValNFe1	VAR nValNFe	PICTURE "@E 99,999,999,999.99"  SIZE 060,008 PIXEL OF oDlg	WHEN (lIncluir .or. lAlterar) 		
	
				@050,105 SAY oDtEmis PROMPT "Data Emissão" OF oDlg FONT oFont PIXEL SIZE 240, 030
				@050,145 MSGET oDtEmis1	VAR dDtEmis	PICTURE "99/99/99"  SIZE 050,008 PIXEL OF oDlg WHEN (lIncluir .or. lAlterar)
				
				@050,200 SAY oDtAut PROMPT "Data Autorização" OF oDlg FONT oFont PIXEL SIZE 240, 030
				@050,250 MSGET oDtAut1	VAR dDtAut	PICTURE "99/99/99"  SIZE 050,008 PIXEL OF oDlg WHEN (lIncluir .or. lAlterar)	
				
				@080,020 SAY oRazao PROMPT "Razão Social" OF oDlg FONT oFont PIXEL SIZE 300, 200
				@080,075 MSGET oRazao1	VAR cRazao	PICTURE "@!"  SIZE 250,008 PIXEL OF oDlg WHEN (lIncluir .or. lAlterar)
				         	        		
				@100,020 SAY oCnpjEmi PROMPT "CNPJ" OF oDlg FONT oFont PIXEL SIZE 230, 030
				@100,048 MSGET oCnpjEmi1	VAR cCNPJEM	PICTURE "@R 99.999.999/9999-99"  SIZE 070,008 PIXEL OF oDlg WHEN .F.
				
				@100,125 SAY oIEEst PROMPT "Inscrição Estadual " OF oDlg FONT oFont PIXEL SIZE 230, 030
				@100,180 MSGET oIEEst1 VAR cIEemit PICTURE ("@R " + Replicate("9",(TamSx3("C00_IEEMIT")[1])))SIZE 070,008 PIXEL OF oDlg WHEN (lIncluir .or. lAlterar)
				
				//======================= Buttons ===========================
				oTBut1 := TButton():New( 135, 245, "Confirmar",oDlg,{|| (lContinue := MDeManual(nOpc,cChave1,cSerie,cNumNFe,nValNFe,dDtEmis,dDtAut,cRazao,cCNPJEM,cIEemit),If(lcontinue,oDlg:End(),))},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
				oTBut2 := TButton():New( 135, 290, "Cancelar",oDlg,{||(lContinue :=.F.,oDlg:End())},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
				
		        
				ACTIVATE MSDIALOG oDlg CENTERED
			
			Else
				If !aListBox[1][11] $ '999' .and. !Alltrim(aListBox[1][12]) $ 'Documento incluido manualmente'
					MsgInfo('Não é possível ' + Lower(cOperation) +' pois o documento não foi inluído manualmente.')
				Else
					MsgInfo('Não é possível '+ Lower(cOperation) + ' pois o documento já foi manifestado.')
				EndIf
			EndIf
		
		Else
			If Len(aListBox) == 0
				Aviso("MD-e manual","Selecione ao menos uma chave para " + IIf(nOpc == 2,"alteração.","exclusão."),{"OK"},3)
			Else
				Aviso("MD-e manual","Selecione apenas uma chave para " + IIf(nOpc == 2,"alteração.","exclusão."),{"OK"},3)
			EndIf
		EndIf
		
		If lContinue
			Aviso("MD-e Manual",IIF(nOpc==1,"Inclusão",IIF(nOpc==2,"Alteração","Exclusão"))+" concluída!",{"OK"},3)
		EndIF
		
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} LoadSerNum()
Carrega a série, numero e cnpj a partir da chave informada

@author Natalia Sartori
@since 30.07.2015
@version P11

@param 	cChave	 - Chave da NF-e
		cSerie	 - Série da NF-e
		cNumNFe - Número da NF-e
		cCNPJEM   - Cnpj Emitente	 da NF-e
		
@Return lReturn - .T. - Retorna na tela a serie,número e cnpj					
/*/
//----------------------------------------------------------------------- 
Static function LoadSerNum(cChave,cSerie,cNumNFe,cCNPJEM)

Local lreturn := .F.

If len(Alltrim(cChave)) == 44
	cSerie := substr(cChave,23,3)
	cNumNFe := substr(cChave,26,9)
	cCNPJEM := substr(cChave,07,14)
	lreturn := .T.
EndIf

If Empty(cChave) .or. len(Alltrim(cChave)) < 44
	//limpa as variáveis
	lreturn := .T.
	cSerie:= ""
	cNumNFe := ""
	ccnpjem:= ""
EndIf

oSerie1:Refresh()
oNumNFe1:Refresh()
oCnpjEmi1:Refresh()

Return lreturn

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetDetails()
Atualiza os dados dos Gets

@author Natalia Sartori
@since 23.07.2015
@version P11

@param aMDe    - Dados da Nota selecionada no browse	
		cChave	 - Chave da NF-e
		cSerie	 - Série da NF-e
		cNumNFe - Número da NF-e
		nValNFe - Valor total da NF-e
		dDtEmis - Data de Emissão da NF-e
		cDtAut  - Data de autorização da NF-e
		cCNPJEM - CNPJ Emitente da NF-e
		cRazao  - Razao Social emitente da NF-e
		cIEemit - IE do emitente da NF-e
		
@return Nil
/*/
//----------------------------------------------------------------------- 
Static Function GetDetails(aMDe,cChave,cSerie,cNumNFe,nValNFe,dDtEmis,dDtAut,cRazao,cCNPJEM,cIEemit)

cChave		:= aMDe[1]
cSerie		:= aMDe[2]
cNumNFe	:= aMDe[3]
nValNFe	:= aMDe[4]
cCNPJEM	:= aMDe[5]
cRazao  	:= aMDe[6]
cIEemit 	:= aMDe[7]
dDtEmis	:= aMDe[8]
dDtAut		:= aMDe[9]

Return

//----------------------------------------------------------------------
/*/{Protheus.doc} MDeManual 
Validações para Inclusão/Alteração/Exclusão do MDe manual

@author Natalia Sartori
@since 30.07.2015
@version P11

@param 		nOpc    - 1=Inclusão/2=Alteração/3=Exclusão	
			cChave	 - Chave da NF-e
			cSerie	 - Série da NF-e
			cNumNFe - Número da NF-e
			nValNFe - Valor total da NF-e
			dDtEmis - Data de Emissão da NF-e
			cDtAut  - Data de autorização da NF-e
			cRazao  - Razao Social emitente da NF-e
			cCNPJEM - CNPJ Emitente da NF-e			
			cIEemit - IE do emitente da NF-e
		
@Return	lRet
/*/
//-----------------------------------------------------------------------
Function MDeManual(nOpc,cChave,cSerie,cNumNFe,nValNFe,dDtEmis,dDtAut,cRazao,cCNPJEM,cIEemit,cCpoEve)
	
	Local aDados		:= {}
	Local aMata103	:= {}
	Local aDadosC00	:= {}
	
	Local cMsg			:= ""
	Local cRetorno	:= ""
	
	Local dData		:= CtoD("  /  /    ")
	Local lRet			:= .F.
	Local lOk			:= .F.
	Local lMata103	:= IIf(FunName()$"MATA103",.T.,.F.)
		
	Default cChave	:= ""
	Default cSerie	:= ""
	Default cNumNFe	:= ""
	Default nValNFe	:= 0
	Default dDtEmis		:= CtoD("  /  /    ")
	Default dDtAut		:= CtoD("  /  /    ")
	Default cRazao	:= ""
	Default cCNPJEM	:= ""
	Default cIEemit	:= ""	
	Default cCpoEve	:= ""	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Define a mensagem de alerta ao usuario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 1 .or. lMata103
		cMsg := "Confirma a inclusão"
		cMsg += IIF(lMata103," da manifestação manual?"+CRLF+CRLF+"Ao confirmar será transmitida a "+iif(cCpoEve='210210','Ciência da Operação','Confirmação da Operação')+"'.","?") //DSERTSS1-177
	ElseIf nOpc == 2
		cMsg := 'Confirma a alteração?'
	ElseIf nOpc == 3
		cMsg := 'Confirma a exclusão?'
	EndIf
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa a operação³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ValidFields(cChave,nValNFe,dDtEmis,dDtAut,nOpc,lMata103,@aDadosC00)
		dData := CtoD("01/"+Substr(cChave,5,2)+"/"+Substr(cChave,3,2))
			If MsgYesNo(cMsg)
				
				//Inclusao
				If nOpc == 1 .or. lMata103

					If Len(aDadosC00) == 0
						aAdd(aDados,{"C00_FILIAL"	,	cFilAnt	})
						aAdd(aDados,{"C00_CHVNFE"	,	cChave		})
						aAdd(aDados,{"C00_SERNFE"	,	cSerie		})
						aAdd(aDados,{"C00_NUMNFE"	,	cNumNFe	})
						aAdd(aDados,{"C00_VLDOC"		,	nValNFe	})
						aAdd(aDados,{"C00_DTEMI"		,	dDtEmis	})
						aAdd(aDados,{"C00_DTREC"		,	dDtAut		})
						aAdd(aDados,{"C00_NOEMIT"	,	Alltrim(cRazao)})
						aAdd(aDados,{"C00_CNPJEM"	,	cCNPJEM	})
						aAdd(aDados,{"C00_IEEMIT"	,	Alltrim(cIEemit)})
						aAdd(aDados,{"C00_STATUS"	,	'0'			})
						aAdd(aDados,{"C00_CODRET"	,	'999'		})
						aAdd(aDados,{"C00_DESRES"	,	'Documento incluido manualmente'})
						aAdd(aDados,{"C00_MESNFE"	,	Strzero(Month(dData),2)})
						aAdd(aDados,{"C00_ANONFE"	,	Strzero(Year(dData),4)})
						aAdd(aDados,{"C00_SITDOC"	,	'1'}) //"Uso autorizado da NFe"
						aAdd(aDados,{"C00_CODEVE"	,	'1'}) //"Envio de Evento não realizado"

						lRet:= RecInC00(.T.,aDados)
					Else
						/*lMata103 - Alimenta variáveis com os dados já existentes na C00 para
						que o xml do evento de ciencia seja montado corretamente*/
						cChave		:= aDadosC00[1]
						cSerie		:= aDadosC00[2]
						cNumNFe	:= aDadosC00[3]
						nValNFe	:= aDadosC00[4]
						cCNPJEM	:= aDadosC00[5]
						cRazao		:= aDadosC00[6]
						cIEemit	:= aDadosC00[7]
						dDtEmis	:= aDadosC00[8]
						dDtAut		:= aDadosC00[9]
						
						lRet := .T.
					EndIf

					If lRet .and. lMata103
						aadd(aMata103,{,cChave,cSerie,cNumNFe,nValNFe,cCNPJEM,Alltrim(cRazao),Alltrim(cIEemit),dDtEmis,dDtAut,.T.,'0','1'})
						lOk:= MontaXmlManif(cCpoEve,aMata103,@cRetorno,"") //DSERTSS1-177
					EndIf									
					
					If lOk // Transmissão da Ciencia da Operação Concluída - lMata103
						Aviso("Envio Manifesto",cRetorno,{"OK"},3)
					EndIF
					
			    //Alteracao
				ElseIf nOpc == 2
					aAdd(aDados,{"C00_FILIAL"	,	cFilAnt	})
					aAdd(aDados,{"C00_CHVNFE"	,	cChave		})
					aAdd(aDados,{"C00_SERNFE"	,	cSerie		})
					aAdd(aDados,{"C00_NUMNFE"	,	cNumNFe	})
					aAdd(aDados,{"C00_VLDOC"		,	nValNFe	})
					aAdd(aDados,{"C00_DTEMI"		,	dDtEmis	})
					aAdd(aDados,{"C00_DTREC"		,	dDtAut		})
					aAdd(aDados,{"C00_NOEMIT"	,	cRazao		})
					aAdd(aDados,{"C00_CNPJEM"	,	cCNPJEM	})
					aAdd(aDados,{"C00_IEEMIT"	,	cIEemit	})
					aAdd(aDados,{"C00_STATUS"	,	'0'			})
					aAdd(aDados,{"C00_CODRET"	,	'999'		})
					aAdd(aDados,{"C00_DESRES"	,	'Documento incluido manualmente'})
					aAdd(aDados,{"C00_MESNFE"	,	Strzero(Month(dData),2)})
					aAdd(aDados,{"C00_ANONFE"	,	Strzero(Year(dData),4)})
					aAdd(aDados,{"C00_SITDOC"	,	'1'	}) //"Uso autorizado da NFe"
					aAdd(aDados,{"C00_CODEVE"	,	'1'}) //"Envio de Evento não realizado"
                 
					lRet := RecInC00(.F.,aDados)

				//Exclusao
				ElseIf nOpc == 3
					//Apaga da C00
					RecLock('C00',.F.)
					C00->(dbDelete())
					C00->(msUnlock())
					lRet := .T.
				EndIf
			Else
				lRet := .F.
			EndIf
	EndIf		

Return lRet
//----------------------------------------------------------------------
/*/{Protheus.doc} RecInC00 
Inclui/Altera registro de manifesto na C00

@author Natalia Sartori
@since 30.07.2015
@version P11 
@Return  lRet
/*/
//-----------------------------------------------------------------------
Static Function RecInC00(lInclui,aDados)
	Local nI		:= 1
	Local lRet		:= .F.
	Default aDados	:= {}
	
	If len(aDados) > 0
		
		//Grava na Tabela
		Begin Transaction
			RecLock("C00",lInclui)
			For nI := 1 to len(aDados)				
				C00->(FieldPut(FieldPos(aDados[nI][1]),aDados[nI][2]))
			Next nI
			C00->(msUnlock())
			lRet := .T.
		end Transaction
	Else
		lRet := .F.
	EndIf
	
Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} ValidFields 
Valida campos da dialog de MD-e Manual e verifica se já existe chave na C00

@author Natalia Sartori
@since 30.07.2015
@version P11 
@Return lReturn
/*/
//-----------------------------------------------------------------------
Static Function ValidFields(cChave,nValNFe,dDtEmis,dDtAut,nOpc,lMata103,aDadosC00)

Local aArea	:= GetArea()
Local lReturn := .T.
Local cMesEmis := ""
Local cAnoEmis := ""
Local dData	:= CtoD("  /  /    ")
Local cNewChave := ""

Default aDadosC00:= {}

If !lMata103
	If nOpc <> 3
		If 	len(Alltrim(cChave)) == 44
			cNewChave:= validcDVNFe(Substr(cChave,1,43))
		EndIf
		Do Case
			Case len(Alltrim(cChave)) < 44
				MsgInfo("Chave informada deve ter 44 dígitos.")
				lReturn := .F.
			Case len(Alltrim(cChave)) == 44 .and. Substr(cChave,21,2) <> '55'
				MsgInfo("Chave informada não se refere a uma NF-e (modelo 55).")
				lReturn := .F.
			Case len(Alltrim(cChave)) == 44 .and. cChave <> cNewChave
				MsgInfo("Dígito verificador que compõe a chave de acesso está incorreto.")
				lReturn := .F.
			Case Empty(dDtEmis)
				MsgInfo("Data de emissão da NF-e não informada.")
				lReturn := .F.
			Case (!Empty(dDtAut) .and. dDtAut < dDtEmis)
				MsgInfo("Data de autorização da NF-e não pode ser menor que a data de emissão da NF-e.")
				lReturn := .F.
			Case !Empty(dDtEmis)
				dData := CtoD("01/"+Substr(cChave,5,2)+"/"+Substr(cChave,3,2))
				cMesEmis := Strzero(Month(dData),2)
				cAnoEmis := Strzero(Year(dData),4)
		
				If (Substr(DtoC(dDtEmis),4,2) <> cMesEmis) .or. (Substr(DtoC(dDtEmis),7,4) <> cAnoEmis) .and. (Substr(DtoC(dDtEmis),7,4) <> Substr(cAnoEmis,3,2))
					MsgInfo("Mês e/ou Ano informado no campo 'Data emissão' não confere com o Mês e/ou Ano informado no campo 'Chave'")
					lReturn := .F.
				EndIf
		EndCase
	EndIf
EndIf

If lReturn
	C00->(DbsetOrder(1))
	If C00->( DbSeek( xFilial("C00") + cChave) )
		If nOpc == 1 .or. lMata103
			If lMata103
				If C00->C00_STATUS <> '0'
					MsgStop('Já existe Manifestação para este documento!!'+CRLF+CRLF+'Consulte a rotina de Manifestação do Destinatário.')
					lReturn := .F.
				Else
					//Se já existir registro na C00 sem manifestação monta array com dados da C00 e não executa a função RecInC00
					aadd(aDadosC00,C00->C00_CHVNFE)
					aadd(aDadosC00,C00->C00_SERNFE)
					aadd(aDadosC00,C00->C00_NUMNFE)
					aadd(aDadosC00,C00->C00_VLDOC)
					aadd(aDadosC00,C00->C00_CNPJEM)
					aadd(aDadosC00,C00->C00_NOEMIT)
					aadd(aDadosC00,C00->C00_IEEMIT)
					aadd(aDadosC00,C00->C00_DTEMI)
					aadd(aDadosC00,C00->C00_DTREC)
				EndIf
			Else
				MsgStop('Já existe MD-e cadastrado com a mesma chave!')
				lReturn := .F.
			EndIf
		EndIf
	Else
		If !lMata103
			If nOpc <> 1
				lReturn := .F.
			EndIf
		EndIf
	EndIf		
EndIf

RestArea(aArea)
Return lReturn

//----------------------------------------------------------------------
/*/{Protheus.doc} validcDVNFe 
Refaz o calculo do digito verificador a partir de uma chave sem digito

@author Natalia Sartori
@since 30.07.2015
@version P11 

@param     cChave - Chave de Acesso da NF-e sem o dígito
					  verificador (43 posições)
 	
@Return	cResult - Retorna chave de acesso com dígito
					  verificador (44 posições)
/*/
//-----------------------------------------------------------------------
Function validcDVNFe(cChave)

Local cResult     := ''
Local cChvAcesso  := cChave

Local nCount      := 0
Local nSequenc    := 2
Local nPonderacao := 0


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³SEQUENCIA DE MULTIPLICADORES (nSequenc), SEGUE A SEGUINTE        ³
//³ORDENACAO NA SEQUENCIA: 2,3,4,5,6,7,8,9,2,3,4... E PRECISA SER   ³
//³GERADO DA DIREITA PARA ESQUERDA, SEGUINDO OS CARACTERES          ³
//³EXISTENTES NA CHAVE DE ACESSO INFORMADA (cChvAcesso)             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCount := Len( AllTrim(cChvAcesso) ) To 1 Step -1
	nPonderacao += ( Val( SubStr( AllTrim(cChvAcesso), nCount, 1) ) * nSequenc )
	nSequenc += 1
	If (nSequenc == 10)
		nSequenc := 2
	EndIf
Next nCount

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando o resto da divisão for 0 (zero) ou 1 (um), o DV devera   ³
//³ ser igual a 0 (zero).                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( mod(nPonderacao,11) > 1)
	cResult := (cChvAcesso + cValToChar( (11 - mod(nPonderacao,11) ) ) )
Else
	cResult := (cChvAcesso + '0')
EndIf

Return cResult

//----------------------------------------------------------------------
/*/{Protheus.doc} MDeMata103 
Função chamada pelo menu 'Manifestar' (MATA103)
para inclusão de chave na C00 e envio da Ciencia de Operação

@author Natalia Sartori
@since 29.07.2015
@version P11 

@param     	cNumNFe - Número da NF-e (SF1->F1_DOC)
			cSerie	 - Série da NF-e (SF1->SERIE)
			cClieFor - Codigo Cliente/Fornecedor (SF1->FORNECE)
			cLoja - Codigo Loja (SF1->F1_LOJA)
			dDtEmis - Data de Emissão da NF-e (SF1->F1_EMISSAO)			
			nValNFe - Valor total da NF-e (SF1->F1_VALBRUT)
			cTipoNFe - Tipo da NF-e (SF1->F1_TIPO)
			cChave	 - Chave da NF-e (SF1->F1_CHVNFE)
			cDtAut  - Data de autorização da NF-e (SF1->F1_DAUTNFE)
 	
@Return Nil
/*/
//-----------------------------------------------------------------------
Function MDeMata103 (cNumNFe,cSerie,cClieFor,cLoja,dDtEmis,nValNFe,cTipoNFe,cChave,dDtAut,cCpoEve)

Local aArea	:= GetArea()
Local aAreaSA1:= SA1->(GetArea())
Local aAreaSA2:= SA2->(GetArea())

Local cRazao	:= ""
Local cCNPJEM	:= ""
Local cIEemit	:= ""

Default cNumNFe	:= ""
Default cSerie	:= ""
Default cClieFor	:= ""
Default cLoja		:= ""
Default cTipoNFe	:= ""
Default cChave	:= ""

Default nValNFe	:= 0
Default dDtEmis	:= CtoD("  /  /    ")
Default dDtAut	:= CtoD("  /  /    ")
Default cCpoEve	:= "210210"  // - DSERTSS1-177

cSerie := substr(cChave,23,3)
cNumNfe:= substr(cChave,26,9)

// Validar se o emitente da NF-e a ser manifestada é o cliente ou fornecedor
If (!Empty(cClieFor) .and. !Empty(cLoja) .and. !Empty(cTipoNFe))
	If cTipoNFe $ "DB" 
		dbSelectArea("SA1")
		dbSetOrder(1)
		MsSeek(xFilial("SA1")+cClieFor+cLoja)
		cRazao  := Alltrim(SA1->A1_NOME)
		cCNPJEM := AllTrim(SA1->A1_CGC)
		cIEemit := Alltrim(SA1->A1_INSCR)
	Else
		dbSelectArea("SA2")
		dbSetOrder(1)  				
		MsSeek(xFilial("SA2")+cClieFor+cLoja)
		cRazao  := Alltrim(SA2->A2_NOME)
		cCNPJEM := AllTrim(SA2->A2_CGC)
		cIEemit := Alltrim(SA2->A2_INSCR)
	EndIf
EndIf

If ReadyTSS()
	MDeManual(0,cChave,cSerie,cNumNFe,nValNFe,dDtEmis,dDtAut,cRazao,cCNPJEM,cIEemit,cCpoEve)
Else
	Aviso("TSS","O TSS está inativo."+CRLF+CRLF+"Para utilizar esta funcionalidade, inicialize o servidor TSS e execute as configurações do serviço através da rotina de Manifestação do Destinatário !!!!",{STR0114},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf
	
RestArea(aArea)
RestArea(aAreaSA1)
RestArea(aAreaSA2)

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} MDeDesMark
Desmarca os registros selecionados do markBrow apos manifestacao

@author Jonatas Almeida
@since 04.07.2016
@version 1.00
/*/
//-----------------------------------------------------------------------
function MDeDesMark()
	local cWhere	:= "%C00.C00_FILIAL='"+xFilial("C00")+"' AND C00.C00_OK ='"+cMarkDlg+"' "+cCondQry+"%"
	local cAliasC00	:= getNextAlias()
	
	BeginSql Alias cAliasC00
	
	SELECT C00_CHVNFE
	FROM %Table:C00% C00
	WHERE %Exp:cWhere% AND
	C00.%notdel%
	EndSql                                                                             
	
	TcSetField(cAliasC00,"C00_DTEMI" ,"D",008,0)
	TcSetField(cAliasC00,"C00_DTREC" ,"D",008,0)
	
	C00->(dbSetOrder(1))
	      
	while((cAliasC00)->(!Eof()))
		if(C00->(dbSeek(xFilial("C00") + (cAliasC00)->(C00_CHVNFE))))
			recLock("C00",.F.)
			C00->C00_OK := space(TamSX3("C00_OK")[1])
			C00->(msUnLock())
		endIf
		
		(cAliasC00)->(dbSkip())
	endDo
	
	(cAliasC00)->(dbCloseArea())
	
	MarkBRefresh()
return

//-----------------------------------------------------------------------
/*/{Protheus.doc} MDeMarkAll
Marca e desmarca todos os registros do markBrow

@author Jonatas Almeida
@since 04.07.2016
@version 1.00
/*/
//-----------------------------------------------------------------------
function MDeMarkAll()
	local cWhere	:= "%C00.C00_FILIAL='"+xFilial("C00")+"' "+cCondQry+"%"
	local cAliasC00	:= getNextAlias()
	
	BeginSql Alias cAliasC00
	
	SELECT C00_OK, C00_CHVNFE
	FROM %Table:C00% C00
	WHERE %Exp:cWhere% AND
	C00.%notdel%
	EndSql
	
	TCSetField(cAliasC00,"C00_DTEMI" ,"D",008,0)
	TCSetField(cAliasC00,"C00_DTREC" ,"D",008,0)
	
	C00->(dbSetOrder(1))

	if((cAliasC00)->(C00_OK) == cMarkDlg)
		while((cAliasC00)->(!Eof()))
			if(C00->(dbSeek(xFilial("C00") + (cAliasC00)->(C00_CHVNFE))))
				recLock("C00",.F.)
				C00->C00_OK := space(TamSX3("C00_OK")[1])
				C00->(msUnLock())
			endIf
				
			(cAliasC00)->(dbSkip())
		endDo
	else
		while((cAliasC00)->(!Eof()))
			if(C00->(dbSeek(xFilial("C00") + (cAliasC00)->(C00_CHVNFE))))
				recLock("C00",.F.)
				C00->C00_OK := cMarkDlg
				C00->(msUnLock())
			endIf
			
			(cAliasC00)->(dbSkip())
		endDo
	endIf
	
	(cAliasC00)->(dbCloseArea())
	
	MarkBRefresh()
return

//-----------------------------------------------------------------------
/*/{Protheus.doc} ManiFiltro
Botao para alterar o filtro do browse

@author Thiago Miyabara
@since 22.01.2018
@version 1.00
/*/
//-----------------------------------------------------------------------
Function ManiFiltro()

	INCLUI     := .F.
	lBtnFiltro := .T.
	CloseBrowse()

Return Nil