#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User Function VAL_SMINI()

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
Autor     := Madaleno
Autor(Rev):= Marcos Alberto Soprani
Programa  := VAL_SMINI
Empresa   := Biancogres Ceramica S.A.
Data      := 16/06/09
Data(Rev) := 11/10/12
Uso       := PCP
Aplica玢o := VALIDACAO SALARIO MINIMIO QUE N肙 PODE SER MENOR QUE SAL FUNCION
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/

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

// Verifica se existe algum funcion醨io com sal醨io abaixo do sal醨io Minimo
CSQL 	:= " SELECT ISNULL(COUNT(*),0) AS QUANT
CSQL 	+= "   FROM " + RetSqlName("SRA")
CSQL 	+= "  WHERE RA_DEMISSA = '        '
CSQL 	+= "    AND RA_MAT NOT LIKE '200%'
// Retira Menor aprendiz da regra
CSQL 	+= "    AND RA_CODFUNC NOT IN('0212','0269','0304','79  ')
// Retira Estagi醨ios
CSQL 	+= "    AND RA_CODFUNC NOT IN('25','0101','0105','0100','0102','0175','0103','0104','279 ')
CSQL 	+= "    AND RA_SALARIO < '"+Alltrim(_SALMIN->RX_TXT)+"'
CSQL 	+= "    AND D_E_L_E_T_ = ' '
If ChkFile("_FUNC")
	dbSelectArea("_FUNC")
	dbCloseArea()
EndIf
TCQUERY CSQL ALIAS "_FUNC" NEW

If _FUNC->QUANT > 0
	MsgBOX("Existe um fucnion醨io com o sal醨io menor que o sal醨io m韓imo.", "Aten玢o!!!")
EndIf

Return
