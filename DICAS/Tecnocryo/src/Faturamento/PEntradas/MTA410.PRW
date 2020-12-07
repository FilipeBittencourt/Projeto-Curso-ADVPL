/* Ponto de Entrada na confirmação do Pedido de Venda
   
   Se a TES for 570 a Natureza Financeira sera alterada para 11004  

   16/08/2020 Eduardo Escrivão
   */

#include "rwmake.ch"
#INCLUDE "topconn.ch"

User Function MTA410()

    Local _nPosTes
	Local _cTes
	Local _i
	Local _SalvaArea := GetArea()
	Local _SalvaSCB  := SCB->(GetArea())
	Local _SalvaSF4  := SF4->(GetArea())
	Local _SalvaSD6  := SD6->(GetArea())


	_nPosTes     := Ascan(AHeader,{|X| AllTrim(X[2])=="C6_TES"    })												
	
		for _i := 1 to len(aCols)
		
			_cTes     := aCols[ _i , _nPosTes   ]

// alert("estamos pe e a tes é " + cvaltochar( _cTes))

			if _CtES = "570"
				M->C5_NATUREZ := "11004"	
			endif

			exit 
		next 


		RestArea(_SalvaSD6)
		RestArea(_SalvaSF4)
		RestArea(_SalvaSCB)
		RestArea(_SalvaArea)
		Return .T.


Return
