#Include "FINC030.CH"
#Include "PROTHEUS.CH"
#Include "MSGRAPHI.CH"
#INCLUDE "PROTHEUS.CH"

User Function MA020ROT()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
Autor     :=
Autor(Rev):= Marcos Alberto Soprani
Empresa   := Biancogres Ceramica S.A.
Data      :=
Data(Rev) := 11/09/14
Uso       := SigaCOM
Aplica玢o := Consulta Personalizada de fornecedor
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北*/

Local _aRotina := {}

AAdd( _aRotina, { "Abrir Cotacoes", "U_WEBCOTAC", 0, 6 } )
AAdd( _aRotina, { "Cons. Fornecedor", "U_x1ConsultFor", 0, 6 } )

Return _aRotina

/*___________________________________________________________________________
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
Ζ+-----------------------------------------------------------------------+Ζ
Ζun玎o    � WEBCOTAC   � Autor �                     � Data �          Ζ�
Ζ+-----------------------------------------------------------------------+Ζ
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
�*/
USER FUNCTION WEBCOTAC()

LOCAL cSHA1    := SA2->A2_YSHA1
LOCAL cComando := ""
IF EMPTY(cSHA1)
	reclock("SA2",.F.)
	SA2->A2_YSHA1 := SHA1(SA2->(A2_COD+A2_LOJA))
	msunlock()
	cSHA1 := SA2->A2_YSHA1
ENDIF

cComando := "http://srv_web_protheus:8787/?q="+cSHA1+"&b="+cEmpAnt

ShellExecute("open",cComando,"","",4)

RETURN

/*___________________________________________________________________________
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
Ζ+-----------------------------------------------------------------------+Ζ
Ζun玎o    � x1ConsultFor  � Autor � Marcos Alberto S.� Data � 11/09/14 Ζ�
Ζ+-----------------------------------------------------------------------+Ζ
ΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖΖ�
�*/
User Function x1ConsultFor()

Private lFc030Con
Private lF030TitAb
Private lF030TitPg
Private lF030TitCom
Private lF030TitFat
Private nVlGeralNf

Fc030Con()

Return
