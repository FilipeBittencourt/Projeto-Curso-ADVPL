#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"

User Function BIA791()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA791
Empresa   := Biancogres Ceramica S.A.
Data      := 27/05/14
Uso       := Gestão de Pessoal
Aplicação := Limpa tabela de contabilização da Folha - SRZ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

U_BIAMsgRun("Processando Limpeza de tabelas...",, {|| gBia791SRZ() })

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ gBia791SRZ  ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 27/05/14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function gBia791SRZ()

Local xLimpaTb := .T.

// Limpa o arquivo de operacoes alocadas
dbSelectArea("SRZ")
If MA280FLock("SRZ")
	Zap
	dbSelectArea("SRZ")
	dbCloseArea("SRZ")
Else
	Help("EXCL")
	xLimpaTb := .F.
Endif

If xLimpaTb
	Aviso('Limpeza de Tabela','A tabela de contabilização da FOLHA foi zerada com sucesso. Pode efetuar a contabilização novamente.',{'Ok'})
EndIf


Return
