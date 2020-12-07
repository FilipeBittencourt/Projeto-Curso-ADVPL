#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
##############################################################################################################
# PROGRAMA...: TCCB_Processar       
# AUTOR......: Fernando Rocha (FACILE SISTEMAS)
# DATA.......: 09/01/2014                      
# DESCRICAO..: Classe que constroi e tela e processa o arquivo CCB
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/                    

User Function FACCB01()

	Local oProc := TCCB_Processar():New()

Return

Class TCCB_Processar        

Data oDlgProc
Data oTexto1
Data oTexto2
Data cTexto1
Data cTexto2   
Data oPanel1

Data oMeter1
Data oMeter2 
Data nPosM1
Data nPosM2  
Data nLastUpdate

Data aTexto
Data oCCB_LoadData 	//Objeto do tipo TCCB_LoadData para acessar os metodos de carga de dados

//Parametros
Data dDataIni
Data dDataFim   
Data cPath
Data cFileBase

Method New()
Method Show()	      
Method Pergunta()

Method Start1()
Method Start2(nMax)
Method Atualiza1(cTexto, nPerc)
Method Atualiza2(cTexto, nPerc)

Method Processar()  
Method LoadREG(dDataIni,dDataFim)
Method Cancelar()		
Method GerarModulo()
Method AddTexto(aDados) 	
Method GrvTxtMod()  //Gravar os dados do respectivo modulo no arquivo texto conforme parametros    
Method ExpExcel(aDados)

EndClass  


Method New() Class TCCB_Processar 

	::nPosM1 := 10
	::nPosM2 := 10
	::cTexto1 := "Inicializando..."
	::cTexto2 := "Inicializando..."     

	::cPath := "C:\TEMP\"
	::cFileBase := "ATUAL"

	::aTexto := {}

	::Show()

Return Self      


Method Show() Class TCCB_Processar

	Local oFont1 := TFont():New("Verdana",,020,,.T.,,,,,.F.,.F.)
	Local oFont2 := TFont():New("Verdana",,020,,.F.,,,,,.F.,.F.)

	Local oGroup1
	Local oGroup2
	Local oPanel2
	Local oPanel3
	Local oSay1
	Local oSButton1
	Local oSButton2
	Local oSButton3

	DEFINE MSDIALOG ::oDlgProc TITLE "Gerador Arquivo CCB" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL  

	@ 000, 000 MSPANEL ::oPanel1 SIZE 250, 126 OF ::oDlgProc COLORS 0, 16777215 RAISED
	@ 000, 000 MSPANEL oPanel2 SIZE 249, 020 OF ::oPanel1 COLORS 0, 16777215 RAISED
	@ 005, 010 SAY oSay1 PROMPT "Gerador Arquivo CCB" SIZE 142, 010 OF oPanel2 FONT oFont1 COLORS 8388608, 16777215 PIXEL
	@ 021, 000 GROUP oGroup1 TO 071, 249 PROMPT "MÛdulos/Registros" OF ::oPanel1 COLOR 0, 16777215 PIXEL
	@ 071, 000 GROUP oGroup2 TO 125, 249 PROMPT "Progresso" OF ::oPanel1 COLOR 0, 16777215 PIXEL
	@ 032, 005 SAY ::oTexto1 PROMPT ::cTexto1 SIZE 131, 011 OF ::oPanel1 FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ 046, 006 METER ::oMeter1 VAR ::nPosM1 SIZE 238, 012 OF ::oPanel1 TOTAL 100 COLOR 0, 16777215 PIXEL
	@ 083, 005 SAY ::oTexto2 PROMPT ::cTexto2 SIZE 131, 011 OF ::oPanel1 FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ 099, 006 METER ::oMeter2 VAR ::nPosM2 SIZE 238, 012 OF ::oPanel1 TOTAL 100 COLOR 0, 16777215 PIXEL
	@ 131, 115 BUTTON oSButton1 PROMPT "Cancelar" SIZE 037, 012 OF ::oDlgProc PIXEL
	@ 131, 155 BUTTON oSButton2 PROMPT "Processar" SIZE 037, 012 OF ::oDlgProc PIXEL
	@ 131, 195 BUTTON oSButton3 PROMPT "Parametros" SIZE 037, 012 OF ::oDlgProc PIXEL

	oSButton1:bAction := {|| ::Cancelar() }
	oSButton2:bAction := {|| ::Processar() }
	oSButton3:bAction := {|| ::Pergunta(.T.) }

	// Don't change the Align Order
	oPanel2:Align := CONTROL_ALIGN_TOP
	oGroup1:Align := CONTROL_ALIGN_TOP
	oGroup2:Align := CONTROL_ALIGN_ALLCLIENT

	::Pergunta(.F.)

	ACTIVATE MSDIALOG ::oDlgProc CENTERED ON INIT (  ) //RETIRADO FUNCAO COMMITCONTROLS
	//ACTIVATE MSDIALOG ::oDlgProc CENTERED ON INIT ( CommitControls() )

Return               

//***********************************************************************************
//Pergunta - Fernando Rocha
//Parametros para a rotina
//***********************************************************************************       
Method Pergunta(lShow) Class TCCB_Processar
	Default lShow := .F.
	Private cPerg := "FSCCB"
	ValPerg()

	//MV_PAR01 = Data Inicial
	//MV_PAR02 = Data Final
	//MV_PAR03 = Pasta Local
	//MV_PAR04 = Nome Base Arquivo

	Pergunte(cPerg,lShow)

	::dDataIni 	:= MV_PAR01
	::dDataFim 	:= MV_PAR02
	::cPath 	:= MV_PAR03
	::cFileBase	:= MV_PAR04 

Return

//***********************************************************************************
//Start1 - Fernando Rocha
//Reiniciar a regua de processamento
//***********************************************************************************       
Method Start1() Class TCCB_Processar
	::nPosM1 := 0	
	::oMeter1:SetTotal(10)
	::oDlgProc:CommitControls()
Return

Method Start2(nMax) Class TCCB_Processar
	::nPosM2 := 0	   
	::oMeter2:SetTotal(nMax)	
	::oDlgProc:CommitControls()
Return

//***********************************************************************************
//Atualiza1 - Fernando Rocha
//Atualizar obejtos da tela - regua de processamento
//***********************************************************************************       
Method Atualiza1(cTexto, nPerc) Class TCCB_Processar

	::cTexto1 := cTexto
	::oTexto1:Refresh()

	::nPosM1 := nPerc * 100
	::oMeter1:Set(nPerc)   

	If (Seconds() - ::nLastUpdate) > 1
		//::oDlgProc:CommitControls()
		::oDlgProc:Refresh()     
		::nLastUpdate := Seconds()
	EndIf

Return

//***********************************************************************************
//Atualiza2 - Fernando Rocha
//Atualizar obejtos da tela - regua de processamento
//***********************************************************************************       
Method Atualiza2(cTexto, nPerc) Class TCCB_Processar

	::cTexto2 := cTexto
	::oTexto2:Refresh()

	::nPosM2 := nPerc * 100
	::oMeter2:Set(nPerc)	

	If (Seconds() - ::nLastUpdate) > 1
		//::oDlgProc:CommitControls()
		::oDlgProc:Refresh()     
		::nLastUpdate := Seconds()
	EndIf

Return              

//***********************************************************************************
//Processar - Fernando Rocha
//Processar geracao do arquivo
//***********************************************************************************
Method Processar() Class TCCB_Processar  
	Local I 

	::nLastUpdate := Seconds()
	::GerarModulo()     

	MSGINFO("PROCESSO TERMINADO","INFORME")
	::oDlgProc:End()

Return

//***********************************************************************************
//Cancelar - Fernando Rocha
//Finaliza rotina
//***********************************************************************************
Method Cancelar() Class TCCB_Processar
	::oDlgProc:End()
Return

//***********************************************************************************
//GerarModulo - Fernando Rocha
//Processar MODULO 3
//***********************************************************************************
Method GerarModulo() Class TCCB_Processar    
	Local I
	Local oReg
	Local aDados
	Local nMax

	//MODULO 3 - REGISTRO 0000
	::Start1()
	::Atualiza1("Processando Dados", 1)

	U_BIAMsgRun("Aguarde... Carregando Dados.",,{|| aDados := ::LoadREG(::dDataIni,::dDataFim) })

	//TXT
	IF MV_PAR05 == 1		
		nMax := Len(aDados)
		::Start2(nMax)
		FOR I := 1 To nMax

			::Atualiza2("Registro - Linha: "+AllTrim(Str(I)), I)
			::AddTexto(aDados[I])     

		NEXT I  

		::GrvTxtMod()
	ELSE

		::ExpExcel(aDados)

	ENDIF	        

Return 

//***********************************************************************************
//AddTexto - Fernando Rocha
//Adicionar linhas no vetor de retorno conforme laytout e dados recebidos
//***********************************************************************************
Method AddTexto(aDados)  Class TCCB_Processar
	//aDados >>> Vetor de dados do registro com a mesmos tipo e qtdes definidos no layout

	Local I
	Local _cString := ""

	If Len(aDados) <= 0
		_cString := "SEM DADOS"
		AAdd(::aTexto, _cString)
		Return
	EndIf

	//Montar String de cada linha do arquivo  
	_cString += PADR(aDados[1],11) 
	_cString += PADR(aDados[2],2)
	_cString += PADR(aDados[3],8)
	_cString += PADR(aDados[4],50)
	_cString += PADR(aDados[5],11)
	_cString += PADR(aDados[6],30)
	_cString += PADR(aDados[7],2)
	_cString += PADR(aDados[8],2)
	_cString += PADR(aDados[9],11)
	_cString += PADR(AllTrim(Str(NoRound(aDados[10],0))),11)
	_cString += PADR(AllTrim(Str(NoRound(aDados[11],0))),11)
	_cString += PADR(AllTrim(Str(NoRound(aDados[12],0))),6)
	_cString += PADR(AllTrim(Str(NoRound(aDados[13],0))),11)
	_cString += PADR(AllTrim(Str(NoRound(aDados[14],0))),6)
	_cString += PADR(aDados[15],11)
	_cString += PADR(aDados[16],11) 
	_cString += PADR(AllTrim(Str(NoRound(aDados[17],0))),6) 
	_cString += PADR(aDados[18],2)
	_cString += PADR(AllTrim(Str(NoRound(aDados[19],0))),6)


	//Adiciona a string resultante dos campos no retorno
	AAdd(::aTexto, _cString)

Return 


//***********************************************************************************
//GrvTxtMod - Fernando Rocha
//Gravar os dados do respectivo modulo no arquivo texto conforme parametros
//***********************************************************************************
Method GrvTxtMod(oModulo) Class TCCB_Processar
	Local I      
	Local nLinhas := Len(::aTexto)
	Local nHdlFile 
	Local cFileName := alltrim(::cPath)+alltrim(::cFileBase)+".TXT"
	Local cString 

	If !File(cFileName)
		nHdlFile := fCreate(cFileName)
	Else                              
		MsgAlert("ARQUIVO "+cFileName+" J¡ EXISTE","CCB - ATEN«√O")		
		Return
	EndIf  

	FOR I := 1 To nLinhas     

		cString := ::aTexto[I] + CRLF 

		fWrite(nHdlFile,cString)	// Grava nome do arquivo a ser processado

	NEXT I

	fClose (nHdlFile)

Return

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±≥Carregar os dados para o arquivo - Stored Procedure					≥±±
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Method LoadREG(dDataIni,dDataFim) Class TCCB_Processar
	Local aDados := {}
	Local aAux := {}   
	Local cSQL   
	Local I := 0

	cSQL := "EXEC SP_GERAR_CCB_"+AllTrim(CEMPANT)+" '"+DTOS(dDataIni)+"','"+DTOS(dDataFim)+"'"  

	TCQUERY cSQL NEW ALIAS "TRB"

	TRB->(DBGotop()) 

	Do While TRB->(!EOF()) 

		aAux := {}
		AAdd(aAux,	TRB->DATA_MOV)		        
		AAdd(aAux,	TRB->INFORMANTE)		
		AAdd(aAux,	TRB->CNPJ)
		AAdd(aAux,	TRB->RAZAO_SOCIAL)
		AAdd(aAux,	TRB->CLIENTE_DESDE)
		AAdd(aAux,	TRB->CIDADE)
		AAdd(aAux,	TRB->UF)
		AAdd(aAux,	TRB->CEP)
		AAdd(aAux,	TRB->MAIOR_FATURA)
		AAdd(aAux,	TRB->V_MAIOR_FATURA)
		AAdd(aAux,	TRB->V_A_VENCER)
		AAdd(aAux,	TRB->PRZ_MED_VENDAS)
		AAdd(aAux,	TRB->V_VENCIDOS)
		AAdd(aAux,	TRB->N_VENCIDOS)
		AAdd(aAux,	TRB->D_PRI_VENC)
		AAdd(aAux,	TRB->D_ULT_VENC)
		AAdd(aAux,	TRB->PRZ_MED_ATRASO)
		AAdd(aAux,	TRB->SITUACAO)
		AAdd(aAux,	TRB->PRZ_MED_PAG)

		AAdd(aDados, aAux) 

		TRB->(DBSkip()) 
	EndDo  

	TRB->(dbCloseArea())		

Return aDados 


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCAO PARA RETORNAR O EXTRATO ATUALIZADO DO ACORDO - USAR NO RELATORIO E WORKFLOW
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Method ExpExcel(aDados) Class TCCB_Processar

	Local aArea := GetArea()
	Local oFWExcel := Nil
	Local oMsExcel := Nil
	Local cDir := GetSrvProfString("Startpath", "")
	Local cFile := "CCB_EXCEL-" + __cUserID +"-"+ dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
	Local cWorkSheet := ""
	Local cTable := ""
	Local cDirTmp := AllTrim(GetTempPath())
	Local I

	cWorkSheet := "CCB_EXCEL"
	cTable := cWorkSheet + " - Data: "+Dtos(dDataBase)

	oFWExcel := FWMsExcel():New()
	oFWExcel:AddWorkSheet(cWorkSheet)
	oFWExcel:AddTable(cWorkSheet, cTable)

	oFWExcel:AddColumn(cWorkSheet, cTable, "Data do Movimento", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Informante", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "CNPJ", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Raz„o Social", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Cliente Desde (Data)", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Cidade", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "UF", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "CEP", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Maior Fatura (Data)", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Valor Maior Fatura", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Valor ‡ Vencer", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Prazo MÈd. Vendas", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Vencidos e N„o Pagos", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "N∫ de TÌtulos Vencidos", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "De (Data)", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "AtÈ (Data)", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Prazo MÈd. Atraso", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "SituaÁ„o", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Prazo MÈd. Pagamentos", 1, 1)


	nMax := Len(aDados)
	::Start2(nMax)
	FOR I := 1 To nMax

		::Atualiza2("Registro - Linha: "+AllTrim(Str(I)), I)

		aAux := {}
		AAdd(aAux, aDados[I][1]) 
		AAdd(aAux, aDados[I][2])
		AAdd(aAux, aDados[I][3])
		AAdd(aAux, aDados[I][4])
		AAdd(aAux, aDados[I][5])
		AAdd(aAux, aDados[I][6])
		AAdd(aAux, aDados[I][7])
		AAdd(aAux, aDados[I][8])
		AAdd(aAux, aDados[I][9])
		AAdd(aAux, aDados[I][10])
		AAdd(aAux, aDados[I][11])
		AAdd(aAux, aDados[I][12])
		AAdd(aAux, aDados[I][13])
		AAdd(aAux, aDados[I][14])
		AAdd(aAux, aDados[I][15])
		AAdd(aAux, aDados[I][16])
		AAdd(aAux, aDados[I][17])
		AAdd(aAux, aDados[I][18])
		AAdd(aAux, aDados[I][19])

		oFWExcel:AddRow(cWorkSheet, cTable,	aAux)

	NEXT I


	oFWExcel:Activate()
	oFWExcel:GetXMLFile(cFile)
	oFWExcel:DeActivate()

	If CpyS2T(cDir + cFile, cDirTmp, .T.)

		fErase(cDir + cFile)

		If ApOleClient('MsExcel')

			oMSExcel := MsExcel():New()
			oMSExcel:WorkBooks:Close()
			oMSExcel:WorkBooks:Open(cDirTmp + cFile)
			oMSExcel:SetVisible(.T.)
			oMSExcel:Destroy()

		EndIf

	Else
		MsgInfo("Arquivo n„o copiado para a pasta tempor·ria do usu·rio.")
	Endif

	RestArea(aArea)

Return() 


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
	aAdd(aTRegs,{"Data Inicial?","D",8,0,0,"G","","","","","","","","Data inicial do perÌodo para impressao."})
	aAdd(aTRegs,{"Data Final?","D",8,0,0,"G","","","","","","","","Data final do perÌodo para impressao."})
	aAdd(aTRegs,{"Pasta Local?","C",30,0,0,"G","","","","","","","","Pasta para gravacao dos arquivos"})
	aAdd(aTRegs,{"Nome Arquivo?","C",30,0,0,"G","","","","","","","","Nome base para gravacao dos arquivos"})
	aAdd(aTRegs,{"Tipo Arquivo?","N",1,0,0,"C","","Arquivo TXT","EXCEL","","","","","Arquivo TXT ou Excel para conferencia"})

	//Criar aRegs na ordem do vetor Temporario
	aRegs := {}
	For I := 1 To Len(aTRegs)
		aAdd(aRegs,{cPerg,StrZero(I,2),aTRegs[I][1],aTRegs[I][1],aTRegs[I][1]	,"mv_ch"+Alltrim(Str(I)),aTRegs[I][2],aTRegs[I][3],aTRegs[I][4],aTRegs[I][5],aTRegs[I][6],aTRegs[I][7],;
		"mv_par"+StrZero(I,2),aTRegs[I][8],"","","","",aTRegs[I][9],"","","","",aTRegs[I][10],"","","","",aTRegs[I][11],"","","","",aTRegs[I][12],"","","",aTRegs[I][13],""})
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
			//ATUALIZA SX1
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

	//Renumerar perguntas
	_ncont := 1
	SX1->(dbSeek(cPerg))
	While .Not. SX1->(Eof()) .And. X1_GRUPO == cPerg
		RecLock("SX1",.F.)
		SX1->X1_ORDEM := StrZero(_ncont,2)
		SX1->(MsUnlock())
		SX1->(DbSkip())
		_ncont++
	EndDo

	//Deletar Perguntas sobrando - apagadas do vetor
	While SX1->(dbSeek(cPerg+StrZero(i,2)))
		RecLock("SX1",.F.)
		SX1->(DbDelete())
		SX1->(MsUnlock())
		i++
	EndDo

Return
