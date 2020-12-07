#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function bia045()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrvt("WALIAS,WOK,WTES,WSENHA,WUSUARIO,GET_SENHA")
SetPrvt("ACOLS,")

Private cArq	:= ""
Private cInd	:= 0
Private cReg	:= 0

Private cArqSF4	:= ""
Private cIndSF4	:= 0
Private cRegSF4	:= 0

cArq := Alias()
cInd := IndexOrd()
cReg := Recno()

DbSelectArea("SF4")
cArqSF4 := Alias()
cIndSF4 := IndexOrd()
cRegSF4 := Recno()

wAlias    := Alias()
wOk       := .T.
wTes      := M->C6_TES
wSenha    := ALLTRIM( GETMV("MV_SENHA") )
wUsuario  := UPPER(ALLTRIM(cUserName))

IF wUsuario $ "ADMINISTRADOR,CAMERINO,KELMER"
	Return(wTes)
Endif

DbSelectArea("SF4")
DbSetOrder(1)
dbSeek(xFilial("SF4")+M->C6_TES,.F.)

While wOk
	If SF4->F4_DUPLIC == "N"
		@ 96,42 TO 323,505 DIALOG oEntra TITLE "Autorizacao p/Emissao NF s/Duplicata"
		@ 8,10 TO 84,222
		
		Get_Senha := SPACE(10)
		
		@ 23,14 SAY "Digite Senha autorizada : "
		@ 23,80 Get Get_Senha PICTURE "@!" PASSWORD Object oGet
		@ 55,20 BUTTON "_Submeter" SIZE 30,15 ACTION fSubmit()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       @ 55,20 BUTTON "_Submeter" SIZE 30,15 ACTION Execute(fSubmit)
		@ 55,60 BUTTON "_Abortar"  SIZE 30,15 ACTION fAborta()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       @ 55,60 BUTTON "_Abortar"  SIZE 30,15 ACTION Execute(fAborta)
		ACTIVATE DIALOG oEntra CENTERED
	Else
		wOk := .F.
	Endif
End
DbSelectArea(wAlias)

If cArqSF4 <> ""
	dbSelectArea(cArqSF4)
	dbSetOrder(cIndSF4)
	dbGoTo(cRegSF4)
	RetIndex("SF4")
EndIf

DbSelectArea(cArq)
DbSetOrder(cInd)
DbGoTo(cReg)

Return(wTes)

Static FUNCTION fSubmit()
If Alltrim(wSenha) == ALLTRIM(Get_Senha)
	wOk := .F.
	Close( oEntra )
Else
	Get_Senha := IIf(!Empty(Get_Senha),Space(10),Space(10))
	dlgRefresh(oEntra)
	ObjectMethod(oGet,"SetFocus(Get_Senha)")
	ObjectMethod(oGet,"Refresh()")
	
	Help(1,"","Y_BIA045")
Endif
Return

Static FUNCTION fAborta()
wTes   := SPACE(3)
wOk    := .F.
aCols [n] [9] := Space(3)
Close( oEntra )
Return
