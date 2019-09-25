#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FC010CON  º Autor ³ MICROSIGA VITORIA  º Data ³  24/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Botao de consulta posicao de clientes (financeiro)         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8-TOP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FC010CON()

Local aSize     := MsAdvSize( .F. )
Local aButtons := {{"AUTOM", {|| fAtualiza()},"Atualizar"},;
                   {"IMPRESSAO", {|| fImprime(oGetDAbert:aCols,oGetDPagos:aCols)},"Relatorio"},;
                   {"AREA", {|| fResumo()},"Resumo"}}
Private oDlg				// Dialog Principal
Private oGetDAbert
Private oGetDPagos
Private cMemoAbr	 := ""
Private oMemoAbr
Private cQtdTitAbr := "Qtd. Tit.: "
Private cValTitAbr := "Total a Receber: "
Private cQtdTitPag := "Qtd. Tit.: "
Private cValTitPag := "Total Recebido: "
Private cMemoPag	 := ""
Private oMemoPag

DEFINE FONT oFontTot	NAME "Arial" 			SIZE 10,15 BOLD			// Quant.

DEFINE MSDIALOG oDlg FROM aSize[7],0 TO aSize[6],aSize[5] TITLE ("Títulos Abertos/Pagos - " + Alltrim(SA1->A1_NOME)) OF oMainWnd PIXEL

	@ 013,006 Say "Titulos em Aberto" Size 060,010 COLOR CLR_BLACK PIXEL OF oDlg
	@ 143,006 Say "Titulos Pagos" Size 060,010 COLOR CLR_BLACK PIXEL OF oDlg

	@ 124,006 Say cQtdTitAbr Size 060,010 COLOR CLR_RED FONT oFontTot PIXEL OF oDlg
	@ 124,100 Say cValTitAbr Size 250,010 COLOR CLR_RED FONT oFontTot PIXEL OF oDlg
	@ 252,006 Say cQtdTitPag Size 060,010 COLOR CLR_RED FONT oFontTot PIXEL OF oDlg
	@ 252,100 Say cValTitPag Size 250,010 COLOR CLR_RED FONT oFontTot PIXEL OF oDlg

	@ 020,410 GET oMemoAbr Var cMemoAbr MEMO Size 090,100 WHEN .F. PIXEL OF oDlg
	@ 150,410 GET oMemoPag Var cMemoPag MEMO Size 090,100 WHEN .F. PIXEL OF oDlg

	// Chamadas das GetDados do Sistema
	fGetDAbert()
	oGetDAbert:bChange := {|| cMemoAbr := oGetDAbert:aCols[oGetDAbert:nAt,23],oMemoAbr:Refresh()}
	
	fGetDPagos()
	oGetDPagos:bChange := {|| cMemoPag := oGetDPagos:aCols[oGetDPagos:nAt,23],oMemoPag:Refresh()}
	
	MsgRun("Selecionando Registros em Aberto, Aguarde...","",{|| CursorWait(), 	fGetInfAbr() ,CursorArrow()})
	MsgRun("Selecionando Registros Pagos, Aguarde...","",{|| CursorWait(), 	fGetInfPag() ,CursorArrow()})

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(	oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButtons) CENTERED 

Return(.F.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fGetDAbert()³ Autor ³ Felipe Caiado Almeida     ³ Data ³12/01/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da GetDados                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGetDados1 foi criado como Private no inicio do Fonte   ³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do            ³±±
±±³           ³ seu programa:                                                    ³±±
±±³           ³                                                                  ³±±
±±³           ³ Para acessar o aCols desta MsNewGetDados: oGetDados1:aCols[nX,nY]³±±
±±³           ³ Para acessar o aHeader: oGetDados1:aHeader[nX,nY]                ³±±
±±³           ³ Para acessar o "n"    : oGetDados1:nAT                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGetDAbert()
// Variaveis deste Form                                                                                                         
Local nX			:= 0                                                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa       	:= {	"XX_EMPRESA",;
								"E1_FILIAL",;
								"E1_PREFIXO",;
								"E1_NUM",;
								"E1_PARCELA",;
								"E1_TIPO",;   
								"E1_SITUACA",;
								"E1_CLIENTE",;
								"E1_EMISSAO",;
								"E1_VENCTO",;
								"E1_ATR",;
								"E1_BAIXA",;
								"E1_VENCREA",;
								"E1_VALOR",;
								"E1_VLCRUZ",;
								"E1_SDACRES",;
								"E1_SDDECRE",;
								"E1_VALJUR",;
								"E1_SALDO",;
								"E1_NATUREZ",;
								"E1_PORTADO",;
								"E1_NUMBCO",;
								"E1_HIST"}
								
// Vetor com os campos que poderao ser alterados                                                                                
Local aAlter       	:= {""}
Local nSuperior    	:= 020           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= 006           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= 120           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= 400           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nOpc         	:= 0//GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                         // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                         // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
Local cSuperDel     	:= ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        	:= "AllwaysTrue"   // Funcao executada para validar a exclusao de uma linha do aCols                   
// Objeto no qual a MsNewGetDados sera criada                                      
Local oWnd          	:= oDlg                                                                                                  
Local aHead        	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Local aCol         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols                      
                                                                                                                                
// Carrega aHead                                                                                                                
DbSelectArea("SX3")                                                                                                             
SX3->(DbSetOrder(2)) // Campo                                                                                                   
For nX := 1 to Len(aCpoGDa)    

	If AllTrim(aCpoGDa[nX]) == "E1_SITUACA"
                                      
		Aadd(aHead,{"Situação",;
						"E1_SITUACA",;
						"@!",;
						10,;
						0,;
						"",;
						"",;
						"C",;
						"",;
						"V",;
						"",;
						""})
						
	ElseIf SX3->(DbSeek(aCpoGDa[nX]))
	
		Aadd(aHead,{ AllTrim(X3Titulo()),;                                                                                         
			SX3->X3_CAMPO	,;                                                                                                       
			SX3->X3_PICTURE,;                                                                                                       
			SX3->X3_TAMANHO,;                                                                                                       
			SX3->X3_DECIMAL,;                                                                                                       
			SX3->X3_VALID	,;                                                                                                       
			SX3->X3_USADO	,;                                                                                                       
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;                                                                                                       
			SX3->X3_CONTEXT,;                                                                                                       
			SX3->X3_CBOX	,;                                                                                                       
			SX3->X3_RELACAO})                                                                                                       
	
	Else
	
		If  Alltrim(aCpoGDa[nX]) == "E1_ATR"
			Aadd(aHead,{"Atraso",;
						"E1_ATR",;
						"9999999999",;
						10,;
						0,;
						"",;
						"",;
						"N",;
						"",;
						"V",;
						SX3->X3_CBOX,;
						SX3->X3_RELACAO })
		EndIf       
		If  Alltrim(aCpoGDa[nX]) == "XX_EMPRESA"
			Aadd(aHead,{"Empresa",;
						"XX_EMPRESA",;
						"@!",;
						02,;
						0,;
						"",;
						"",;
						"C",;
						"",;
						"V",;
						"",;
						""})
		EndIf
	Endif                                                                                                                         
Next nX                                                                                                                         
// Carregue aqui a Montagem da sua aCol                                                                                         
aAux := {}                          
For nX := 1 to Len(aCpoGDa)         
	If DbSeek(aCpoGDa[nX])             
		If Alltrim(aCpoGDa[nX]) == "E1_ATR"
			Aadd(aAux,0)
		Else			
			Aadd(aAux,CriaVar(SX3->X3_CAMPO))
		EndIf
	Endif                              
Next nX                             
Aadd(aAux,.F.)                      
Aadd(aCol,aAux)                     

oGetDAbert:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;                               
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)                                   

// Cria ExecBlocks da GetDados

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fGetDPagos()³ Autor ³ Felipe Caiado Almeida     ³ Data ³12/01/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da GetDados                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGetDados1 foi criado como Private no inicio do Fonte   ³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do            ³±±
±±³           ³ seu programa:                                                    ³±±
±±³           ³                                                                  ³±±
±±³           ³ Para acessar o aCols desta MsNewGetDados: oGetDados1:aCols[nX,nY]³±±
±±³           ³ Para acessar o aHeader: oGetDados1:aHeader[nX,nY]                ³±±
±±³           ³ Para acessar o "n"    : oGetDados1:nAT                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGetDPagos()
// Variaveis deste Form                                                                                                         
Local nX			:= 0                                                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa       	:= {	"XX_EMPRESA",;
								"E1_FILIAL",;
								"E1_PREFIXO",;
								"E1_NUM",;
								"E1_PARCELA",;
								"E1_TIPO",;
								"E1_CLIENTE",;
								"E1_EMISSAO",;
								"E1_VENCREA",;
								"E5_DATA",;
								"E5_DTDISPO",;
								"E1_VALOR",;
								"E1_VLCRUZ",;
								"E5_VLJUROS",;
								"E5_VLMULTA",;
								"E5_VLCORRE",;
								"E5_VLDESCO",;
								"E5_VALOR",;
								"E1_NATUREZ",;
								"E5_BANCO",;
								"E5_AGENCIA",;
								"E5_CONTA",;
								"E5_HISTOR",;
								"E5_MOTBX",;
								"E5_TIPODOC",;
								"E1_VALJUR",;
								"E1_MULTA"}
// Vetor com os campos que poderao ser alterados                                                                                
Local aAlter       	:= {""}
Local nSuperior    	:= 150           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= 006           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= 250           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= 400           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nOpc         	:= 0//GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                         // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                         // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
Local cSuperDel     	:= ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        	:= "AllwaysTrue"   // Funcao executada para validar a exclusao de uma linha do aCols                   
// Objeto no qual a MsNewGetDados sera criada                                      
Local oWnd          	:= oDlg                                                                                                  
Local aHead        	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Local aCol         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols                      
                                                                                                                                
// Carrega aHead                                                                                                                
DbSelectArea("SX3")                                                                                                             
SX3->(DbSetOrder(2)) // Campo                                                                                                   
For nX := 1 to Len(aCpoGDa)                                                                                                     
	If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
		Aadd(aHead,{ AllTrim(X3Titulo()),;                                                                                         
			SX3->X3_CAMPO	,;                                                                                                       
			SX3->X3_PICTURE,;                                                                                                       
			SX3->X3_TAMANHO,;                                                                                                       
			SX3->X3_DECIMAL,;                                                                                                       
			SX3->X3_VALID	,;                                                                                                       
			SX3->X3_USADO	,;                                                                                                       
			SX3->X3_TIPO	,;                                                                                                       
			SX3->X3_F3 		,;                                                                                                       
			SX3->X3_CONTEXT,;                                                                                                       
			SX3->X3_CBOX	,;                                                                                                       
			SX3->X3_RELACAO})                                                                                                       

	ElseIf  Alltrim(aCpoGDa[nX]) == "XX_EMPRESA"

			Aadd(aHead,{"Empresa",;
						"XX_EMPRESA",;
						"@!",;
						02,;
						0,;
						"",;
						"",;
						"C",;
						"",;
						"V",;
						"",;
						""})
	EndIf                                                                                                                     
Next nX                                                                                                                         
// Carregue aqui a Montagem da sua aCol                                                                                         
aAux := {}                          
For nX := 1 to Len(aCpoGDa)         
	If DbSeek(aCpoGDa[nX])             
		Aadd(aAux,CriaVar(SX3->X3_CAMPO))
	Endif                              
Next nX                             
Aadd(aAux,.F.)                      
Aadd(aCol,aAux)                     

oGetDPagos:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;                               
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)                                   

// Cria ExecBlocks da GetDados

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetInfAbrº Autor ³ MICROSIGA VITORIA  º Data ³  24/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ atualiza arquivo de itens em aberto                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGetInfAbr()

Local aParam 	:= {}
Local cCheques	:=	IIF(Type('MVCHEQUES')=='C',MVCHEQUES,MVCHEQUE)
Local nQtdTit 	:= 0
Local nValTit 	:= 0
Local cAlias	:= GetNextAlias()

Local oVIXA095 	:= VIXA095():New()
Local nPosTab	:= 0
Local ix		:= 0

Local cTabSE1
Local cTabSA1
Local cCptSE1
Local cCptSA1
Local cEmpSE1

Local cFilQuery	:= ""

cQtdTitAbr 		:= "Qtd. Tit.: "
cValTitAbr 		:= "Total a Receber: "
oGetDAbert:aCols:= {}

aadd(aParam,MV_PAR01)
aadd(aParam,MV_PAR02)
aadd(aParam,MV_PAR03)
aadd(aParam,MV_PAR04)
aadd(aParam,MV_PAR05)
aadd(aParam,MV_PAR06)
aadd(aParam,MV_PAR07)
aadd(aParam,MV_PAR08)
aadd(aParam,MV_PAR09)
aadd(aParam,MV_PAR10)
aadd(aParam,MV_PAR11)
aadd(aParam,MV_PAR12)
aadd(aParam,MV_PAR13)
aadd(aParam,MV_PAR14)
aadd(aParam,MV_PAR15)

//Rotina para montar array com tabelas
oVIXA095:MontaSA1Proc()

//Recupera o nome das tabelas a serem analisadas
cTabSA1 := AllTrim(Posicione("SX2",1,"SA1","X2_ARQUIVO"))
cCptSA1	:= iif(SX2->X2_MODO == "C",Space(Len(SM0->M0_CODFIL)),SM0->M0_CODFIL)

//Verifica se encontra no vetor o cliente a admin	ser processado
nPosTab := aScan(oVIXA095:aSA1, {|x| x[1] == cTabSA1 .and. x[2] == cCptSA1 })

//Monta o filtro da query 
If cPaisLoc != "BRA"
 
	cFilQuery += " AND SE1.E1_TIPO NOT IN " + FormatIn(cCheques,"|")

EndIf
		                                           				
If aParam[13] == 1
		
	cFilQuery += " AND SE1.E1_LOJA = '"+SA1->A1_LOJA+"' "
	
EndIf		 	

If aParam[05] == 2

	cFilQuery += " AND SE1.E1_TIPO <> 'PR' "

EndIf

If aParam[15] == 2

	cFilQuery += " AND SE1.E1_TIPO <> 'RA' "

EndIf
		
If aParam[11] == 2
		
	If aParam[09] == 1
			    
		cFilQuery += " AND SE1.E1_NUMLIQ = '"+Space(Len(SE1->E1_NUMLIQ))+"' "

	Else
			
		cFilQuery += " AND SE1.E1_NUMLIQ	= '"+Space(Len(SE1->E1_NUMLIQ))+"' "
		cFilQuery += " AND SE1.E1_TIPOLIQ 	= '"+Space(Len(SE1->E1_TIPOLIQ))+"' "
														
	EndIf
			                      
Else

	//cFilQuery += " AND SE1.E1_TIPOLIQ = '"+Space(Len(SE1->E1_TIPOLIQ))+"' "

EndIf

cFilQuery := "% "+cFilQuery+" %"
		
For iX := 1 to Len(oVIXA095:aSA1[nPosTab][6])
		
	//define a tabela que irá buscar as vendas
	cTabSE1	:= "% "+oVIXA095:aSA1[nPosTab][6][iX][1]+" %"
	cFilSE1	:= "% '"+oVIXA095:aSA1[nPosTab][6][iX][2]+"' %"
    cEmpSE1	:= SubStr(oVIXA095:aSA1[nPosTab][6][iX][1],4,2)
	 
	 //Query para analisar a data da ultima compra do cliente	
	BeginSql Alias cAlias

	SELECT	%Exp:cEmpSE1%	XX_EMPRESA
		,	*

	FROM	%Exp:cTabSE1% SE1 
	
			LEFT JOIN %table:SX5% SX5 ON 	SX5.%notdel%
										AND SX5.X5_FILIAL	= %xFilial:SX5%
										AND SX5.X5_CHAVE	= SE1.E1_SITUACA
										AND SX5.X5_TABELA	= '07'
			
	WHERE	SE1.E1_FILIAL	IN (%Exp:cFilSE1%)
		AND SE1.%notdel%	
			               
		AND SE1.E1_CLIENTE	= %Exp:SA1->A1_COD%
		AND SE1.E1_EMISSAO	BETWEEN %Exp:aParam[1]% AND %Exp:aParam[2]%
		AND SE1.E1_VENCREA	BETWEEN %Exp:aParam[3]% AND %Exp:aParam[4]%
		AND SE1.E1_PREFIXO	BETWEEN %Exp:aParam[6]% AND %Exp:aParam[7]% 
	
		AND SE1.E1_SALDO	> 0				
	    
  		%Exp:cFilQuery%
	    	     
		ORDER BY E1_FILIAL, E1_VENCREA, E1_PREFIXO, E1_NUM, E1_PARCELA
	
	EndSql
	
	(cAlias)->(dbGoTop())
	
	While (cAlias)->(!Eof())

		Aadd(oGetDAbert:aCols,{	(cAlias)->XX_EMPRESA,;
								(cAlias)->E1_FILIAL,;
								(cAlias)->E1_PREFIXO,;
								(cAlias)->E1_NUM,;
								(cAlias)->E1_PARCELA,;
								(cAlias)->E1_TIPO,;     
								(cAlias)->X5_DESCRI,;     									
								(cAlias)->E1_CLIENTE,;
								DtoC(StoD((cAlias)->E1_EMISSAO)),;
								DtoC(StoD((cAlias)->E1_VENCTO)),;
								dDataBase - StoD((cAlias)->E1_VENCTO) ,;
								DtoC(StoD((cAlias)->E1_BAIXA)),;
								DtoC(StoD((cAlias)->E1_VENCREA)),;
								(cAlias)->E1_VALOR,;
								(cAlias)->E1_VLCRUZ,;
								(cAlias)->E1_SDACRES,;
								(cAlias)->E1_SDDECRE,;
								(cAlias)->E1_VALJUR,;
								(cAlias)->E1_SALDO,;
								(cAlias)->E1_NATUREZ,;
								(cAlias)->E1_PORTADO,;
								(cAlias)->E1_NUMBCO,;
								(cAlias)->E1_HIST,;
								.F.})

		nQtdTit ++

		Do Case
		
			Case (cAlias)->E1_TIPO == "RA "; nValTit -= (cAlias)->E1_SALDO
			Case (cAlias)->E1_TIPO == "AB-"; nValTit -= (cAlias)->E1_SALDO
			Case (cAlias)->E1_TIPO == "NCC"; nValTit -= (cAlias)->E1_SALDO
			
			OtherWise; nValTit += (cAlias)->E1_SALDO
		
		EndCase

		(cAlias)->(dbSkip())
   		
	EndDo
	 
	(cAlias)->(dbCloseArea())

Next	

If Len(oGetDAbert:aCols) == 0

	Aadd(oGetDAbert:aCols,{	"",;
							CriaVar("E1_FILIAL"),;
							CriaVar("E1_PREFIXO"),;
							CriaVar("E1_NUM"),;
							CriaVar("E1_PARCELA"),;
							CriaVar("E1_TIPO"),;
							CriaVar("E1_SITUACA"),;
							CriaVar("E1_CLIENTE"),;
							CriaVar("E1_EMISSAO"),;
							CriaVar("E1_VENCTO"),;
							0 ,;
							CriaVar("E1_BAIXA"),;
							CriaVar("E1_VENCREA"),;
							CriaVar("E1_VALOR"),;
							CriaVar("E1_VLCRUZ"),;
							CriaVar("E1_SDACRES"),;
							CriaVar("E1_SDDECRE"),;
							CriaVar("E1_VALJUR"),;
							CriaVar("E1_SALDO"),;
							CriaVar("E1_NATUREZ"),;
							CriaVar("E1_PORTADO"),;
							CriaVar("E1_NUMBCO"),;
							CriaVar("E1_HIST"),;
							.F.})
EndIf

cQtdTitAbr := cQtdTitAbr + Alltrim(Str(nQtdTit))
cValTitAbr := cValTitAbr + Transform(nValTit,"@E 999,999,999.99")
oGetDAbert:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetInfPagº Autor ³ MICROSIGA VITORIA  º Data ³  24/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ atualiza arquivo de itens Pagos                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fGetInfPag()

Local aParam := {}
Local nQtdTit := 0
Local nValTit := 0    

Local cAlias	:= GetNextAlias()

Local oVIXA095 	:= VIXA095():New()
Local nPosTab	:= 0
Local ix		:= 0

Local cTabSE1
Local cTabSE5
Local cTabSA1

Local cCptSE1
Local cCptSE5
Local cCptSA1

Local cEmpSE1

Local cFilQuery	:= ""
            
oGetDPagos:aCols := {}

cQtdTitPag := "Qtd. Tit.: "
cValTitPag := "Total Recebido: "

aadd(aParam,MV_PAR01)
aadd(aParam,MV_PAR02)
aadd(aParam,MV_PAR03)
aadd(aParam,MV_PAR04)
aadd(aParam,MV_PAR05)
aadd(aParam,MV_PAR06)
aadd(aParam,MV_PAR07)
aadd(aParam,MV_PAR08)
aadd(aParam,MV_PAR09)
aadd(aParam,MV_PAR10)
aadd(aParam,MV_PAR11)
aadd(aParam,MV_PAR12)
aadd(aParam,MV_PAR13)
aadd(aParam,MV_PAR14)
aadd(aParam,MV_PAR15)

//Rotina para montar array com tabelas
oVIXA095:MontaSA1Proc()

//Recupera o nome das tabelas a serem analisadas
cTabSA1 := AllTrim(Posicione("SX2",1,"SA1","X2_ARQUIVO"))
cCptSA1	:= iif(SX2->X2_MODO == "C",Space(Len(SM0->M0_CODFIL)),SM0->M0_CODFIL)

//Verifica se encontra no vetor o cliente a admin	ser processado
nPosTab := aScan(oVIXA095:aSA1, {|x| x[1] == cTabSA1 .and. x[2] == cCptSA1 })

//Monta o filtro da query 
If cPaisLoc != "BRA"
 
	cFilQuery += " AND SE1.E1_TIPO NOT IN " + FormatIn(cCheques,"|")

Else

	cFilQuery += " AND SE1.E1_ORIGEM <> 'FINA087A' "
	
EndIf
		                                           				
If aParam[13] == 1
		
	cFilQuery += " AND SE1.E1_LOJA = '"+SA1->A1_LOJA+"' "
	
EndIf		 	

If aParam[05] == 2

	cFilQuery += " AND SE1.E1_TIPO <> 'PR' "

EndIf

If aParam[15] == 2

	cFilQuery += " AND SE1.E1_TIPO <> 'RA' "

EndIf
		               
If aParam[08] == 2
	
	cFilQuery += " AND SE5.E5_MOTBX <> 'FAT' "
	
Endif

If aParam[09] == 2                           

	cFilQuery += " AND SE5.E5_MOTBX <> 'LIQ' "

Endif

cFilQuery := "% "+cFilQuery+" %"

For iX := 1 to Len(oVIXA095:aSA1[nPosTab][6])

	//define a tabela que irá buscar as vendas
	cTabSE1	:= "% "+oVIXA095:aSA1[nPosTab][6][iX][1]+" %"  
	cTabSE5	:= "% SE5"+SubStr(cTabSE1,6,3)+" %"
	
	cFilSE1	:= "% '"+oVIXA095:aSA1[nPosTab][6][iX][2]+"' %"
	
    cEmpSE1	:= SubStr(oVIXA095:aSA1[nPosTab][6][iX][1],4,2)
	 
	 //Query para analisar a data da ultima compra do cliente	
	BeginSql Alias cAlias

	SELECT	%Exp:cEmpSE1%	XX_EMPRESA
		,	SE1.*
		,	SE5.*
		,	SX5.*
		
	FROM	%Exp:cTabSE1% SE1 
	
			LEFT JOIN %table:SX5% SX5 ON 	SX5.%notdel%
										AND SX5.X5_FILIAL	= %xFilial:SX5%
										AND SX5.X5_CHAVE	= SE1.E1_SITUACA
										AND SX5.X5_TABELA	= '07'
										
			INNER JOIN  %Exp:cTabSE5% SE5 ON	SE5.%notdel%
											AND SE5.E5_FILIAL	= SE1.E1_FILIAL
											AND SE5.E5_NATUREZ	= SE1.E1_NATUREZ
											AND SE5.E5_PREFIXO	= SE1.E1_PREFIXO
											AND SE5.E5_NUMERO	= SE1.E1_NUM
											AND SE5.E5_PARCELA	= SE1.E1_PARCELA
											AND SE5.E5_TIPO		= SE1.E1_TIPO
											AND SE5.E5_CLIFOR	= SE1.E1_CLIENTE
											AND SE5.E5_LOJA		= SE1.E1_LOJA
											AND SE5.E5_TIPODOC	<> 'JR'
											AND SE5.E5_RECPAG	= 'R'
											AND SE5.E5_SITUACA	<> 'C'
											
											AND NOT EXISTS (	SELECT	A.E5_NUMERO
														   		FROM	%Exp:cTabSE5% A
																WHERE 	A.E5_FILIAL		= SE5.E5_FILIAL
																	AND	A.E5_NATUREZ	= SE5.E5_NATUREZ
																	AND	A.E5_PREFIXO	= SE5.E5_PREFIXO
																	AND	A.E5_NUMERO		= SE5.E5_NUMERO
																	AND	A.E5_PARCELA	= SE5.E5_PARCELA
																	AND	A.E5_TIPO		= SE5.E5_TIPO
																	AND	A.E5_CLIFOR		= SE5.E5_CLIFOR
																	AND	A.E5_LOJA		= SE5.E5_LOJA
																	AND	A.E5_SEQ		= SE5.E5_SEQ
																	AND	A.E5_TIPODOC	= 'ES'
																	AND	A.E5_RECPAG		<> 'R'
																	AND	A.%notdel%)
													
	WHERE	SE1.E1_FILIAL	IN (%Exp:cFilSE1%)
		AND SE1.%notdel%	
			               
		AND SE1.E1_CLIENTE	= %Exp:SA1->A1_COD%
		AND SE1.E1_EMISSAO	BETWEEN %Exp:aParam[1]% AND %Exp:aParam[2]%
		AND SE1.E1_VENCREA	BETWEEN %Exp:aParam[3]% AND %Exp:aParam[4]%
		AND SE1.E1_PREFIXO	BETWEEN %Exp:aParam[6]% AND %Exp:aParam[7]% 
	
		AND SE1.E1_TIPO 	NOT LIKE '__-'
		AND SE1.E1_TIPO 	NOT IN ('RA ','PA ',%Exp:MV_CRNEG%,%Exp:MV_CPNEG%)
	    
  		%Exp:cFilQuery%
	    	     
		ORDER BY E1_FILIAL, E1_VENCREA, E1_PREFIXO, E1_NUM, E1_PARCELA
	
	EndSql

	(cAlias)->(dbGoTop())
	
	While (cAlias)->(!Eof())

   		Aadd(oGetDPagos:aCols,{	  	(cAlias)->XX_EMPRESA,;
									(cAlias)->E1_FILIAL,;
									(cAlias)->E1_PREFIXO,;
									(cAlias)->E1_NUM,;
									(cAlias)->E1_PARCELA,;
									(cAlias)->E1_TIPO,;   									
									(cAlias)->E1_CLIENTE,;
									DtoC(StoD((cAlias)->E1_EMISSAO)),;
									DtoC(StoD((cAlias)->E1_VENCREA)),;
									DtoC(StoD((cAlias)->E5_DATA)),;
									DtoC(StoD((cAlias)->E5_DTDISPO)),;
									(cAlias)->E1_VALOR,;
									(cAlias)->E1_VLCRUZ,;
									(cAlias)->E5_VLJUROS,;
									(cAlias)->E5_VLMULTA,;
									(cAlias)->E5_VLCORRE,;
									(cAlias)->E5_VLDESCO,;
									(cAlias)->E5_VALOR,;
									(cAlias)->E1_NATUREZ,;
									(cAlias)->E5_BANCO,;
									(cAlias)->E5_AGENCIA,;
									(cAlias)->E5_CONTA,;
									(cAlias)->E5_HISTOR,;
									(cAlias)->E5_MOTBX,;
									(cAlias)->E5_TIPODOC,;
									(cAlias)->E1_VALJUR,;
									(cAlias)->E1_MULTA,;
									.F.})
         
		nQtdTit++
		
		Do Case
		
			Case (cAlias)->E1_TIPO == "RA "; nValTit -= (cAlias)->E5_VALOR
			Case (cAlias)->E1_TIPO == "AB-"; nValTit -= (cAlias)->E5_VALOR
			Case (cAlias)->E1_TIPO == "NCC"; nValTit -= (cAlias)->E5_VALOR
			
			OtherWise; nValTit += (cAlias)->E5_VALOR
		
		EndCase

		(cAlias)->(dbSkip())
   		
	EndDo
	 
	(cAlias)->(dbCloseArea())

Next

If Len(oGetDPagos:aCols) == 0

	Aadd(oGetDPagos:aCols,{	"",;	
							CriaVar("E1_FILIAL"),;
							CriaVar("E1_PREFIXO"),;
							CriaVar("E1_NUM"),;
							CriaVar("E1_PARCELA"),;
							CriaVar("E1_TIPO"),;
							CriaVar("E1_CLIENTE"),;
							CriaVar("E1_EMISSAO"),;
							CriaVar("E1_VENCREA"),;
							CriaVar("E5_DATA"),;
							CriaVar("E5_DTDISPO"),;
							CriaVar("E1_VALOR"),;
							CriaVar("E1_VLCRUZ"),;
							CriaVar("E5_VLJUROS"),;
							CriaVar("E5_VLMULTA"),;
							CriaVar("E5_VLCORRE"),;
							CriaVar("E5_VLDESCO"),;
							CriaVar("E5_VALOR"),;
							CriaVar("E1_NATUREZ"),;
							CriaVar("E5_BANCO"),;
							CriaVar("E5_AGENCIA"),;
							CriaVar("E5_CONTA"),;
							CriaVar("E5_HISTOR"),;
							CriaVar("E5_MOTBX"),;
							CriaVar("E5_TIPODOC"),;
							CriaVar("E1_VALJUR"),;
							CriaVar("E1_MULTA"),;
							.F.})

EndIf

cQtdTitPag := cQtdTitPag + Alltrim(Str(nQtdTit))
cValTitPag := cValTitPag + Transform(nValTit,"@E 999,999,999.99")
oGetDPagos:Refresh()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fAtualiza º Autor ³ MICROSIGA VITORIA  º Data ³  24/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza Acols com informacoes                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fAtualiza()

	MsgRun("Selecionando Registros em Aberto, Aguarde...","",{|| CursorWait(), 	fGetInfAbr() ,CursorArrow()})
	MsgRun("Selecionando Registros Pagos, Aguarde...","",{|| CursorWait(), 	fGetInfPag() ,CursorArrow()})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fImprime  º Autor ³ MICROSIGA VITORIA  º Data ³  24/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime relatorio das informacoes                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fImprime(aAbertos,aPagos)

Local oReport	//Objeto relatorio TReport (Release 4)
Local aAbertos 	:= aAbertos
Local aPagos 	:= aPagos

//	ValPerg()

//	Pergunte("RELTIT",.T.)
	
	oReport := RelTitDEF(aAbertos,aPagos)
	oReport:PrintDialog()

Return(.T.)   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RelTitDEF º Autor ³ MICROSIGA VITORIA  º Data ³  24/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime relatorio das informacoes                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RelTitDEF(aAbertos,aPagos)
Local oReport				//Objeto relatorio TReport (Release 4)
Local oSection1 			//Objeto secao 1 do relatorio 
Local oSection2 			//Objeto secao 1 do relatorio
Local oSection3 			//Objeto secao 1 do relatorio

DEFINE REPORT oReport NAME "RELTIT" TITLE "TITULOS POR CLIENTE" ACTION {|oReport| RelTitIMP( oReport, aAbertos, aPagos )} DESCRIPTION "TITULOS POR CLIENTE"

oReport:SetLandscape() 

DEFINE SECTION oSection1 OF oReport TITLE "Dados Cliente" TABLES "SE1","SA1"

DEFINE CELL NAME "A1_COD"			OF oSection1 ALIAS "SA1" TITLE "Codigo" SIZE 09 BLOCK {|| SA1->A1_COD + "/" + SA1->A1_LOJA}
DEFINE CELL NAME "A1_NOME"			OF oSection1 ALIAS "SA1" TITLE "Nome" BLOCK {|| Alltrim(SA1->A1_NOME)}


DEFINE SECTION oSection2 OF oSection1 TITLE "Titulos Em Aberto" TABLES "SE1"

DEFINE CELL NAME "XX_EMPRESA"				OF oSection2 ALIAS "XXX"
DEFINE CELL NAME "E1_FILIAL"				OF oSection2 ALIAS "SE1"
DEFINE CELL NAME "E1_PREFIXO"				OF oSection2 ALIAS "SE1"
DEFINE CELL NAME "E1_NUM"					OF oSection2 ALIAS "SE1"
DEFINE CELL NAME "E1_PARCELA"				OF oSection2 ALIAS "SE1"
DEFINE CELL NAME "E1_TIPO"					OF oSection2 ALIAS "SE1"
DEFINE CELL NAME "E1_SITUACA"					OF oSection2 ALIAS "SE1"
DEFINE CELL NAME "E1_EMISSAO"				OF oSection2 ALIAS "SE1"
DEFINE CELL NAME "E1_VENCREA"				OF oSection2 ALIAS "SE1"
DEFINE CELL NAME "E1_ATR"					OF oSection2 ALIAS "" TITLE "___Atraso" PICTURE "9999999999" SIZE 10
DEFINE CELL NAME "E1_VALOR"					OF oSection2 ALIAS "SE1"
DEFINE CELL NAME "E1_SALDO"					OF oSection2 ALIAS "SE1"
DEFINE CELL NAME "E1_NATUREZ"				OF oSection2 ALIAS "SE1"

DEFINE SECTION oSection3 OF oSection1 TITLE "Titulos Pagos" TABLES "SE1","SE5"

DEFINE CELL NAME "XX_EMPRESA"				OF oSection3 ALIAS "XXX"
DEFINE CELL NAME "E1_FILIAL"				OF oSection3 ALIAS "SE1"
DEFINE CELL NAME "E1_PREFIXO"				OF oSection3 ALIAS "SE1"
DEFINE CELL NAME "E1_NUM"					OF oSection3 ALIAS "SE1"
DEFINE CELL NAME "E1_PARCELA"				OF oSection3 ALIAS "SE1"
DEFINE CELL NAME "E1_TIPO"					OF oSection3 ALIAS "SE1"
DEFINE CELL NAME "E1_EMISSAO"				OF oSection3 ALIAS "SE1"
DEFINE CELL NAME "E1_VENCREA"				OF oSection3 ALIAS "SE1"
DEFINE CELL NAME "E5_VALOR"					OF oSection3 ALIAS "SE5"
DEFINE CELL NAME "E1_NATUREZ"				OF oSection3 ALIAS "SE1"

TRFunction():New(oSection2:Cell("E1_NUM"),,"COUNT",,"",/*cPicture*/,/*uFormula*/,,.F.,.F.)
TRFunction():New(oSection2:Cell("E1_SALDO"),,"SUM",,"",/*cPicture*/,/*uFormula*/,,.F.,.F.)
TRFunction():New(oSection3:Cell("E1_NUM"),,"COUNT",,"",/*cPicture*/,/*uFormula*/,,.F.,.F.)
TRFunction():New(oSection3:Cell("E5_VALOR"),,"SUM",,"",/*cPicture*/,/*uFormula*/,,.F.,.F.)

oSection1:SetTotalText("")
oSection2:SetTotalText("")
oSection3:SetTotalText("")
oReport:SetTotalText("")
oSection1:SetTotalInLine(.F.)
oSection2:SetTotalInLine(.F.)
oSection3:SetTotalInLine(.F.)
oReport:SetTotalInLine(.F.)

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RelTitIMP º Autor ³ MICROSIGA VITORIA  º Data ³  24/08/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime relatorio das informacoes                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RelTitIMP( oReport, aAbertos, aPagos )
Local oSection1 := oReport:Section(1)		//Objeto secao 1 do relatorio (Cabecalho, campos da tabela SU7) 
Local oSection2 := oSection1:Section(1)
Local oSection3 := oSection1:Section(2)

oReport:SetMeter(RecCount())

oSection1:Init()
oSection1:PrintLine()
oSection1:Finish()

_nEmpresa	:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "XX_EMPRESA"})
_nFilial	:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "E1_FILIAL"})
_nPrefix	:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "E1_PREFIXO"})
_nNumero	:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "E1_NUM"})
_nParcel	:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "E1_PARCELA"})
_nTipo		:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "E1_TIPO"})  
_nEmissa	:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "E1_EMISSAO"})
_nVencRe	:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "E1_VENCREA"})
_nAtraso	:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "E1_ATR"})
_nValor		:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "E1_VALOR"})
_nSaldo		:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "E1_SALDO"})
_nNature	:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "E1_NATUREZ"})

nI := 0
oReport:SkipLine(1)
oReport:PrintText("TITULOS EM ABERTO")
oSection2:Init()
For nI := 1 To Len(aAbertos)
                                                                                             
	oSection2:Cell("XX_EMPRESA"):SetValue(aAbertos[nI,_nEmpresa])
	oSection2:Cell("E1_FILIAL"):SetValue(aAbertos[nI,_nFilial])
	oSection2:Cell("E1_PREFIXO"):SetValue(aAbertos[nI,_nPrefix])
	oSection2:Cell("E1_NUM"):SetValue(aAbertos[nI,_nNumero])
	oSection2:Cell("E1_PARCELA"):SetValue(aAbertos[nI,_nParcel])
	oSection2:Cell("E1_TIPO"):SetValue(aAbertos[nI,_nTipo])
	oSection2:Cell("E1_EMISSAO"):SetValue(aAbertos[nI,_nEmissa])
	oSection2:Cell("E1_VENCREA"):SetValue(aAbertos[nI,_nVencRe])
	oSection2:Cell("E1_ATR"):SetValue(aAbertos[nI,_nAtraso])
	oSection2:Cell("E1_VALOR"):SetValue(aAbertos[nI,_nValor])
	oSection2:Cell("E1_SALDO"):SetValue(aAbertos[nI,_nSaldo])
	oSection2:Cell("E1_NATUREZ"):SetValue(aAbertos[nI,_nNature])

	oSection2:PrintLine()

	If oReport:Cancel()
		Exit
	EndIf

Next
oSection2:Finish()

_nEmpresa	:= Ascan(oGetDPagos:aHeader,{|x| Alltrim(x[2]) == "XX_EMPRESA"})
_nFilial	:= Ascan(oGetDPagos:aHeader,{|x| Alltrim(x[2]) == "E1_FILIAL"})
_nPrefix	:= Ascan(oGetDPagos:aHeader,{|x| Alltrim(x[2]) == "E1_PREFIXO"})
_nNumero	:= Ascan(oGetDPagos:aHeader,{|x| Alltrim(x[2]) == "E1_NUM"})
_nParcel	:= Ascan(oGetDPagos:aHeader,{|x| Alltrim(x[2]) == "E1_PARCELA"})
_nTipo		:= Ascan(oGetDPagos:aHeader,{|x| Alltrim(x[2]) == "E1_TIPO"})
_nEmissa	:= Ascan(oGetDPagos:aHeader,{|x| Alltrim(x[2]) == "E1_EMISSAO"})
_nVencRe	:= Ascan(oGetDPagos:aHeader,{|x| Alltrim(x[2]) == "E1_VENCREA"})
_nValor		:= Ascan(oGetDPagos:aHeader,{|x| Alltrim(x[2]) == "E5_VALOR"})
_nNature	:= Ascan(oGetDPagos:aHeader,{|x| Alltrim(x[2]) == "E1_NATUREZ"})

nI := 0
oReport:SkipLine(1)
oReport:PrintText("TITULOS PAGOS")
oSection3:Init()
For nI := 1 To Len(aPagos)

	oSection3:Cell("XX_EMPRESA"):SetValue(aPagos[nI,_nEmpresa])
	oSection3:Cell("E1_FILIAL"):SetValue(aPagos[nI,_nFilial])
	oSection3:Cell("E1_PREFIXO"):SetValue(aPagos[nI,_nPrefix])
	oSection3:Cell("E1_NUM"):SetValue(aPagos[nI,_nNumero])
	oSection3:Cell("E1_PARCELA"):SetValue(aPagos[nI,_nParcel])
	oSection3:Cell("E1_TIPO"):SetValue(aPagos[nI,_nTipo])
	oSection3:Cell("E1_EMISSAO"):SetValue(aPagos[nI,_nEmissa])
	oSection3:Cell("E1_VENCREA"):SetValue(aPagos[nI,_nVencRe])
	oSection3:Cell("E5_VALOR"):SetValue(aPagos[nI,_nValor])
	oSection3:Cell("E1_NATUREZ"):SetValue(aPagos[nI,_nNature])
	oSection3:PrintLine()
	If oReport:Cancel()
		Exit
	EndIf

Next
oSection3:Finish()

Return()

Static Function ValPerg()

Local aHelpPor := {}

u_zPutSX1( 'RELTIT','01','Titulos','','','mv_ch1','N',1,0,0,'C','','','','','mv_par01','Abertos','','','','Pagos','','','','Todos','','','','','','','',aHelpPor,{},{} )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³fResumo   ³ Autor ³ Felipe Caiado Almeida ³ Data ³13/01/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fResumo()
// Variaveis Locais da Funcao

// Defina aqui os Botoes da sua EnchoiceBar
Local aButtons	:= {}
// Variaveis Private da Funcao
Private oDlg1				// Dialog Principal
// Privates das NewGetDados
Private oGetDados1
Private oGetDados2

DEFINE MSDIALOG oDlg1 TITLE "Resumo Por Mês" FROM C(208),C(233) TO C(592),C(655) PIXEL

	@ C(017),C(005) Say "Titulos em Aberto" Size 060,010 COLOR CLR_BLACK PIXEL OF oDlg1
	@ C(017),C(112) Say "Titulos Pagos" Size 060,010 COLOR CLR_BLACK PIXEL OF oDlg1
	// Chamadas das GetDados do Sistema
	fGetDados1()
	fGetDados2()
	fGetResumo()

ACTIVATE MSDIALOG oDlg1 CENTERED  ON INIT EnchoiceBar(oDlg1, {||oDlg1:End()},{||oDlg1:End()},,aButtons)

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fGetDados1()³ Autor ³ Felipe Caiado Almeida     ³ Data ³13/01/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da GetDados                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGetDados1 foi criado como Private no inicio do Fonte   ³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do            ³±±
±±³           ³ seu programa:                                                    ³±±
±±³           ³                                                                  ³±±
±±³           ³ Para acessar o aCols desta MsNewGetDados: oGetDados1:aCols[nX,nY]³±±
±±³           ³ Para acessar o aHeader: oGetDados1:aHeader[nX,nY]                ³±±
±±³           ³ Para acessar o "n"    : oGetDados1:nAT                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGetDados1()
// Variaveis deste Form                                                                                                         
Local nX			:= 0                                                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa       	:= {"E1_MESANO","E1_VALOR"}
// Vetor com os campos que poderao ser alterados                                                                                
Local aAlter       	:= {""}
Local nSuperior    	:= C(023)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= C(005)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= C(187)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= C(106)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nOpc         	:= 0//GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                         // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                         // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
Local cSuperDel     	:= ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        	:= "AllwaysTrue"   // Funcao executada para validar a exclusao de uma linha do aCols                   
// Objeto no qual a MsNewGetDados sera criada                                      
Local oWnd          	:= oDlg1                                                                                                  
Local aHead        	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Local aCol         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols                      
                                                                                                                                
// Carrega aHead                                                                                                                
DbSelectArea("SX3")                                                                                                             
SX3->(DbSetOrder(2)) // Campo                                                                                                   
For nX := 1 to Len(aCpoGDa)                                                                                                     
	If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
		Aadd(aHead,{ AllTrim(X3Titulo()),;                                                                                         
			SX3->X3_CAMPO	,;                                                                                                       
			SX3->X3_PICTURE,;                                                                                                       
			SX3->X3_TAMANHO,;                                                                                                       
			SX3->X3_DECIMAL,;                                                                                                       
			SX3->X3_VALID	,;                                                                                                       
			SX3->X3_USADO	,;                                                                                                       
			SX3->X3_TIPO	,;                                                                                                       
			SX3->X3_F3 		,;                                                                                                       
			SX3->X3_CONTEXT,;                                                                                                       
			SX3->X3_CBOX	,;                                                                                                       
			SX3->X3_RELACAO})                                                                                                       
	Else
		Aadd(aHead,{"Ano/Mês",;
					"E1_MESANO",;
					"@!",;
					9,;
					0,;
					"",;
					"",;
					"C",;
					"",;
					"V",;
					SX3->X3_CBOX,;
					SX3->X3_RELACAO })
	Endif                                                                                                                         
Next nX                                                                                                                         
// Carregue aqui a Montagem da sua aCol                                                                                         
aAux := {}                          
For nX := 1 to Len(aCpoGDa)         
	If DbSeek(aCpoGDa[nX])             
		If Alltrim(aCpoGDa[nX]) == "E1_MESANO"
			Aadd(aAux,Space(9))
		Else
			Aadd(aAux,CriaVar(SX3->X3_CAMPO))
		EndIf
	Endif                              
Next nX                             
Aadd(aAux,.F.)                      
Aadd(aCol,aAux)                     

oGetDados1:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;                               
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)                                   

// Cria ExecBlocks da GetDados

Return Nil                                                                                                                      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fGetDados2()³ Autor ³ Felipe Caiado Almeida     ³ Data ³13/01/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da GetDados                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGetDados2 foi criado como Private no inicio do Fonte   ³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do            ³±±
±±³           ³ seu programa:                                                    ³±±
±±³           ³                                                                  ³±±
±±³           ³ Para acessar o aCols desta MsNewGetDados: oGetDados2:aCols[nX,nY]³±±
±±³           ³ Para acessar o aHeader: oGetDados2:aHeader[nX,nY]                ³±±
±±³           ³ Para acessar o "n"    : oGetDados2:nAT                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGetDados2()
// Variaveis deste Form                                                                                                         
Local nX			:= 0                                                                                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa       	:= {"E1_MESANO","E1_VALOR"}
// Vetor com os campos que poderao ser alterados                                                                                
Local aAlter       	:= {""}
Local nSuperior    	:= C(023)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= C(112)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= C(187)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= C(203)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nOpc         	:= 0//GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                         // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                         // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
Local cSuperDel     	:= ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk        	:= "AllwaysTrue"   // Funcao executada para validar a exclusao de uma linha do aCols                   
// Objeto no qual a MsNewGetDados sera criada                                      
Local oWnd          	:= oDlg1                                                                                                  
Local aHead        	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Local aCol         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols                      
                                                                                                                                
// Carrega aHead                                                                                                                
DbSelectArea("SX3")                                                                                                             
SX3->(DbSetOrder(2)) // Campo                                                                                                   
For nX := 1 to Len(aCpoGDa)                                                                                                     
	If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
		Aadd(aHead,{ AllTrim(X3Titulo()),;                                                                                         
			SX3->X3_CAMPO	,;                                                                                                       
			SX3->X3_PICTURE,;                                                                                                       
			SX3->X3_TAMANHO,;                                                                                                       
			SX3->X3_DECIMAL,;                                                                                                       
			SX3->X3_VALID	,;                                                                                                       
			SX3->X3_USADO	,;                                                                                                       
			SX3->X3_TIPO	,;                                                                                                       
			SX3->X3_F3 		,;                                                                                                       
			SX3->X3_CONTEXT,;                                                                                                       
			SX3->X3_CBOX	,;                                                                                                       
			SX3->X3_RELACAO})                                                                                                       
	Else
		Aadd(aHead,{"Ano/Mês",;
					"E1_MESANO",;
					"@!",;
					9,;
					0,;
					"",;
					"",;
					"C",;
					"",;
					"V",;
					SX3->X3_CBOX,;
					SX3->X3_RELACAO })
	Endif                                                                                                                         
Next nX                                                                                                                         
// Carregue aqui a Montagem da sua aCol                                                                                         
aAux := {}                          
For nX := 1 to Len(aCpoGDa)         
	If DbSeek(aCpoGDa[nX])             
		If Alltrim(aCpoGDa[nX]) == "E1_MESANO"
			Aadd(aAux,Space(9))
		Else
			Aadd(aAux,CriaVar(SX3->X3_CAMPO))
		EndIf
	Endif                              
Next nX                             
Aadd(aAux,.F.)                      
Aadd(aCol,aAux)                     

oGetDados2:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;                               
                             aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)                                   

// Cria ExecBlocks da GetDados

Return Nil                                                                                                                      

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)                                                         
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)                                                                

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³GetResumo³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGetResumo()

oGetDados1:aCols := {}
nI := 0
_nVencRe	:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "E1_VENCREA"})
_nValor		:= Ascan(oGetDAbert:aHeader,{|x| Alltrim(x[2]) == "E1_SALDO"})
If Alltrim(oGetDAbert:aCols[1,1]) <> ""
	For nI := 1 To Len(oGetDAbert:aCols)
		_cData := Substr(oGetDAbert:aCols[nI,_nVencRe],4,5)
		_cData := "20" + Substr(_cData,4,2) + "/" + Substr(_cData,1,2)
		_nLocaliz := Ascan(oGetDados1:aCols,{|x| Alltrim(x[1]) == _cData})
		If _nLocaliz == 0
			Aadd(oGetDados1:aCols,{_cData,oGetDAbert:aCols[nI,_nValor],.F.})
		Else
			oGetDados1:aCols[_nLocaliz,2] += oGetDAbert:aCols[nI,_nValor]
		EndIf
	Next
Else
	Aadd(oGetDados1:aCols,{Space(09),0,.F.})
EndIf
aSort(oGetDados1:aCols,,,{|x,y| x[1]<y[1]})
oGetDados1:Refresh()

oGetDados2:aCols := {}
nI := 0
_nVencRe	:= Ascan(oGetDPagos:aHeader,{|x| Alltrim(x[2]) == "E1_VENCREA"})
_nValor		:= Ascan(oGetDPagos:aHeader,{|x| Alltrim(x[2]) == "E5_VALOR"})
If Alltrim(oGetDPagos:aCols[1,1]) <> ""
	For nI := 1 To Len(oGetDPagos:aCols)
		_cData := Substr(oGetDPagos:aCols[nI,_nVencRe],4,5)
		_cData := "20" + Substr(_cData,4,2) + "/" + Substr(_cData,1,2)
		_nLocaliz := Ascan(oGetDados2:aCols,{|x| Alltrim(x[1]) == _cData})
		If _nLocaliz == 0
			Aadd(oGetDados2:aCols,{_cData,oGetDPagos:aCols[nI,_nValor],.F.})
		Else
			oGetDados2:aCols[_nLocaliz,2] += oGetDPagos:aCols[nI,_nValor]
		EndIf
	Next
Else
	Aadd(oGetDados2:aCols,{Space(09),0,.F.})
EndIf
aSort(oGetDados2:aCols,,,{|x,y| x[1]<y[1]})
oGetDados2:Refresh()

Return()