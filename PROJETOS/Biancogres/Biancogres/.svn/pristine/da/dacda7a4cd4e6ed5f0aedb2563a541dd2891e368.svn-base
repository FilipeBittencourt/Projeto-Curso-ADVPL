#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User Function VAL_SMINI()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Madaleno
Autor(Rev):= Marcos Alberto Soprani
Programa  := VAL_SMINI
Empresa   := Biancogres Ceramica S.A.
Data      := 16/06/09
Data(Rev) := 11/10/12
Uso       := PCP
Aplicação := VALIDACAO SALARIO MINIMIO QUE NÃO PODE SER MENOR QUE SAL FUNCION
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

// Busca salario minimo
CSQL 	:= " SELECT RX_TXT
CSQL	+= "   FROM " +RetSqlName("SRX")
CSQL	+= "  WHERE RX_TIP = '11'
CSQL	+= "    AND RX_COD = '"+Substr(dtos(dDataBase),1,6)+"'
CSQL	+= "    AND D_E_L_E_T_ = ' '
If ChkFile("_SALMIN")
	dbSelectArea("_SALMIN")
	dbCloseArea()
EndIf
TCQUERY CSQL ALIAS "_SALMIN" NEW

// Verifica se existe algum funcionário com salário abaixo do salário Minimo
CSQL 	:= " SELECT ISNULL(COUNT(*),0) AS QUANT
CSQL 	+= "   FROM " + RetSqlName("SRA")
CSQL 	+= "  WHERE RA_DEMISSA = '        '
CSQL 	+= "    AND RA_MAT NOT LIKE '200%'
// Retira Menor aprendiz da regra
CSQL 	+= "    AND RA_CODFUNC NOT IN('0212','0269','0304','79  ')
// Retira Estagiários
CSQL 	+= "    AND RA_CODFUNC NOT IN('25','0101','0105','0100','0102','0175','0103','0104','279 ')
CSQL 	+= "    AND RA_SALARIO < '"+Alltrim(_SALMIN->RX_TXT)+"'
CSQL 	+= "    AND D_E_L_E_T_ = ' '
If ChkFile("_FUNC")
	dbSelectArea("_FUNC")
	dbCloseArea()
EndIf
TCQUERY CSQL ALIAS "_FUNC" NEW

If _FUNC->QUANT > 0
	MsgBOX("Existe um fucnionário com o salário menor que o salário mínimo.", "Atenção!!!")
EndIf

Return
