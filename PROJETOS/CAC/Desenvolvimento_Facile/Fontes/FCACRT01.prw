#Include "Totvs.ch"

/*
##############################################################################################################
# PROGRAMA...: AT200BUT
# AUTOR......: Luiz Guilherme Barcellos (FACILE SISTEMAS)
# DATA.......: 19/05/2015
# DESCRICAO..: Rotina para alteração do número do contrato de manutenção
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:                      ]
##############################################################################################################
*/

User Function FCACRT01()

Local cContrAtu := AAH->AAH_CONTRT
Local cNroContr := Space(TamSx3("AAH_CONTRT")[1])


DEFINE MSDIALOG oDlg TITLE " ALTERAÇÃO DE NÚMERO " FROM 0,0 TO 150, 300 OF oMainWnd PIXEL Style DS_MODALFRAME

@ 010,020 SAY "Informe o novo número do contrato: " SIZE 200,10 PIXEL OF oDlg

@ 020,020 MSGET cNroContr SIZE 110, 10 PIXEL OF oDlg

@ 040,020 BUTTON "Confirma" SIZE 50,12 PIXEL OF oDlg ACTION (fConfirma(cContrAtu, cNroContr), oDlg:end())
@ 040,080 BUTTON "Cancela " SIZE 50,12 PIXEL OF oDlg ACTION (oDlg:end())

ACTIVATE MSDIALOG oDlg CENTER

Return


Static function fConfirma(cContrAtu, cNroContr)

If !fValid(cNroContr)
	MsgStop("Alteração inválida","FCACRT01")
ElseIf !MsgYesNo("Confirma alteração do número do contrato "+ALLTRIM(cContrAtu)+" para "+ALLTRIM(cNroContr)+" ?"+chr(13)+chr(10)+"A operação não poderá ser desfeita.","FCACRT01")
	MsgAlert("Alteração cancelada pelo usuário.","FCACRT01")
Else
	LjMsgRun("Aguarde... Alterando tabelas refenciadas...",, {|| fAltera(cContrAtu, cNroContr) })
Endif

Return



Static function fAltera(cContrAtu, cNroContr)

Local _aArea := GetArea()

cNroContr := PADR(LTRIM(cNroContr), TamSx3("AAH_CONTRT")[1]," ")

Begin Transaction

RecLock("AAH",.f.)
AAH->AAH_CONTRT := cNroContr
AAH->(MsUnlock())

M->AAH_CONTRT := cNroContr

DbSelectArea("AB6")
AB6->(DbSetOrder(1))
AB6->(dbgotop())
While !AB6->(Eof())
	If AB6->AB6_YCONTR == cContrAtu
		RecLock("AB6",.f.)
		AB6->AB6_YCONTR := cNroContr
		AB6->(MsUnlock())
	Endif
	AB6->(dbskip())
Enddo

DbSelectArea("AB9")
AB9->(DbSetOrder(1))
AB9->(dbgotop())
While !AB9->(Eof())
	If AB9->AB9_CONTRT == cContrAtu
		RecLock("AB9",.f.)
		AB9->AB9_CONTRT := cNroContr
		AB9->(MsUnlock())
	Endif
	AB9->(dbskip())
Enddo

DbSelectArea("AA3")
AA3->(DbSetOrder(1))
AA3->(dbgotop())
While !AA3->(Eof())
	If AA3->AA3_CONTRT == cContrAtu
		RecLock("AA3",.f.)
		AA3->AA3_CONTRT := cNroContr
		AA3->(MsUnlock())
	Endif
	AA3->(dbskip())
Enddo

END TRANSACTION

MsgAlert("Alteração realizada!!","FCACRT01") 

RestArea(_aArea)

Return


Static function fValid(cNroContr)

Local lRet := !empty(cNroContr) .AND. ExistChav("AAH",PADR(LTRIM(cNroContr), TamSx3("AAH_CONTRT")[1]," "))

Return lRet
