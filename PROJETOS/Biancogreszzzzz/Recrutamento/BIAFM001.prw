/*---------+-----------+-------+----------------------+------+------------+
|Funcao    |BIAFM001   | Autor | Marcelo Sousa        | Data | 31.07.2018 |
|          |           |       | Facile Sistemas      |      |            |
+----------+-----------+-------+----------------------+------+------------+
|Descricao |WORKFLOW UTILIZADO VIA BOTAO NO CADASTRO DE CURRмCULO         |
|          |DENTRO DO RECRUTAMENTO PARA ENVIO DE MENSAGENS AO CANDIDATO.  |
+----------+--------------------------------------------------------------+
|Uso       |RECRUTAMENTO E SELEгцO                                        |
+----------+-------------------------------------------------------------*/

#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

User Function BIAFM001()

	/*дддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
	╠╠ DeclaraГЦo de Variaveis Private dos Objetos                             ╠╠
	ы╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддд*/
	Local cCand  := SQG->QG_NOME 
	Local lAlt := .F.
	Public cDados := SPACE(100)
	Public cEmail := SQG->QG_EMAIL
	cUsrtst := __cUserID
	aUsrtst2 := UsrRetGrp(cUsrtst)
	SetPrvt("oDlg1","oSay1","oGet1","oBtn1","oBtn2","oFont1")
	
	/*дддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
	╠╠ Trata a permissЦo de usuАrio para o envio                               ╠╠
	ы╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддд*/	
	DBSELECTAREA("ZR3")
	ZR3->(dbsetorder(1))
	ZR3->(DBSEEK(xFilial("ZR3")+cUsrtst))
	
	IF ZR3->ZR3_USUARI == cUsrtst .AND. ZR3->ZR3_RECRUT == "1"
		lAlt := .T.
	ENDIF
	
	/*дддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
	╠╠ EM CASO DE ALTERAгцO, O SISTEMA EXIBE A OPгцO DE ENVIO                  ╠╠
	ы╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддд*/
	IF ALTERA 
	
		IF lAlt
	
			/*дддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
			╠╠ Definicao do Dialog e todos os seus componentes.                        ╠╠
			ы╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддд*/
			oFont1     := TFont():New( "MS Sans Serif",0,-24,,.T.,0,,400,.F.,.F.,,,,,, )
			oFont2     := TFont():New( "MS Sans Serif",0,-12,,.T.,0,,400,.F.,.F.,,,,,, )
			oDlg1      := MSDialog():New(092,232,430,900,"ENVIO DE E-MAIL PARA " + cCand,,,.F.,,,,,,.T.,,,.T.)
			oSay1      := TSay():New( 020,055,{||"Informe o texto a ser enviado para " + cEmail},oDlg1,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,245,016)
			oGet1      := tMultiget():new(038,020,{|u| If(PCount()>0,cDados:=u,cDados)},oDlg1,296,92,,,,,,.T.)
			
			/*дддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
			╠╠ Execucao das tarefas                                                    ╠╠
			ы╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддд*/
			oBtn1 := TButton():New( 140, 228, "Enviar",oDlg1,  {||ENVMAIL(),oDlg1:end()}, 088,020,,oFont1,.F.,.T.,.F.,,.F.,,,.F. )
			oBtn2 := TButton():New( 140, 020, "Cancelar",oDlg1,{||oDlg1:end()},088,020,,oFont1,,.T.,,"",,,,.F. )
			
			oDlg1:Activate(,,,.T.)
		
		ELSE 
			
			Alert("VocЙ nЦo tem permissЦo para enviar e-mails")
			Return
		
		ENDIF 	
	
	ELSE	
		
		Alert("Envio de E-mail sС И possivel na alteraГЦo do currМculo")
		Return
	
	ENDIF	

Return

/*дддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠ Montagem e envio do e-mail para o portador do currМculo.                ╠╠
ы╠╠юддддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддд*/
Static Function ENVMAIL()

	cDados += '</br>'+CRLF
	cDados += '</br>'+CRLF
	cDados += '<br> <br><FONT SIZE=3>Atenciosamente,</FONT></br>'+CRLF
	cDados += '</br>'+CRLF
	cDados += '<FONT SIZE=3>Recrutamento Biancogres</FONT>'+CRLF
	cDados += '</body>'+CRLF
	cDados += '</html>'+CRLF
	
	U_BIAEnvMail(,cEmail,"Recrutamento Biancogres",cDados)

Return 