#include 'protheus.ch'
#include 'parmtype.ch'

//U_TSTArray FOR
User Function TSTArray()

	Local aFruta  := {} //Array dimensional
	Local aNome   := {} //Array dimensional
	Local nI := 0

	// add dados
	aFruta := {"Banana","Pera",100.37,"100.37",".T.",.T.}

	AADD(aNome,"Filipe")
	AADD(aNome,"João")
	AADD(aNome,"Leonardo")
	AADD(aNome,"Gielardi")

	//saber o tamanho do array  use a função Len()
//	alert("O array de aFruta possui um tamanho de: "+cValToChar(Len(aFruta))+" posições." )
//	alert("O array de aNome  possui um tamanho de: "+cValToChar(Len(aNome))+" posições." )

	"USANDO o FOR O array NOMEARRAY possui um tamanho de: XXXX posições
	na posição 1 tem : XXXX
	na posição 2 tem : XXXX
	......
	alert()


Return .T.


/*

	/////////// especiais

	AADD(aAluno,"Filipe")
	AADD(aAluno,"Rua um dois 3 ,Casa 04,2987874-690 , Laranjeiras")
	AADD(aAluno,{"PORTUGUES","MATEMATICA","HISTORIA"})

	AADD(aEscola, aAluno)

	aAluno := {}
	AADD(aAluno,"leonardo")
	AADD(aAluno,"Rua um dois 3 ,Casa 05,2987874-690 , Laranjeiras")
	AADD(aAluno,{"PORTUGUES","MATEMATICA","HISTORIA"})

	AADD(aEscola, aAluno)

	aAluno := {}

	*/