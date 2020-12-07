#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BIA814   บ Autor ณ Ranisses A. Corona บ Data ณ  08/06/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relacao Comissao Supervisores							  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Financeiro                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BIA814()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private Enter := CHR(13)+CHR(10)
Private cSql  := ""
lEnd       := .F.
cString    := "SE3"
cDesc1     := "Este programa tem como objetivo imprimir relatorio "
cDesc2     := "da Comissao dos Supervisores.                      "
cDesc3     := ""
cTamanho   := "P"
limite     := 80		
aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
cNomeprog  := "BIA814"
cPerg      := "BIA814"
aLinha     := {}
nLastKey   := 0
cTitulo	   := "Rel. Comissao Supervisores"
Cabec1     := ""
Cabec2     := ""
nBegin     := 0
cDescri    := ""
cCancel    := "***** CANCELADO PELO OPERADOR *****"
m_pag      := 1                                    
wnrel      := "BIA814"
lprim      := .t.
li         := 80
nTipo      := 0
wFlag      := .t.        

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT.								     ณ
//ณ Verifica Posicao do Formulario na Impressora.				             ณ
//ณ Solicita os parametros para a emissao do relatorio			             |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

pergunte(cPerg,.F.)

wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)

//Cancela a impressao
If nLastKey == 27
	Return
Endif

If cempant <> "01"
	MsgAlert("Este relat๓rio somente podera ser utilizado na empresa Biancogres!.")
	Return
EndIf

//Parametros
Super	:= MV_PAR01			//Supervisor
Datade	:= Dtos(MV_PAR02)	//Emissao De
DataAte	:= Dtos(MV_PAR03)	//Emissao Ate
nValor1	:= MV_PAR04			//Valor Incesa
nValor2	:= MV_PAR05			//Valor Livre

nVALOR	:= 0
lFlag	:= .T.


//Verifica se o relatorio ja processado no mes
cSQL := "SELECT SUM(E3_YVLEMP1) VL1, SUM(E3_YVLEMP2) VL2			" + Enter
cSQL += "FROM SE3010 SE3 											" + Enter
cSQL += "WHERE 	SE3.E3_EMISSAO 	BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' AND	" + Enter
cSQL += "		SE3.E3_VEND		= '"+Super+"'			AND			" + Enter
cSQL += "		SE3.E3_PREFIXO	= 'S1'					AND			" + Enter
cSQL += "		SE3.D_E_L_E_T_	= '' 								" + Enter
If chkfile("_COM")
	dbSelectArea("_COM")
	dbCloseArea()
EndIf
TCQUERY cSQL ALIAS "_COM" NEW


//Executa atualizacao
If _COM->VL1 == 0 .And. _COM->VL2 == 0

	cSQL := "SELECT '01' AS EMP, SE3.R_E_C_N_O_ AS RECNO_, SE3.E3_BASE, SE3.E3_COMIS			" + Enter
	cSQL += "FROM SE3010 SE3 											" + Enter
	cSQL += "WHERE 	SE3.E3_EMISSAO 	BETWEEN '"+DTOS(MV_PAR02)+"' AND '"+DTOS(MV_PAR03)+"' AND	" + Enter
	cSQL += "		SE3.E3_VEND		= '"+Super+"'			AND			" + Enter
	cSQL += "		SE3.E3_PREFIXO	= 'S1'					AND			" + Enter
	cSQL += "		SE3.D_E_L_E_T_	= '' 								" + Enter
	cSQL += "ORDER BY SE3.E3_EMISSAO									" + Enter
	If chkfile("_COMI")
		dbSelectArea("_COMI")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_COMI" NEW
	
	
	Do While !_COMI->(EOF())
		If 	lFlag
	
			nVALOR += _COMI->E3_COMIS
	
			If nVALOR >= 0 .And. nVALOR <= nValor1
				SQL := "UPDATE SE3010 SET E3_YVLEMP1 = E3_COMIS					" + Enter
				SQL += "WHERE R_E_C_N_O_ = '"+Alltrim(Str(_COMI->RECNO_))+"' 	" + Enter
				TcSQLExec(SQL)
		    Else
				DIF1	:=  nVALOR			- nValor1
				DIF2	:= _COMI->E3_COMIS	- DIF1
		
				SQL := "UPDATE SE3010 SET E3_YVLEMP1 = '"+Str(DIF2)+"'			" + Enter
				SQL += "WHERE R_E_C_N_O_ = '"+Alltrim(Str(_COMI->RECNO_))+"' 	" + Enter
				TcSQLExec(SQL)
		        
				nVALOR	:= 0
				lFlag 	:= .F.
		    EndIf
		Else
	
			nVALOR += _COMI->E3_COMIS
	
			If nVALOR >= 0 .And. nVALOR <= nValor2
				SQL := "UPDATE SE3010 SET E3_YVLEMP2 = E3_COMIS					" + Enter
				SQL += "WHERE R_E_C_N_O_ = '"+Alltrim(Str(_COMI->RECNO_))+"' 	" + Enter
				TcSQLExec(SQL)
		    Else
				DIF1	:=  nVALOR			- nValor2
				DIF2	:= _COMI->E3_COMIS	- DIF1
		
				SQL := "UPDATE SE3010 SET E3_YVLEMP2 = '"+Str(DIF2)+"'			" + Enter
				SQL += "WHERE R_E_C_N_O_ = '"+Alltrim(Str(_COMI->RECNO_))+"' 	" + Enter
				TcSQLExec(SQL)
		        
				nVALOR	:= 0
				Exit
		    EndIf
		EndIf
	
		_COMI->(DBSKIP())

	End Do

EndIf




//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5]==1
	//Parametros Crystal Em Disco
	Private x:="1;0;1;Comissใo Supervisores"
Else
	//Direto Impressora
	Private x:="3;0;1;Comissใo Supervisores"
Endif

//Chama o Relatorio em Crystal
callcrys("BIA814",MV_PAR01+";"+DTOC(MV_PAR02)+";"+DTOC(MV_PAR03),x)

Return