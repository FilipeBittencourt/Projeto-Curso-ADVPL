#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 24/05/02

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ BIA344   ³ Autor ³ Magnago               ³ Data ³ 10/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Requisita Senha para Liberacao do Fator de Desconto        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RDMAKE                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BIA344()        // incluido pelo assistente de conversao do AP5 IDE em 24/05/02

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local nC5FATFIN := M->C5_YMAXCND
Local nE4FATFIN := Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_YMAXDES")

SetPrvt("_NOMEUSER,_IDSUPER,_DADSUP,_DADUSER,_USUARAT,_NUSUARAT")
SetPrvt("WSENHAS,WSENHAU,LRET,WTIPO")
SetPrvt("WSENHA")

Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

_nomeuser := cUserName
_IdSuper  := ""
_dadsup   := {}
_daduser  := {}
_UsuarAt  := ""
_NUsuarAt := ""
wSenhaS   := ""
wSenhaU   := ""
lRet      := .T.
wTipo     := M->C5_TIPO

//Para pedidos da Mundi para LM, o Fator Financeiro será sempre 1
If cEmpAnt == "13" .And. M->C5_CLIENTE == "010064"
	nE4FATFIN := 1
EndIf

If xFilial("SC5") == "02"
   lRet := .F.
   MsgStop("Atencao, este Pedido NAO PODE SER INCLUIDO NA FILIAL.")
EndIf

If lRet
   If wTipo == "N"
      psworder(2)                          // Pesquisa por Nome
      If  pswseek(_nomeuser,.t.)           // Nome do usuario, Pesquisa usuarios
          _daduser  := pswret(1)           // Numero do registro
          _UsuarAt  := _daduser[1,1]
          _NUsuarAt := _daduser[1,2]
          _IdSuper  := _daduser[1,11]
          wSenhaU   := _daduser[1,3]
      EndIf
      psworder(1)                      // Pesquisa por ID
      If  pswseek(_IdSuper,.T.)        // id do superior
          _dadsup  := pswret(1)
          _UsuarAt := _dadsup[1,1]
          _NUsuarAt:= _dadsup[1,2]
          _IdSuper := _dadsup[1,11]
         wSenhaS   := _daduser[1,3]
      EndIf
      If  nC5FATFIN <> nE4FATFIN
          _nomeuser:=AllTrim(_NUsuarAt)
          wSenha   := Space(6)
          @ 115,085 To 267,727 Dialog oDlg Title "Libera‡„o do Fator de Desconto"
          @ 002,002 To 038,315
          @ 009,008 Say OemToAnsi('Para liberar o bloqueio para este pedido, digite a SENHA de desbloqueio')
          @ 020,008 Say OemToAnsi('Usuario Autorizado a Desbloquear: '+Alltrim(_nomeuser))
          @ 042,004 Say OemToAnsi("Senha   :")
          @ 042,042 Get wSenha  Valid .T.  PASSWORD
          @ 059,277 BmpButton Type 1 Action Close(oDlg)
          Activate Dialog oDlg
          PswOrder(2)
          If PswSeek(_nomeuser,.T.)
             If !PswName(wSenha)
                 MsgAlert("Senha Invalida. Favor Digitar Senha Correta para Alterar o Fator de Desconto")
                 nC5FATFIN  := nE4FATFIN
             EndIf
          Else
             MsgAlert("Erro, nao foi possivel determinar a senha do usuario")
             nC5FATFIN  := nE4FATFIN
          EndIf
      EndIf
   EndIf
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(nC5FATFIN)