#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 23/04/01

User Function BIA453()        // incluido pelo assistente de conversao do AP5 IDE em 23/04/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CNATUREZ,CCONTA")
Private cCodLP  := Paramixb

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � BIA453   � Autor � Microsiga             � Data � 10/03/09 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Execblock para buscar dados da natureza financeira na      낢�
굇�          � Reconciliacao Bancaria automatica.                         낢�
굇�          �                                                            낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Especifico: BIANCOGRES S/A                                 낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

cNaturez := SE5->E5_NATUREZ
//cNaturez := NEWSE5->E5_NATUREZ
//DbSelectArea("TRB")
//DbSelectArea("SE5")
//DbGoTo(TRB->RECSE5)

DbSelectArea("SED")
DbSeek(xFilial("SED")+SE5->E5_NATUREZ)

DO CASE
	CASE cCodLP $ '562001C_564001C' //Retorna conta contabil
		IF EMPTY(SED->ED_YCTADES)
			cConta := '31803003'
		ELSE
			cConta := SED->ED_YCTADES
		ENDIF
	CASE cCodLP $ '563001C_565001C' //Retorna conta contabil
		
		//|Pontin - chamado 6646 |
		If AllTrim(SE5->E5_NATUREZ) == "1213"
			
			If AllTrim(SE5->E5_BANCO) == "001" //BB
				cConta := "41404001"
			ElseIf AllTrim(SE5->E5_BANCO) == "021" //Banestes
				cConta := "41404002"
			ElseIf AllTrim(SE5->E5_BANCO) == "237" //Bradesco
				cConta := "41404008"
			ElseIf AllTrim(SE5->E5_BANCO) == "104" //Caixa
				cConta := "41404010"
			Else 
				cConta := SED->ED_YCTAREC
			EndIf
			
		Else
			cConta := SED->ED_YCTAREC
		EndIf
		
	CASE cCodLP $ '562001H_563001H_563002H_564001H_565001H_565002H' //Retorna historico contabil
		IF cCodLP $ '562001H_563001H_563002H'
			cConta := ALLTRIM(SE5->E5_HISTOR)
		ELSE
			cConta := 'CNC. ' + ALLTRIM(SE5->E5_HISTOR)
		ENDIF
		IF UPPER(ALLTRIM(FUNNAME())) == "FINA470"
			cConta := ALLTRIM(SED->ED_YHIST)
		ENDIF
ENDCASE

//---------------------------------------------------------------------------------------------------------------------------------      
/*
IF !IsInCallStack("CA100INCL")
	cNaturez := SE5->E5_NATUREZ
	chist    := SE5->E5_HISTOR
	VAR_IXB  := {CNATUREZ,chist}
ELSE
	CNATUREZ :=VAR_IXB[1]
	chist    :=var_ixb[2]
ENDIF

alert("Avaliando Historico")

DbSelectArea("SED")
DbSeek(xFilial("SED")+cNaturez)

DO CASE
	CASE cCodLP $ '562001C_564001C' //Retorna conta contabil
		IF EMPTY(SED->ED_YCTADES)
			cConta := '31803003'
		ELSE
			cConta := SED->ED_YCTADES
		ENDIF
	CASE cCodLP $ '563001C_565001C' //Retorna conta contabil
		cConta := SED->ED_YCTAREC
	CASE cCodLP $ '562001H_563001H_563002H_564001H_565001H_565002H' //Retorna historico contabil
		IF cCodLP $ '562001H_563001H_563002H'
			cConta := ALLTRIM(SE5->E5_HISTOR)
		ELSE
			cConta := 'CNC. ' + ALLTRIM(SE5->E5_HISTOR)
		ENDIF
		IF UPPER(ALLTRIM(FUNNAME())) == "FINA470"
			cConta := ALLTRIM(SED->ED_YHIST)
		ENDIF
ENDCASE
*/
Return(cConta)
