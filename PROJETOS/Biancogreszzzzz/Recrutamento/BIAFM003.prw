/*---------+-----------+-------+----------------------+------+------------+
|Funcao    |WFRSP2     | Autor | Marcelo Sousa        | Data | 17.07.2018 |
|          |           |       | Facile Sistemas      |      |            |
+----------+-----------+-------+----------------------+------+------------+
|Descricao |WORKFLOW UTILIZADO PARA INFORMAR AO CANDIDATO A PARTICIPACAO  |
|          |EM UMA NOVA ETAPA DO PROCESSO SELETIVO.                       |
+----------+--------------------------------------------------------------+
|Uso       |RECRUTAMENTO E SELEÇÃO                                        |
+----------+-------------------------------------------------------------*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"

User Function BIAFM003(cOpc)
	
	IF cOpc == 3		
		ENVMAIL(3)
	ELSE	
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
		±± Definicao do Dialog e todos os seus componentes.                        ±±
		Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		oFont1     := TFont():New( "MS Sans Serif",0,-24,,.T.,0,,400,.F.,.F.,,,,,, )
		oFont2     := TFont():New( "MS Sans Serif",0,-12,,.T.,0,,400,.F.,.F.,,,,,, )
		oDlg1      := MSDialog():New(092,232,150,800,"ENVIO DE E-MAIL PARA CANDIDATOS",,,.F.,,,,,,.T.,,,.T.)
					
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
		±± Execucao das tarefas                                                    ±±
		Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		oBtn1 := TButton():New( 07, 190, "Todos",oDlg1,  {||ENVMAIL(1),oDlg1:end()}, 088,020,,oFont1,.F.,.T.,.F.,,.F.,,,.F. )
		oBtn2 := TButton():New( 07, 100, "Selecionado",oDlg1,{||ENVMAIL(2),oDlg1:end()},088,020,,oFont1,.F.,.T.,.F.,,.F.,,,.F.  )
		oBtn2 := TButton():New( 07, 010, "Cancelar",oDlg1,{||oDlg1:end()},088,020,,oFont1,.F.,.T.,.F.,,.F.,,,.F. )
		oDlg1:Activate(,,,.T.)
	ENDIF 



Return 


/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Função que monta e-mail para candidato                                  ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function ENVMAIL(cOpc)
    
    Local cCabec := ""
    Local cCodProc := ""
	Local cCodEt := ""
	Local cPer := ""
	Local cHora := ""
	Local cEmPara := ""
	Local cCand := ""
    Local cTab := Getnextalias()    
    
   	
	/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±± Definindo a query que trará os dados necessários.                       ±±
	±± para a montagem do e-mail. 											   ±±	
	Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	cQuery := ""
	cQuery += " SELECT QS_DESCRIC, "
	cQuery += " QD_DATA, "
	cQuery += " QD_HORA, "
	cQuery += " QG_EMAIL, "
	cQuery += " X5_DESCRI, "
	cQuery += " QG_NOME, "
	cQuery += " QG_SEXO, "
	cQuery += " QD_CURRIC, "
	cQuery += " QD_FILIAL "
	cQuery += " FROM " + RetSqlName("SQD") + " SQD " 
	cQuery += " JOIN " + RetSqlName("SQG") + " SQG ON QD_CURRIC = QG_CURRIC "
	cQuery += " JOIN " + RetSqlName("SQS") + " SQS ON QD_VAGA = QS_VAGA "
	cQuery += " JOIN " + RetSqlName("SX5") + " SX5 ON X5_CHAVE = QD_TPPROCE "
	cQuery += " WHERE SQD.D_E_L_E_T_ = '' "
	cQuery += " AND SQS.D_E_L_E_T_ = '' "
	cQuery += " AND SQG.D_E_L_E_T_ = '' "
	cQuery += " AND X5_TABELA = 'R9' "
	cQuery += " AND QS_VAGA = " + VALTOSQL(SQS->QS_VAGA)
	cQuery += " AND QD_CURRIC + QD_VAGA + QD_DATA IN (SELECT QD_CURRIC+QD_VAGA+MIN(QD_DATA) FROM " + RetSqlName("SQD") + " WHERE D_E_L_E_T_ = '' AND QD_SITPROC = 0 GROUP BY QD_CURRIC,QD_VAGA) "
	
	IF cOpc == 3
		cQuery += " AND QD_YENVIO <> 'S' "
	ELSEIF cOpc == 2
		cQuery += " AND QD_CURRIC = " + SCGN000016->TRX_CURRIC
	ENDIF
			
	TcQuery cQuery New Alias (cTab)
	
	While !(cTab)->(EOF())
		
		cCodProc := ALLTRIM((cTab)->QS_DESCRIC)
		cCodEt := ALLTRIM((cTab)->X5_DESCRI)
		cPer := CVALTOCHAR(STOD((cTab)->QD_DATA))
		cHora := (cTab)->QD_HORA
		cCand := (cTab)->QG_NOME
		cEmPara := (cTab)->QG_EMAIL
			
		cCabec := "PROCESSO SELETIVO PARA "+cCodProc+" - ANDAMENTO"
		  
		cMens := '<html>'+CRLF
		cMens += '<body>'+CRLF
		cMens += '<FONT SIZE=4 face="arial">Olá ' +cCand+ ',' +CRLF
		cMens += '</br>'+CRLF
		
		IF (cTab)->QG_SEXO == 'F'
			cMens += '<FONT SIZE=4 face="arial">Você está sendo convocada para a etapa abaixo:'+CRLF
		ELSE
			cMens += '<FONT SIZE=4 face="arial">Você está sendo convocado para a etapa abaixo:'+CRLF		
		ENDIF
		
		cMens += '</br>'+CRLF
		cMens += '<FONT SIZE=4 face="arial">Vaga: ' +cCodProc+ CRLF
		cMens += '<FONT SIZE=4 face="arial">Etapa: ' +cCodEt+ CRLF
		cMens += '<FONT SIZE=4 face="arial">Período: ' +cPer+ ' as ' + cHora +  'Hs' +CRLF
		cMens += '</br>'+CRLF
		cMens += '</br>'+CRLF
		cMens += '<br> <br><FONT SIZE=3>Atenciosamente,</FONT></br>'+CRLF
		cMens += '</br>'+CRLF
		cMens += '<FONT SIZE=3>Recrutamento Biancogres</FONT>'+CRLF
		cMens += '</body>'+CRLF
		cMens += '</html>'+CRLF
		
		U_BIAEnvMail(,cEmPara,cCabec,cMens)
		
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
		±± Acertando campo controle para não executar mais o Workflow.             ±±
		Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
		DBSELECTAREA("SQD")
		SQD->(DBSETORDER(1))
		SQD->(DBSEEK((cTab)->QD_FILIAL+(cTab)->QD_DATA+(cTab)->QD_CURRIC))
		
		IF SQD->QD_YENVIO <> "S"
			RECLOCK("SQD",.F.)
				SQD->QD_YENVIO := "S"
			SQD->(MSUNLOCK())
		ENDIF
		/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±*/
		
		(cTab)->(DBskip())
	
	ENDDO
	
	(cTab)->(DbCloseArea())
		
Return .T.	