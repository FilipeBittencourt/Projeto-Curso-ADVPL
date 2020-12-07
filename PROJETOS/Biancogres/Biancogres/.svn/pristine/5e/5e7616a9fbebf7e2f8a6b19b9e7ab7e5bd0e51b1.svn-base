#include "rwmake.ch"

User Function BIA340()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA340
Empresa   := Biancogres Ceramica S.A.
Data      := 19/11/14
Uso       := PCP
Aplicação := Cadastro de novos produtos para BPC - SAP
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

dbSelectArea("SX2")
dbSeek("Z51")

cCadastro := Upper(Alltrim(SX2->X2_NOME))
aRotina   := { {"Pesquisar"     ,"AxPesqui"	  ,0,1},;
{               "Visualizar"    ,"AxVisual"	  ,0,2},;
{               "Incluir"       ,"AxInclui"	  ,0,3},;
{               "Alterar"       ,"AxAltera"	  ,0,4} }

dbSelectArea("Z51")
dbSetOrder(1)
dbGoTop()

Z51->(mBrowse(06,01,22,75,"Z51"))

dbSelectArea("Z51")

Return()

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Função   ¦ BIA340R  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 19/11/14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Ação     ¦ Valida digitação do código referencial para associação com ¦¦¦
¦¦¦          ¦  o código novo                                             ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA340R()

Local hrRet1 := .T.
Local hrAreaAt := GetArea()

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1") + M->Z51_CODREF)
	
	If SB1->B1_TIPO <> 'PP'
		
		hrRet1 := .F.
		MsgINFO("Somente está disponível para associação a Cadastro NOVO, produtos do tipo PP. Favor Verificar!!!")
		
	EndIf
	
EndIf

RestArea(hrAreaAt)

Return ( hrRet1 )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Função   ¦ BIA340V  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 19/11/14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Ação     ¦ Valida digitação do código atual para associação com o có- ¦¦¦
¦¦¦          ¦ digo novo                                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA340V()

Local hrRet1 := .T.
Local hrAreaAt := GetArea()

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1") + M->Z51_CODATU)
	
	If SB1->B1_TIPO <> 'PP'
		
		hrRet1 := .F.
		MsgINFO("Somente está disponível para associação a Cadastro NOVO, produtos do tipo PP. Favor Verificar!!!")
		
	Else
		
		dbSelectArea("Z51")
		dbSetOrder(2)
		If dbSeek(xFilial("Z51") + M->Z51_CODATU)
			hrRet1 := .F.
			MsgINFO("O Código ATUAL informado, já está associado a outro Código NOVO: " + Z51->Z51_CODNEW + ". Favor Verificar!!!")
		EndIf
		
	EndIf
	
EndIf

RestArea(hrAreaAt)

Return ( hrRet1 )

