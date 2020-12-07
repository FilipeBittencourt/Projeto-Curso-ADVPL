#include "rwmake.ch"

User Function PagTitulo()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrvt("_RETTIT,cAlias")

/////  PROGRAMA PARA RETORNAR O NUMERO DO TITULO O PREFIXO, A PARCELA + SPACE 7
/////  PARA O SISTEMA DO PAGFOR POSICAO ( 151 - 165 )
cAlias := GetArea()

_RETTIT  :=  SE2->E2_PREFIXO + SUBSTR(SE2->E2_NUM,1,6) + IIF(!EMPTY(SE2->E2_PARCELA),SE2->E2_PARCELA,SPACE(1))

DbSelectArea("SX5")
If DbSeek(xFilial("SX5")+"17"+SE2->E2_TIPO,.T.)
   _RETTIT := _RETTIT + SUBS(SX5->X5_DESCRI,1,2)
Else
   _RETTIT := _RETTIT + SPACE(2)
   Alert("O Tipo " + SE2->E2_TIPO + " nao esta cadastrado na tabela 17.")
EndIf

_RETTIT  :=  _RETTIT + SE2->E2_FORNECE + SE2->E2_LOJA

DbSelectArea(cAlias)

Return(SUBS(_RETTIT,1,20))