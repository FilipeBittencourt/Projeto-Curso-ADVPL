#include "rwmake.ch"
#include "topconn.ch"

//Funcao para apagar arquivos *.dtc, *.idx, *.cdx, localizados no diretorio sigaadv e indice no ctreeint
User Function DelTrab(cTempFile)

If File(cTempFile+GETDBEXTENSION())
	Ferase(cTempFile+GETDBEXTENSION())
Endif

If File(cTempFile+".CDX")
	Ferase(cTempFile+".CDX")
Endif

If File(cTempFile+OrdBagExt())
	Ferase(cTempFile+OrdBagExt())
Endif

Return
