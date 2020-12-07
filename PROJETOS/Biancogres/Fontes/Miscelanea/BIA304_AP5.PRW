#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia304()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("BREP,M->NVOLUME,M->NOLDVOL,")

//BIA304.PRW - CALCULA VOLUME DA META

// bRep := {|| cRepres == UZ8->UZ8_REP .AND. cMesAno == UZ8->UZ8_MESANO }

   DBSELECTAREA("UZ8")
   DBSETORDER(1)

   IF DBSEEK(XFILIAL("UZ8")+cRepres+cMesAno,.F.)

      M->nVolume := 0 

      DBEval( {|| M->nVolume := M->nVolume + UZ8->UZ8_VOLUME },,;
              {|| cRepres == UZ8->UZ8_REP .AND. cMesAno == UZ8->UZ8_MESANO},,, .F. )
   
//    WHILE !EOF() .AND. EVAL( bRep )
//
//       M->nVolume := (M->nVolume + UZ8->UZ8_VOLUME)
//       DBSKIP()
// 
//    ENDDO

   ENDIF

   M->nOldVol := M->nVolume

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> __RETURN( .T. )
Return( .T. )        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

