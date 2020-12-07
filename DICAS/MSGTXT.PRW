#Include 'protheus.ch'


User Function MSGTXT(cMensagem,cTitulo)

	Local oDlg
	Local oGet
	Local oBtn1	
	Local lRet			:= .F.
	Private cTexto 		:= ""
  
  Default cTitulo := "Resumo das notas"
  Default cMensagem := ""
  cMensagem := "Status" + CRLF+ CRLF
    cMensagem += "000 notas Aceitas" + CRLF
    cMensagem += "000 notas Rejeitadas" + CRLF+ CRLF
    cMensagem += CRLF+"------------------------------------" + CRLF + CRLF
    cMensagem += "Doc: 000000999/1" + CRLF
    cMensagem += "Data: 01/01/2020" + CRLF
    cMensagem += "Codigo: 999" + CRLF
    cMensagem += "Descricao: rejeicao x" + CRLF
    cMensagem += CRLF+"------------------------------------" + CRLF + CRLF
    cMensagem += "Doc: 000000777/1" + CRLF
    cMensagem += "Data: 01/01/2020" + CRLF
    cMensagem += "Codigo: 999" + CRLF
    cMensagem += "Descricao: rejeicao x" + CRLF
    cMensagem += CRLF+"------------------------------------" + CRLF + CRLF
    cMensagem += "Doc: 00000088/1" + CRLF
    cMensagem += "Data: 01/01/2020" + CRLF
    cMensagem += "Codigo: 999" + CRLF
    cMensagem += "Descricao: rejeicao x" + CRLF
    cMensagem += CRLF+"------------------------------------" + CRLF + CRLF

	//cTexto += 'BLOQUEIO POR REGRAS DE NEGÓCIO:' +CRLF + CRLF
	cTexto := cMensagem

	DEFINE MSDIALOG oDlg Title cTitulo From 000,000	To 350,400 Pixel

		@ 005,005 Get oGet VAR cTexto MEMO SIZE 193,150 Of oDlg Pixel READONLY
		oGet:bRClicked := {||AllwaysTrue()}
		
		//oBtn1     := TButton():New( 020,160,"Cancelar",oDlg,{|| oDlg:End()},040,012,,,,.T.,,"",,,,.F. )
	
	ACTIVATE MSDIALOG oDlg CENTER

Return lRet