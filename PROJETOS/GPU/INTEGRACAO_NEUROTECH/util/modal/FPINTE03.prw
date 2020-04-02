#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FPINTE03
Tela para exibir o resultado das validações das 5 regras
@author  Pontin
@since   19.12.18
@version 1.0
/*/
//-------------------------------------------------------------------

User Function FPINTE03(cMensagem,cTitulo,cTipo)

	Local oDlg
	Local oGet
	Local oBtn1
	Local oBtn2
	Local oBtn3
	Local lRet			:= .F.
	Private cTexto 		:= ""
	Private cFileRem	:= ""
	Private nHdl		:= 0

	Default cTipo		:= "1"
	Default cTitulo		:= FunName()

	cTexto += 'BLOQUEIO POR REGRAS DE NEGÓCIO:' +CRLF + CRLF
	cTexto += cMensagem

	DEFINE MSDIALOG oDlg Title cTitulo From 000,000	To 350,400 Pixel

		@ 005,005 Get oGet VAR cTexto MEMO SIZE 150,150 Of oDlg Pixel
		oGet:bRClicked := {||AllwaysTrue()}

		oBtn1      := TButton():New( 005,160,"Salvar Log",oDlg,{|| xImp()},040,012,,,,.T.,,"",,,,.F. )
		oBtn2      := TButton():New( 020,160,"Cancelar",oDlg,{|| oDlg:End()},040,012,,,,.T.,,"",,,,.F. )

		If cTipo == "1"
			oBtn3      := TButton():New( 035,160,"Avaliar Crédito",oDlg,{|| lRet := .T.,oDlg:End()},040,012,,,,.T.,,"",,,,.F. )
		EndIf

	ACTIVATE MSDIALOG oDlg CENTER

Return lRet


//-------------------------------------------------------------------------------------------------------
//Função para operação de salvar do log
Static Function xImp()

	cFileRem	:= cGetFile("Arquivos TXT|*.TXT",OemToAnsi("Salvar Arquivo..."),,'C:\',.F.)
	nHdl		:= fCreate(cFileRem+cValToChar(Year(ddatabase))+cValToChar(Month(ddatabase))+;
						cValToChar(Day(ddatabase))+'-'+Substr(Time(),1,2)+Substr(Time(),4,2)+'.txt')
	If nHdl == -1
		MsgAlert('Falha ao copiar arquivo para o servidor')
	Endif

	fWrite(nHdl,cTexto)
	fClose(nHdl)

Return