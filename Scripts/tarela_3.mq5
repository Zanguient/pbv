//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
   MqlRates rates[];
   ArraySetAsSeries(rates, true); // o candle mais atual passa ser o índice zero do vetor

   //+----------------------
   //| Variavels
   //+----------------------

   string dataMaior;
   double maiorVolume;
   string dataMenor;
   double menorVolume = 10000000000000000;
   double volumeTotal;
   double menorPreco = 10000000000000000;
   double maiorPreco;
   int alta = 0;
   int baixa = 0;
   int lado = 0;
   string res;

   int candles = 100;

   int totalCopiado = CopyRates(_Symbol, 0, 0, candles, rates);

   if(totalCopiado > 0) {

      Print("Candles copiados: " + totalCopiado);

      int size = MathMin( totalCopiado, candles);

      for(int i = 0; i < size; i++) {

//         A

         if (maiorVolume < rates[i].tick_volume ) {
            maiorVolume = rates[i].tick_volume;
            dataMaior = TimeToString(rates[i].time);
         }

//         B

         if ( menorVolume > rates[i].tick_volume ) {
            menorVolume = rates[i].tick_volume;
            dataMenor = TimeToString(rates[i].time);
         }

//         C

         volumeTotal += rates[i].tick_volume;

//         D

         if ( maiorPreco < rates[i].high ) {
            maiorPreco = rates[i].high;
         }
         if ( menorPreco > rates[i].high ) {
            menorPreco = rates[i].high;
         }

//         E
         //Print ("Valor de I ", i);
         if ( i < (candles - 1) ) {

            if (  rates[i].high > rates[i + 1].high ) {
               alta += 1;
            } else if (rates[i].high < rates[i + 1].high) {
               baixa += 1;
            } else {
               lado += 1;
            }
         }

// Fim do for

      }

//      E

      if ( alta > baixa && alta > lado ) {
         res = "Alta";
      } else if ( alta < baixa && baixa > lado ) {
         res = "Baixa";
      } else {
         res = "Lateralizado";
      }

//    Saidas


      Print("Atividade 03");
      Print("<- A ->");
      Print("A data do candle com maior volume negociado " + dataMaior);
      Print("<- B ->");
      Print("A data com menor volume negociado " + dataMenor);
      Print("<- C ->");
      Print("Volume total acumulado negociado do período " + volumeTotal);
      Print("<- D ->");
      Print(" Menor (mínima) " + menorPreco + " - " + " maior (máxima) " +   maiorPreco);
      Print("<- E ->");
      Print("O mercado esta de " + res);



   } else Print("Falha ao receber dados históricos do ativo ", _Symbol );
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
