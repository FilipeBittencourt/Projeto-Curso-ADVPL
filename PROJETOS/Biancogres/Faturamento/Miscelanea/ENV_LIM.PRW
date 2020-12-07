#include "rwMake.ch"
#include "Topconn.ch"
#include "ap5mail.ch"

/*/{Protheus.doc} ENV_LIM
@author BRUNO MADALENO
@since 22/09/05
@version 2.0
@description ROTINA PARA GERAR OS AQRQUIVO DO LIMITE DE CREDITO  
@type function
/*/

USER Function ENV_LIM()

PRIVATE sREPDE 	:= SPACE(6)
PRIVATE sREPATE := SPACE(6)
PRIVATE SS_ATRA := ""
PRIVATE SS_LIMI := ""

@ 200,1 TO 390,390 DIALOG oLeTxt TITLE OemToAnsi("WORKFLOW FINANCEIRO - REPRESENTANTE")
@ 01,03 TO 080,190
@ 10,010 Say "Este programa irá gerar e enviar para o e-mail dos Representantes "
@ 18,010 Say "os relatórios de Limite de Crédito e Títulos em Aberto com mais "
@ 26,010 Say "de 3 dias de atraso"
@ 50,20 	Say "REPRESENTANTES DE"
@ 50,100 	Say "REPRESENTANTES ATE"
@ 60,35 	Get sREPDE PICTURE "@!" Object oGet
@ 60,115 	Get sREPATE PICTURE "@!" Object oGet
@ 81,128 BMPBUTTON TYPE 01 ACTION OkProc()
@ 81,158 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)


Activate Dialog oLeTxt Centered

Return()

//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
//² FUNCAO PARA PROCESSAR A ROTINA                    ²
//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
Static Function OkProc()
Processa( {|| ENV_LIM2() } )
Close(oLeTxt)
Return


//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
//² FUNCAO PARA PROCESSAR A ROTINA                    ²
//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
Static function ENV_LIM2()
Private cEOL			:= "CHR(13)+CHR(10)"
Private Representante	:= ""
PRIVATE EMAIL 			:= ""
PRIVATE CSQL 			:= ""
Private nTotRep			:= 0
Private nARQUIVO 		:= ""
Private nLINHA_LOG 		:= ""
PRIVATE CSTATUS 		:= ""
Private cNewPath 		:= "C:\Temp\"
Private lDebug			:= .F.

Private cArqLim
Private fArqLim
Private cEOL    := "CHR(13)+CHR(10)"
Private Enter 	:= chr(13) + Chr(10)

Private nTblPED  := "##TMP_PEDIDDOPENDENTE"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)
Private nTblTIT  := "##TMP_TITULOABERTO"+cEmpAnt+__cUserID+strzero(seconds()*3500,10)
Private nNomeTMP := "##TMP_ENV_LIM"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //Alltrim(Str(randomize(1,34000)))

//Fecha tela atual
Close(oLeTxt)

If Empty(cEOL)
	cEOL := CHR(13)+CHR(10)
Else
	cEOL := Trim(cEOL)
	cEOL := &cEOL
Endif

//************************************ CRIANDO O ARQUIVO DE LOG DO ENVIO ************************************
If !lIsDir( cNewPath )
	MakeDir( cNewPath )
EndIf 

cArqTxt := "C:\Temp\LOG_REPRESENTANTES.TXT"
nARQUIVO    := fCreate(cArqTxt)

nLINHA_LOG := REPLICATE("*",125)
fWrite(nARQUIVO,nLINHA_LOG+cEOL)
nLINHA_LOG := "********************************** LOG DE ENVIO DOS REPRESENTANTES *******************************************"
fWrite(nARQUIVO,nLINHA_LOG+cEOL)
nLINHA_LOG := REPLICATE("*",125)
fWrite(nARQUIVO,nLINHA_LOG+cEOL)
fWrite(nARQUIVO,cEOL)
fWrite(nARQUIVO,cEOL)

cLin := REPLICATE("-",125)
fWrite(nARQUIVO,cLin+cEOL)

nLINHA_LOG := nLINHA_LOG := PADR("CODIGO",8) + PADR("NOME",35) + PADR("EMAIL",35) + "STATUS"
fWrite(nARQUIVO,nLINHA_LOG+cEOL)

cLin := REPLICATE("-",125)
fWrite(nARQUIVO,cLin+cEOL)
//************************************ FIM DA CRIACAO ************************************

//Selecionando os Representantes
CSQL := "SELECT A3_COD, A3_NOME, A3_NREDUZ, A3_EMAIL, A3_YEMP 		"  
CSQL += "FROM SA3010 												"
CSQL += "WHERE	A3_FILIAL	=   '"+xFilial("SA3")+"'	AND			" 	
CSQL += "		A3_COD BETWEEN '"+sREPDE+"' AND '"+sREPATE+"' AND	"
//CSQL += "		A3_YENVWF	=   'S' AND " //DEFINIR COM VAGNER
CSQL += "		A3_EMAIL	<>  ''	AND	"
CSQL += "		D_E_L_E_T_	=	'' 		"
CSQL += "ORDER BY A3_COD 				"
If chkfile("cREP")
	DbSelectArea("cREP")
	DbCloseArea()
EndIf
TCQUERY CSQL ALIAS "cREP" NEW

dbSelectArea("cREP")
cREP->(DbGotop())

//Quantidade de Registro de Query
nTotRep := Contar("cREP","!Eof()")

If nTotRep <= 0
	msgBox("Não foi encontrado nenhum Representante. Favor verificar os parametros informados.","Workflow Financeiro - Representantes","ALERT")
	Return()
EndIf

//Gerando Bases //ALTERAÇÃO MUDOU A PERFORMANCE DE QUERY PRINCIPAL DE 58s para 1s.
cSql := "SELECT * INTO "+nTblPED+" FROM VW_SALDOPEDIDO_NOVO "
U_BIAMsgRun("Aguarde... Gerando Base... Pedidos Pendentes... ",,{|| TcSQLExec(cSql)})

cSql := "SELECT * INTO "+nTblTIT+" FROM VW_SALDOTITULO"
U_BIAMsgRun("Aguarde... Gerando Base... Saldo por Cliente... ",,{|| TcSQLExec(cSql)})

cSql := "EXEC SP_ENV_LIM '"+nNomeTMP+"' "
U_BIAMsgRun("Aguarde... Gerando Base... Titulos em Aberto... ",,{|| TcSQLExec(cSql)})

ProcRegua(nTotRep)

dbSelectArea("cREP")
cREP->(DbGotop())

While !	cREP->(EOF())
	
	IncProc("Gerando informações para: " + cREP->A3_COD + "-"+Alltrim(cREP->A3_NREDUZ) + " ..." )
	
	Representante 	:= alltrim(cREP->A3_COD)
	EMAIL 			:= alltrim(cREP->A3_EMAIL)

	//Valida se o representante fez Rescisão em todas as Marcas ou esta bloqueado	
	aEmp 	:= {}
	aEmp 	:= U_fValResc(cREP->A3_COD)

	If ASCAN(aEmp, {|x| x[2] == "1" }) == 0
		cREP->(DBSKIP())
		Loop
	EndIf
			
	If lDebug	
		cArqLim := "C:\Temp\"+Representante+"_LIM.TXT"
	Else
		cArqLim := "\P10\relato\Rep\"+Representante+"_LIM.TXT"
	EndIf
	
	fArqLim    := fCreate(cArqLim)    
	
	SS_ATRA := ""
	SS_LIMI := ""
    
    //Monta Cabeçalho do Arquivo
	CABARQ_LIM()
	
	//(Thiago Dantas - 23/02/15) -> mudança do metodo para envio a fim de melhorar a performance.
	CSQL := SqlLimCli(cREP->A3_COD,StrTokArr(Alltrim(cREP->A3_YEMP), "/" )) 
	If chkfile("cREP2")
		DbSelectArea("cREP2")
		DbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS "cREP2" NEW
	dbSelectArea("cREP2")
	dbGotop()

	//Gera arquivo com o Limite de Credito dos Clientes
	U_BIAMsgRun("Gerando Relatório Limite Crédito... ",,{|| ARQ_LIM()})	   
    fClose(fArqLim)
		
	//Gera arquivo com Titulos em Atraso
	U_BIAMsgRun("Gerando Relatório de Títulos em Atraso... ",,{||ARQUIVO_TIT_ATRASADOS()})
	
	//Enviar os arquivos gerados por Email
	U_BIAMsgRun("Enviando e-mail...",,{||CRIA_EMAIL()})	
	
	nLINHA_LOG := PADR(Representante,8)
	nLINHA_LOG += PADR(ALLTRIM(cREP->A3_NOME),40) + "  "
	nLINHA_LOG += PADR(EMAIL,35)
	nLINHA_LOG += IIF(CSTATUS="OK","EMAIL ENVIADO COM SUCESSO","ERRO AO ENVIAR O EMAIL")
	fWrite(nARQUIVO,nLINHA_LOG+cEOL)
	
	cREP->(DBSKIP())
		
End Do

fClose(nARQUIVO)

WinExec("NOTEPAD " + cArqTxt)

If chkfile("cREP")
	DbSelectArea("cREP")
	DbCloseArea()
EndIf

If chkfile("cREP2")
	DbSelectArea("cREP2")
	DbCloseArea()
EndIf

RETURN()
//-----------------------------------------------------------------------
Static Function CABARQ_LIM()

	nTamLin := 110
	cLin    := Space(nTamLin)+cEOL
	
	cLin := REPLICATE("-",150)
	fWrite(fArqLim,cLin+cEOL)
	
	cLin := PADR("CODIGO",8) + PADR("NOME",42) +PADR("   GRUPO",10) + PADL("LIMITE CREDITO",15)+PADL("VENC. LIMITE",15)+PADL("TIT. ABERTOS",15)+PADL("PED. CARTEIRA",15)+ PADL("SALDO",15)+ PADL("% UTILIZACAO",15) //+ PADL("LIMITE TOMADO",15)
	fWrite(fArqLim,cLin+cEOL)
	
	cLin := PADR(cREP->A3_NOME + "aa",30)
	fWrite(fArqLim,cLin+cEOL)
	
	cLin := REPLICATE("-",150)
	fWrite(fArqLim,cLin+cEOL)
	
	_GRUPO := ""
	fWrite(fArqLim,cEOL)
Return
//-----------------------------------------------------------------------
Static Function ARQ_LIM()

While !cREP2->(EOF())	
	
	SS_LIMI := "S"
	
	cNomeCli := AllTrim(cREP2->A1_COD) + ' - ' + Alltrim(cREP2->A1_NOME) 
	
	cLin := PADR(cNomeCli,50)
	cLin += PADL(cREP2->A1_GRPVEN,10)
	cLin += PADR(Transform(cREP2->A1_LC,   "@E 999,999,999.99"),15)
	cLin += PADR('    ' + DtoC(StoD(cREP2->A1_VENCLC)),15)
	cLin += PADR(Transform(cREP2->TITULO,"@E 999,999,999.99"),15)
	cLin += PADR(Transform(cREP2->PEDIDO,"@E 999,999,999.99"),15)
	cLin += PADR(Transform(cREP2->SALDO,"@E 999,999,999.99"),15)
	cLin += PADR(Transform(cREP2->PERC,"@E 999,999.99")+" %" ,15)
	
	fWrite(fArqLim,cLin+cEOL)

	cREP2->(DBSKIP())

End Do

Return

//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
//² GERA RELATORIO DE TITULOS EM ATRASO               ²
//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
STATIC FUNCTION ARQUIVO_TIT_ATRASADOS()
Local cSql		:= ""
Local CCLIENTE	:= ""
Local CNOMEEMP	:= ""
Local NTOTAL 	:= 0
Local J 		:= 1
Local lPassou 	:= .F.

Private cArqTxt
Private nHdl
Private cEOL    := "CHR(13)+CHR(10)"

Enter := chr(13) + Chr(10)

If Empty(cEOL)
	cEOL := CHR(13)+CHR(10)
Else
	cEOL := Trim(cEOL)
	cEOL := &cEOL
Endif

cRepreDe  := Representante

If lDebug	
	cArqTxt := "C:\Temp\"+cRepreDe+"_ATR.TXT"
Else
	cArqTxt := "\P10\relato\Rep\"+cRepreDe+"_ATR.TXT"
EndIf

//Monta arquivo de trabalho
cSql := "SELECT EMP, A3_COD, A3_NOME, A3_FAX, A3_TEL, A3_TELEX, DATEDIFF(day, E1_VENCTO, GETDATE()) AS DIAS, A1_COD, A1_NOME, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VENCTO, E1_HIST, E1_SALDO " 
cSql += "FROM "+nNomeTMP+" SE1 	INNER JOIN SA1010 SA1 ON	" 
cSql += "		SE1.E1_CLIENTE	= SA1.A1_COD AND			" 
cSql += "		SE1.E1_LOJA 	= SA1.A1_LOJA 				" 
cSql += "						INNER JOIN SA3010 SA3 ON	"
cSql += "		SE1.E1_VEND1	= SA3.A3_COD 				"
cSql += "WHERE	SA1.A1_FILIAL	= '"+xFilial("SA1")+"' 
cSql += "		AND SA3.A3_COD	= '"+cRepreDe+"'
cSql += "		AND SA1.D_E_L_E_T_ = '' "
cSql += "		AND SA3.D_E_L_E_T_ = '' "
cSql += "ORDER BY EMP, A3_COD, A1_COD, DIAS DESC "
If chkfile("ctrabalho")
	dbSelectArea("ctrabalho")
	dbCloseArea()
EndIf
TcQuery cSql New Alias "ctrabalho"

IF !ctrabalho->(EOF())
	nHdl    := fCreate(cArqTxt)
	SS_ATRA := "S"
END IF

While !EOF()
	IF J = 65
		fWrite(nHdl,cEOL)
		fWrite(nHdl,cEOL)
	END IF
	IF J = 66
		fWrite(nHdl,cEOL)
	END IF
	J := 1
	nTamLin := 118
	
	//************* IMPRIMINDO O CABECALHO   *****************
	cLin := REPLICATE("-",118)
	fWrite(nHdl,cLin+cEOL)
	
	cLin := "REPRESENTANTE     CLIENTE    PRF/TITULO/PARC/TIPO    VALOR TITULO    VENCIMENTO  ATRASO EM DIAS   OBS   CHEQUE ATRASO "
	fWrite(nHdl,cLin+cEOL)
	
	cLin := REPLICATE("-",118)
	fWrite(nHdl,cLin+cEOL)
	
	fWrite(nHdl,cEOL)
	fWrite(nHdl,cEOL)
	
	cLin := PADR(ctrabalho->A3_COD,8) + PADR(ctrabalho->A3_NOME,50)
	fWrite(nHdl,cLin+cEOL)
	
	cLin := "TEL:  " + PADR(ctrabalho->A3_TEL,15)
	fWrite(nHdl,cLin+cEOL)
	
	cLin := "FAX:  " + PADR(ctrabalho->A3_FAX,15)
	fWrite(nHdl,cLin+cEOL)
	
	cLin := "CEL:  " + PADR(ctrabalho->A3_TELEX,15)
	fWrite(nHdl,cLin+cEOL)
	
	fWrite(nHdl,cEOL)
	
	
	cLin := REPLICATE("-",118)
	fWrite(nHdl,cLin+cEOL)
	If ctrabalho->EMP == "01"
		CNOMEEMP	:= "BIANCOGRES CERAMICA S/A"
	ElseIf ctrabalho->EMP == "05"
		CNOMEEMP	:= "INCESA REVESTIMENTO CERAMICO LTDA"
	Else
		CNOMEEMP	:= "LM  COMERCIO LTDA"
	EndIf
	//CNOMEEMP := IIF(ALLTRIM(ctrabalho->E1_PREFIXO)="","INCESA REVESTIMENTO",IIF(ALLTRIM(ctrabalho->E1_PREFIXO)="S1","BIANCOGRES","INCESA"))
	cLin := "*********************************************** "+PADR(CNOMEEMP,20)+" *************************************************"
	fWrite(nHdl,cLin+cEOL)
	cLin := REPLICATE("-",118)
	fWrite(nHdl,cLin+cEOL)
	fWrite(nHdl,cEOL)
	
	//********** FIM IMPRIMINDO O CABECALHO   *****************
	//fClose(nHdl)
	CCLIENTE := ctrabalho->A1_COD
	//CEMPRESA := ctrabalho->E1_PREFIXO
	CEMPRESA := ctrabalho->EMP
	Do while !eof() //.and. J<=65
		CCLIENTE := ctrabalho->A1_COD
		
		//IF CEMPRESA <> ctrabalho->E1_PREFIXO
		IF CEMPRESA <> ctrabalho->EMP
			cLin := REPLICATE("-",118)
			fWrite(nHdl,cLin+cEOL)
			If ctrabalho->EMP == "01"
				CNOMEEMP	:= "BIANCOGRES CERAMICA S/A"
			ElseIf ctrabalho->EMP == "05"
				CNOMEEMP	:= "INCESA REVESTIMENTO CERAMICO LTDA"
			Else
				CNOMEEMP	:= "LM COMERCIO LTDA"
			EndIf
			//CNOMEEMP := IIF(ALLTRIM(ctrabalho->E1_PREFIXO)="   ","INCESA REVESTIMENTO",IIF(ALLTRIM(ctrabalho->E1_PREFIXO)="S1","BIANCOGRES","INCESA"))
			cLin := "*********************************************** "+PADR(CNOMEEMP,20)+" *************************************************"
			fWrite(nHdl,cLin+cEOL)
			cLin := REPLICATE("-",118)
			fWrite(nHdl,cLin+cEOL)
			//CEMPRESA := ctrabalho->E1_PREFIXO
			CEMPRESA := ctrabalho->EMP
			fWrite(nHdl,cEOL)
		END IF
		
		cLin := REPLICATE(" ",21) + PADR(ctrabalho->A1_COD,8) + PADR(ctrabalho->A1_NOME,50)
		fWrite(nHdl,cLin+cEOL)
		J ++
		//fWrite(nHdl,cEOL)
		//J ++
		NTOTAL := 0
		DO WHILE !eof() .and. CCLIENTE = ctrabalho->A1_COD //.and. J<=65
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o cancelamento pelo usuario...                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			J ++
			NTOTAL += ctrabalho->E1_SALDO
			cLin := REPLICATE(" ",30)
			cLin += PADR(ctrabalho->E1_PREFIXO,3)
			cLin += PADR(ctrabalho->E1_NUM,9)
			cLin += PADR(ctrabalho->E1_PARCELA,4)
			cLin += PADR(ctrabalho->E1_TIPO,5)
			cLin += PADR(Transform(ctrabalho->E1_SALDO,    "@E 999,999,999.99"),15)
			cLin += PADR(STOD(ctrabalho->E1_VENCTO),10)
			cLin += PADR(ctrabalho->DIAS,5)
			cLin += PADR(ctrabalho->E1_HIST,30)
			fWrite(nHdl,cLin+cEOL)
			DbSkip()
		ENDDO
		cLin := REPLICATE(" ",30) + "TOTAL EM ATRASO     " + PADR(Transform(NTOTAL,    "@E 999,999,999.99"),15)
		fWrite(nHdl,cLin+cEOL)
		J ++
		//if J<=65
		cLin := REPLICATE(" ",21) +REPLICATE("-",70)
		fWrite(nHdl,cLin+cEOL)
		J ++
		//end if
		//if J<=65
		fWrite(nHdl,cEOL)
		J ++
		//end if
	ENDDO
ENDDO
fClose(nHdl)
DbSelectArea("ctrabalho")
DbCloseArea()
RETURN()


//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
//² ROTINA PARA ENVIAR EMAIL PARA REPRESENTANTES      ²
//²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
STATIC Function CRIA_EMAIL()

cData     := DTOC(DDATABASE)
cTitulo   := "Relatorio de Limite de Credito e Titulos Vencidos"

cMensagem := "		Email enviado automaticamente pelo PROTHEUS (microsiga). " + CHR(13)+CHR(10)
cMensagem += "Segue em anexo os relatorios de limite de credito e dos titulos em aberto com mais de 3 dias em atraso." + CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += "	As informações geradas são referentes as empresas Biancogres e Incesa. " + CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += "ATENÇÃO A OBSERVAÇÃO:  " + CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += "  SEGUE ABAIXO AS CONFIGURAÇÕES PARA A IMPRESSÃO DOS RELATORIOS NO BLOCO DE NOTAS" + CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += "  ESTA CONFIGURAÇÃO TERÁ QUE SER FEITA SOMENTE UMA VEZ." + CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += "A Fonte do relatorio tem que ser a ' Courier New ' e o tamanho '' 8 '' " + CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += "As margens devem estar configuradas da seguinte maneira." + CHR(13)+CHR(10)
cMensagem += "	Esquerda:  4         Direita:  4" + CHR(13)+CHR(10)
cMensagem += "	Superior: 12        Inferior: 12" + CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)
cMensagem += CHR(13)+CHR(10)

ENV_EMAIL(cData,cTitulo,cMensagem)

RETURN
//---------------------------------------------------------------------------------------------------
Static Function SqlLimCli(cRep,aEmp)
Local cSqlLim := ""
Local lPassou := .F.

cSqlLim += " SELECT *, A1_LC - (PEDIDO+TITULO) AS  SALDO  , CASE WHEN A1_LC <> 0 THEN (PEDIDO+TITULO)/ A1_LC * 100 ELSE 0 END PERC
cSqlLim += " FROM (
cSqlLim += " SELECT A1_GRPVEN, ACY.ACY_DESCRI, A1_COD, A1_NOME, ISNULL(SG.LC, SA1.A1_LC ) AS A1_LC, ISNULL(SG.VENCLC, SA1.A1_VENCLC ) AS A1_VENCLC,  
cSqlLim += " 		SUM(ISNULL(ISNULL(SG.PEDIDO,SP.SALDO),0)) AS PEDIDO, 
cSqlLim += " 		SUM(ISNULL(ISNULL(SG.TITULO,ST.SALDO),0)) AS TITULO
cSqlLim += " FROM "+RetSqlName("SA1")+" SA1 WITH (NOLOCK)  
cSqlLim += " 		LEFT JOIN "+nTblPED+" SP WITH(NOLOCK) ON A1_COD= SP.C5_CLIENTE	AND A1_LOJA	= SP.C5_LOJACLI
cSqlLim += " 		LEFT JOIN "+nTblTIT+" ST WITH(NOLOCK) ON A1_COD= ST.E1_CLIENTE	AND A1_LOJA	= ST.E1_LOJA
cSqlLim += " 		LEFT JOIN ACY010 ACY WITH(NOLOCK) ON ACY.ACY_FILIAL='"+xFilial("ACY")+"' AND SA1.A1_GRPVEN = ACY.ACY_GRPVEN AND ACY.D_E_L_E_T_ = ''
cSqlLim += " 		LEFT JOIN 
cSqlLim += " (SELECT A1_GRPVEN AS GRPVEN,MAX(A1_VENCLC) AS VENCLC, MAX(A1_LC) AS LC, SUM(ISNULL(SP1.SALDO,0)) AS PEDIDO, SUM(ISNULL(ST1.SALDO,0)) AS TITULO
cSqlLim += " FROM "+RetSqlName("SA1")+" SA12 WITH(NOLOCK)
cSqlLim += " LEFT JOIN "+nTblPED+" SP1 WITH(NOLOCK) ON A1_COD= SP1.C5_CLIENTE	AND A1_LOJA	= SP1.C5_LOJACLI
cSqlLim += " LEFT JOIN "+nTblTIT+" ST1 WITH(NOLOCK) ON A1_COD= ST1.E1_CLIENTE	AND A1_LOJA	= ST1.E1_LOJA
cSqlLim += " WHERE SA12.A1_FILIAL	= ''
cSqlLim += " AND SA12.A1_GRPVEN <> ''
cSqlLim += " AND SA12.D_E_L_E_T_	= ''
cSqlLim += " GROUP BY A1_GRPVEN
cSqlLim += " ) SG
cSqlLim += " ON SG.GRPVEN = SA1.A1_GRPVEN
cSqlLim += " WHERE SA1.A1_FILIAL= '"+xFilial("SA1")+" '
// RECUPERA A CLAUSULA WHERE
cSqlLim += WHRCLAUSE(aEmp,cRep)

cSqlLim += " AND SA1.D_E_L_E_T_	= ''
cSqlLim += " GROUP BY A1_GRPVEN, ACY.ACY_DESCRI, A1_COD, A1_NOME, SG.LC, SA1.A1_LC, SG.VENCLC, SA1.A1_VENCLC
cSqlLim += " )L
cSqlLim += " ORDER BY PERC DESC, A1_NOME

Return cSqlLim

//---------------------------------------------------------------------------------------------------
// (RODRIGO RIBEIRO/JUSSARA NOBREGA - 04/06/19) ***  ESTRUTURA A CLAUSULA WHERE DE ACORDO COM A EMPRESA ATENDIDA PELO VENDEDOR. ***
//---------------------------------------------------------------------------------------------------
STATIC Function WHRCLAUSE (aEmp, cRep)
	Local cWhrClause := ""
	Local iIndex := 1
	Local bPassou := .F.
		
	For iIndex:= 1 to LEN(aEmp)
		If ( aEmp[iIndex] == "0101" ) // BIANCOGRES
			cWhrClause +=  IIF(bPassou, " OR "," ") + "SA1.A1_VEND = '"+cRep+"' OR SA1.A1_YVENDB2 = '"+cRep+"' OR SA1.A1_YVENDB3 = '"+cRep+"'
			bPassou := .T.
		EndIf
		If ( aEmp[iIndex] == "0501" ) // INCESA
			cWhrClause += IIF(bPassou, " OR "," ") + "SA1.A1_YVENDI = '"+cRep+"' OR SA1.A1_YVENDI2 = '"+cRep+"' OR SA1.A1_YVENDI3 = '"+cRep+"'
			bPassou := .T.
		EndIf
		If ( aEmp[iIndex] == "0599" ) // BELLACASA
			cWhrClause += IIF(bPassou, " OR "," ") + "SA1.A1_YVENBE1 = '"+cRep+"' OR SA1.A1_YVENBE2 = '"+cRep+"' OR SA1.A1_YVENBE3 = '"+cRep+"'
			bPassou := .T.
		EndIf
		If ( aEmp[iIndex] == "1399" ) // MUNDIALLI
			cWhrClause += IIF(bPassou, " OR "," ") + "SA1.A1_YVENML1 = '"+cRep+"' OR SA1.A1_YVENML2 = '"+cRep+"' OR SA1.A1_YVENML3 = '"+cRep+"'
			bPassou := .T.
		EndIf
		If ( aEmp[iIndex] == "1401" ) // VITCER
			cWhrClause += IIF(bPassou, " OR "," ") + "SA1.A1_YVENVT1 = '"+cRep+"' OR SA1.A1_YVENVT2 = '"+cRep+"' OR SA1.A1_YVENVT3 = '"+cRep+"'
			bPassou := .T.
		EndIf
		If ( aEmp[iIndex] == "0199" ) // PEGASUS
			cWhrClause += IIF(bPassou, " OR "," ") + "SA1.A1_YVENPEG = '"+cRep+"'
			bPassou := .T.
		EndIf
		If ( aEmp[iIndex] == "1302" ) // VINILICO
			cWhrClause += IIF(bPassou, " OR "," ") + "SA1.A1_YVENVI1 = '"+cRep+"'
			bPassou := .T.
		EndIf
	Next		
	If (!bPassou)
		cWhrClause += " SA1.A1_VEND = 'XXXXXX' "
	EndIf  

Return " AND ( " + cWhrClause + " ) "

//---------------------------------------------------------------------------------------------------
// (Thiago Dantas - 02/06/14) ***  Novo método de envio de email pegando parametros do servidor. ***
//---------------------------------------------------------------------------------------------------
STATIC Function ENV_EMAIL(cData,cTitulo,cMensagem)
	
	lResult 	:= .F.
   	cRecebe 	:= EMAIL
	cAssunto	:= "Relatorio de limite de credito e titulos em aberto"
	
	cAnexos := ""
	IF SS_LIMI = "S"
		cAnexos		:= cArqLim //"\P10\relato\Rep\"+Representante+"_LIM.txt"
	END IF
	IF SS_ATRA = "S"
		IF cAnexos = ""
			cAnexos		:= "\P10\relato\Rep\"+Representante+"_ATR.txt"
		ELSE
			cAnexos		+= ",\P10\relato\Rep\"+Representante+"_ATR.txt"
		END IF
	END IF

	If !lDebug
		U_BIAEnvMail(,cRecebe,cAssunto,cMensagem,'',cAnexos)
	Else	
		U_BIAEnvMail(,'jussara.nobrega@biancogres.com.br',cAssunto,cMensagem,'',cAnexos)
	EndIf
	
Return //lResult

//---------------------------------------------------------------------------------------------------
// Valida Rescisao do Representante para envio das informações
//---------------------------------------------------------------------------------------------------
User Function fValResc(cRepr)
Local cSql		:= ""
Local aEmp		:= {}
Local aEmpRet	:= {}

//Posiciona no cadastro de Marcas
Z37->(DbSetOrder(1))
Z37->(DbGoTop())

//Verifica todas as Marcas para o Representante
While !Z37->(Eof())

	cSql := ""
	cSql += " SELECT COUNT(*) QUANT "
	cSql += " FROM "+RetSqlName("SA3")+ " " 
	cSql += " WHERE A3_FILIAL	= '"+xFilial("SA3")+"' AND "
	cSql += "		A3_COD 		= '"+cRepr+"' AND " 
	cSql += "		A3_YEMP 	LIKE '%"+Alltrim(Z37->Z37_MARCA)+"%' 	AND " 
	cSql += "		D_E_L_E_T_ 	= '' "
	If chkfile("_SA3")
		DbSelectArea("_SA3")
		DbCloseArea()
	EndIf
	TcQuery cSql Alias "_SA3" New

	cSql := ""
	cSql += " SELECT COUNT(*) QUANT
	cSql += " FROM 
	cSql += " (
	If Z37->Z37_MARCA == "0101"
		cSql += " SELECT Z78_VEND FROM Z78010 where Z78_VEND = '"+cRepr+"' AND D_E_L_E_T_ = ''
		cSql += " UNION ALL	
	EndIf
	If Z37->Z37_MARCA $ "0501/0599/1399"	
		cSql += " SELECT Z78_VEND FROM Z78050 where Z78_VEND = '"+cRepr+"' AND D_E_L_E_T_ =''
		cSql += " UNION ALL
	EndIf
	If Z37->Z37_MARCA == "1401"
		cSql += " SELECT Z78_VEND FROM Z78140 where Z78_VEND = '"+cRepr+"' AND D_E_L_E_T_ = ''
		cSql += " UNION ALL	
	EndIf
	cSql += " SELECT Z78_VEND FROM Z78070 where Z78_VEND = '"+cRepr+"' AND Z78_MARCA = '"+Alltrim(Z37->Z37_MARCA)+"' AND D_E_L_E_T_ =''
	cSql += "  ) TMP
	If chkfile("_Z78")
		DbSelectArea("_Z78")
		DbCloseArea()
	EndIf
	TcQuery cSql Alias "_Z78" New

	aEmp := {}

	If _SA3->QUANT > 0 .And. _Z78->QUANT == 0
		aadd(aEmp,Z37->Z37_MARCA,1)
		aadd(aEmp,"1")
	Else
		aadd(aEmp,Z37->Z37_MARCA,0)	
		aadd(aEmp,"0")
	EndIf
	
	aadd(aEmpRet,aEmp)
	
	_SA3->(DbCloseArea())
	_Z78->(DbCloseArea())

	Z37->(DbSkip())
EndDo                   
Z37->(DbCloseArea())

Return(aEmpRet)