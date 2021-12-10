#include "protheus.ch"
//U_Checkbox
User Function Checkbox()
    Local _stru:={}
    Local aCpoBro := {}
    Local oDlgLocal := Nil
    Local aCores := {}

    Private lInverte := .F.
    Private cMark   := nil
    Private oMark := nil
    Private oJSobj := nil
    //Cria um arquivo de Apoio

    If Select("SX6") <= 0
        RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
    EndIf
    cMark   := GetMark()

    AADD(_stru,{"OK"     ,"C"	,2		,0		})
    AADD(_stru,{"COD"    ,"C"	,6		,0		})
    AADD(_stru,{"LOJA"   ,"C"	,2		,0		})
    AADD(_stru,{"NOME"   ,"C"	,40		,0		})
    AADD(_stru,{"MCOMPRA","N"	,17		,2		})
    AADD(_stru,{"END"    ,"C"	,40		,0		})
    AADD(_stru,{"STATUS" ,"C"	,2		,0		})
    cArq := Criatrab(_stru,.T.)
    DBUSEAREA(.t.,,carq,"TTRB")


    //Alimenta o arquivo de apoio com os registros do cadastro de clientes (SA1)
    DbSelectArea("SA1")
    DbGotop()

    While  SA1->(!Eof())
        DbSelectArea("TTRB")
        RecLock("TTRB",.T.)
        TTRB->COD     :=  SA1->A1_COD
        TTRB->LOJA    :=  SA1->A1_LOJA
        TTRB->NOME    :=  SA1->A1_NOME
        TTRB->MCOMPRA :=  SA1->A1_MCOMPRA
        TTRB->END	  :=  SA1->A1_END
        TTRB->STATUS  := "0"    //Verde
        MsunLock()
        SA1->(DbSkip())
    Enddo

    //Define as cores dos itens de legenda.
    aCores := {}
    aAdd(aCores,{"TTRB->STATUS == '0'","BR_VERDE"	})
    aAdd(aCores,{"TTRB->STATUS == '1'","BR_AMARELO"	})
    aAdd(aCores,{"TTRB->STATUS == '2'","BR_VERMELHO"})


    //Define quais colunas (campos da TTRB) serao exibidas na MsSelect
    aCpoBro	:= {{ "OK"			,, "Mark"           ,"@!"},;
        { "COD"			,, "Codigo"         ,"@!"},;
        { "LOJA"		,, "Loja"           ,"@1!"},;
        { "NOME"		,, "Nome"           ,"@X"},;
        { "MCOMPRA"		,, "Maior Compra"   ,"@E 999,999,999.99"},;
        { "End"			,, "Endereco"       ,"@!"}}

    //Cria uma Dialog
    DEFINE MSDIALOG oDlg TITLE "MarkBrowse c/Refresh" From 9,0 To 315,800 PIXEL

    DbSelectArea("TTRB")
    DbGotop()

    //Cria a MsSelect
    oMark := MsSelect():New("TTRB","OK","",aCpoBro,@lInverte,@cMark,{17,1,150,400},,,,,aCores)
    oMark:bMark := {| | Disp()}

    //Exibe a Dialog
    // ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()})
    @ 005,020 BUTTON "Confirma" SIZE 50,12 PIXEL OF oDlg ACTION (EXIBE(), oDlg:end())
    @ 000,080 BUTTON "Cancela " SIZE 50,12 PIXEL OF oDlg ACTION (oDlg:end())

    ACTIVATE MSDIALOG oDlg CENTER

    //Fecha a Area e elimina os arquivos de apoio criados em disco.
    TTRB->(DbCloseArea())
    // Iif(File(cArq + GetDBExtension()),FErase(cArq  + GetDBExtension()) ,Nil)

Return

//Funcao executada ao Marcar/Desmarcar um registro.   
Static Function Disp()
    RecLock("TTRB",.F.)
    If Marked("OK")
        TTRB->OK := cMark
    Else
        TTRB->OK := ""
    Endif
    MSUNLOCK()
    oMark:oBrowse:Refresh()
Return()

Static Function EXIBE()

    LOCAL cmsg := ""

Return()