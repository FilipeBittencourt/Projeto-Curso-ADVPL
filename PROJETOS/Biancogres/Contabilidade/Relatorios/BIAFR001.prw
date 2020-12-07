#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "INKEY.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"

#DEFINE LF CHR(10)

/*
|-----------------------------------------------------------|
| Função: | BIAFR001																			  |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 01/10/14																			  |
|-----------------------------------------------------------|
| Desc.:	| Rotina para confrontar o relatorio de balancete |
| 				| analitico da contabilidade (CTBR040) com  os    |
| 				| relatorios de posição de titulos a receber      |
| 				| FINR130 e posição de titulos a pagar FINR150    |
|-----------------------------------------------------------|
| OS:			|	1666-14 - Usuário: Jean Vitor Morais   		 			|
|-----------------------------------------------------------|
*/

User Function BIAFR001()
Local _nOpcao := 0
Private _cPathPrintUser := __RELDIR
Private _Daduser        := _Grupo:= {}
Private _Nomeuser       := Substr(cUsuario,7,15)
Private _cPathRel       := ""
Private _cArqTemp1      := ""
Private _cArqTemp2      := ""
Private _cArqTemp3      := ""
Private _cArqTemp4      := ""
Private lAvlSalEmp := fAvlSalEmp()
Private _cArqRelCont    := _cPathPrintUser+"CTBR040.CSV"
Private _cArqRelFin     := ""
Private _oDlg           := Nil // Dialog principal

// Utilizadas na impressao
Private _cNomeRel    := "BIAFR001"

// Titulo do relatorio
Private _cTitulo     := "Conciliação ContabilxFinanceira"
Private _cCodA       := "A00000"
Private _cCodB       := "B00000"
Private _cCodC       := "C00000"

// Descricao do relatorio
Private _cDesc1      := "Resultado da conciliação de clientes/fornecedor da contábilidade com "
Private _cDesc2      := "o financeiro atravez dos relatórios CTBR040 e FINR130/FINR150.       "

Private _cDesc3      := "                                                                     "
Private _lPodeComp   := .T.
Private _lTemDic     := .F.
Private _lTemFilt    := .F.
Private _lGravParam  := .F.
Private _cAlias	     := "SM0"
Private _aOrdem	     := {}
Private _aTexto      := {}
Private _nSaldo      := _nSaldo1 := _nSaldo2 := 0

// Nome da chave no SX1
Private cPerg        := "BIAFR001"

Private _nCrcControl := 0
Private _nCbCont	   := 0
Private _cArqTemp    := ""
Private _cTamanho    := "G"
Private _cCbTxt	     := SPACE(10)
Private _cCabec1     := ""
Private _cCabec2     := ""

// Utilizadas na subrotiona de pre-impressao
Public nLastKey := 0
Public aLinha   := {}
Public aReturn  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
Public m_pag    := 1
Public lEnd     := .F.
Private aRelCon := {}
Private aRelFin := {}

// Cria o parametro no SX1 caso ele nao exista e o chama na tela
PutSx1(cPerg, "01", "Modo de conciliação          ?", "", "", "mv_ch1", "N", 01, 00, 01, "C",           "",    "", "", "", "MV_PAR01", "Clientes       ", "", "", "", "Fornecedor  ", "", "", "", "", "", "", "", "", "", "", "", {;
"Indica o modo de conciliação a ser      ",;
"empregado:                              ",;
"   Clientes - o sistema irá conciliar o ",;
"   relatório de Balancete de VerIficação",;
"   Anual em Reais com o Relatório de    ",;
"   Posição de Títulos a Receber.        ",;
"                                        ",;
"   Fornecedores - o sistema irá         ",;
"   conciliar o relatório de Balancete de",;
"   VerIficação Anual em Reais com o     ",;
"   Relatório de Posição de Títulos a    ",;
"   Pagar.                               "},{},{},"")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tela principal da rotina.                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 96,42 TO 565,555 DIALOG _oDlg TITLE "Conciliação de Clientes/Fornecedores (Contábil x Financeiro)"
@ 8,10 TO 224,247
@ 018,22 SAY "Esta rotina tem por finalidade confrontar o relatório de Balancete de Verificação Anual"
@ 030,22 SAY "em Reais (CTBR040), da Contabilidade Gerêncial, com o relatório de Posição dos Títulos "
@ 042,22 SAY "a Receber (FINR130) ou o relatório de Posição de Títulos a Pagar (FINR150), ambos do   "
@ 054,22 SAY "Financeiro e de acordo com os parâmetros informados pelo usuário. O processo analisará "
@ 066,22 SAY "o Saldo Atual dos clientes/fornecedores com o valor Vencidos+Vencer e emitirá ao final "
@ 078,22 SAY "da análise um novo relatório com as divergências encontradas.                          "
@ 090,22 SAY ""
@ 102,22 SAY "ATENÇÃO:                                                                               "
@ 114,22 SAY "1)  Para que a rotina seja executada corretamente os relatórios mencionados devem ser  "
@ 126,22 SAY "previamente gerados em disco, com o nome padrão dado pelo sistema e de acordo com as   "
@ 138,22 SAY "configurações informadas no documento em posse do setor contábil,                      "
@ 150,22 SAY "'CONCILIAÇÃO DE CLIENTES.doc' e 'CONCILIAÇÃO DE FORNECEDORES.doc'.                     "
@ 166,22 SAY "2)  Além disso, O USUÁRIO DEVERÁ INFORMAR OBRIGATÓRIAMENTE OS PARÂMETROS               "
@ 178,22 SAY "antes de prosseguir com a rotina de conciliação.                                       "
@ 205,140 BMPBUTTON TYPE 5 ACTION eval({|| If(pergunte(cPerg,.T.), _nOpcao := 1, MsgAlert("Informe ou Confirme os parâmetros antes de prosseguir.","Aviso!")) })
@ 205,175 BMPBUTTON TYPE 1 ACTION eval({|| If( _nOpcao == 1, fProcessa(), MsgAlert("Informe ou Confirme os parâmetros antes de prosseguir.","Impossível continuar!")) })
@ 205,210 BMPBUTTON TYPE 2 ACTION eval({|| _nOpcao := -1, Close(_oDlg) })
ACTIVATE DIALOG _oDlg CENTERED VALID _nOpcao <> 0
Return


// Processa a rotina principal
Static function fProcessa()
Local _cMsg := ""

// Definicao do layout do relatorio de divergencias em funcao dos parametros do usuario
If MV_PAR01 == 1 // Conciliacao de Clientes
	_cArqRelCont := _cPathPrintUser+"CONT.CSV"
	_cArqRelFin  := _cPathPrintUser+"FIN.CSV"	
	
	_cCabec1     := "CLIENTE -------------------   OCORRENCIA ----------------------------------   (a)----- SALDO   (b)----- SALDO   (c)----- JUROS   ---- DIFERENCA"
	_cCabec2     := "COD.   NOME                                                                         CONTABIL       FINANCEIRO       FINANCEIRO      (a - b + c)"
	_cTitulo     := alltrim(_cTitulo)+" (Clientes)"
	
elseIf MV_PAR01 == 2 // Conciliacao de Fornecedor
	_cArqRelCont := _cPathPrintUser+"CONT1.CSV"
	_cArqRelFin  := _cPathPrintUser+"FIN1.CSV"		
	_cCabec1     := "FORNECEDOR ----------------   OCORRENCIA ----------------------------------   (a)----- SALDO   (b)----- SALDO   ---- DIFERENCA"
	_cCabec2     := "COD.   NOME                                                                         CONTABIL       FINANCEIRO          (a - b)"
	_cTitulo     := alltrim(_cTitulo)+" (Fornecedores)"
EndIf

 _cTitulo += " - Divergências"

//VerIfica a existencia dos relatorios na pasta de spool de impressao do usuario
If file(_cArqRelCont) .AND. file(_cArqRelFin)
	
	//fecha a caixa de dialogo principal
	Close(_oDlg)
	
	//processamento principal.
	aRelCon := fReadFile(_cArqRelCont)
	aRelFin := fReadFile(_cArqRelFin)
	
	fCriaTemp()
	Processa({|| fAcumula()} , "Importando dados dos relatórios")
	Processa({|| fConcilia()}, "Conciliação")
	fImprimir()

Else
	
	If !file(_cArqRelCont)
		_cMsg := "Atenção! "
		_cMsg += LF
		_cMsg += LF+"Gere o relatório contábil em disco, seguindo as configurações"
		If MV_PAR01 == 1 // Conciliacao de Clientes
			_cMsg += " do documento 'CONCILIAÇÃO DE CLIENTES.DOC', antes de prosseguir"
		elseIf MV_PAR01 == 2 // Conciliacao de Fornecedor
			_cMsg += " do documento 'CONCILIAÇÃO DE FORNECEDOR.DOC', antes de prosseguir"
		EndIf
		_cMsg += " com está rotina."
		MsgAlert(_cMsg, "Relatório contábil CTBR040.CSV não encontrado na pasta "+_cPathPrintUser)
	else
	
		_cMsg := "Atenção! "
		_cMsg += LF
		_cMsg += LF+"Gere o relatório financeiro em disco, seguindo as configurações"
		If MV_PAR01 == 1 // Conciliacao de Clientes
			_cMsg += " do documento 'CONCILIAÇÃO DE CLIENTES.DOC', antes de prosseguir com está rotina."
			MsgAlert(_cMsg, "Relatório financeiro FINR130.##R não encontrado na pasta "+_cPathPrintUser)
		elseIf MV_PAR01 == 2 // Conciliacao de Fornecedor
			_cMsg += " do documento 'CONCILIAÇÃO DE FORNECEDOR.DOC', antes de prosseguir com está rotina."
			MsgAlert(_cMsg, "Relatório financeiro FINR150.##R não encontrado na pasta "+_cPathPrintUser)
		EndIf
		
	EndIf
	
EndIf
return


// Cria Tabela(s) Auxiliar(es) Temporaria(s).
Static FUNCTION fCriaTemp()
local _aCampos := {}

If Select("RELC") > 0
	RELC->(DbCloseArea())
EndIf

If Select("RELF") > 0
	RELF->(DbCloseArea())
EndIf

If Select("REL") > 0
	REL->(DbCloseArea())
EndIf
          
If Select("RELFIL") > 0
	RELFIL->(DbCloseArea())
EndIf


//gera o arquivo temporário para o relatorio da contabilidade
_aCampos := {}

AADD(_aCampos, {"COMPL1", "C", 13, 0})
AADD(_aCampos, {"INDICE", "C", 6, 0})
AADD(_aCampos, {"SALDO", "C", 20, 0})
AADD(_aCampos, {"TIPCC", "C", 2, 0})

_cArqTemp1 := CriaTrab(_aCampos, .T.)
DbUseArea(.T.,, _cArqTemp1, "RELC")
RELC->(DbCreateInd(_cArqTemp1+".001","INDICE", {||INDICE}) )

// Geracao do arquivo temporario para o relatorio financeiro de acordo com o parametro
If MV_PAR01 == 1 // Conciliacao de Clientes
	
	_aCampos := {}
	
	AADD(_aCampos, {"INDICE", "C", 6, 0})	
	AADD(_aCampos, {"JUROS", "C", 20, 0})
	AADD(_aCampos, {"SALDO", "C", 20, 0})
		
	_cArqTemp2 := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cArqTemp2, "RELF")
	RELF->(DbCreateInd(_cArqTemp2+".001","INDICE", {||INDICE}) )
	
elseIf MV_PAR01 == 2 // Conciliacao de Fornecedor
	
	_aCampos := {}
	
	AADD(_aCampos, {"INDICE", "C", 6, 0})
	AADD(_aCampos, {"COMPIND", "C", 2, 0})	
	AADD(_aCampos, {"JUROS", "C", 20, 0})
	AADD(_aCampos, {"SALDO", "C", 20, 0})
	
	_cArqTemp2 := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cArqTemp2, "RELF")
	RELF->(DbCreateInd(_cArqTemp2+".001","INDICE+COMPIND", {||INDICE+COMPIND}) )	
	
	_aCampos := {}
	 
	AADD(_aCampos, {"INDICE", "C", 6, 0})
	AADD(_aCampos, {"COMPIND", "C", 2, 0})	
	AADD(_aCampos, {"JUROS", "C", 20, 0})
	AADD(_aCampos, {"SALDO", "C", 20, 0})
	
	_cArqTemp4 := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cArqTemp4, "RELFIL")
	RELFIL->(DbCreateInd(_cArqTemp4+".001","INDICE+COMPIND", {||INDICE+COMPIND}) )
	
EndIf


// Gera o arquivo temporário de consiliacao de acordo com o parametro de usuario
_aCampos := {}

If MV_PAR01 == 1 // Conciliacao de Clientes
	
	AADD(_aCampos,{ "TIPO   ","C",006,0})
	AADD(_aCampos,{ "CLIFOR ","C",006,0})
	AADD(_aCampos,{ "NOME   ","C",020,0})
	AADD(_aCampos,{ "OBS    ","C",045,0})
	AADD(_aCampos,{ "SALDOC ","N",018,2})
	AADD(_aCampos,{ "SALDOF ","N",018,2})
	AADD(_aCampos,{ "JUROSF ","N",012,2})
	AADD(_aCampos,{ "DIF    ","N",012,2})
	
	_cArqTemp3 := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cArqTemp3, "REL")
	REL->(DbCreateInd(_cArqTemp3+".001","CLIFOR+TIPO", {||CLIFOR+TIPO}) )
	
elseIf MV_PAR01 == 2 // Conciliacao de Fornecedores
	
	AADD(_aCampos,{ "TIPO   ","C",006,0})
	AADD(_aCampos,{ "CLIFOR ","C",006,0})
	AADD(_aCampos,{ "NOME   ","C",020,0})
	AADD(_aCampos,{ "OBS    ","C",045,0})
	AADD(_aCampos,{ "SALDOC ","N",018,2})
	AADD(_aCampos,{ "SALDOF ","N",018,2})
	AADD(_aCampos,{ "JUROSF ","N",012,2})	
	AADD(_aCampos,{ "DIF    ","N",012,2})
	
	_cArqTemp3 := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cArqTemp3, "REL")
	REL->(DbCreateInd(_cArqTemp3+".001","TIPO", {||TIPO}) )
	
EndIf

return



// Alimenta a(s) tabela(s) temporaria(s).
Static function fAcumula()
Local nCount := 0
 
	ProcRegua(2)

	IncProc("Importando dados contábeis ...")
	DbSelectArea("RELC")
	
	For nCount := 1 To Len(aRelCon)
	
		RecLock("RELC", .T.)
			
			RELC->COMPL1 := aRelCon[nCount, 1]
			RELC->INDICE := SubStr(aRelCon[nCount, 1], 14, 6)
			RELC->SALDO := SubStr(aRelCon[nCount, 7], 1, 20)
			RELC->TIPCC := SubStr(aRelCon[nCount, 7], 21, 2)
		
		RELC->(MsUnLock())
	
	Next
	
	IncProc("Importando dados financeiros ...")
	DbSelectArea("RELF")

	For nCount := 1 To Len(aRelFin)
	
		RecLock("RELF", .T.)
			
			If MV_PAR01 == 1
			
				RELF->INDICE := SubStr(aRelFin[nCount, 1], 1, 6)
				RELF->JUROS := aRelFin[nCount, 5]
				RELF->SALDO := aRelFin[nCount, 6]
				
			ElseIf MV_PAR01 == 2
						
				RELF->INDICE := SubStr(aRelFin[nCount, 1], 1, 6)
				RELF->COMPIND := SubStr(aRelFin[nCount, 1], 8, 2)
				RELF->JUROS := aRelFin[nCount, 12]
				RELF->SALDO := aRelFin[nCount, 14]

				If lAvlSalEmp
					
					RecLock("RELFIL", .T.)
					
						RELFIL->INDICE := SubStr(aRelFin[nCount, 1], 1, 6)
						RELFIL->COMPIND := SubStr(aRelFin[nCount, 1], 8, 2)
						RELFIL->JUROS := aRelFin[nCount, 12]
						RELFIL->SALDO := aRelFin[nCount, 14]
						
					RELFIL->(MsUnLock())
					
				EndIf
							
			EndIf
		
		RELF->(MsUnLock())
	
	Next

Return()



// Processa os dados acumulados na(s) tabela(s) temporaria(s).
Static function fConcilia()
Local _nSaldoContabil   := 0
local _nValJurosFin     := 0
Local _nSaldoFinanceiro := 0
Local _cIndiceContabil  := ""
Local _nAcrescimoFinanceiro := 0

// IdentIficacao do prefixo da conta cliente ou fornecedor de acordo com o parametro
Local _cPrefixContaClIfor := If(MV_PAR01==1, "1.1.2.01.", "2.1.1.02.")
Local _cAliasClIfor       := If(MV_PAR01==1, "SA1", "SA2")
Local _cCmpNomeRduzClIfor := If(MV_PAR01==1, "A1_NREDUZ", "A2_NREDUZ")
Local _cQuery             := ""
Local _cFiltro            := ""
Local _cChave             := ""
Local _cIndice            := ""
Local _cContaContabil     := ""
Local _cCondicao          := ".T."
Local _nTotFor            := 0

// Conciliando o relatorio contabil
DbSelectArea("RELC")
ProcRegua(RELC->(LastRec()))
RELC->(DbGoTop())
While !RELC->(eof())
	IncProc("Conciliando o relatório Contábil ...")
	
	If Substr(RELC->COMPL1, 1, 9) # _cPrefixContaClIfor
		RELC->(dbskip())
		loop
	EndIf
	
	_cIndiceContabil := strzero(val(RELC->INDICE),6)
	
	// IdentIficacao do prefixo da conta cliente ou fornecedor
	If ( _cIndiceContabil <> "000000" .And. substr(RELC->COMPL1,1,9) == _cPrefixContaClIfor )
		
		// Inicializa variaveis de comparacao
				
		_nSaldoContabil := Val(StrTran(StrTran(RELC->SALDO,".",""),",","."))
		
		// Tratamento para Tipo de conta
		// Conta devedora: sinal + 
		// Conta credora: sinal -
		If AllTrim(RELC->TIPCC) == "C"
			_nSaldoContabil := _nSaldoContabil * (-1)
		EndIf
		
		_nSaldoFinanceiro := 0
		_nValJurosFin     := 0
		
		If MV_PAR01 == 2 // Conciliacao de Fornecedores
			
			// Filtra todos os fornecedores que utilizam a conta atual
			_cQuery := "SELECT "
			_cQuery += " A2_COD,"
			_cQuery += " A2_LOJA,"
			_cQuery += " A2_NREDUZ"
			_cQuery += " FROM "+RetSqlName("SA2")+" SA2"
			_cQuery += " WHERE"
			_cQuery += " SA2.A2_FILIAL='"+xFilial("SA2")+"'"
			_cQuery += " AND SA2.A2_CONTA = '"+ Right(StrTran(RELC->COMPL1, ".", ""), 8) + RELC->INDICE +"'"
			_cQuery += " AND SA2.D_E_L_E_T_=''"
			_cQuery += " ORDER BY A2_COD,A2_LOJA"
			_cQuery := ChangeQuery(_cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"QRY",.T.,.T.)
			_nTotFor := 0

			While !QRY->(Eof())
														
				// Localiza o fornecedor no relatorio financeiro
				If RELF->(DbSeek(QRY->A2_COD+QRY->A2_LOJA))
										
					// Avalia se a empresa analisara saldo finaceiro por filial
					If lAvlSalEmp
					
						// Localiza o fornecedor
						If RELFIL->(DbSeek(QRY->A2_COD+QRY->A2_LOJA))
							
							While !RELFIL->(Eof()) .And. RELFIL->(INDICE+COMPIND) == QRY->(A2_COD+A2_LOJA)
								
								// Acumula no saldo financeiro os dados do fornecedor atual, para no final comparar com o saldo da conta.
								_nSaldoFinanceiro += val(StrTran(StrTran(RELFIL->SALDO,".",""),",","."))
								_nTotFor++
								
								RELFIL->(DbSkip())
							
							EndDo
							
						EndIf
						
					Else

						// Acumula no saldo financeiro os dados do fornecedor atual, para no final comparar com o saldo da conta.
						_nSaldoFinanceiro += val(StrTran(StrTran(RELF->SALDO,".",""),",","."))
						_nTotFor++
						
					EndIf
					
				EndIf
				
				QRY->(DBSkip())
				
			EndDo

			QRY->(DBCloseArea())
			
			// Caso o fornecedor nao exista no relatorio financeiro registra este fato no relatorio de divergencias
			If (_nTotFor == 0) .AND. (_nSaldoContabil <> 0)
				
				RecLock("REL",.T.)
				REL->TIPO    := _cCodB
				REL->NOME    := GetAdvFVal("SA2", "A2_NREDUZ", xFilial("SA2")+_cIndiceContabil, 1, "")
				REL->CLIFOR  := _cIndiceContabil									
				REL->OBS     := "Fornecedor inexistente no Relatorio Financeiro"
				REL->SALDOC  := _nSaldoContabil
				REL->SALDOF  := 0
				REL->DIF  := (REL->SALDOC - REL->SALDOF)
				REL->(MsUnlock())
				
				// incrementa o codigo de divergencia do tipo B (inexistencia)
				_cCodB := soma1(_cCodB,6)
			EndIf
			
		EndIf // ...Fornecedores
		
		
		// Se a conciliacao for a de Fornecedores executa a conferencia de saldo; se a conciliacao for a de Clientes localiza o cliente no relatorio financeiro atravez da conta-contabil.
		If (MV_PAR01 == 1 .AND. RELF->(DbSeek(_cIndiceContabil))) .OR. (MV_PAR01 == 2)
			
			If MV_PAR01 == 1 // Conciliacao de Clientes
				
				// Tratamento para empresas com varias filiais
				cFilCli := "INDICE == '" + _cIndiceContabil + "'"
					
				RELF->(DbSetFilter({|| &cFilCli }, cFilCli))
					
				While !RELF->(Eof())
					
					_nValJurosFin 		+= Val(StrTran(StrTran(RELF->JUROS,".",""),",","."))
					_nSaldoFinanceiro += Val(StrTran(StrTran(RELF->SALDO,".",""),",",".")) //- _nAcrescimoFinanceiro
						
					RELF->(DbSkip())
						
				EndDo()
					
				RELF->(DbClearFilter())
					
				RELF->(DbSeek(_cIndiceContabil))
					
			EndIf // ...Clientes
			
			// Registra no relatorio de divergencias quaisquer diferencas entre o financeiro e a contabilidade
			
			If MV_PAR01 == 2
				_nSaldoFinanceiro := _nSaldoFinanceiro * (-1)
			EndIf
			
			
			If _nSaldoContabil - (_nSaldoFinanceiro - If (MV_PAR01==1, _nValJurosFin, 0)) <> 0
			
				If MV_PAR01 == 1 // Conciliacao de Clientes

					RecLock("REL",.T.)
					REL->TIPO    := _cCodA
					REL->NOME    := GetAdvFVal("SA1", "A1_NREDUZ", xfilial("SA1")+_cIndiceContabil, 1, "")
					REL->CLIFOR  := _cIndiceContabil
					REL->OBS     := "Saldo contabil difere do saldo financeiro"
					REL->SALDOC  := _nSaldoContabil 
					REL->SALDOF  := _nSaldoFinanceiro
					REL->JUROSF  := _nValJurosFin
					REL->DIf     := (_nSaldoContabil - _nSaldoFinanceiro + _nValJurosFin)
					REL->(MsUnlock())
					
					// incrementa o codigo de divergencia do tipo A (diferenca de valores)
					_cCodA := soma1(_cCodA,6)
					
				ElseIf MV_PAR01 == 2 .And. _nSaldoFinanceiro <> 0// Conciliacao de Fornecedores
					
					RecLock("REL",.T.)
					REL->TIPO    := _cCodA
					REL->NOME    := GetAdvFVal("SA2", "A2_NREDUZ", xfilial("SA2")+_cIndiceContabil, 1, "")
					REL->CLIFOR  := _cIndiceContabil					
					REL->OBS     := "Saldo contabil difere do saldo financeiro"
					REL->SALDOC  := _nSaldoContabil
					REL->SALDOF  := _nSaldoFinanceiro
					REL->DIF     := (_nSaldoContabil - _nSaldoFinanceiro)
					REL->(MsUnlock())
					
					// incrementa o codigo de divergencia do tipo A (diferenca de valores)
					_cCodA := soma1(_cCodA,6)
														
				EndIf
				
			EndIf
			
		ElseIf MV_PAR01 == 1 .And. _nSaldoContabil <> 0 // Somente conciliacao de Clientes
			
			RecLock("REL",.T.)
			REL->TIPO    := _cCodB
			REL->CLIfOR  := _cIndiceContabil
			REL->NOME    := GetAdvFVal("SA1", "A1_NREDUZ", xfilial("SA1")+_cIndiceContabil, 1, "")
			REL->OBS     := "Cliente inexistente no Relatorio Financeiro"
			REL->SALDOC  := _nSaldoContabil
			REL->SALDOF  := 0
			REL->DIF  := (REL->SALDOC - REL->SALDOF)
			REL->(MsUnlock())
			
			// incrementa o codigo de divergencia do tipo B (inexistencia)
			_cCodB := soma1(_cCodB,6)
			
		EndIf
		
	EndIf
	RELC->(DbSkip())
EndDo


// Conciliando o relatorio financeiro.
DbSelectArea("RELF")
ProcRegua(RELF->(LastRec()))
RELF->(DbGoTop())
While !RELF->(eof())
	
	// Mensagem de acompanhamento de processo de acordo com o parametro
	If MV_PAR01 == 1 // Conciliacao de Clientes
		IncProc("Veificando inexistência de clientes ...")
		
	elseIf MV_PAR01 == 2 // Conciliacao de Fornecedores
		IncProc("Verificando inexistência de fornecedores ...")
	EndIf
	
	// VerIfica se he um registro valido.
	If (RELF->INDICE < "000000") .OR. (RELF->INDICE > "999999")
		RELF->(DbSkip())
		Loop
	EndIf
	
	// verIfica se o cliente/fornecedor constante no relatorio financeiro existe no relatorio contabil
	If MV_PAR01 == 1
		_lExiste := RELC->(DbSeek(right(RELF->INDICE,6)))
	elseIf MV_PAR01 == 2
		_lExiste := RELC->(DbSeek(right(alltrim(GetAdvFVal("SA2","A2_CONTA",xFilial("SA2")+RELF->INDICE+RELF->COMPIND,1,"")),6)))
		_nSaldoFinanceiro := val(StrTran(StrTran(RELF->SALDO,".",""),",","."))
	EndIf
	
	// Registra no relatorio de divergencias os dados do cliente/fornecedor inexistente no relatorio contabil
	If !_lExiste
		
		If MV_PAR01 == 1
			RecLock("REL",.T.)
			REL->TIPO   := _cCodC
			REL->CLIFOR := RELF->INDICE
			REL->NOME   := GetAdvFVal("SA1", "A1_NREDUZ", xFilial("SA1")+RELF->INDICE, 1, "")
			REL->OBS    := "Cliente inexistente no Relatorio Contabil"
			REL->SALDOC := 0
			REL->SALDOF := val(StrTran(StrTran(RELF->SALDO,".",""),",","."))
			REL->DIF    := (REL->SALDOC - REL->SALDOF)
			
		elseIf MV_PAR01 == 2 .AND. (_nSaldoFinanceiro <> 0)
			RecLock("REL",.T.)
			REL->TIPO := _cCodC
			REL->CLIFOR := RELF->INDICE
			REL->NOME := GetAdvFVal("SA2", "A2_NREDUZ", xFilial("SA2")+RELF->INDICE+RELF->COMPIND, 1, "")
			REL->OBS  := "Fornecedor inexistente no Relatorio Contabil"
			REL->SALDOC  := 0
			REL->SALDOF  := val(StrTran(StrTran(RELF->SALDO,".",""),",",".")) * (-1)
			REL->DIF  := (REL->SALDOC - REL->SALDOF)
		EndIf
		
		REL->(MsUnlock())
		
		// incrementa o codigo de divergencia
		_cCodC := soma1(_cCodC,6)
		
	EndIf
	
	RELF->(DbSkip())
EndDo

return



// Tela de impressao do relatorio de conciliacao.
Static Function fImprimir()

	If MsgYesNo("Deseja exportar o relatório para Excel?")
	
		fExport()
	
	Else
	
		// Envia controle para a funcao SETPRINT
		// Solicita os parametros para a emissao do relatorio			             
		_cNomeRel := SetPrint(_cAlias,_cNomeRel,cPerg,@_cTitulo,_cDesc1,_cDesc2,_cDesc3,_lTemDic,_aOrdem,_lPodeComp,_cTamanho,,_lTemFilt)
		If ( LastKey()=K_ESC ) .OR. ( nLastKey=K_ESC )
			return
		EndIf
		
		// Inicio da geracao do relatorio.
		SetDefault(aReturn,_cAlias)
		_nCrcControl := iIf(aReturn[4]==1,15,18)
		
		// Impressao do relatorio de divergencias
		RptStatus({|lEnd| fImpressao(@lEnd)})
		
		// Se a impress„o for em Disco, chama SPOOL e Libera relatorio para Spool da Rede                                                          
		If aReturn[5]==1
			Set Printer to
			Commit
			OurSpool(_cNomeRel)
		EndIf
		MS_Flush()	
	
	EndIf


return


// Imprime o resultado do processamento.                     
Static FUNCTION fImpressao(lEnd)
Local _cDetalhe    := ""
Local _nLin        := 80
Local _nTotalCon := 0
Local _nTotalFin := 0
Local _nTotalJur := 0
Local _nTotalDIf   := 0

If !REL->(eof())
	SetRegua( REL->(LastRec()) )
	REL->(DBGoTop())
	While !REL->(eof())
		
		IncRegua()
				
		// Testa o salto de pagina
		If _nLin >= 64
			_nLin := Cabec(_cTitulo,_cCabec1,_cCabec2,_cNomeRel,_cTamanho,_nCrcControl) + 1
		EndIf
		
		// VerIfica o cancelamento pelo usuario...                             
		If (LastKey() == K_ALT_A) .OR. If(lEnd==Nil,.F.,lEnd) .OR. lAbortPrint
			@_nLin,000 PSAY "*** CANCELADO PELO OPERADOR ***"
			break
		EndIf
		
	  // Detalhe de impressao.                                               
		_cDetalhe := ""
		
		_cDetalhe += padr(REL->CLIFOR , 006) + space(1)
		_cDetalhe += padr(REL->NOME   , 020) + space(3)
		_cDetalhe += padr(REL->OBS    , 045) + space(3)
				
		_cDetalhe += transform(REL->SALDOC,"@E 999,999,999.99") + space(3)
		_cDetalhe += transform(REL->SALDOF,"@E 999,999,999.99") + space(3)
			
		If MV_PAR01 == 1
			_cDetalhe += transform(REL->JUROSF,"@E 999,999,999.99") + space(3)
		EndIf

		_cDetalhe += transform(REL->DIF   ,"@E 999,999,999.99")
									
		@ _nLin,000 PSay _cDetalhe
		_nLin++
		
		// contabiliza Totais
		_nTotalCon += REL->SALDOC
		_nTotalFin += REL->SALDOF
		
		If MV_PAR01 == 1
			_nTotalJur += REL->JUROSF
		EndIf

		_nTotalDIf += REL->DIF
		
		REL->(DBSkip())
				
	EndDo
	
	// Testa o salto de pagina
	If _nLin >= 62
		_nLin := Cabec(_cTitulo,_cCabec1,_cCabec2,_cNomeRel,_cTamanho,_nCrcControl) + 1
	EndIf
	
	// impressao do total
	_nLin++
	
	_cDetalhe := PadR("TOTAIS ..............................", 74, ".") + space(4)
	
	_cDetalhe += transform(_nTotalCon, "@E 999,999,999.99") + space(3)
	_cDetalhe += transform(_nTotalFin, "@E 999,999,999.99") + space(3)
			
	If MV_PAR01 == 1
		_cDetalhe += transform(_nTotalJur, "@E 999,999,999.99") + space(3)
	EndIf	
	
	_cDetalhe += transform(_nTotalDIf,"@E 999,999,999.99")
	
	@ _nLin,000 PSay _cDetalhe
else
	SetRegua(1)
	IncRegua()
	@_nLin,000 PSAY "*** NAO FORAM ENCONTRADAS INCONCISTÊNCIAS ***"
EndIf

//Imprime rodape.
Roda(_nCbCont, _cCbtxt, _cTamanho)
return()


Static Function fExport()
	U_BIAMsgRun("Exportando dados para Planilha...", "Aguarde!", {|| fExportExcel() })
Return()


Static Function fExportExcel()
Local aArea := GetArea()
Local oFWExcel := Nil
Local oMsExcel := Nil
Local cDir := GetSrvProfString("Startpath", "")
Local cFile := "BIAFR001-" + __cUserID +"-"+ dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
Local cWorkSheet := ""
Local cTable := ""
Local cDirTmp := AllTrim(GetTempPath())
		
	cWorkSheet := If (MV_PAR01 == 1, "Clientes", "Fornecedores")
  cTable := _cTitulo +" - "+ "Data: " + dToC(dDataBase) +" - "+ Capital(FWFilialName(cEmpAnt, cFilAnt, 2))

  oFWExcel := FWMsExcel():New()		

	oFWExcel:AddWorkSheet(cWorkSheet)
	oFWExcel:AddTable(cWorkSheet, cTable)

	oFWExcel:AddColumn(cWorkSheet, cTable, "Código", 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, If (MV_PAR01 == 1, "Cliente", "Fornecedor"), 1, 1)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Ocorrência", 1, 1)		
	oFWExcel:AddColumn(cWorkSheet, cTable, "Saldo Contábil", 3, 2, .T.)
	oFWExcel:AddColumn(cWorkSheet, cTable, "Saldo Financeiro", 3, 2, .T.)

	If MV_PAR01 == 1
		oFWExcel:AddColumn(cWorkSheet, cTable, "Juros Financeiro", 3, 2, .T.)
	EndIf
	
	oFWExcel:AddColumn(cWorkSheet, cTable, "Diferença", 3, 2, .T.)
	
	
	DbSelectArea("REL")
	
	REL->(DBGoTop())
	
	While !REL->(Eof())
						
		If MV_PAR01 == 1
			aCampos := {REL->CLIFOR, REL->NOME, REL->OBS, REL->SALDOC, REL->SALDOF, REL->JUROSF, REL->DIF}
		Else
			aCampos := {REL->CLIFOR, REL->NOME, REL->OBS, REL->SALDOC, REL->SALDOF, REL->DIF}
		EndIf
		
		oFWExcel:AddRow(cWorkSheet, cTable, aCampos)

		REL->(DbSkip())
		
	EndDo
	
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
		MsgInfo("Arquivo não copiado para a pasta temporária do usuário.")
	Endif
	
	RestArea(aArea)
				  				
Return()


// Avalia se a empresa analisara saldo finaceiro por filial
Static Function fAvlSalEmp()
Local lRet := .F.

	If cEmpAnt $ "01/06" // 01 - Bianco, 06 - JK Serviços
		lRet := .T.
	EndIf
	
Return(lRet)


Static Functio fReadFile(cFile)
Local aValue := {}
Local cLine := ""	
		
	If FT_FUSE(AllTrim(cFile)) > 0
		
		FT_FGOTOP()
			
		While(!FT_FEOF())
			
			cLine := FT_FREADLN()
			
			aAdd(aValue, StrTokArr2(cLine, ";", .T.))
			
			FT_FSKIP()
			
		EndDo()
		
	EndIf

Return(aValue)