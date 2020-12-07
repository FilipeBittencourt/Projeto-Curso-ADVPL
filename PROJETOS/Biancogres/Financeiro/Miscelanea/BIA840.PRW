#include "rwmake.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BIA840   º Autor ³ Ranisses A. Corona º Data ³  24/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Infor. Complem. - CNAB A Pagar Bradesco [374 a 413]        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BIA840()
Local nRet			:= ""

If SEA->EA_MODELO  $ "01_02_05"
	nRet := Space(40)

ElseIf SEA->EA_MODELO $ "03_08"
	nTpDOCTE	:= "C" 				//C=Titularidade Diferente
	nNuDOCTE	:= "000000"		//Esse campo devera ser informando zerado
	nCoDOCTE	:= "01"				//01=Credito em Conta Corrente
	nTpConta	:= "01"				//01=Conta Corrente Individual
	nBrancos	:= Space(29)
	nRet			:= nTpDOCTE+nNuDOCTE+	nTpConta+nTpConta+nBrancos

ElseIf SEA->EA_MODELO $ "31"
	If !Empty(Alltrim(SE2->E2_CODBAR))
		If Substr(SE2->E2_CODBAR,1,3) == "237"
				nAg				:= StrZero(Val(Substr(SE2->E2_CODBAR,20,4)),4)		
				nCart			:= Substr(SE2->E2_CODBAR,24,02)
				nNosNum		:= Substr(SE2->E2_CODBAR,26,11)
				nCC				:= StrZero(Val(Substr(SE2->E2_CODBAR,37,7)),7)		
				nBrancos	:= Space(13)
				nDgCdBar	:= Substr(SE2->E2_CODBAR,05,01)
				nCodMoe		:= Substr(SE2->E2_CODBAR,04,01)
				nRet			:= nAg+nCart+nNosNum+nCC+"0"+nDgCdBar+nCodMoe+nBrancos
		Else
				nCpLivre	:= Substr(SE2->E2_CODBAR,20,25)
				nDgCdBar	:= Substr(SE2->E2_CODBAR,05,01)
				nCodMoe		:= Substr(SE2->E2_CODBAR,04,01)
				nBrancos	:= Space(13)
				nRet			:= nCpLivre+nDgCdBar+nCodMoe+nBrancos
		EndIf

	Else
		If Substr(SE2->E2_YLINDIG,1,3) == "237"
				nAg				:= StrZero(Val(Substr(SE2->E2_YLINDIG,5,4)),4)									
				nCart			:= Substr(SE2->E2_YLINDIG,09,1)+Substr(SE2->E2_YLINDIG,11,1)	
				nNosNum		:= StrZero(Val(Substr(SE2->E2_YLINDIG,12,09)+Substr(SE2->E2_YLINDIG,22,2)),11)	
				nCC				:= StrZero(Val(Substr(SE2->E2_YLINDIG,24,7)),7)								
				nDgCdBar	:= Substr(SE2->E2_YLINDIG,33,01)
				nCodMoe		:= Substr(SE2->E2_YLINDIG,04,01)
				nBrancos	:= Space(13)
				nRet			:= nAg+nCart+nNosNum+nCC+"0"+nDgCdBar+nCodMoe+nBrancos
		Else
				nCpLivre	:= Substr(SE2->E2_YLINDIG,05,05)+Substr(SE2->E2_YLINDIG,11,10)+Substr(SE2->E2_YLINDIG,22,10)
				nDgCdBar	:= Substr(SE2->E2_YLINDIG,33,01)
				nCodMoe		:= Substr(SE2->E2_YLINDIG,04,01)
				nBrancos	:= Space(13)
				nRet			:= nCpLivre+nDgCdBar+nCodMoe+nBrancos
		EndIf
	EndIf
EndIf

Return(nRet)