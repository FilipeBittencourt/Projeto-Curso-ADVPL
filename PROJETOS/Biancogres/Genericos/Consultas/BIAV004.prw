#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*

Consulta de usuários que tenham o mesmo menu

*/

User Function BIAV004()
	Local oFont1
	Local nx
	Public cDados := SPACE(100)
	oFont1     := TFont():New( "MS Sans Serif",0,-24,,.T.,0,,400,.F.,.F.,,,,,, )
	oFont2     := TFont():New( "MS Sans Serif",0,-12,,.T.,0,,400,.F.,.F.,,,,,, )
	oDlg1      := MSDialog():New(092,232,430,900,"Busca de usuários com o mesmo menu " ,,,.F.,,,,,,.T.,,,.T.)
	oSay1      := TSay():New( 020,055,{||"Informe o nome do menu " },oDlg1,,oFont2,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,245,016)
	oGet1      := tMultiget():new(038,020,{|u| If(PCount()>0,cDados:=u,cDados)},oDlg1,296,92,,,,,,.T.)
	oBtn1 := TButton():New( 140, 228, "Pesquisar",oDlg1,  {||RETMENU(ALLTRIM(cDados)),oDlg1:end()}, 088,020,,oFont2,.F.,.T.,.F.,,.F.,,,.F. )
	oBtn2 := TButton():New( 140, 150, "Lista Usuarios",oDlg1,  {||RETUSU(),oDlg1:end()}, 088,020,,oFont2,.F.,.T.,.F.,,.F.,,,.F. )
	oDlg1:Activate(,,,.T.)

Return

Static Function RETUSU()
	Local aAllusers := FWSFALLUSERS()
	Local nx
	conout("*************VERIFICACAO LISTAGEM DE USUARIOS - INICIO****************")

	For nx := 1 To Len(aAllusers)
		//Pesquisa pelo ID do usuario
		aReturn := FWUsrUltLog(aAllusers[nx][2])
		If LEN(aReturn) > 0
			conout("ID: "+aAllusers[nx][2] + " - Usuario: "+aAllusers[nx][3] + " - " + "Data ultimo logon: " + dtoc(aReturn[1]) + " hora: " + aReturn[2] )
		end if
	Next
	conout("*************VERIFICACAO LISTAGEM DE USUARIOS - FIM****************")
	MsgAlert("Favor analisar o console.log")
return

Static Function RETMENU(_Menu)
	Local nx
	Local y
	Local retorno := ""
	Local aRet := AllUsers()
	conout("*************VERIFICACAO DE MENUS - INICIO****************")
	ConOut("HORA: " + TIME())
	For nx := 1 To Len(aRet)
		for y := 1 To Len(aRet[nx][3])
			if at(UPPER(_Menu),UPPER(aRet[nx][3][y])) > 0
				retorno += aRet[nx][1][2]+"<br>"
				conout(aRet[nx][1][2])
				conout(aRet[nx][3][y])
			end if
		Next
	Next
	MSGINFO(retorno, "Usuários - "+_Menu )
	ConOut("HORA: " + TIME())
	conout("*************VERIFICACAO DE MENUS - FIM****************")
Return