#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ACE_COMI       ºAutor  ³ MADALENO           º Data ³  19/03/07   º±±
±±º          ³                ºAlter. ³ Ranisses A. Corona º Data ³  02/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ ACERTA COMISSAO NO CADASTRO DE COMISAO CONFORME OS PARAMETROS    º±±
±±º          ³ Implementatacao da Tabela Acerto Supervisores                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ACE_COMI()

//Obriga a executar a rotina somente na Biancogres
If Alltrim(cempant) <> "01"
	MsgAlert("Esta rotina deve ser executada somente na Biancogres!")
	Return
EndIf
  
//Verifica se a rotina ja foi executada no mes corrente
If Subst(Dtos(dDataBase),1,6) <= Subst(Dtos(GetMv("MV_YACECOM")),1,6)
	MsgAlert("Esta rotina ja foi realizada neste mes!")
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela com descritivo do programa                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Acerta Comissao Supervisor"
@ 8,10 TO 84,222

@ 16,12 SAY "Este programa tem por finalidade: "
@ 24,12 SAY "Corrigir o % de comissao do Supervisor, conforme contrato estabelecido."

@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("ACE_CO", .T.)
@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)

ACTIVATE DIALOG oDlg5 CENTERED

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OkProc    ³ Autor ³Gustav Koblinger Junior³ Data ³ 15.02.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Confirma o Processamento                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OkProc()
Processa( {|| RunProc() } )
Close(oDlg5)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RunProc   ³ Autor ³ Ary Medeiros          ³ Data ³ 15.02.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Executa o Processamento                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RunProc()
Local SQL 		:= ""
Local Enter 	:= chr(13) + Chr(10)
Local nVALOR 	:= 0
Local Percent 	:= 0
Local PercAnt 	:= 0
Local Val_Comi 	:= 0
Local lFlag 	:= .T.

//Busca Supervisores Cadastrados
SQL := "SELECT ZD_COD			" + Enter
SQL += "FROM SZD010				" + Enter
SQL += "WHERE D_E_L_E_T_ = ''	" + Enter
SQL += "GROUP BY ZD_COD 		" + Enter
If chkfile("_REP")
	dbSelectArea("_REP")
	dbCloseArea()
EndIf
TCQUERY SQL ALIAS "_REP" NEW

//Verifica todos os Supervisores
Do While ! _REP->(EOF())
	
	//Verifica regra de Desconto do Supervisor esta ativo
	SQL := "SELECT  *						" + Enter
	SQL += "FROM "+RETSQLNAME("SZD")+" SZD 	" + Enter
	SQL += "WHERE 	SZD.ZD_COD		=	'"+_REP->ZD_COD+"'		AND " + Enter
	SQL += "		SZD.ZD_DATAINI	<=	'"+DTOS(dDatabase)+"'	AND	" + Enter
	SQL += "		SZD.ZD_DATAFIM	>=	'"+DTOS(dDatabase)+"' AND	" + Enter
	SQL += "		SZD.D_E_L_E_T_	=	''							" + Enter
	If chkfile("_TAB")
		dbSelectArea("_TAB")
		dbCloseArea()
	EndIf
	TCQUERY SQL ALIAS "_TAB" NEW
	
	If _TAB->(EOF())
		MsgBox("Não existe regra cadastrada para o Supervisor "+ALLTRIM(_REP->ZD_COD)+". Favor verificar!")
		DbSelectArea("_REP") 
		DbSkip()		
		Loop
	EndIf
	
	//Monta base para acerto do Supervisor
	If Alltrim(_TAB->ZD_EMP) == "B"  
		SQL := "SELECT '01' AS EMP, SE3.R_E_C_N_O_ AS RECNO_, SE3.E3_BASE 	" + Enter
		SQL += "FROM SE3010 SE3 											" + Enter
		SQL += "WHERE 	SE3.E3_EMISSAO 	BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND " + Enter
		SQL += "		SE3.E3_VEND		= '"+_REP->ZD_COD+"'	AND			" + Enter
		SQL += "		SE3.E3_PREFIXO	IN ('S1','1')			AND			" + Enter
		SQL += "		SE3.E3_DATA 	= ''					AND			" + Enter
		SQL += "		SE3.D_E_L_E_T_	= '' 								" + Enter
		SQL += "ORDER BY E3_EMISSAO 										" + Enter
		If chkfile("_COMI")
			dbSelectArea("_COMI")
			dbCloseArea()
		EndIf
		TCQUERY SQL ALIAS "_COMI" NEW
	ElseIf Alltrim(_TAB->ZD_EMP) == "I"
		SQL := "SELECT '05' AS EMP, SE3.R_E_C_N_O_ AS RECNO_, SE3.E3_BASE 	" + Enter
		SQL += "FROM SE3050 SE3 											" + Enter
		SQL += "WHERE 	SE3.E3_EMISSAO 	BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND " + Enter
		SQL += "		SE3.E3_VEND		= '"+_REP->ZD_COD+"'	AND			" + Enter
		SQL += "		SE3.E3_DATA 	= ''					AND			" + Enter
		SQL += "		SE3.D_E_L_E_T_	= '' 								" + Enter
		SQL += "UNION ALL													" + Enter
		SQL += "SELECT '01' AS EMP, SE3.R_E_C_N_O_ AS RECNO_, SE3.E3_BASE 	" + Enter
		SQL += "FROM SE3010 SE3 											" + Enter
		SQL += "WHERE 	SE3.E3_EMISSAO 	BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND " + Enter
		SQL += "		SE3.E3_VEND		= '"+_REP->ZD_COD+"'	AND			" + Enter
		SQL += "		SE3.E3_PREFIXO	IN ('S2','2')			AND			" + Enter
		SQL += "		SE3.E3_DATA 	= ''					AND			" + Enter
		SQL += "		SE3.D_E_L_E_T_	= '' 								" + Enter
		//SQL += "ORDER BY E3_EMISSAO 										" + Enter
		If chkfile("_COMI")
			dbSelectArea("_COMI")
			dbCloseArea()
		EndIf
		TCQUERY SQL ALIAS "_COMI" NEW
	EndIf
	
	//Zera Variaveis
	nVALOR		:= 0
	Percent		:= 0
	PercAnt		:= 0
	Val_Comi	:= 0	
	lFlag			:= .T.
	DIF1      := 0
	DIF2			:= 0
			
	Do While !_COMI->(EOF())
		
		nVALOR += _COMI->E3_BASE
		
		Do While !_TAB->(EOF())
			IF _TAB->ZD_VLRMIN <= nVALOR  .And. _TAB->ZD_VLRMAX >= nVALOR
				Percent	:= _TAB->ZD_COMIS
				Exit
			Else
				PercAnt := _TAB->ZD_COMIS
				lFlag 	:= .F.
				_TAB->(DBSKIP())
			EndIf
		End Do
		
		If lFlag
			Val_Comi := ((_COMI->E3_BASE/100)*Percent)
		Else
			DIF1 		:=  nVALOR - _TAB->ZD_VLRMIN
			DIF2 		:= _COMI->E3_BASE - DIF1
			
			Percent 	:= PercAnt
			Val_Comi 	:= ( ( DIF2 / 100 ) * Percent )
			
			Percent 	:=  _TAB->ZD_COMIS
			Val_Comi 	+= ( ( DIF1 / 100 ) * Percent )
			Percent 	:= (( Val_Comi / _COMI->E3_BASE ) *100 )
			lFlag		:= .T.
		EndIf
		
		Percent  := Round(Percent,2)
		Val_Comi := Round(Val_Comi,4)
		
		If _COMI->EMP == "01"
			SQL := "UPDATE SE3010 SET E3_PORC = '"+ALLTRIM(STR(Percent))+"', E3_COMIS = '"+ALLTRIM(STR(Val_Comi))+"' " + Enter
			SQL += "WHERE R_E_C_N_O_ = '"+Alltrim(Str(_COMI->RECNO_))+"' " + Enter
			TcSQLExec(SQL)
		ElseIf _COMI->EMP == "05"
			SQL := "UPDATE SE3050 SET E3_PORC = '"+ALLTRIM(STR(Percent))+"', E3_COMIS = '"+ALLTRIM(STR(Val_Comi))+"' " + Enter
			SQL += "WHERE R_E_C_N_O_ = '"+Alltrim(Str(_COMI->RECNO_))+"' " + Enter
			TcSQLExec(SQL)
		EndIf
		
		_COMI->(DBSKIP())
		
	End Do
	
	_REP->(DBSKIP())
	
End Do

//Atualiza o parametro que valida a Data
PutMV("MV_YACECOM",dDataBase)

MsgAlert("Correção realizada com sucesso!")

Return()