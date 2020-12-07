#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'COLORS.CH'

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MOV797B  ºAutor  ³ Alberto            º Data ³  25/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Browser Principal para Rotina de Pesagem de Veiculos       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP 811                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function MOV797B()

cPerg := "MO797B"
fTamX1 := If (Alltrim(oApp:cVersion) == "MP8.11", 6, 10)

ValidPerg()

If !Pergunte(cPerg,.T.)
	Return
Else
	
	cFiltro := ""
	
	If MV_PAR01 == 1
		cFiltro := " Z11_PESOIN >= 0 .AND. Z11_PESOSA == 0 .AND. Z11_SITUAC <> 'C' "
	EndIf
	
	If MV_PAR02 == 2
		cFiltro += If (!Empty(cFiltro), " .AND. ", "") + " Z11_MOTPAT = 'S' .AND. Z11_SITUAC <> 'C' "		
	ElseIf MV_PAR02 == 3
		cFiltro += If (!Empty(cFiltro), " .AND. ", "") + " Z11_MOTPAT = 'N' .AND. Z11_SITUAC <> 'C' "	
	EndIf
		
	If MV_PAR03 == 2
	
		cFiltro += If (!Empty(cFiltro), " .AND. ", "") + " Z11_STATUS = 'S' .AND. Z11_SITUAC <> 'C' "		
	ElseIf MV_PAR03 == 3
		cFiltro += If (!Empty(cFiltro), " .AND. ", "") + " Z11_STATUS <> 'S' .AND. Z11_SITUAC <> 'C' "	
	EndIf		
	
		
	If !Empty(cFiltro)	
		Z11->(DbSetFilter({|| &cFiltro},cFiltro))
		Z11->(DbGoTop())
	EndIf
	
EndIf

dbSelectArea("Z11")

// Tiago Rossini Coradini - 20/06/2016 - OS: 2420-16 - Angelo Alencar - Alteração no indice padrão da rotina
If cEmpAnt == "05"
	DbSetOrder(4)
Else
	DbSetOrder(1)
EndIf

DbGoTop()

aCores := {{"Z11_PESOIN = 0 .AND. Z11_PESOSA = 0" , "BR_BRANCO"},;
					{"Z11_PESOIN = 0.01 .AND. Z11_PESOSA = 0" , "BR_AZUL"},;
					{"Z11_PESOIN > 0.01	.AND. Z11_PESOSA = 0" , "BR_VERDE"},;
					{"Z11_PESOIN <> 0 .AND. Z11_PESOSA <> 0" , "BR_VERMELHO"}}
					
n := 1
cCadastro := " ....: Pesagem de Veículos :.... "

aRotina   := {  {"Pesquisar", 'AxPesqui', 0, 1},;
{                "Visualizar", 'ExecBlock("MOV797", .F., .F., "V")', 0, 2},;
{                "Incluir", 'ExecBlock("MOV797", .F., .F., "IN")', 0, 3},;
{                "Liberar", 'ExecBlock("LIB_PESA", .F., .F., "IN")', 0, 4},;
{                "Carregamento", 'ExecBlock("MOV797", .F., .F., "E")' , 0, 5},;
{                "Materia Prima", 'ExecBlock("MOV797", .F., .F., "M")', 0, 6},;
{                "Saida", 'ExecBlock("MOV797", .F., .F., "S")', 0, 7},;
{                "Imprimir", 'ExecBlock("GERA_TICK", .F., .F., "I")', 0, 8},;
{                "Demonst.", 'ExecBlock("MOV583", .F., .F., "I")', 0, 9},;
{                "Legenda", 'Execblock("MOV797C", .F., .F., "L")', 0, 10},;
{                "Nota Fiscal", 'Execblock("INF_NF", .F., .F., "L")', 0, 11},;
{                "ALTERA PLACA", 'Execblock("ALT_PESAGEM", .F., .F., "L")', 0, 12},;
{                "TRANSFERENCIA", 'Execblock("TRAN_PESAGEM",.F.,.F.,"L")', 0, 13},;
{                "Alterar", 'ExecBlock("MOV797",.F.,.F.,"AL")', 0, 15},;
{                "ALTERA DADOS", 'U_M797ALTD()', 0, 16},;
{                "Encerra Manual", 'U_M797ENCM()', 0, 17},;
{                "Encerra Automatico", 'U_M797ENCA()', 0, 18},;
{                "Rel. Acompanhamento", 'ExecBlock("BIA230", .F., .F., "I")', 0, 19},;
{                "Motor. no Pátio", 'ExecBlock("AltMotPat", .F., .F., "L")', 0, 20},;
{                "Importação Nota Fiscal", 'U_PNFM0001()', 0, 21}}


//{                "Int. Guardian", 'U_BIA797A()', 0, 14},;


mBrowse(6,1,22,75, "Z11", , , , , ,aCores)

Z11->(DbClearFilter())

Return


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ LIB_PESA                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ FUNCAO PARA A LIBERACAO DA PESAGEM                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function LIB_PESA()


If MsgYesNo("Liberar ticket para pesagem?")

	IF Z11->Z11_PESOIN = 0
		dbSelectArea("Z11")
		dbSetOrder(1)
		If dbSeek(xFilial("Z11")+Z11->Z11_PESAGE)
			Reclock("Z11",.F.)
			Z11->Z11_PESOIN := 0.01
			MsUnLock()
		EndIf
	ELSE
		Alert("PESAGEM JÁ LIBERADO ANTERIORMENTE...")
		RETURN
	ENDIF

EndIf

Return

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Dialeg1                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao para apresenta a Cor na tela                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
User Function MOV797C()

Brwlegenda(cCadastro, "Legenda",{{"BR_BRANCO", "PESAGEM AGENDADA"},;
																{"BR_AZUL", "PESAGEM LIBERADA"},;
																{"BR_VERDE", "PESAGEM SEM SAIDA DO VEICULO"},;
																{"BR_VERMELHO", "PESAGEM CONCLUÍDA"}})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.05.06 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Filtrar Apenas Aberto ?","","","mv_ch01","N",1,0,0,"C","","mv_par01","Sim","","","","","Não","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"02","Motorista no Patio ?","","","mv_ch02","N",1,0,0,"C","","mv_par02","Todas","","","","","Sim","","","","","Não","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Integrado ao ECOSIS ?","","","mv_ch03","N",1,0,0,"C","","mv_par03","Todas","","","","","Sim","","","","","Não","","","","","","","","","","","","","",""})

For i := 1 to Len(aRegs)
	if !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.t.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return

//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±ALTERA DADOS DO Z11 - GARDENIA
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
User Function M797ALTD()
Local ldebug	:= .F.
Local _cUserAc 	:= AllTrim(GetMV("MV_YBALALT"))
Local aCampCar 	:= {'Z11_MOTORI', 'Z11_CODTRA', 'Z11_LJTRAN', 'Z11_OBSER', 'Z11_CLVEIC','Z11_PESMAX', 'Z11_NOMCLI', 'Z11_MOTPAT','Z11_HORACH'  }
Local aCampDes 	:= {'Z11_MOTORI', 'Z11_CODTRA', 'Z11_LJTRAN', 'Z11_OBSER', 'Z11_CLVEIC','Z11_PESMAX', 'Z11_NOMCLI', 'Z11_MOTPAT','Z11_HORACH','Z11_HORAIN','Z11_HORASA','Z11_DATAIN', 'Z11_DATASA', 'Z11_PESOIN', 'Z11_PESOSA', 'Z11_PESLIQ', 'Z11_PCAVAL', 'Z11_PCARRE', 'Z11_GUARDI' }

If !(AllTrim(cUserName) $ _cUserAc) .And. !ldebug
	MsgAlert("USUÁRIO SEM ACESSO A ESTA OPERAÇÃO","ALTERA DADOS BALANÇA")
	Return
EndIf

If Z11->Z11_MERCAD == 1
	AXALTERA("Z11",Z11->(RecNo()),4,,aCampDes)
Else
	AXALTERA("Z11",Z11->(RecNo()),4,,aCampCar)
EndIf

Return
//---------------------------------------------------------------------------------------


 // Tiago Rossini Coradini - OS: 3813-15 - Leiliane Stefania Bona - Encerramento de Ticket
User Function M797ENCM()
Local _cUserAc 	:= AllTrim(GetMV("MV_YBALALT"))
Local cAliasTmp	:= GetNextAlias()
Local cCOBSS  := Space(200)
	
	SetPrvt("oDlgObser","oGetObser")

	If !(AllTrim(cUserName) $ _cUserAc)
		MsgAlert("USUÁRIO SEM ACESSO A ESTA OPERAÇÃO (PARÂMETRO: MV_YBALALT)","ENCERRAR TICKET")
		Return
	EndIf

	If Z11->Z11_PESOSA > 0
		MsgBox("Não é possível encerrar o Ticket pois a pesagem já foi finalizada!", "ENCERRAR TICKET","ERRO")
		Return
	EndIf

	BeginSql Alias cAliasTmp
		SELECT ZZV_CARGA FROM %Table:ZZV% WHERE ZZV_TICKET = %Exp:Z11->Z11_PESAGE% AND %NOTDEL% 
	EndSql

	If !(cAliasTmp)->(Eof())
		
		If !MsgYesNo("Atenção, o Ticket está associado a carga "+ AllTrim((cAliasTmp)->ZZV_CARGA)+"." + Chr(13) + "Deseja realmente ecerrar o Ticket?")
			Return()
		EndIf
		
	EndIf

	If MsgBox ("Confirma o encerramento da Pesagem do Ticket "+AllTrim(Z11->Z11_PESAGE)+", Placa "+AllTrim(Z11->Z11_PCAVAL)+" ?","Atenção","YesNo")
	
		oDlgObser	:= MSDialog():New( 103,235,233,614,"OBSERVAÇÃO",,,.F.,,,,,,.T.,,,.T. )
		oGetObser   := TGet():New( 004,004,{|u| If(PCount()>0,cCOBSS:=u,cCOBSS)},oDlgObser,176,034,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cCOBSS",,)
		oBtnOk      := TButton():New( 044,144,"CONFIRMA",oDlgObser,{|| oDlgObser:End() },037,012,,,,.T.,,"",,,,.F. )
		
		oDlgObser:Activate(,,,.T.)
		
		If Empty(AllTrim(cCOBSS))
			ALERT("Favor informar a Obrservação!")
			Return()
		EndIf
	    
    RecLock("Z11", .F.)
			
			Z11->Z11_PESOIN := 0.01
			Z11->Z11_PESOSA := 0.01
			Z11->Z11_OBSER := AllTrim(cCOBSS)
									
		MsUnlock()
		    
    Envioemail(AllTrim(cCOBSS))
    
    MsgBox("Ticket encerrado com sucesso!", "Informcao", "INFO")
    
	EndIf
	
Return()


User Function M797ENCA()
Local cUserAc := AllTrim(GetMV("MV_YBALALT"))
Local nDia := GetMv("MV_YDENCAU",,5)
Local cSQL := ""

	If AllTrim(cUserName) $ cUserAc
		
		If MsgYesNo("Atenção, todos os Tickets em aberto até o dia: " + cValToChar(DaySub(dDataBase, nDia)) + " serão finalizados automaticamente." + Chr(13) + Chr(13) +;
								"Deseja realmente ecerrar os Tickets?")

			cSQL := " UPDATE " + RetSQLName("Z11")
			cSQL += " SET Z11_PESOIN = 0.01, Z11_PESOSA = 0.01, Z11_OBSER = " + ValToSQL("ENCERRADO AUTOMATICO - USUARIO: " + AllTrim(cUserName))
			cSQL += " WHERE Z11_FILIAL = " + ValToSQL(xFilial("Z11"))
			cSQL += " AND Z11_PESOIN >= 0 "
			cSQL += " AND Z11_PESOSA = 0 "
			cSQL += " AND Z11_DATAIN < " + ValToSQL(DaySub(dDataBase, nDia))
			cSQL += " AND D_E_L_E_T_ = '' "
		
			U_BIAMsgRun("Encerrando Tickets...", "Aguarde!", {|| TcSQLExec(cSQL), TcRefresh(RetSQLName("Z11")) })
																
		Else
			
			Return()
			
		EndIf	
		
	Else
	
		MsgAlert("Usuário sem acesso a esta operação(Parâmetro: MV_YBALALT)", "Encerrar ticket automaticamente")
		
		Return()
		
	EndIf

Return()


//---------------------------------------------------------------------------------------
Static Function Envioemail(cObs)
Local cMensag 	:= ""
Local cRecebe 	:= U_EmailWF('M797ENCM', cEmpAnt)
Local cArqAnexo := ""
Local cAssunto 	:= "Encerramento Manual de Ticket de Balança"
Local nHora 	:= Val(SubStr(Time(),1,2))
Local Enter	:= CHR(13)+CHR(10)

	If nHora >= 0 .And. nHora < 12
		cMensag := "Prezado(a), bom dia."+Enter+Enter
	ElseIf nHora >= 12 .And. nHora < 18
		cMensag := "Prezado(a), boa tarde."+Enter+Enter
	Else
		cMensag := "Prezado(a), boa noite."+Enter+Enter
	EndIf
	cMensag += "O Ticket: "+AllTrim(Z11->Z11_PESAGE)+" com a Placa: "+AllTrim(Z11->Z11_PCAVAL)+" da Empresa: "+ Capital(FWFilialName(cEmpAnt, cFilAnt, 2)) +" foi encerrado no Protheus."+Enter
	cMensag += "Observação: "+cObs+Enter
	cMensag += 'Este e-mail é automático. Não Responda esta mensagem.'
	 
	U_BIAEnvMail(,cRecebe,cAssunto,cMensag,'',cArqAnexo) 

Return()